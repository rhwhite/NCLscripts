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

Dir = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_CTL/atm/hist/"

print("Calc Rossby Refractive Index")

cdf_fileU = addfile(Dir + "zonalmean_U_WACCM_f19_CTL.cam2.h2.0002-0041.nc","r")
cdf_fileT = addfile(Dir + "zonalmean_T_WACCM_f19_CTL.cam2.h2.0002-0041.nc","r")
cdf_fileZ = addfile(Dir + "zonalmean_Z3_WACCM_f19_CTL.cam2.h2.0002-0041.nc","r")
; get pressure levels

level = cdf_fileU->lev_p		; in hpa, or mb
level!0="lev_p"
lat = cdf_fileU->lat
lat!0="lat"
time = cdf_fileU->time

U = cdf_fileU->U
T = cdf_fileT->T
Z = cdf_fileZ->Z3

; Set up filename
fileo = Dir + "/ZMKs_daily_2-41.nc" 
system("/bin/rm -f " + fileo)

; Call CalcZMKs
;Calc TH

lev_id = 1

TH = T*((1000.0/conform(T,level,lev_id))^0.286)
copy_VarCoords(T,TH)

returned = calcZMKs(U,TH,Z,level,lat,fileo)
print(returned)

; Calculate time mean
Uclim = dim_avg_n_Wrap(U,0)
THclim = dim_avg_n_Wrap(TH,0)
Zclim = dim_avg_n_Wrap(Z,0)

;set up filename
fileo_clim = Dir + "/ZMKs_daily_clim_2-41.nc"
system("/bin/rm -f " + fileo_clim)

; Call CalcZMKs
returned = calcZMKs(Uclim,THclim,Zclim,level,lat,fileo_clim)
;print(returned)




end
