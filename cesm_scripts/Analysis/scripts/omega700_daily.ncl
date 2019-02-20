load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("get daily Omega on 700mb")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
hfile = getenv("NCL_ARG_hfile")
Experiments = new(nexps,"string")

dirstring = getenv("NCL_dirstr")
outdirstring = getenv("NCL_outdirstr")


do ne = 0,nexps-1
    Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)
h2startday = getenv("NCL_h2start")

version=getenv("NCL_CESMversion")
if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

nsecs = getenv("NCL_nsecs")

h2mon = "01"
hfile = "h1"

do exps = 0,nexps-1

	Experiment = Experiments(exps)
    filo = "OMEGA700_daily_" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.nc"

    Dir = (Direc + Experiment + "/" + dirstring + "/raw/")
	OutDir = (Direc + Experiment + "/" + dirstring + "/")
    print(OutDir + filo)
	print(Experiment)

	iyear = startyr
    yearstring = sprinti("%0.4i",iyear)

	filename = (Dir + Experiment + "." + camversion + "." + hfile + "." + yearstring +"-01-01-" + nsecs + ".nc")
    filePHIS = (Dir + Experiment + "." + camversion + ".h0." + yearstring + "-" + h2mon + ".nc")

	cdf_file = addfile(filename,"r")
    cdf_file_PHIS = addfile(filePHIS,"r")

    date  = cdf_file->date
    time = cdf_file->time
    lat = cdf_file->lat
    lon = cdf_file->lon

    hyam  = cdf_file->hyam
    hybm  = cdf_file->hybm
    hyai  = cdf_file->hyai
    hybi  = cdf_file->hybi
    p0    = cdf_file->P0
    psfc  = cdf_file->PS
    u     = cdf_file->U
    v     = cdf_file->V
    PHIS = cdf_file_PHIS->PHIS(0,:,:)

    ndims = dimsizes(u)
    nlevs = ndims(1)
    print(nlevs)
    TBOT  = cdf_file->T(:,nlevs-1,:,:)


    omega = omega_ccm_driver(p0,psfc,u,v,hyam,hybm,hyai,hybi)
    
    ; select level 700. 
    var = vinth2p_ecmwf(omega,hyam,hybm,(/700/),psfc,1,0.01 * p0,1,True,0,TBOT,conform(psfc,PHIS,(/1,2/)))


	do iyear = startyr+1,endyr
        yearstring = sprinti("%0.4i",iyear)
        filename = (Dir + Experiment + "." + camversion + "." + hfile + "." + yearstring +"-01-01-" + nsecs + ".nc")


		cdf_file = addfile(filename,"r")

        hyam  = cdf_file->hyam
        hybm  = cdf_file->hybm
        hyai  = cdf_file->hyai
        hybi  = cdf_file->hybi
        p0    = cdf_file->P0
        psfc  = cdf_file->PS
        u     = cdf_file->U
        v     = cdf_file->V
        PHIS = cdf_file_PHIS->PHIS(0,:,:)

        ndims = dimsizes(u)
        nlevs = ndims(1)
        print(nlevs)
        TBOT  = cdf_file->T(:,nlevs-1,:,:)

        omega = omega_ccm_driver(p0,psfc,u,v,hyam,hybm,hyai,hybi)

        ; select level 700
        OMEGA700_temp = vinth2p_ecmwf(omega,hyam,hybm,(/700/),psfc,1,0.01 * p0,1,True,0,TBOT,conform(psfc,PHIS,(/1,2/)))

		date_temp  = cdf_file->date
 	 	time_temp = cdf_file->time

		var_temp2 = array_append_record(var,OMEGA700_temp,0)
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


    varsqueeze = rm_single_dims(var)
	ndim  = dimsizes(varsqueeze)

    printVarSummary(varsqueeze)
    ;-----------------------------------------------------------------------
    ;Write variables to a new netcdf file
    ;-----------------------------------------------------------------------
	print("writing file")
	filo = "OMEGA700_daily_" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.nc"
	system("/bin/rm -f " + OutDir + filo)
	setfileoption("nc","format","netcdf4")	; allow us to write variables >2GB
    print(OutDir + filo)
	fout = addfile(OutDir + filo, "c")

	setfileoption(fout,"DefineMode",True)

; set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout,fAtt)
	
;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ndim(0),ndim(1),ndim(2)/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
	filevardef(fout,"time",typeof(time),getvardims(time))
    filevardef(fout,"date",typeof(date),getvardims(date))
	filevardef(fout,"lat",typeof(lat),getvardims(lat))
	filevardef(fout,"lon",typeof(lon),getvardims(lon))
	
    fout ->date    = (/date/)
	fout ->time    = (/time/)
	fout ->lat    = (/lat/)
	fout ->lon    = (/lon/)
	
    fout ->OMEGA700 = varsqueeze

	delete(lat)
	delete(lon)
	delete(time)
end do

end
