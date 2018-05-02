load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

undef("calcFullKs")
function calcFullKs(U,TH,Z,levels,lat,filo)

; Code to calculate Rossby stationary wave number, including vertical
; propagation, following Hu and Tung 2002
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (dq/dphi)/u - (f/2NH)2
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a

begin
   ; Set up some constants
    a = 6.37122e06  ; radius of Earth
    PI = 3.14159265358979

    cp = 1.00464e3
    Rd = 287.0
    kappa = (Rd/cp)
    omega =  7.2921e-5
    g = 9.80616

    ; Calculate sines and cosines etc
    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    c2phi = cphi * cphi
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    a2 = a*a

    ; get dims
    dimNames = getvardims(U)
    ndims =dimsizes(dimNames)

    if ndims .eq. 3 then
        levid = 0
        latid = 1
        lonid = 2
    else if ndims .eq. 4 then
        timeid = 0
        levid = 1
        latid = 2
        lonid = 3
    else if ndims .eq. 5 then
        timeid = 1
        levid = 2
        latid = 3
        lonid = 4
    else
        print(ndims)
        print("wrong number of dimensions, need at least 3, and not expecting more than 5!")
        print("make sure you're not passing zonal means")
        return(0)
    end if
    end if
    end if

    if dimNames(latid) .eq. "lat" .or. dimNames(latid) .eq. "latitude" .or. dimNames(latid) .eq. "lats" .or. dimNames(latid) .eq. "Latitude" then
        continue
    else
        print(dimNames(latid))
        print("this should be latitude! Your file dimensions are out of order or your latitude dimension is named differently to expected")
        return(0)
    end if

    if dimNames(lonid) .eq. "lon" .or. dimNames(lonid) .eq. "longitude" .or. dimNames(lonid) .eq. "lons" .or. dimNames(lonid) .eq. "Longitude" then
        continue
    else
        print(dimNames(lonid))
        print("this should be longitude! Your file dimensions are out of order or your longitude dimension is named differently to expected")
        return(0)
    end if

    if dimNames(levid) .eq. "plev" .or. dimNames(levid) .eq. "lev_p" .or.dimNames(levid) .eq. "levels" .or. dimNames(levid) .eq. "level" then
        continue
    else
        print(dimNames(levid))
        print("this should be levels! Your file dimensions are out of order or your levels dimension is named differently to expected")
        return(0)
    end if

    ; Calculate coriolis parameter
    f = 2*omega*sin(phi)
    f2 = conform(U,f * f,latid)

    ; Calculate Ucos(phi)
    Ucphi = U * conform(U,cphi,latid)
    copy_VarCoords(U,Ucphi)

    ; Calculate d/dphi (Ucphi)
    dUcphidphi = center_finite_diff_n(Ucphi,phi,False,0,latid)

    ; Calculate 1/cphi * dUcphi/dphi
    tempdUcphidphi = dUcphidphi / conform(dUcphidphi,cphi,latid)

    ; Calculate meridional gradient of this
    d2Uetcdphi = center_finite_diff_n(tempdUcphidphi,phi,False,0,latid)

    ; Calculate N and H
    ; Calculate buoyancy freqency, N^2
    ; Should use geometric height, but estimating this as geopotential height:
    ; http://glossary.ametsoc.org/wiki/Geopotential_height
    ; states that the two are numerically interchangeable for most
    ; meteorological purposes

    dTHdZ = center_finite_diff_n(TH,Z,False,0, levid)
    copy_VarCoords(TH,dTHdZ)

    N2 = (g/TH) * dTHdZ ; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5

    dN2dz = center_finite_diff_n(N2,Z,False,0,levid)

    H = 8000.0

    ; Calculate stretching term
    dUdz = center_finite_diff_n(U,Z,False,0,levid)
    d2Udz2 = center_finite_diff_n(dUdz,Z,False,0,levid)

    ; Calculate Ks terms

    q1 = conform(U,2.0 * omega * cphi / a,latid)
    q2 = d2Uetcdphi / a2
    q3 = (f2/(H * N2) + (f2 / (N2 * N2)) * dN2dz) * dUdz
    q4 = - (f2/N2) * d2Udz2
    q5 = (f2/(4 * N2 * H * H))

    ; Calculate Ks
    ; for safety, get rid of any 0 values in U
    U = where(U.eq.0, U@_FillValue, U)

    ; Jul 10 2017 corrected bug in minus sign of q3 and q4
    Ks2 = 1/U * (q1 - q2 + q3 + q4) - q5

    Ks2a2 = Ks2 * a2

    Ks = sqrt(Ks2a2)

    ;Ks_Uterms = sqrt((1/U) * ((q1-q2) * a2))

    ;Ks_dqterm = sqrt((1/10.0) * ((q1-q2+q3+q4) * a2))
    ;Ks_dqUterm = sqrt((1/U) * ((q1-q2+q3+q4) * a2))
    ;Ks_dudzterm = sqrt((1/10.0 * (q3) * a2))
    ;Ks_qaterm = ((q1-q2+q3+q4) * a2)
    ;Ks_Uterm = 1/U

    copy_VarCoords(U,Ks)

    copy_VarCoords(Ks,Ks2)
    copy_VarCoords(Ks,N2)
    copy_VarCoords(Ks,Ks2a2)
    copy_VarCoords(Ks,q1)
    copy_VarCoords(Ks,q2)
    copy_VarCoords(Ks,q3)
    copy_VarCoords(Ks,q4)
    copy_VarCoords(Ks,q5)

    ;----------------------------------------------------------------------
    ; Write out results to a new netcdf file
    ;-----------------------------------------------------------------------

    fout_std = addfile(filo, "c")
    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fAtt@history = "created by CalcFullKs.ncl"
    fileattdef(fout_std,fAtt)

    fout_std->U = U
    fout_std->Ksa = Ks
    fout_std->N2 = N2
    fout_std->Ks2a2 = Ks2a2
    ;fout_std->q1 = q1
    ;fout_std->q2 = q2
    ;fout_std->q3 = q3
    ;fout_std->q4 = q4
    ;fout_std->q5 = q5

    return(1)

