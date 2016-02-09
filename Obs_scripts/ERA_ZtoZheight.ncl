load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Z to Z height, ERA-I")

startyr=1979
endyr=2015
nyears = endyr-startyr+1

timespan = "DJF"

Dir = "/home/disk/eos4/rachel/Obs/ERAI/"

filename = (Dir + "ERAI_Z850_" + timespan + "_6hrly_" + tostring(startyr) + "-" + tostring(endyr) + ".nc")

cdf_file = addfile(filename,"w")

lat = cdf_file->latitude
lon = cdf_file->longitude
Z = short2flt(cdf_file->z)

Z850 = Z/9.8

Z850!0 = cdf_file->z!0
Z850!1 = cdf_file->z!1
Z850!2 = cdf_file->z!2

Z850var = dim_variance_n_Wrap(Z850,0)

ndims = dimsizes(Z850)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
setfileoption(cdf_file,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(cdf_file,fAtt)

;set dimensions of output file
;dimNames = (/"time","latitude","longitude"/)
;dimSizes = (/ndims(0),ndims(1),ndims(2)/)
;dimUnlim = (/True,False,False/)
;filedimdef(cdf_file,dimNames,dimSizes,dimUnlim)

filevardef(cdf_file,"Z850",typeof(Z850),getvardims(Z850))
filevardef(cdf_file,"Z850var",typeof(Z850),getvardims(Z850))


cdf_file ->Z850 = (/Z850/)

delete(lat)
delete(lon)

cdf_file->Z850_var = (/Z850var/)


end
