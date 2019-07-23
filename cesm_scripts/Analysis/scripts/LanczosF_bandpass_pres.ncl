load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
hfile = getenv("NCL_ARG_hfile")
Experiments = new(nexps,"string")

lowbound = getenv("NCL_low_bpf")
highbound = getenv("NCL_high_bpf")

dirstring = getenv("NCL_dirstr")
outdirstring = getenv("NCL_outdirstr")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

version=getenv("NCL_CESMversion")
if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

varin = getenv("NCL_var")
inlev = getenv("NCL_inlev")


nyears = endyr-startyr+1

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
    Dir = (Direc + Experiment + "/" + dirstring + "/")
	OutDir = (Direc + Experiment + "/" + dirstring + "/")

	print(Experiment)
    iyear = startyr
    startyrstr = sprinti("%0.4i",startyr)
    endyrstr = sprinti("%0.4i",endyr)


    filename = "U_V_pldaily_" + Experiment + "." + camversion + "." + startyrstr + "-" + endyrstr + ".nc"

	filein = (Dir + "/" + filename)

	cdf_file = addfile(filein,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
    time  = cdf_file->time

    if varin .eq. "V" then
        varall = cdf_file->V
    end if

    levs = cdf_file->lev_p
    nlevs = dimsizes(levs)
    do ilev=0,nlevs-1
        if levs(ilev) .eq. inlev then
            var=varall(:,ilev,:,:)
        end if
    end do

    if (time(1) - time(0)) .ne. 1 then
        print("may not be daily data")
        exit()
    end if

	ndim  = dimsizes(var)

; ***********************************************
; create the filter weights and apply
; ***********************************************
	ihp     = 2                             ; band pass
	sigma   = 1.0                           ; Lanczos sigma

	nWgt    = 31                            ; 31 days (must be odd)

	dt = 1.0                                ; days per timestep
  
	fca     = dt/tofloat(highbound)                        ; low freq, 6 days = 1/24 timesteps
	fcb     = dt/tofloat(lowbound)                        ; high freq = 2 days = 1/8 timesteps

    wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

	varbpf = var

	do ilat = 0,ndim(1)-1
		do ilon = 0,ndim(2)-1
            varbpf(:,ilat,ilon) = wgt_runave(var(:,ilat,ilon), wgt, 0)      ;
        end do
	end do

	varbpf!0 = var!0
	varbpf!1 = var!1
	varbpf!2 = var!2

	delete(var)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	print("writing file")
	filo = varin + tostring(inlev) + "mb_bpf" + tostring(lowbound) + "-" + tostring(highbound) + "_" + filename
	system("/bin/rm -f " + OutDir + filo)
	setfileoption("nc","format","netcdf4")	; allow us to write variables >2GB
    print(OutDir + filo)
	fout = addfile(OutDir + filo, "c")

	setfileoption(fout,"DefineMode",True)

    ; set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
    fAtt@history = "created by LanczosF_bandpass_pres.ncl" 
	fileattdef(fout,fAtt)
	
	if varin .EQ. "V"	
		fout ->V = varbpf
	else
		print("defaulting for wrong variable")
        fout ->varbpf = varbpf
	end if

	delete(varbpf)
	delete(lat)
	delete(lon)
	delete(time)
end do

end
