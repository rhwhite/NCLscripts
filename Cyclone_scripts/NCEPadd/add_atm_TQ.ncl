load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

startyr = 20
nyears = 30

DirFrom = "/home/disk/rachel/CESM_outfiles/DEF-CTL/"

Vars = (/"T","Q"/)
FileVars = (/"T","Q"/)

nvars = dimsizes(Vars)

DEFname = "_Regrid_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"

do ivar = 0,nvars-1
	print(Vars(ivar))
	print(FileVars(ivar))

	if Vars(ivar) .EQ. "T" then
		FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/air_1948-2014.nc"
		Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_air_1948-2014.nc"
	else if Vars(ivar) .EQ. "Q" then
                FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/shum_1948-2014.nc"
                Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_shum_1948-2014.nc"
	else
		print("error with variable names!")
		exit
	end if
	end if

	cdf_file_NCEP = addfile(FileNCEP,"r")
	cdf_file_DEF = addfile(DirFrom + Vars(ivar) + DEFname, "r")


	if (Vars(ivar) .EQ. "T") then
		NCEPin = cdf_file_NCEP->air
		DEFin = cdf_file_DEF->air
        else if (Vars(ivar) .EQ. "Q") then
                NCEPin = cdf_file_NCEP->shum
                DEFin = cdf_file_DEF->shum
        else if (Vars(ivar) .EQ. "U250" .OR. Vars(ivar) .EQ. "U850") then
                NCEPin = cdf_file_NCEP->uwnd
                DEFin = cdf_file_DEF->uwnd
        else if (Vars(ivar) .EQ. "V250" .OR. Vars(ivar) .EQ. "V850") then
                NCEPin = cdf_file_NCEP->vwnd
                DEFin = cdf_file_DEF->vwnd
	end if
	end if
	end if
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
		NCEPout(itime,:,:,:) = NCEPout(itime,:,:,:) + DEFin(idxmonth,:,:,:)


	end do
	print("last month is " + tostring(idxmonth + 1))

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
        dimNames = (/"time","level","lat","lon"/)
        dimSizes = (/ndims(0),ndims(1),ndims(2),ndims(3)/)
        dimUnlim = (/True,False,False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

;        filevardef(fout_std,"lev_p",typeof(plev_to),getvardims(plev_to))
;        filevardef(fout_std,"lat","double",getvardims(lat_to))
;        filevardef(fout_std,"lon","double",getvardims(lon_to))

        if (FileVars(ivar) .EQ. "V") then
                filevardef(fout_std,"vwnd",typeof(NCEPout),getvardims(NCEPout))
        else if (FileVars(ivar) .EQ. "U") then
                filevardef(fout_std,"uwnd",typeof(NCEPout),getvardims(NCEPout))
        else if (FileVars(ivar) .EQ. "T") then
                filevardef(fout_std,"air",typeof(NCEPout),getvardims(NCEPout))
        else if (FileVars(ivar) .EQ. "Q") then
                filevardef(fout_std,"shum",typeof(NCEPout),getvardims(NCEPout))
        end if
        end if
        end if
        end if

        ;fout_std->lev_p = plev_to
        ;fout_std->lat = lat_to
        ;fout_std->lon = lon_to

        if (FileVars(ivar) .EQ. "V") then
                fout_std->vwnd = (NCEPout)
        else if (FileVars(ivar) .EQ. "U") then
                fout_std->uwnd = (NCEPout)
        else if (FileVars(ivar) .EQ. "T") then
                fout_std->air = (NCEPout)
 	else if (FileVars(ivar) .EQ. "Q") then
		fout_std->shum = (NCEPout)
	end if
	end if
	end if
	end if

	delete([/NCEPin,NCEPout,DEFin,NCEPtimes,NCEP_months/])

end do

end

