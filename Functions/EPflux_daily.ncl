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

undef("printEPdaily")
function printEPdaily(Dir,filo:string,U,V,THETA,level)
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

    THETAp = center_finite_diff_n(THETAzm(time|:,lev_p|:,lat|:),loglevel,False,0,1) 
                    ;derivative in log coords doesn't care whether in Pa or in mb.
    ;        THETAp = THETAp / conform(THETAp,100.0 * level,1) 
    ; converts "level" to pascals from millibars while dividing by pressure.
    THETAp = center_finite_diff_n(THETAzm(time|:,lev_p|:,lat|:),level*100.0,False,0,1) ;

    copy_VarMeta(THETAzm,THETAp)
    ; za stands for zonal anomaly
    ;THETAp!2="lat"
    ; zm stands for zonal mean

    Uzm = dim_avg_n_Wrap(U(time|:,lev_p|:,lat|:,lon|:),3)

    Uza = dim_rmvmean_Wrap(U(time|:,lev_p|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    Vza = dim_rmvmean_Wrap(V(time|:,lev_p|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    THETAza = dim_rmvmean_Wrap(THETA(time|:,lev_p|:,lat|:,lon|:))

    UV = Uza * Vza
    copy_VarMeta(Uza,UV)
    UVzm = dim_avg_n_Wrap(UV(time|:,lev_p|:,lat|:,lon|:),3) 
                                            ; averages over longitude dimension
;    UVzmtm = dim_avg_n_Wrap(UVzm(time|:,lev_p|:,lat|:),0)   
;                                            ; average over time dimension

    VTHETA = Vza * THETAza
    copy_VarCoords(Vza,VTHETA)
    VTHETAzm = dim_avg_n_Wrap(VTHETA(time|:,lev_p|:,lat|:,lon|:),3) 
                                         ;average over longitude dimension
;    VTHETAzmtm = dim_avg_n_Wrap(VTHETAzm(time|:,lev_p|:,lat|:),0)   
;                                        ; average over time dimension

;    THETAptm = dim_avg_n_Wrap(THETAp(time|:,lev_p|:,lat|:),0)          
;                                        ; time mean of THETAp
    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    sphi = sin(phi)
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    f = 2*omega*sin(phi)

    Fphi = -UVzm*conform(UVzm,acphi,2)
    Fx = -UVzm
    Fphicphi = Fphi * conform(Fphi,cphi,2)
    Fp = conform(VTHETAzm,f*acphi,2) * VTHETAzm/THETAp
    Fpxy = conform(VTHETAzm,f,2) * VTHETAzm/THETAp

    FphiBEH = (1.0 / P0) * conform(Fphi,level,1) * Fphi
    FpBEH = (1.0/P0) * conform(Fp,level,1) * Fp

    copy_VarMeta(UVzm,Fphi)
    copy_VarMeta(UVzm,FphiBEH)
    copy_VarMeta(UVzm,Fx)
    copy_VarMeta(VTHETAzm,Fp)
    copy_VarMeta(VTHETAzm,FpBEH)
    copy_VarMeta(VTHETAzm,Fpxy)
    
    ; take derivative with respect to latitude using 1/[a cos(phi)] d/dphi
    ; [cos(phi)*X] = d/d[asin(phi)] (cos(phi) * X)

    Fphicphi = Fphi * conform(Fphi,cphi,2)
    FphiBEHcphi = FphiBEH * conform(FphiBEH,cphi,2)
    copy_VarMeta(Fphi,Fphicphi)
    copy_VarMeta(Fphi,FphiBEHcphi)

    EPdiv1 = center_finite_diff_n(Fphicphi(time|:,lev_p|:,lat|:),phi,False,0,2)/conform(Fphicphi,acphi,2)

    EPdivBEH1 = center_finite_diff_n(FphiBEHcphi(time|:,lev_p|:,lat|:),phi,False,0,2)/conform(Fphicphi,acphi,2)

    latdist = gc_latlon(lat(40),0,lat(41),0,1,3) ; in m

    EPdiv1xy = center_finite_diff_n(Fx(time|:,lev_p|:,lat|:),latdist,False,0,2)

    ; take derivate with respect to pressure
    ; Pressure in pascals
    EPdiv2 = center_finite_diff_n(Fp(time|:,lev_p|:,lat|:),level*100.0,False,0,1)
    ; Convert to pa from hpa
    EPdivBEH2 = center_finite_diff_n(FpBEH(time|:,lev_p|:,lat|:),level*100.0,False,0,1)  

    EPdiv2xy = center_finite_diff_n(Fpxy(time|:,lev_p|:,lat|:),level*100.0,False,0,1)

    ; Add together derivative components
    EPdiv = EPdiv1 + EPdiv2
    EPdivxy = EPdiv1xy + EPdiv2xy
    EPdivBEH = EPdivBEH1 + EPdivBEH2


    copy_VarMeta(Fp,EPdiv)
    copy_VarMeta(Fp,EPdiv1)
    copy_VarMeta(Fp,EPdiv2)
    copy_VarMeta(Fp,EPdivxy)
    copy_VarMeta(Fp,EPdivBEH)
    copy_VarMeta(Fp,Fphi)

    
    ; Compute acceleration from divF

    dudt = 86400.0 * EPdiv/conform(EPdiv,acphi,2);
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


    fout_std->EPdiv_tm = dim_avg_n_Wrap(EPdiv(time|:,lev_p|:,lat|:),0)
    fout_std->dudt_tm = dim_avg_n_Wrap(dudt(time|:,lev_p|:,lat|:),0)
    fout_std->Fp_tm = dim_avg_n_Wrap(Fp(time|:,lev_p|:,lat|:),0)
    fout_std->Fphi_tm = dim_avg_n_Wrap(Fphi(time|:,lev_p|:,lat|:),0)

    return(1)

end
