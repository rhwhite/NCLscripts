load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_6hrly")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1
ntimes = toint(nyears * 365.25 * 4)
dirstr = getenv("NCL_dirstr")

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

Ps = 1013.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + dirstr)
	print(Experiment)

	filename = Dir + "raw/" + Experiment + ".cam2.h1.0002-01-01-00000.nc"

	cdf_file = addfile(filename,"r")

	lats = cdf_file->lat
	lons = cdf_file->lon

	nlats = dimsizes(lats)
	nlons = dimsizes(lons)


	filo = "SF_" + Experiment + ".cam2.h1." + tostring(startyr) + "-" + tostring(endyr) + ".nc"
	system("/bin/rm -f " + Dir + filo)
	fout_std = addfile(Dir + filo, "c")

	setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ntimes,nlats,nlons/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"lats",typeof(lats),getvardims(lats))
	filevardef(fout_std,"lons",typeof(lons),getvardims(lons))

	filevardef(fout_std,"SF250",typeof(cdf_file->U250), (/"time","lat","lon"/))
	filevardef(fout_std,"SFZA250",typeof(cdf_file->U250),(/"time","lat","lon"/))

	filevardef(fout_std,"SF850",typeof(cdf_file->U250),(/"time","lat","lon"/))
	filevardef(fout_std,"SFZA850",typeof(cdf_file->U250),(/"time","lat","lon"/))

	fout_std->lat = lats
	fout_std->lon = lons

	writecount = 0

	do iyear = startyr,endyr
		print(iyear)
		if iyear .LT. 10 then
			stryear = "0" + tostring(iyear)
		else
			stryear = tostring(iyear)
		end if

		filename = Dir + "raw/" + Experiment + ".cam2.h1.00" + stryear + "-01-01-00000.nc"

		cdf_file = addfile(filename,"r")

		ntimes = dimsizes(cdf_file->time)

                SF250 = new((/ntimes,nlats,nlons/), typeof(cdf_file->U250))
                SF850 = new((/ntimes,nlats,nlons/), typeof(cdf_file->U250))
                temp = new((/ntimes,nlats,nlons/),typeof(cdf_file->U250))
                
                uv2sfvpf(cdf_file->U250(:,:,:),cdf_file->V250(:,:,:),SF250,temp)
                uv2sfvpf(cdf_file->U850(:,:,:),cdf_file->V850(:,:,:),SF850,temp)

		SFZA250 = dim_rmvmean_Wrap(SF250)
                SFZA850 = dim_rmvmean_Wrap(SF850)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
		fout_std->SF250(writecount:writecount+ntimes-1,:,:) = (/SF250/)
		fout_std->SFZA250(writecount:writecount+ntimes-1,:,:)  = (/SFZA250/)

                fout_std->SF850(writecount:writecount+ntimes-1,:,:)  = (/SF850/)
                fout_std->SFZA850(writecount:writecount+ntimes-1,:,:)  = (/SFZA850/)
		writecount = writecount + ntimes

	end do

end do

end
