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

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/SSWs/"

filenames =(/"pre61","pre62","pre52","pre41","pre31","pre1","pre2","pre3","pre4","pre5","dur","post","whole"/)
nfiles = dimsizes(filenames)

; loop over each variable separately
do i = 0,nfiles-1
    var = filenames(i)
    print(var)

    cdf_fileU = addfile(Dir + "U" + var + "ERAI.nc","r")
    cdf_fileT = addfile(Dir + "T" + var + "ERAI.nc","r")
    cdf_fileZ = addfile(Dir + "Z" + var + "ERAI.nc","r")

    U = cdf_fileU->U
    T = cdf_fileT->T
    Z = cdf_fileZ->Z

    ; get pressure levels

    level = cdf_fileU->level		; in hpa, or mb
    level!0="level"
    nlevs = dimsizes(level)
    lat = tofloat(cdf_fileU->latitude)
    lat!0="latitude"
    lon = tofloat(cdf_fileU->longitude)
    lon!0="longitude"

    nlat = filevardimsizes(cdf_fileU,"latitude")
    nlon = filevardimsizes(cdf_fileU,"longitude")

    ; Set up filename
    fileo = Dir + "/Ks" + var + "_ZM.nc"
    system("/bin/rm -f " + fileo)

    ; Call CalcZMKs

    ; Calculate means over time
    ;time_id = 1
    ;Utm = dim_avg_n_Wrap(U,time_id)
    ;Ttm = dim_avg_n_Wrap(T,time_id)
    ;Ztm = dim_avg_n_Wrap(Z,time_id)

    ;Calc TH

    lev_id = 1
    TH = T*((1000.0/conform(T,level,lev_id))^0.286)
    copy_VarCoords(T,TH)

    ; Calculate zonal mean
    lon_id = 3
    U_zm = dim_avg_n_Wrap(U,lon_id)
    TH_zm = dim_avg_n_Wrap(TH,lon_id)
    Z_zm = dim_avg_n_Wrap(Z,lon_id)

    returned = calcZMKs(U_zm,TH_zm,Z_zm,level,lat,fileo)
    if returned .ne. 1 then
        print("error in calcZMKs")
        print(returned)
    end if
    delete([/U_zm,Z_zm,TH_zm,U,T,Z,TH/])
end do

end
