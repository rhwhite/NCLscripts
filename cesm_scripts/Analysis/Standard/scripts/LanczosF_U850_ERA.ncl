load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter U850 ERA-I")

startyr=1980
endyr=2015
nyears = endyr-startyr+1

timespan = "Annual"

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/"
File = "ERAI_U850_NAtl_1980-2015.nc"
filename = (Dir + File)

name = "LP10day"

cdf_file = addfile(filename,"r")

var = tofloat(cdf_file->u)

time  = cdf_file->time
latitude = cdf_file->latitude
longitude = cdf_file->longitude
ntim  = dimsizes(var)

; ***********************************************
; create the filter weights and apply
; ***********************************************
ihp     = 0                            ; low pass
sigma   = 1.0                           ; Lanczos sigma

nWgt    = 61                           ; 365: lose half a year (182 days) at each end = 2*182+1 = 365  

dt = 1.0                                ; days per timestep

fca     = dt/10.                        ; low freq, 10 days = 1/10 timesteps
fcb = -999.

wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )


varbpf_temp = var
varbpf_temp(:,:,:) = 1.0

do ilat = 0,ntim(1)-1
;	print(ilat * 1)
	do ilon = 0,ntim(2)-1
		varbpf_temp(:,ilat,ilon) = wgt_runave (var(:,ilat,ilon), wgt, 0 )      ;
	end do
end do

ndims = dimsizes(varbpf_temp)
ntimes = ndims(0)

print(ndims)
print(dimsizes(var))

latitude!0 = "latitude"
longitude!0 = "longitude"

varbpf_temp!0 = "time"
varbpf_temp!1 = "latitude"
varbpf_temp!2 = "longitude"
delete(var)

;ntimes2 = ntimes - (731*2)

varbpf = new((/ntimes,ndims(1),ndims(2)/),typeof(varbpf_temp))
timebpf = new((/ntimes/),typeof(time))

count = 0


do nt = 0,ntimes-1
	varbpf(count,:,:) = varbpf_temp(nt,:,:)
	timebpf(count) = time(nt)
	count = count + 1
end do

timebpf@long_name = "time"
timebpf@units = "hours since 1900-01-01"
timebpf@calendar = "gregorian"

latitude@units = "degrees_north"
latitude@long_name = "latitude"

longitude@units = "degrees_east"
longitude@long_name = "longitude"

varbpf!0 = varbpf_temp!0
varbpf!1 = varbpf_temp!1
varbpf!2 = varbpf_temp!2

delete(varbpf_temp)
ndims2 = dimsizes(varbpf(0:count-1,:,:))

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
filo = name + "_" + File 
system("/bin/rm -f " + Dir + filo)
fout = addfile(Dir + filo, "c")

setfileoption(fout,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)

;set dimensions of output file
dimNames = (/"time","latitude","longitude"/)
dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
dimUnlim = (/True,False,False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"time",typeof(timebpf),getvardims(timebpf))
filevardef(fout,"latitude",typeof(latitude),getvardims(latitude))
filevardef(fout,"longitude",typeof(longitude),getvardims(longitude))

filevardef(fout,"u_lpf",typeof(varbpf),getvardims(varbpf))

fout ->time    = timebpf
fout ->latitude    = latitude
fout ->longitude    = longitude

fout ->u_lpf = (/varbpf(0:count-1,:,:)/)

end