end


undef("calcZMKs")
function calcZMKs(U,TH,Z,levels,lat,filo)

; Code to calculate Rossby stationary wave number, including vertical
; propagation, following Hu and Tung 2002
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (dq/dphi)/u - (f/2NH)2
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a

begin
   ; Set up some constants
    a = 6.37122e06  ; radius of Earth
    PI = 3.14159265358979

    cp = 1.00464e3
    Rd = 287.0
    kappa = (Rd/cp)
    omega =  7.2921e-5
    g = 9.80616

    ; Calculate sines and cosines etc
    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    c2phi = cphi * cphi
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    a2 = a*a

    ; get dims
    dimNames = getvardims(U)
    ndims =dimsizes(dimNames)

    if ndims .eq. 2 then
        levid = 0
        latid = 1
    else if ndims .eq. 3 then
        timeid = 0
        levid = 1
        latid = 2
    else if ndims .eq. 4 then
        timeid = 1
        levid = 2
        latid = 3
    else
        print(ndims)
        print("wrong number of dimensions, need at least 3, and not expecting more than 4!")
        print("make sure you pass zonal means")
        return(0)
    end if
    end if
    end if

    if dimNames(latid) .eq. "lat" .or. dimNames(latid) .eq. "latitude" .or. dimNames(latid) .eq. "lats" .or. dimNames(latid) .eq. "Latitude" then
        continue
    else
        print(dimNames(latid))
        print("this should be latitude! Your file dimensions are out of order or your latitude dimension is named differently to expected")
        return(0)
    end if

    if dimNames(levid) .eq. "plev" .or. dimNames(levid) .eq. "lev_p" .or.dimNames(levid) .eq. "levels" .or. dimNames(levid) .eq. "level" then
        continue
    else
        print(dimNames(levid))
        print("this should be levels! Your file dimensions are out of order or your levels dimension is named differently to expected")
        return(0)
    end if 

    ; Calculate coriolis parameter
    f = 2*omega*sin(phi)
    f2 = conform(U,f * f,latid)

    ; Calculate Ucos(phi)
    Ucphi = U * conform(U,cphi,latid)
    copy_VarCoords(U,Ucphi)

    ; Calculate d/dphi (Ucphi)
    dUcphidphi = center_finite_diff_n(Ucphi,phi,False,0,latid)

    ; Calculate 1/cphi * dUcphi/dphi
    tempdUcphidphi = dUcphidphi / conform(dUcphidphi,cphi,latid)

    ; Calculate meridional gradient of this
    d2Uetcdphi = center_finite_diff_n(tempdUcphidphi,phi,False,0,latid)

    ; Calculate N and H

    ; Calculate buoyancy freqency, N^2
    ; Should use geometric height, but estimating this as geopotential height:
    ; http://glossary.ametsoc.org/wiki/Geopotential_height
    ; states that the two are numerically interchangeable for most
    ; meteorological purposes

    dTHdZ = center_finite_diff_n(TH,Z,False,0, levid)
    copy_VarCoords(TH,dTHdZ)

    N2 = (g/TH) * dTHdZ ; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5

    dN2dz = center_finite_diff_n(N2,Z,False,0,levid)

    H = 8000.0

    ; Calculate stretching term
    dUdz = center_finite_diff_n(U,Z,False,0,levid)
    d2Udz2 = center_finite_diff_n(dUdz,Z,False,0,levid)

    ; Calculate Ks terms

    q1 = conform(U,2.0 * omega * cphi / a,latid)
    q2 = d2Uetcdphi / a2
    q3 = (f2/(H * N2) + (f2 / (N2 * N2)) * dN2dz) * dUdz
    q4 = - (f2/N2) * d2Udz2
    q5 = (f2/(4 * N2 * H * H))

    ; Calculate Ks
    ; for safety, get rid of any 0 values in U
    U = where(U.eq.0, U@_FillValue, U)

    ; Jul 10 2017 corrected bug in minus sign of q3 and q4
    Ks2 = 1/U * (q1 - q2 + q3 + q4) - q5

    Ks2a2 = Ks2 * a2

    Ks = sqrt(Ks2a2)

    ;Ks_Uterms = sqrt((1/U) * ((q1-q2) * a2))

    ;Ks_dqterm = sqrt((1/10.0) * ((q1-q2+q3+q4) * a2))
    ;Ks_dqUterm = sqrt((1/U) * ((q1-q2+q3+q4) * a2))
    ;Ks_dudzterm = sqrt((1/10.0 * (q3) * a2))
    ;Ks_qaterm = ((q1-q2+q3+q4) * a2)
    ;Ks_Uterm = 1/U

    copy_VarCoords(U,Ks)
    
    copy_VarCoords(Ks,Ks2)
    copy_VarCoords(Ks,N2)
    copy_VarCoords(Ks,Ks2a2)
    copy_VarCoords(Ks,q1)
    copy_VarCoords(Ks,q2)
    copy_VarCoords(Ks,q3)
    copy_VarCoords(Ks,q4)
    copy_VarCoords(Ks,q5)

    ;----------------------------------------------------------------------
    ; Write out results to a new netcdf file
    ;-----------------------------------------------------------------------

    fout_std = addfile(filo, "c")

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fAtt@history = "created by Calc_ZMKs.ncl"
    fileattdef(fout_std,fAtt)

    fout_std->U = U
    fout_std->Ksa = Ks
    fout_std->N2 = N2
    fout_std->Ks2a2 = Ks2a2
    fout_std->q1 = q1
    fout_std->q2 = q2
    fout_std->q3 = q3
    fout_std->q4 = q4
    fout_std->q5 = q5

    return(1)

