; 3-D wave-activity flux derived by Plumb (1985, JAS)
; See (5.7) of Plumb 1985
;
; Used data: daily-mean data of NCEP/NCAR reanalys 1
;  air tempeature (air: degK)   ; air.2000.nc
;  geopotential height (hgt: m) ; hgt.2000.nc
;
; The data are available at 
; http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html

; input files are
;
; The unit of level is [hPa]
;
; Basic state: zonal-mean fields 
;
; Perturbation: deviation from zonal-mean fields
;
; Calculating the flux for each day of input data.
;
; Note that 
; (i)  10-day low-pass filter is applied
; (ii) The first and last 10 days of output data are missing.
;

; Output files are
; x-component:  Plumb1985-Fx.daily.2000.nc
; y-component:  Plumb1985-Fy.daily.2000.nc
; z-component:  Plumb1985-Fz.daily.2000.nc



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; daily mean data in short
tfile = addfile("/e4b/ncep/plev/daily_mean/nc/air.2000.nc","r")
zfile = addfile("/e4b/ncep/plev/daily_mean/nc/hgt.2000.nc","r")

; Test a variable's type prior to reading the variable

if (getfilevartypes(tfile,"air").eq."short")then
tvarorg = short2flt(tfile->air)
else
tvarorg = tfile[:]->air
end if

if (getfilevartypes(zfile,"hgt").eq."short")then
zvarorg = short2flt(zfile->hgt)
else
zvarorg = zfile[:]->hgt
end if

time = tfile->time
lat = tfile->lat
lon = tfile->lon
level = tfile->level

ntime = dimsizes(time)
nlat = dimsizes(lat)
nlon = dimsizes(lon)
nlevel = dimsizes(level)

;  Gas constant
gc=290
;  Gravitational acceleration
ga=9.80665

;  Radius of the earth
re=6378388
; scale height
sclhgt=8000.

; pi
pi = atan(1.0)*4.

; Coriolis parameter
f =  2.*2.*pi/(60.*60.*24.)*sin(pi/180. * lat(:))
f!0 = "lat"
f&lat = lat
f@_FillValue = -1.e+21

; missing for 10S - 10N
do ilat = 0, nlat-1
if (abs(lat(ilat) ).lt. 10. ) then
f(ilat)= f@_FillValue
end if
end do

; cosine
coslat = cos(lat(:)*pi/180.)

;10-day low-pass fileter
; The output data of the first and lat 10 days is all missing.
wgt = filwgts_lanczos(21, 0,0.1, -999.,1)

zvar = wgt_runave_n_Wrap(zvarorg,wgt,0,0)
tvar = wgt_runave_n_Wrap(tvarorg,wgt,0,0)


; zonal mean
tznl = dim_avg_n_Wrap(tvar(:,:,:,:),3)


; 1-D -> 4-D
leveltmp = conform_dims(dimsizes(tvar),level,1)
coslattmp = conform_dims(dimsizes(tvar),coslat,2)
ftmp = conform_dims(dimsizes(tvar),f,2)

; 3-D -> 4-D
tznltmp = conform_dims( (/ntime,nlevel,nlat,nlon/),tznl,(/0,1,2/))

; potential temperature
theta = tznltmp*(1000./leveltmp)^0.286

;K/m
dthetadz = center_finite_diff_n(theta,-sclhgt*log(level/1000),False,0,1)

; Brunt Vaisala frequency
NN = (gc*(leveltmp/1000.)^0.286)/sclhgt * dthetadz

; deviations from zonal mean
psidev = dim_rmvmean(zvar)*ga /ftmp

;dpsidev/dlon
dpsidevdlon =  center_finite_diff_n(psidev,lon*pi/180.,True,0,3)

;ddpsidev/dlonlon
ddpsidevdlonlon =  center_finite_diff_n(dpsidevdlon,lon*pi/180.,True,0,3)

;dpsidev/dlat
dpsidevdlat = center_finite_diff_n(psidev, lat*pi/180., False,0,2)

;ddpsidev/dlonlat
ddpsidevdlonlat =  center_finite_diff_n(dpsidevdlon,lat*pi/180.,False,0,2)

;dpsidev/dz
dpsidevdz = center_finite_diff_n(psidev, -sclhgt*log(level/1000),False,0,1)

;ddpsidev/dlondz
ddpsidevdlonz = center_finite_diff_n(dpsidevdlon, -sclhgt*log(level/1000),False,0,1)

;x-component of (5.7)
Fx = leveltmp/1000./(2.*re*re*coslattmp)*(dpsidevdlon*dpsidevdlon-psidev*ddpsidevdlonlon)

;y-component of (5.7)
Fy = leveltmp/1000./(2.*re*re)*(dpsidevdlon*dpsidevdlat-psidev*ddpsidevdlonlat)

;z-component of (5.7)
Fz = leveltmp/1000.*ftmp*ftmp/(2.*NN*re)*(dpsidevdlon*dpsidevdz-psidev*ddpsidevdlonz)

; for output
Fx!0 = "time"
Fx&time = time
Fx!1 = "level"
Fx&level = level
Fx!2 = "lat"
Fx&lat = lat
Fx!3 = "lon"
Fx&lon = lon

Fy!0 = "time"
Fy&time = time
Fy!1 = "level"
Fy&level = level
Fy!2 = "lat"
Fy&lat = lat
Fy!3 = "lon"
Fy&lon = lon

Fz!0 = "time"
Fz&time = time
Fz!1 = "level"
Fz&level = level
Fz!2 = "lat"
Fz&lat = lat
Fz!3 = "lon"
Fz&lon = lon

psidev!0 = "time"
psidev&time = time
psidev!1 = "level"
psidev&level = level
psidev!2 = "lat"
psidev&lat = lat
psidev!3 = "lon"
psidev&lon = lon

Fx@units = "m^2/s^2"
Fx@units = "m^2/s^2"
Fz@units = "m^2/s^2"

psidev@units = "m^2/s"

ncFx = addfile("Plumb1985-Fx.daily.2000.nc","c")
ncFy = addfile("Plumb1985-Fy.daily.2000.nc","c")
ncFz = addfile("Plumb1985-Fz.daily.2000.nc","c")

ncpsidev = addfile("psidev.daily.2000.nc","c")

ncFx->Fx = Fx
ncFy->Fy = Fy
ncFz->Fz = Fz
ncpsidev->psidev = psidev
end

