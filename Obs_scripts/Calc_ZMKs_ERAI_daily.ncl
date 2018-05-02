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

print("Calc Rossby Refractive Index")

startyr=1980
endyr=2015
nyears = endyr-startyr+1

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/"

; loop over each year separately as this is how raw data is
do iyear = startyr,endyr
    print(tostring(iyear))
    filein = "daily_" + tostring(iyear) + ".nc"

    cdf_file = addfile(Dir + "ERAI_U_TH_Z_" + filein,"r")

    ; get pressure levels

    level = cdf_file->level		; in hpa, or mb
    level!0="level"
    lat = tofloat(cdf_file->latitude)
    lat!0="latitude"
    lon = tofloat(cdf_file->longitude)
    lon!0="longitude"

    U = cdf_file->u(:,:,:,:)
    T = cdf_file->t(:,:,:,:)
    Z = cdf_file->z(:,:,:,:)/9.81

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

    delete([/Uzm,Zzm,THzm,U,T,Z,TH/])
end do

end
