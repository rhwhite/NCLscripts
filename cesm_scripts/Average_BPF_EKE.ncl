load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
Experiments = (/"CESMtopof09","CESMnoRTf09"/);"CESMtopof19","CESMnoRTf19",

nyears = 20

print(Experiments)

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

Experiment = Experiments(exps)

print(Experiment)

iyear = 2
yearstring = ("0" + tostring(iyear))

diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiment +"/atm/hist/"
filename = diro + "EKE_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"

cdf_file = addfile(filename,"r")
print("file read in")

lat = cdf_file->lat
lon = cdf_file->lon
EKE850 = cdf_file->EKE850
time  = cdf_file->time
  
ndims  = dimsizes(EKE850)
print(ndims)   

print(getvardims(EKE850))

; ***********************************************
; create the filter weights and apply
; ***********************************************
  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  nWgt    = 1461                           ; 1461 lose half a year at each end = 2*740+1 = 1461  

  dt = 0.25                                ; days per timestep
  
  fca     = dt/6.                        ; low freq, 6 days = 1/24 timesteps
  fcb     = dt/2.                        ; high freq = 2 days = 1/8 timesteps

print(fca)
print(fcb)
  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

 EKE850bpf_temp = EKE850
 EKE850bpf_temp(:,:,:) = 0.0
 EKE850bpf_temp!0 = EKE850!0
 EKE850bpf_temp!1 = EKE850!1
 EKE850bpf_temp!2 = EKE850!2

do ilat = 0,ndims(1)-1
	print(ilat * 1)
	do ilon = 0,ndims(2)-1
		EKE850bpf_temp(:,ilat,ilon) = wgt_runave (EKE850(:,ilat,ilon), wgt, 0 )      ;
	end do
end do

delete(EKE850)
ndims = dimsizes(EKE850bpf_temp)
ntimes = ndims(0)
print(ndims)

EKE850bpf = EKE850bpf_temp(731:ntimes-731,:,:)
delete(EKE850bpf_temp)
timebpf = time(731:ntimes-731)
delete(time)
ndims2 = dimsizes(EKE850bpf)
print(ndims2)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiment +"/atm/hist/"
filo = "EKE_" + tostring(nyears) + "_BPF2_6_" + Experiment + ".cam2.h1.nc"
system("/bin/rm -f " + diro + filo)
fout_bpf = addfile(diro + filo, "c")

setfileoption(fout_bpf,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_bpf,fAtt)

;set dimensions of output file
dimNames = (/"time","lat","lon"/)
dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
dimUnlim = (/True,False,False/)
filedimdef(fout_bpf,dimNames,dimSizes,dimUnlim)

filevardef(fout_bpf,"time",typeof(timebpf),getvardims(timebpf))
filevardef(fout_bpf,"lat",typeof(lat),getvardims(lat))
filevardef(fout_bpf,"lon",typeof(lon),getvardims(lon))

filevardef(fout_bpf,"EKE850_bpf2_6",typeof(EKE850bpf),getvardims(EKE850bpf))
filevardef(fout_bpf,"EKE250_bpf2_6",typeof(EKE850bpf),getvardims(EKE850bpf))

fout_bpf ->time    = (/timebpf/)
fout_bpf ->lat    = (/lat/)
fout_bpf ->lon    = (/lon/)

fout_bpf ->EKE850_bpf2_6 = (/EKE850bpf/)

delete(EKE850bpf)
delete(timebpf)
delete(lat)
delete(lon)

; Repeat for 250 level

EKE250 = cdf_file->EKE250
time  = cdf_file->time
  
ndims  = dimsizes(EKE250)
print(ndims)   

EKE250bpf_temp = EKE250
EKE250bpf_temp(:,:,:) = 0.0
EKE250bpf_temp!0 = EKE250!0
EKE250bpf_temp!1 = EKE250!1
EKE250bpf_temp!2 = EKE250!2

do ilat = 0,ndims(1)-1
	print(ilat * 1)
	do ilon = 0,ndims(2)-1
		EKE250bpf_temp(:,ilat,ilon) = wgt_runave (EKE250(:,ilat,ilon), wgt, 0 )      ;
	end do
end do

delete(EKE250)
ndims = dimsizes(EKE250bpf_temp)
ntimes = ndims(0)
print(ndims)

EKE250bpf = EKE250bpf_temp(731:ntimes-731,:,:)
delete(EKE250bpf_temp)

fout_bpf ->EKE250_bpf2_6 = (/EKE250bpf/)

delete(EKE250bpf)

end do

end