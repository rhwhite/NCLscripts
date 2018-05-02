load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"


; Code to calculate Rossby stationary wave number, following Hoskins and Ambrizzi 1993. 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

; Get experiment names

startyr=1979
endyr=2015
nyears = endyr-startyr+1

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Monthly/"

filein = "pl_DJF_monthly_1980-2015.nc"

print("Calc Rossby Refractive Index")

cdf_fileU = addfile(Dir + "ERAI_U_" + filein,"r")
cdf_fileT = addfile(Dir + "ERAI_T_" + filein,"r")
cdf_fileZ = addfile(Dir + "ERAI_Z_" + filein,"r")

; get pressure levels

level = cdf_fileU->level		; in hpa, or mb
level!0="level"
lat = tofloat(cdf_fileU->latitude)
lat!0="latitude"
lon = tofloat(cdf_fileU->longitude)
lon!0="longitude"

U = cdf_fileU->u(:,:,:,:)
T = cdf_fileT->t(:,:,:,:)
Z = cdf_fileZ->z(:,:,:,:)/9.81

; Set up filename
fileo = Dir + "/ERAI_Ks_" + filein
system("/bin/rm -f " + fileo)

; Call CalcZMKs
;Calc TH

lev_id = 1
lon_id = 3

TH = T*((1000.0/conform(T,level,lev_id))^0.286)
copy_VarCoords(T,TH)

; Calc ZMs
Uzm = dim_avg_n_Wrap(U,lon_id) ; get zonal mean U
Zzm = dim_avg_n_Wrap(Z,lon_id) ; get zonal mean Z
THzm = dim_avg_n_Wrap(TH,lon_id) ; get zonal mean TH

returned = calcZMKs(Uzm,THzm,Zzm,level,lat,fileo)

print(returned)

; Calculate time mean
Uclim = dim_avg_n_Wrap(Uzm,0)
THclim = dim_avg_n_Wrap(THzm,0) 
Zclim = dim_avg_n_Wrap(Zzm,0) 

;set up filename
fileo_clim = Dir + "/ERAI_Ks_Clim" + filein
system("/bin/rm -f " + fileo_clim)

; Call CalcZMKs


returned = calcZMKs(Uclim,THclim,Zclim,level,lat,fileo_clim)

print(returned)

end