end

undef("printEP")
function printEP(Dir,filo:string,U,V,THETA,level)
; Calculate EP fluxes on a daily basis and then take the average.
; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates

begin

    a = 6.37122e06  ; radius of Earth
    PI = 3.14159265358979
    omega =  7.2921e-5
    g = 9.80616
    P0 = 1000.0

    ; Calculate zonal mean TH
    THETAzm = dim_avg_Wrap(THETA)
    lat = THETAzm&lat

    ; Calculate d(THETA)/dp on time mean fields from vertical finite differences in
    ; log-pressure coordinates
    ; noting that dT/dp = (1/p) * dT/d(lnp)
    loglevel = log(level)

    THETAp = center_finite_diff_n(THETAzm(time|:,lev_int|:,lat|:),loglevel,False,0,1)
                    ;derivative in log coords doesn't care whether in Pa or in mb.
    ;        THETAp = THETAp / conform(THETAp,100.0 * level,1)
    ; converts "level" to pascals from millibars while dividing by pressure.
    THETAp = THETAp/conform(THETAp,100.0 * level,1)

    copy_VarMeta(THETAzm,THETAp)
    ; za stands for zonal anomaly
    ;THETAp!2="lat"
    ; zm stands for zonal mean

    Uzm = dim_avg_n_Wrap(U(time|:,lev_int|:,lat|:,lon|:),3)

    Uza = dim_rmvmean_Wrap(U(time|:,lev_int|:,lat|:,lon|:))
                                        ; removes mean of rightmost dimension
    Vza = dim_rmvmean_Wrap(V(time|:,lev_int|:,lat|:,lon|:))
                                        ; removes mean of rightmost dimension
    THETAza = dim_rmvmean_Wrap(THETA(time|:,lev_int|:,lat|:,lon|:))

    UV = Uza * Vza
    copy_VarMeta(Uza,UV)
    UVzm = dim_avg_n_Wrap(UV(time|:,lev_int|:,lat|:,lon|:),3)
                                            ; averages over longitude dimension

    VTHETA = Vza * THETAza
    copy_VarCoords(Vza,VTHETA)
    VTHETAzm = dim_avg_n_Wrap(VTHETA,3)
                                         ;average over longitude dimension
    VTHETAzm = dim_avg_n_Wrap(VTHETA,3)
                                         ;average over longitude dimension

    THETAptm = dim_avg_n_Wrap(THETAp,0) ; average over time


    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    sphi = sin(phi)
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    f = 2*omega*sin(phi)

    latfac = acphi * cos(phi)

    Fphi = -UVzm*conform(UVzm,latfac,2)

    Fp_orig = conform(VTHETAzm,f*acphi,2) * VTHETAzm/THETAp
    Fp = conform(VTHETAzm,f*acphi,2) * VTHETAzm/conform(VTHETAzm,THETAptm,(/1,2/))

    copy_VarMeta(UVzm,Fphi)
    copy_VarMeta(VTHETAzm,Fp)

    ; take derivative with respect to latitude using 1/[a cos(phi)] d/dphi
    ; [cos(phi)*X] = d/d[asin(phi)] (cos(phi) * X)
    ; note that Fphi already has an extra factor of cos(phi)

    EPdiv1 = center_finite_diff_n(Fphi(time|:,lev_int|:,lat|:),asphi,False,0,2)

    ; take derivate with respect to pressure
    ; Pressure in pascals
    EPdiv2 = center_finite_diff_n(Fp(time|:,lev_int|:,lat|:),level*100.0,False,0,1)
    ; Convert to pa from hpa

    ; Add together derivative components
    EPdiv = EPdiv1 + EPdiv2

    copy_VarMeta(Fp,EPdiv)
    copy_VarMeta(Fp,EPdiv1)
    copy_VarMeta(Fp,EPdiv2)
    copy_VarMeta(Fp,Fphi)


    ; Compute acceleration from divF

    dudt = 86400.0 * EPdiv/conform(EPdiv,acphi,2);
    dudt@long_name = "acceleration from EP flux divergence"
    dudt@units = "m/s2"
    copy_VarCoords(EPdiv,dudt)

    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    setfileoption("nc","format","netcdf4classic")

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
    fout_std->Fp_orig = Fp_orig
    fout_std->Fphi = Fphi
    fout_std->EPdiv1 = EPdiv1
    fout_std->EPdiv2 = EPdiv2
    fout_std->VTHETAzm = VTHETAzm
    fout_std->VTHETA = VTHETA
    fout_std->THETAp = THETAp

    fout_std->EPdiv_tm = dim_avg_n_Wrap(EPdiv(time|:,lev_int|:,lat|:),0)
    fout_std->dudt_tm = dim_avg_n_Wrap(dudt(time|:,lev_int|:,lat|:),0)
    fout_std->Fp_tm = dim_avg_n_Wrap(Fp(time|:,lev_int|:,lat|:),0)
    fout_std->Fphi_tm = dim_avg_n_Wrap(Fphi(time|:,lev_int|:,lat|:),0)

    return(1)

end
