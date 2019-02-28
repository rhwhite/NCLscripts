load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
hfile = getenv("NCL_ARG_hfile")
Experiments = new(nexps,"string")

dirstring = getenv("NCL_dirstr")
outdirstring = getenv("NCL_outdirstr")


do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

version=getenv("NCL_CESMversion")
if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

varin = getenv("NCL_ARG_var")
print(varin)
print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
    Dir = (Direc + Experiment + "/" + dirstring + "/")
	OutDir = (Direc + Experiment + "/" + outdirstring + "/")

	print(Experiment)
    iyear = startyr

    yearstring = sprinti("%0.4i",iyear)

	filename = (Dir + Experiment + "." + camversion + "." + hfile + "." + yearstring +"-01-01-" + secs + ".nc")

	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	if varin .EQ. "Z850"
		var = cdf_file->Z850
	else if varin .EQ. "TS"
		var = cdf_file->TS
	else if varin .EQ. "PRECT"
		if Experiment .EQ. "CESMtopof19"
			var = cdf_file->PRECC + cdf_file->PRECL
		else    
			var = cdf_file->PRECT
		end if
	end if
	end if
	end if

	time  = cdf_file->time
	date = cdf_file->date 
 
	ntim  = dimsizes(var)
	;print(ntim)   

	do iyear = startyr+1,endyr
        yearstring = sprinti("%0.4i",iyear)

		filename = (Dir + Experiment + "." + camversion + "." + hfile + "." + yearstring +"-01-01-" + secs + ".nc")

		cdf_file = addfile(filename,"r")

		if varin .EQ. "Z850"
			var_temp = cdf_file->Z850
		else if varin .EQ. "TS"
			var_temp = cdf_file->TS
		else if varin .EQ. "PRECT"
			if Experiment .EQ. "CESMtopof19"
				var_temp = cdf_file->PRECC + cdf_file->PRECL
			else
				var_temp = cdf_file->PRECT
			end if
		end if
		end if
		end if

		date_temp  = cdf_file->date
 	 	time_temp = cdf_file->time

		var_temp2 = array_append_record(var,var_temp,0)
		time_temp2 = array_append_record(time,time_temp,0)
		date_temp2 = array_append_record(date,date_temp,0)
		delete(var)
		delete(time)
		delete(date)
		var = var_temp2
		time = time_temp2
		date = date_temp2
		delete(var_temp2)
		delete(time_temp2)
		delete(date_temp2)
	
	end do

	ntim  = dimsizes(var)
;print(ntim)   


; ***********************************************
; create the filter weights and apply
; ***********************************************
	ihp     = 2                             ; band pass
	sigma   = 1.0                           ; Lanczos sigma

	nWgt    = 1461                           ; 1461 lose half a year at each end = 2*740+1 = 1461  

	dt = 0.25                                ; days per timestep
  
	fca     = dt/6.                        ; low freq, 6 days = 1/24 timesteps
	fcb     = dt/2.                        ; high freq = 2 days = 1/8 timesteps

	wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

	varbpf_temp = var
	varbpf_temp(:,:,:) = 0.0

	varbpf_temp = var

	do ilat = 0,ntim(1)-1
		do ilon = 0,ntim(2)-1
			varbpf_temp(:,ilat,ilon) = wgt_runave (var(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	ndims = dimsizes(varbpf_temp)
	ntimes = ndims(0)

	varbpf_temp!0 = var!0
	varbpf_temp!1 = var!1
	varbpf_temp!2 = var!2
	delete(var)


	ntimes2 = nyears*4*365;

	ntimes2 = ntimes - (731*2)

	varbpf = new((/ntimes2,ndims(1),ndims(2)/),typeof(varbpf_temp))
	timebpf = new((/ntimes2/),typeof(time))
	datebpf = new((/ntimes2/),typeof(date))

	count = 0

	do nt = 731,ntimes-732
		varbpf(count,:,:) = varbpf_temp(nt,:,:)
		timebpf(count) = time(nt)
        datebpf(count) = date(nt)
		count = count + 1
	end do

	varbpf!0 = varbpf_temp!0
	varbpf!1 = varbpf_temp!1
	varbpf!2 = varbpf_temp!2

	delete(varbpf_temp)
	ndims2 = dimsizes(varbpf(0:count-1,:,:))



;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	print("writing file")
	filo = varin + "bpf_Annual_" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + "." + camversion + ".nc"
	system("/bin/rm -f " + OutDir + filo)
	setfileoption("nc","format","netcdf4")	; allow us to write variables >2GB
	fout = addfile(OutDir + filo, "c")

	setfileoption(fout,"DefineMode",True)

; set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout,fAtt)
	
;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
	filevardef(fout,"time",typeof(timebpf),getvardims(timebpf))
    filevardef(fout,"date",typeof(datebpf),getvardims(datebpf))
	filevardef(fout,"lat",typeof(lat),getvardims(lat))
	filevardef(fout,"lon",typeof(lon),getvardims(lon))
	
	filevardef(fout,varin + "bpf",typeof(varbpf),getvardims(varbpf))
	
    fout ->date    = (/datebpf/)
	fout ->time    = (/timebpf/)
	fout ->lat    = (/lat/)
	fout ->lon    = (/lon/)
	
	if varin .EQ. "TS"	
		fout ->TSbpf = (/varbpf/)
	else if (varin .EQ. "Z850")
        fout ->Z850bpf = (/varbpf/)
	else if varin .EQ. "PRECT"
		fout ->PRECTbpf = (/varbpf/)
	else
		print("defaulting for some reason")
        fout ->varbpf = (/varbpf/)
	end if
	end if
	end if	

	delete(varbpf)
	delete(timebpf)
	delete(lat)
	delete(lon)
	delete(var_temp)
	delete(time_temp)
	delete(time)
end do

end
