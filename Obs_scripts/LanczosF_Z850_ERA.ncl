load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter_Z ERA-I")

startyr=1979
endyr=2015
nyears = endyr-startyr+1

timespan = "DJF"

Dir = "/home/disk/eos4/rachel/Obs/ERAI/"

filename = (Dir + "ERAI_Z850_" + timespan + "_6hrly_" + tostring(startyr) + "-" + tostring(endyr) + ".nc")

cdf_file = addfile(filename,"r")

lat = cdf_file->latitude
lon = cdf_file->longitude
Z850 = cdf_file->Z850

time  = cdf_file->time

ntim  = dimsizes(Z850)

; ***********************************************
; create the filter weights and apply
; ***********************************************
ihp     = 2                             ; band pass
sigma   = 1.0                           ; Lanczos sigma

nWgt    = 1461                           ; 1461 lose half a year at each end = 2*740+1 = 1461  

dt = 0.25                                ; days per timestep

fca     = dt/6.                        ; low freq, 6 days = 1/24 timesteps
fcb     = dt/2.                        ; high freq = 2 days = 1/8 timesteps

wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )


Z850bpf_temp = Z850
Z850bpf_temp(:,:,:) = 1.0

do ilat = 0,ntim(1)-1
;	print(ilat * 1)
	do ilon = 0,ntim(2)-1
		Z850bpf_temp(:,ilat,ilon) = wgt_runave (Z850(:,ilat,ilon), wgt, 0 )      ;
	end do
end do

ndims = dimsizes(Z850bpf_temp)
ntimes = ndims(0)

lat!0 = "lat"
lon!0 = "lon"

Z850bpf_temp!0 = "time"
Z850bpf_temp!1 = "lat"
Z850bpf_temp!2 = "lon"
delete(Z850)

if (timespan .eq. "Annual")
	ntimes2 = nyears*4*365;
else if (timespan .eq. "DJF")
	ntimes2 = nyears*4*(31+31+28);
else if (timespan .eq. "JJA")
	ntimes2 = nyears*4*(30+31+31);
else
	print("timespan is wrong")
	exit
end if
end if
end if

ntimes2 = ntimes - (731*2)

Z850bpf = new((/ntimes2,ndims(1),ndims(2)/),typeof(Z850bpf_temp))
timebpf = new((/ntimes2/),typeof(time))

count = 0

do nt = 731,ntimes-732
	Z850bpf(count,:,:) = Z850bpf_temp(nt,:,:)
	timebpf(count) = time(nt)
	count = count + 1
end do

Z850bpf!0 = Z850bpf_temp!0
Z850bpf!1 = Z850bpf_temp!1
Z850bpf!2 = Z850bpf_temp!2

delete(Z850bpf_temp)
ndims2 = dimsizes(Z850bpf(0:count-1,:,:))

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
filo = "ERAI_Z850bpf_2_" + timespan + "_6hrly_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"
system("/bin/rm -f " + Dir + filo)
fout = addfile(Dir + filo, "c")

setfileoption(fout,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)

;set dimensions of output file
dimNames = (/"time","lat","lon"/)
dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
dimUnlim = (/True,False,False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"time",typeof(timebpf),getvardims(timebpf))
filevardef(fout,"lat",typeof(lat),getvardims(lat))
filevardef(fout,"lon",typeof(lon),getvardims(lon))

filevardef(fout,"Z850bpf",typeof(Z850bpf),getvardims(Z850bpf))
filevardef(fout,"Z850bpf_var",typeof(Z850bpf),(/"lat","lon"/))

fout ->time    = (/timebpf/)
fout ->lat    = (/lat/)
fout ->lon    = (/lon/)

fout ->Z850bpf = (/Z850bpf(0:count-1,:,:)/)

delete(Z850bpf)
delete(timebpf)
delete(lat)
delete(lon)
delete(time)

fout->Z850bpf_var = dim_variance_n(fout->Z850bpf(:,:,:),0)


end
