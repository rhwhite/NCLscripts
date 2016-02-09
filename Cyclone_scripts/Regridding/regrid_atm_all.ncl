load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

startyr = 20
nyears = 30

DirFrom = "/home/disk/rachel/CESM_outfiles/DEF-CTL/"

Vars = (/"T","Q","U250","U850","V250","V850"/)
FileVars = (/"T","Q","U","U","V","V"/)

nvars = dimsizes(Vars)

FileFrom = "_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"
Outname = "_Regrid_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"

Fileto = "/home/disk/eos4/rachel/Obs/NCEP-NCAR/Cyclone/air.mon.mean.nc"

do ivar = 0,nvars-1
	print(Vars(ivar))
	print(FileVars(ivar))

	cdf_file_to = addfile(Fileto,"r")
	cdf_file_from = addfile(DirFrom + Vars(ivar) + FileFrom,"r")

	print("files read in")

	lat_to = cdf_file_to->lat
	lon_to = cdf_file_to->lon

	lat_from = cdf_file_from->lat
	lon_from = cdf_file_from->lon
	plev_to = cdf_file_from->lev_p

	if (FileVars(ivar) .EQ. "U") then
		var = cdf_file_from->U
	else if (FileVars(ivar) .EQ. "V") then
                var = cdf_file_from->V
        else if (FileVars(ivar) .EQ. "T") then
                var = cdf_file_from->T
        else if (FileVars(ivar) .EQ. "Q") then
                var = cdf_file_from->Q
	end if
	end if
	end if
	end if


	Opt 		= True
	Opt@SrcFileName = "source_grid_file.nc" 
	Opt@DstFileName = "dest_grid_file.nc"
	Opt@WgtFileName = DirFrom + "Weights_" + FileFrom

	Opt@SrcForceOverwrite = True
	Opt@DstForceOverwrite = True
	Opt@ForceOverwrite      = True

	Opt@SrcGridLat = lat_from
	Opt@SrcGridLon = lon_from

	Opt@DstGridLat = lat_to
	Opt@DstGridLon = lon_to

	Opt@InterpMethod = "patch"

	Opt@SrcInputFileName = DirFrom + FileFrom
	Opt@DstInputFileName = Fileto

	Opt@Check = True

	var_regrid = ESMF_regrid(var,Opt)
	printVarSummary(var_regrid)

	print(var_regrid&lat)
	print(typeof(var_regrid&lat))

	dims = getvardims(var_regrid)

	print(dims)
	ndims = dimsizes(var_regrid)
	;-----------------------------------------------------------------------
	;Write variables to a new netcdf file
	;-----------------------------------------------------------------------
	system("/bin/rm -f " + DirFrom + Vars(ivar) + Outname)
	
	setfileoption("nc","Format","LargeFile")

	fout_std = addfile(DirFrom + Vars(ivar) + Outname, "c")

	setfileoption(fout_std,"DefineMode",True)
;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

;set dimensions of output file
	dimNames = (/"time","lev_p","lat","lon"/)
	dimSizes = (/ndims(0),ndims(1),ndims(2),ndims(3)/)
	dimUnlim = (/True,False,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"lev_p",typeof(plev_to),getvardims(plev_to))
	filevardef(fout_std,"lat","double",getvardims(lat_to))
	filevardef(fout_std,"lon","double",getvardims(lon_to))

        if (FileVars(ivar) .EQ. "V") then
		filevardef(fout_std,"vwnd",typeof(var_regrid),getvardims(var_regrid))
	else if (FileVars(ivar) .EQ. "U") then
		filevardef(fout_std,"uwnd",typeof(var_regrid),getvardims(var_regrid))
        else if (FileVars(ivar) .EQ. "T") then      
                filevardef(fout_std,"air",typeof(var_regrid),getvardims(var_regrid))
        else if (FileVars(ivar) .EQ. "Q") then      
                filevardef(fout_std,"shum",typeof(var_regrid),getvardims(var_regrid))
	end if
	end if
	end if
	end if

	fout_std->lev_p = plev_to
print("written plev")
	;fout_std->lat = lat_to
	;fout_std->lon = lon_to
print("written lats and lons")

        if (FileVars(ivar) .EQ. "V") then
		fout_std->vwnd = (var_regrid)
        else if (FileVars(ivar) .EQ. "U") then      
                fout_std->uwnd = (var_regrid)
        else if (FileVars(ivar) .EQ. "T") then
                fout_std->air = (var_regrid)
        else if (FileVars(ivar) .EQ. "Q") then
                fout_std->shum = (var_regrid)
	end if
	end if
	end if
	end if

	delete(plev_to)
	delete(var_regrid)
	delete(var)
end do

end
