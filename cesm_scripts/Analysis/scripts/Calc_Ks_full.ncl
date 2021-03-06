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

; Get experiment names

print("Calc Rossby Refractive Index")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

timespans = (/"Annual","DJF","JJA","MAM","SON"/)
;timespan = getenv("NCL_season")
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

    timespan = timespans(ts)
    dimsexps = dimsizes(Experiments)
    nexps = dimsexps(0)

    do exps = 0,nexps-1
        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")
        print(Experiment)

        filenamepl = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
        ; open file with seasonal averages
        cdf_filepl = addfile(filenamepl,"r")

        ; get pressure levels

        level = cdf_filepl->lev_p		; in hpa, or mb
        level!0="lev_p"
        levsizes = dimsizes(level)
        nlevels = filevardimsizes(cdf_filepl,"lev_p")
        nlat = filevardimsizes(cdf_filepl,"lat")
        nlon = filevardimsizes(cdf_filepl,"lon")

        lat = tofloat(cdf_filepl->lat)
        lat!0="lat"
        lon = tofloat(cdf_filepl->lon)
        lon!0="lon"

        U = cdf_filepl->U(:,:,:,:)
        TH = cdf_filepl->TH(:,:,:,:)
        Z = cdf_filepl->Z3(:,:,:,:)
    ; Set up some constants
        phi = lat*PI/180.0      ; Get latitude in radians
        cphi = cos(phi)
        c2phi = cphi * cphi
        acphi = a * cos(phi)
        asphi = a * sin(phi)
        f = 2*omega*sin(phi)
        a2 = a*a
        f2 = f * f
        f2map = conform(U,f2,2)

    ; Calculate Ucos(phi)

        Ucphi = U * conform(U,cphi,2)
        copy_VarCoords(U,Ucphi)

    ; Calculate d/dphi (Ucphi)
        dUcphidphi = center_finite_diff_n(Ucphi(time|:,lev_p|:,lat|:,lon|:),phi,False,0,2)

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
    ; using TH instead of virtual TH (close to identical above the boundary
    ; layer)

        dTHdZ = center_finite_diff_n(TH(time|:,lev_p|:,lat|:,lon|:),Z,False,0, 1)
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

        q3 = (f2map/(H * N2) + (f2map / (N2 * N2)) * dN2dz) * dUdz

        q4 = - (f2map/N2) * d2Udz2

    ; Calculate Ks

        ; for safety, get rid of any 0 values in U
        U = where(U.eq.0, U@_FillValue, U)

        Ks2 = 1/U * (q1 - q2 + q3 + q4) - (f2map/(4 * N2 * H * H))

        Ks2a2 = Ks2 * a2

        Ks_dqterm = sqrt((1/10.0) * ((q1-q2+q3+q4) * a2))

        Ks_dqUterm = sqrt((1/U) * ((q1-q2+q3+q4) * a2))

        Ks_dudzterm = sqrt((1/10.0 * (q3) * a2))

        Ks_Uterm = 1/U

        Ks_qaterm = ((q1-q2+q3+q4) * a2)

        Ks = sqrt(Ks2a2)

        copy_VarCoords(U,Ks)
        copy_VarCoords(U,Ks2)


    ;----------------------------------------------------------------------
    ; Write out results to a new netcdf file
    ;-----------------------------------------------------------------------

        filo = "Ks_full_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h0.nc"
        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

        fout_std->U = U
        fout_std->Ks = Ks
        fout_std->Ks2 = Ks2

        print("printed it")


    end do
end do

end
