load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

startyr = 20
nyears = 30

DirFrom = "/home/disk/rachel/CESM_outfiles/DEF-CTL/"
FileFrom = "SST_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"
Outname = "SST_Regrid_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"

Fileto = "/home/disk/eos4/rachel/Obs/NCEP-NCAR/Cyclone/skt.mon.mean.nc"

cdf_file_to = addfile(Fileto,"r")
cdf_file_from = addfile(DirFrom + FileFrom,"r")

print("files read in")

lat_to = cdf_file_to->lat
lon_to = cdf_file_to->lon

lat_from = cdf_file_from->lat
lon_from = cdf_file_from->lon

var = cdf_file_from->SST

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

ndimspre = dimsizes(var)
ntimes = ndimspre(0)
print(ndimspre)

nlats_to = dimsizes(lat_to)
nlons_to = dimsizes(lon_to)

var_regrid = new((/12,nlats_to,nlons_to/),typeof(var))
do imonth=0,ntimes-1
	var_regrid(imonth,:,:) = ESMF_regrid(var(imonth,:,:),Opt)
end do

var_regrid!0 = "time"
dims = getvardims(var_regrid)
print(dims)
ndims = dimsizes(var_regrid)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
        system("/bin/rm -f " + DirFrom + Outname)
        
	setfileoption("nc","Format","LargeFile")

        fout_std = addfile(DirFrom + Outname, "c")

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

        filevardef(fout_std,"lat",typeof(lat_to),getvardims(lat_to))
        filevardef(fout_std,"lon",typeof(lon_to),getvardims(lon_to))


        filevardef(fout_std,"skt",typeof(var_regrid),getvardims(var_regrid))

        fout_std->lat = lat_to
        fout_std->lon = lon_to
print("written lats and lons")
        fout_std->skt = (/var_regrid/)


end
