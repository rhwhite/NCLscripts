load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Calculate EP fluxes on a daily basis and then take the average.
; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates
; Plots the EP Flux vectors in a latitude-log(pressure) coordinate
; plot the divergence of EP-Flux

undef("printEP")
function printEP_stat(Dir,filo:string,U,V,THETA,level)
begin

    a = 6.37122e06  ; radius of Earth
    PI = 3.14159265358979
    omega =  7.2921e-5
    g = 9.80616
    P0 = 1000.0

    ; Calculate zonal mean TH
    THETAzm = dim_avg_Wrap(THETA)
    lat = THETAzm&lat

    ; Calculate d(THETA)/dp from vertical finite differences in
    ; log-pressure coordinates
    ; noting that dT/dp = (1/p) * dT/d(lnp)
    loglevel = log(level)

    THETAp = center_finite_diff_n(THETAzm(lev_int|:,lat|:),loglevel,False,0,1) 
                    ;derivative in log coords doesn't care whether in Pa or in mb.
    ;        THETAp = THETAp / conform(THETAp,100.0 * level,0) 
    ; converts "level" to pascals from millibars while dividing by pressure.
    THETAp = THETAp/conform(THETAp,100.0 * level,0)

    copy_VarMeta(THETAzm,THETAp)
    ; za stands for zonal anomaly
    ;THETAp!2="lat"
    ; zm stands for zonal mean

    Uzm = dim_avg_n_Wrap(U(lev_int|:,lat|:,lon|:),2)

    Uza = dim_rmvmean_Wrap(U(lev_int|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    Vza = dim_rmvmean_Wrap(V(lev_int|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    THETAza = dim_rmvmean_Wrap(THETA(lev_int|:,lat|:,lon|:))

    UV = Uza * Vza
    copy_VarMeta(Uza,UV)
    UVzm = dim_avg_n_Wrap(UV(lev_int|:,lat|:,lon|:),2) 
                                            ; averages over longitude dimension

    VTHETA = Vza * THETAza
    copy_VarCoords(Vza,VTHETA)
    VTHETAzm = dim_avg_n_Wrap(VTHETA(lev_int|:,lat|:,lon|:),2) 
                                         ;average over longitude dimension
    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    sphi = sin(phi)
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    f = 2*omega*sin(phi)

    latfac = acphi * cos(phi)

    Fphi = -UVzm*conform(UVzm,latfac,1)
    
    Fp = conform(VTHETAzm,f*acphi,1) * VTHETAzm/THETAp

    copy_VarMeta(UVzm,Fphi)
    copy_VarMeta(VTHETAzm,Fp)
    
    ; take derivative with respect to latitude using 1/[a cos(phi)] d/dphi
    ; [cos(phi)*X] = d/d[asin(phi)] (cos(phi) * X)
    ; note that Fphi already has an extra factor of cos(phi)

    EPdiv1 = center_finite_diff_n(Fphi(lev_int|:,lat|:),asphi,False,0,1)

    ; take derivate with respect to pressure
    ; Pressure in pascals
    EPdiv2 = center_finite_diff_n(Fp(lev_int|:,lat|:),level*100.0,False,0,0)
    ; Convert to pa from hpa

    ; Add together derivative components
    EPdiv = EPdiv1 + EPdiv2

    copy_VarMeta(Fp,EPdiv)
    copy_VarMeta(Fp,EPdiv1)
    copy_VarMeta(Fp,EPdiv2)
    copy_VarMeta(Fp,Fphi)

    
    ; Compute acceleration from divF

    dudt = 86400.0 * EPdiv/conform(EPdiv,acphi,1);
    dudt@long_name = "acceleration from EP flux divergence"
    dudt@units = "m/s2"
    copy_VarCoords(EPdiv,dudt)

    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")
    print(Dir + filo)

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout_std,fAtt)

    fout_std->EPdiv = EPdiv
    fout_std->dudt = dudt
    fout_std->Fp = Fp
    fout_std->Fphi = Fphi
    fout_std->EPdiv1 = EPdiv1
    fout_std->EPdiv2 = EPdiv2
    fout_std->VTHETAzm = VTHETAzm
    fout_std->VTHETA = VTHETA
    fout_std->THETAp = THETAp

    return(1)

end
