load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter U ERA-I")

startyr=1980

timespan = "Annual"

Dir = "/home/Earth/rwhite/data/ERAI/daily_mean/"
File = "ERAI_U_day_3deg_1980.nc"
filename = (Dir + File)

cutoff = 30
name = "testlowP" + tostring(cutoff) + "day"

ZM = 0

cdf_file = addfile(filename,"r")

vartemp = short2flt(cdf_file->u)

if ZM .EQ. 1 then
    var = dim_avg_n(vartemp,2)
else
    var = vartemp
end if 

time  = cdf_file->time
latitude = cdf_file->latitude
longitude = cdf_file->longitude
ndim  = dimsizes(var)
print(ndim)

; ***********************************************
; create the filter weights and apply
; ***********************************************
ihp     = 0                            ; low pass
sigma   = 1.0                           ; Lanczos sigma

nWgt    = 31                           ; 

dt = 1.0                                ; days per timestep

fca     = dt/tofloat(cutoff)                        ; low freq, 10 days = 1/10 timesteps
fcb = -999.

wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

print(wgt)
varbpf_temp = var
if ZM .EQ. 1 then
    varbpf_temp(:,:) = 1.0
    do ilat = 0,ndim(1)-1
        varbpf_temp(:,ilat) = wgt_runave (var(:,ilat), wgt, 0 )      ;
    end do
else
    varbpf_temp(:,:,:) = 1.0
    do ilat = 0,ndim(1)-1
        do ilon = 0,ndim(2)-1
            varbpf_temp(:,ilat,ilon) = wgt_runave (var(:,ilat,ilon), wgt, 0 )      ;
        end do
    end do

end if

ndims = dimsizes(varbpf_temp)

ntimes = ndims(0)

print(ndims)
print(dimsizes(var))

latitude!0 = "latitude"
longitude!0 = "longitude"

varbpf_temp!0 = "time"
varbpf_temp!1 = "latitude"
if ZM .EQ. 0 then
    varbpf_temp!2 = "longitude"
end if
delete(var)

;ntimes2 = ntimes - (731*2)

timebpf = new((/ntimes/),typeof(time))
count = 0

print(ntimes)
if ZM .EQ. 1 then
    varbpf = new((/ntimes,ndims(1)/),typeof(varbpf_temp))
    do nt = 0,ntimes-1
        varbpf(count,:) = varbpf_temp(nt,:)
        timebpf(count) = time(nt)
        count = count + 1
    end do
else
    varbpf = new((/ntimes,ndims(1),ndims(2)/),typeof(varbpf_temp))
    do nt = 0,ntimes-1
        varbpf(count,:,:) = varbpf_temp(nt,:,:)
        timebpf(count) = time(nt)
        count = count + 1
    end do
end if

timebpf@long_name = "time"
timebpf@units = "hours since 1900-01-01"
timebpf@calendar = "gregorian"

latitude@units = "degrees_north"
latitude@long_name = "latitude"

longitude@units = "degrees_east"
longitude@long_name = "longitude"

varbpf!0 = varbpf_temp!0
varbpf!1 = varbpf_temp!1
if ZM .NE. 1 then
    varbpf!2 = varbpf_temp!2
end if

delete(varbpf_temp)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
if ZM .EQ. 1 then
    filo = name + "_ZM_" + File 
else
    filo = name + "_" + File
end if

system("/bin/rm -f " + Dir + filo)
fout = addfile(Dir + filo, "c")

setfileoption(fout,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)

;set dimensions of output file
if ZM .EQ. 1 then
    dimNames = (/"time","latitude"/)
    dimSizes = (/ndims(0),ndims(1)/)
    dimUnlim = (/True,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)
else
    dimNames = (/"time","latitude","longitude"/)
    dimSizes = (/ndims(0),ndims(1),ndims(2)/)
    dimUnlim = (/True,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)
    filevardef(fout,"longitude",typeof(longitude),getvardims(longitude))
end if


filevardef(fout,"time",typeof(timebpf),getvardims(timebpf))
filevardef(fout,"latitude",typeof(latitude),getvardims(latitude))

filevardef(fout,"u_lpf",typeof(varbpf),getvardims(varbpf))

fout ->time    = timebpf
fout ->latitude    = latitude
print(count)
if ZM .EQ. 1 then
    print(varbpf(0:10,:))
    fout ->u_lpf = (/varbpf(0:count-1,:)/)
else
    fout ->longitude    = longitude
    fout ->u_lpf = (/varbpf(0:count-1,:,:)/)

end if

end
