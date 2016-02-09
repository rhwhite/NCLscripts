load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

startyr = 20
nyears = 30

DirFrom = "/home/disk/rachel/CESM_outfiles/DEF-CTL/"

Vars = (/"SST"/)
FileVars = (/"skt"/)

nvars = dimsizes(Vars)

DEFname = "_Regrid_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"

do ivar = 0,nvars-1
	print(Vars(ivar))
	print(FileVars(ivar))

	if Vars(ivar) .EQ. "SST" then
		FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/skt_1948-2014.nc"
		Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_skt_1948-2014.nc"
	else
		print("wrong variable")
	end if

	cdf_file_NCEP = addfile(FileNCEP,"r")
	cdf_file_DEF = addfile(DirFrom + Vars(ivar) + DEFname, "r")


	if (Vars(ivar) .EQ. "SST") then
		NCEPin = cdf_file_NCEP->skt
		DEFin = cdf_file_DEF->skt
	end if


	NCEPout = NCEPin

	printVarSummary(NCEPin)
	printVarSummary(DEFin)

	NCEPtimes = cdf_file_NCEP->time
 	ntimes = dimsizes(NCEPtimes)
	ndims = dimsizes(NCEPin)

 
        ; do months since 1948-01-01 so that 1+mod(month,12) is 1 for first, january.
	NCEP_months = cd_convert( NCEPtimes, "months since 1948-01-01 00:00" )                 

	print(ntimes)

	print("files read in")

	do itime=0,ntimes-1

		idxmonth = tointeger(mod(NCEP_months(itime),12))
		NCEPout(itime,:,:) = NCEPout(itime,:,:) + DEFin(idxmonth,:,:)


	end do
	print("last month is " + tostring(idxmonth))

        ;-----------------------------------------------------------------------
        ;Write variables to a new netcdf file
        ;-----------------------------------------------------------------------
        system("/bin/rm -f " + Fileto)

        setfileoption("nc","Format","LargeFile")

        fout_std = addfile(Fileto, "c")

        setfileoption(fout_std,"DefineMode",True)
;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

;set dimensions of output file
        dimNames = (/"time","lat","lon"/)
        dimSizes = (/ndims(0),ndims(1),ndims(2)/)
        dimUnlim = (/True,False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

;        filevardef(fout_std,"lev_p",typeof(plev_to),getvardims(plev_to))
;        filevardef(fout_std,"lat","double",getvardims(lat_to))
;        filevardef(fout_std,"lon","double",getvardims(lon_to))

        if (FileVars(ivar) .EQ. "skt") then
                filevardef(fout_std,"skt",typeof(NCEPout),getvardims(NCEPout))
        end if

        ;fout_std->lev_p = plev_to
        ;fout_std->lat = lat_to
        ;fout_std->lon = lon_to

        if (FileVars(ivar) .EQ. "skt") then
                fout_std->skt = (NCEPout)
	end if

	delete([/NCEPin,NCEPout,DEFin,NCEPtimes,NCEP_months/])

end do

end

