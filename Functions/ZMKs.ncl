load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Code to calculate Rossby stationary wave number, including vertical
; propagation, following Hu and Tung 2002
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (dq/dphi)/u - (f/2NH)2
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a

undef("calcZMKs")
function calcZMKs(U,T,Z,lat,filo)
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
    f = 2*omega*sin(phi)
    a2 = a*a
    f2 = conform(U,f * f,2)
    
    ; Calculate Ucos(phi)
    Ucphi = U * conform(U,cphi,2)
    copy_VarCoords(U,Ucphi)

    ; Calculate d/dphi (Ucphi)
    dUcphidphi = center_finite_diff_n(Ucphi(time|:,lev_p|:,lat|:),phi,False,0,2)

    ; Calculate 1/cphi * dUcphi/dphi
    tempdUcphidphi = dUcphidphi / conform(dUcphidphi,cphi,2)

    ; Calculate meridional gradient of this
    d2Uetcdphi = center_finite_diff_n(tempdUcphidphi,phi,False,0,2)

    ; Calculate N and H
    
    ; Calculate buoyancy freqency, N^2
    ; Should use geometric height, but estimating this as geopotential height:
    ; http://glossary.ametsoc.org/wiki/Geopotential_height
    ; states that the two are numerically interchangeable for most
    ; meteorological purposes

    dTHdZ = center_finite_diff_n(TH(time|:,lev_p|:,lat|:),Z,False,0, 1)
    copy_VarCoords(TH,dTHdZ)

    N2 = (g/TH) * dTHdZ ; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5

    dN2dz = center_finite_diff_n(N2,Z,False,0,1)

    H = 8000.0

    ; Calculate stretching term
    dUdz = center_finite_diff_n(U,Z,False,0,1)
    d2Udz2 = center_finite_diff_n(dUdz,Z,False,0,1)

    ; Calculate Ks terms

    q1 = conform(U,2.0 * omega * cphi / a,2)
    q2 = d2Uetcdphi / a2
    q3 = (f2/(H * N2) + (f2 / (N2 * N2)) * dN2dz) * dUdz
    q4 = - (f2/N2) * d2Udz2


    ; Calculate Ks
    ; for safety, get rid of any 0 values in U
    U = where(U.eq.0, U@_FillValue, U)

    ; Jul 10 2017 corrected bug in minus sign of q3 and q4
    Ks2 = 1/U * (q1 - q2 + q3 + q4) - (f2/(4 * N2 * H * H))

    Ks2a2 = Ks2 * a2

    Ks_dqterm = sqrt((1/10.0) * ((q1-q2+q3+q4) * a2))
    Ks_dqUterm = sqrt((1/U) * ((q1-q2+q3+q4) * a2))
    Ks_dudzterm = sqrt((1/10.0 * (q3) * a2))
    Ks_Uterm = 1/U
    Ks_qaterm = ((q1-q2+q3+q4) * a2)

    Ks = sqrt(Ks2a2)

    Ks!0 = "time"
    Ks!1 = "lev_p"
    Ks!2 = "lat"

    Ks@lev_p = level
    Ks@lat = lat

    copy_VarCoords(Ks,Ks2)
    copy_VarCoords(Ks,Ks2a2)
    copy_VarCoords(Ks,q1)
    copy_VarCoords(Ks,q2)
    copy_VarCoords(Ks,q3)
    copy_VarCoords(Ks,q4)
    copy_VarCoords(Ks,Ks_dqterm)
    copy_VarCoords(Ks,Ks_dqUterm)
    copy_VarCoords(Ks,Ks_dudzterm)
    copy_VarCoords(Ks,Ks_Uterm)
    copy_VarCoords(Ks,Ks_qaterm)

    ;----------------------------------------------------------------------
    ; Write out results to a new netcdf file
    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fAtt@history = "created by Calc_ZMKs.ncl"
    fileattdef(fout_std,fAtt)

    fout_std->U = U
    fout_std->Ks = Ks

    fout_std->Ks2 = Ks2
    fout_std->Ks2a2 = Ks2a2


