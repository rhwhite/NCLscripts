load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Code to calculate Rossby stationary wave number, following Hoskins and Ambrizzi 1993. 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

; Get arguments
argDir = getenv("NCL_ARG_dir")
file_prefix = getenv("NCL_ARG_filename")

Dir = argDir + "/daily_data/"

; Define some constants
a = 6.37122e06  ; radius of Earth
PI = 3.14159265358979
omega =  7.2921e-5  ; rotation speed
g = 9.80616     ; gravitational constant

filename = (Dir + file_prefix)
print(filename)
cdf_filepl = addfile(filename,"r")

; get coordinate data
nlat = filevardimsizes(cdf_filepl,"latitude")
nlon = filevardimsizes(cdf_filepl,"longitude")
ntimes = filevardimsizes(cdf_filepl,"time")

lat = cdf_filepl->latitude
lon = cdf_filepl->longitude
times = cdf_filepl->time

; get U wind data
U = cdf_filepl->u(:,:,:)
;U = cdf_filepl->u(:,0,:,:)

; Set up some trig constants
phi = lat*PI/180.0      ; Get latitude in radians
cphi = cos(phi)
c2phi = cphi * cphi
acphi = a * cos(phi)
asphi = a * sin(phi)
f = 2*omega*sin(phi)
a2 = a*a
f2 = f * f

; Calculate Ucos(phi)

Ucphi = U * conform(U,cphi,1)
copy_VarCoords(U,Ucphi)

; Calculate d/dphi (Ucphi)
dUcphidphi = center_finite_diff_n(Ucphi(time|:,latitude|:,longitude|:),phi,False,0,1)

; Calculate 1/cphi * dUcphi/dphi
tempdUcphidphi = dUcphidphi / conform(dUcphidphi,cphi,1)
; Calculate meridional gradient of this

d2Uetcdphi = center_finite_diff_n(tempdUcphidphi,phi,False,0,1)

; Calculate BetaM

BetaM1 = 2.0 * omega * c2phi / a

; Correction on 22nd Aug 2019: c2phi to cphi
; Mostly this only impacts higher latitudes
;BetaM2 = d2Uetcdphi * conform(d2Uetcdphi,c2phi,1) / a2
BetaM2 = d2Uetcdphi * conform(d2Uetcdphi,cphi,1) / a2

BetaM = conform(BetaM2,BetaM1,1) - BetaM2

; Calculate inverse of U
Uinv = 1. / where(U.ne.0, U, U@_FillValue) 

; Calculate Ks = (a^2 cos(phi) * BetaM / U)^0.5
Ks2 = conform(BetaM,a2,-1) * conform(BetaM,cphi,1) * BetaM * Uinv
Ks = sqrt(Ks2)

delete("BetaM1")
delete("BetaM2")
delete("Uinv")
delete("d2Uetcdphi")
delete("tempdUcphidphi")
delete("Ucphi")
delete("U")
;Ks!0 = "time"
;Ks!1 = "lat"
;Ks!2 = "lon"

;Ks@time = times
;Ks@lat = lat
;Ks@lon = lon	

copy_VarCoords(U,Ks)
copy_VarCoords(U,Ks2)
copy_VarCoords(Ks,BetaM)

;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------
; allow large variables
setfileoption("nc","format","netcdf4")

filo = "Ks_" + file_prefix
system("/bin/rm -f " + Dir + filo)
fout_std = addfile(Dir + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)
print("created it")
filedimdef(fout_std,(/"time","latitude","longitude"/),(/ntimes,nlat,nlon/),(/True,False,False/))
filevardef(fout_std,"Ks",typeof(Ks),getvardims(Ks))
filevardef(fout_std,"Ks2",typeof(Ks2),getvardims(Ks2))
filevardef(fout_std,"latitude",typeof(lat),(/"latitude"/))
filevardef(fout_std,"longitude",typeof(lon),(/"longitude"/))
filevardef(fout_std,"time",typeof(times),(/"time"/))

fAtt@history = "created by Calc_Btp_Ks_daily_generic.ncl on " + systemfunc("date")

;filevardef(fout_std,"U",typeof(U),getvardims(U))
fout_std->Ks = (/Ks/)
fout_std->Ks2 = (/Ks2/)
fout_std->latitude = (/lat/)
fout_std->longitude = (/lon/)
fout_std->time = (/times/)

print("printed it")

end
