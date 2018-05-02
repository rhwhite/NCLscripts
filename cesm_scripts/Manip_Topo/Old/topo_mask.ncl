load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

diro = "/home/disk/eos4/rachel/inputdata/topo/"
filename = diro + "USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

PHIS_Topo = cdf_file->PHIS
lats = cdf_file->lat
lons = cdf_file->lon
ndims = dimsizes(PHIS_Topo)
delete(cdf_file)
delete(filename)

filename = diro + "NoTopo_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

PHIS_NoTopo = cdf_file->PHIS
delete(cdf_file)
delete(filename)

filename = diro + "NoRT_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

PHIS_NoRT = cdf_file->PHIS
delete(cdf_file)
delete(filename)


filename = diro + "NoR_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

PHIS_NoR = cdf_file->PHIS
delete(cdf_file)
delete(filename)

filename = diro + "NoT_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

PHIS_NoT = cdf_file->PHIS
delete(cdf_file)
delete(filename)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------

diro = "/home/disk/eos4/rachel/inputdata/topo/"
filo = "masks_USGS-gtopo30_1.9x2.5.nc"

system("/bin/rm -f " + diro + filo)
fout = addfile(diro + filo, "c")

setfileoption(fout,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)

;set dimensions of output file
dimNames = (/"lat","lon"/)
dimSizes = (/ndims(0),ndims(1)/)
dimUnlim = (/False,False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"lat",typeof(lats),getvardims(lats))
filevardef(fout,"lon",typeof(lons),getvardims(lons))

filevardef(fout,"Mask_Topo_NoTopo",typeof(PHIS_Topo),getvardims(PHIS_Topo))
filevardef(fout,"Mask_Topo_NoRT",typeof(PHIS_Topo),getvardims(PHIS_Topo))
filevardef(fout,"Mask_Topo_NoT",typeof(PHIS_Topo),getvardims(PHIS_Topo))
filevardef(fout,"Mask_Topo_NoR",typeof(PHIS_Topo),getvardims(PHIS_Topo))
filevardef(fout,"Mask_NoRT_NoR",typeof(PHIS_Topo),getvardims(PHIS_Topo))
filevardef(fout,"Mask_NoRT_NoT",typeof(PHIS_Topo),getvardims(PHIS_Topo))

fout ->lat    = (/lats/)
fout ->lon    = (/lons/)

Mask_Topo_NoTopo = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))
Mask_Topo_NoRT = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))
Mask_Topo_NoT = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))
Mask_Topo_NoR = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))
Mask_NoRT_NoR = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))
Mask_NoRT_NoT = new(dimsizes(PHIS_Topo),typeof(PHIS_Topo))

do ilat = 0,ndims(0)-1
print(ilat * 1.0)
	do ilon = 0,ndims(1)-1
		if (PHIS_Topo(ilat,ilon) .NE. PHIS_NoTopo(ilat,ilon))
			Mask_Topo_NoTopo(ilat,ilon) = 0
		else
			Mask_Topo_NoTopo(ilat,ilon) = 1
		end if
		if (PHIS_Topo(ilat,ilon) .NE. PHIS_NoRT(ilat,ilon))
			Mask_Topo_NoRT(ilat,ilon) = 0
		else
			Mask_Topo_NoRT(ilat,ilon) = 1
		end if
 		if (PHIS_Topo(ilat,ilon) .NE. PHIS_NoT(ilat,ilon))
			Mask_Topo_NoT(ilat,ilon) = 0
		else
			Mask_Topo_NoT(ilat,ilon) = 1
		end if
 		if (PHIS_Topo(ilat,ilon) .NE. PHIS_NoR(ilat,ilon))
			Mask_Topo_NoR(ilat,ilon) = 0
		else
			Mask_Topo_NoR(ilat,ilon) = 1
		end if
 		if (PHIS_NoRT(ilat,ilon) .NE. PHIS_NoR(ilat,ilon))
			Mask_NoRT_NoR(ilat,ilon) = 0
		else
			Mask_NoRT_NoR(ilat,ilon) = 1
		end if				
 		if (PHIS_NoRT(ilat,ilon) .NE. PHIS_NoT(ilat,ilon))
			Mask_NoRT_NoT(ilat,ilon) = 0
		else
			Mask_NoRT_NoT(ilat,ilon) = 1
		end if
	end do
end do	

fout->Mask_Topo_NoTopo = (/Mask_Topo_NoTopo/)
fout->Mask_Topo_NoRT = (/Mask_Topo_NoRT/)
fout->Mask_Topo_NoR = (/Mask_Topo_NoR/)
fout->Mask_Topo_NoT = (/Mask_Topo_NoT/)
fout->Mask_NoRT_NoT = (/Mask_NoRT_NoT/)
fout->Mask_NoRT_NoR = (/Mask_NoRT_NoR/)

end