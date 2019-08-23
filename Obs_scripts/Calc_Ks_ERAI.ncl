load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Code to calculate Rossby stationary wave number, following Hoskins and Ambrizzi 1993. 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks^2 = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

; Get experiment names

startyr=1979
endyr=2015
nyears = endyr-startyr+1

timespan = "DJF"

Dir = "/home/disk/eos4/rachel/Obs/ERAI/"

filename = (Dir + "ERAI_climfrommonthly_DJF_1979-2015.nc")

print("Calc Rossby Refractive Index")

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616

cdf_filepl = addfile(filename,"r")

; get pressure levels

level = cdf_filepl->level		; in hpa, or mb
level!0="level"
levsizes = dimsizes(level)
nlevels = filevardimsizes(cdf_filepl,"level")
nlat = filevardimsizes(cdf_filepl,"latitude")
nlon = filevardimsizes(cdf_filepl,"longitude")

lat = tofloat(cdf_filepl->latitude)
lat!0="latitude"
lon = tofloat(cdf_filepl->longitude)
lon!0="longitude"

U = cdf_filepl->u(:,:,:,:)

; Set up some constants
phi = lat*PI/180.0      ; Get latitude in radians
cphi = cos(phi)
c2phi = cphi * cphi
acphi = a * cos(phi)
asphi = a * sin(phi)
f = 2*omega*sin(phi)
a2 = a*a
f2 = f * f

; Calculate Ucos(phi)

Ucphi = U * conform(U,cphi,2)
copy_VarCoords(U,Ucphi)

; Calculate d/dphi (Ucphi)
dUcphidphi = center_finite_diff_n(Ucphi(time|:,level|:,latitude|:,longitude|:),phi,False,0,2)

; Calculate 1/cphi * dUcphi/dphi
tempdUcphidphi = dUcphidphi / conform(dUcphidphi,cphi,2)
; Calculate meridional gradient of this

d2Uetcdphi = center_finite_diff_n(tempdUcphidphi,phi,False,0,2)

; Calculate BetaM

BetaM1 = 2.0 * omega * c2phi / a

; Correction on 22nd Aug 2019: c2phi to cphi
; Mostly this only impacts higher latitudes
;BetaM2 = d2Uetcdphi * conform(d2Uetcdphi,c2phi,2) / a2
BetaM2 = d2Uetcdphi * conform(d2Uetcdphi,cphi,2) / a2

BetaM = conform(BetaM2,BetaM1,2) - BetaM2

; Calculate Ks = (a^2 cos(phi) * BetaM / U)^0.5

Ks = sqrt(conform(BetaM,a2,-1) * conform(BetaM,cphi,2) * BetaM / U)

Ks!0 = "time"
Ks!1 = "level"
Ks!2 = "latitude"
Ks!3 = "longitude"

Ks@level = level
Ks@lat = lat
Ks@lon = lon	


copy_VarCoords(Ks,BetaM)


;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------

filo = "Ks_" + timespan + tostring(startyr) + "_" + tostring(nyears) + ".nc"
system("/bin/rm -f " + Dir + filo)
fout_std = addfile(Dir + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"time","latitude","longitude","level"/)
dimSizes = (/1,nlat,nlon,nlevels/)
dimUnlim = (/False,False,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
filevardef(fout_std,"level",typeof(level),getvardims(level))
filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

filevardef(fout_std,"Ks",typeof(Ks),getvardims(Ks))
filevardef(fout_std,"BetaM",typeof(Ks),getvardims(Ks))

filevardef(fout_std,"U",typeof(U),getvardims(U))
fout_std->U = U
fout_std->Ks = Ks
fout_std->BetaM = BetaM
fout_std->lat = lat
fout_std->level = level
fout_std->lon = lon

print("printed it")


end
