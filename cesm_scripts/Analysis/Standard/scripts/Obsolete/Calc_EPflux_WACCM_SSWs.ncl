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

Dir = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_CTL/atm/hist/SSWs/"

print("Calc Rossby Refractive Index")

filenames = (/"pre51","pre41","pre31","pre1","pre2","pre3","pre4","dur","post","whole"/)
nfiles = dimsizes(filenames)
print(nfiles)

do i = 0,nfiles-1
    var = filenames(i)

    cdf_fileU = addfile(Dir + "U" + var + "_ZM.nc","r")
    cdf_fileT = addfile(Dir + "T" + var + "_ZM.nc","r")
    cdf_fileZ = addfile(Dir + "Z" + var + "_ZM.nc","r")

    cdf_fileU_daily = addfile(Dir + "U" + var + "_ZM_daily.nc","r")
    cdf_fileT_daily = addfile(Dir + "T" + var + "_ZM_daily.nc","r")
    cdf_fileZ_daily = addfile(Dir + "Z" + var + "_ZM_daily.nc","r")

    ; get pressure levels

    level = cdf_fileU->lev_p		; in hpa, or mb
    level!0="lev_p"
    lat = cdf_fileU->lat
    lat!0="lat"

    U = cdf_fileU->U
    T = cdf_fileT->T
    Z = cdf_fileZ->Z

    Udaily = cdf_fileU_daily->U
    Tdaily = cdf_fileT_daily->T
    Zdaily = cdf_fileZ_daily->Z


    ; Set up filename
    fileo = Dir + "/Ks" + var + "_ZM.nc" 
    system("/bin/rm -f " + fileo)

    ; Call CalcZMKs
    ;Calc TH

    lev_id = 1

    TH = T*((1000.0/conform(T,level,lev_id))^0.286)
    copy_VarCoords(T,TH)

    returned = calcZMKs(U,TH,Z,level,lat,fileo)
    ;print(returned)

    ; Calculate time mean
    Uclim = dim_avg_n_Wrap(U,0)
    THclim = dim_avg_n_Wrap(TH,0) 
    Zclim = dim_avg_n_Wrap(Z,0) 

    ;set up filename
    fileo_clim = Dir + "/Ks" + var + "_ZM_clim.nc"
    system("/bin/rm -f " + fileo_clim)

    ; Call CalcZMKs
    returned = calcZMKs(Uclim,THclim,Zclim,level,lat,fileo_clim)
    ;print(returned)


    ; Repeat on daily data

    lev_id = 2

    THdaily = Tdaily*((1000.0/conform(Tdaily,level,lev_id))^0.286)
    copy_VarCoords(Tdaily,THdaily)

    ;set up filename
    fileo_daily = Dir + "/Ks" + var + "_ZM_daily.nc"
    system("/bin/rm -f " + fileo_daily)

    ; Call CalcZMKs


    returned = calcZMKs(Udaily,THdaily,Zdaily,level,lat,fileo_daily)
    ;print(returned)

    delete([/Udaily,Tdaily,THdaily,Zdaily/])

end do

end
