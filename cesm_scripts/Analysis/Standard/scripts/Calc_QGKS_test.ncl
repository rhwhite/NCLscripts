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
rho0 = 1.225    ; kg/m3
dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

timespans = (/"DJF"/)
;timespan = getenv("NCL_season")
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

;------------------------------
undef("brunt_vaisala_atm")
function brunt_vaisala_atm(th:numeric, z:numeric, opt[1]:integer, ndimz[1]:integer)
;
; Brunt-Vaisala:
;   The frequency at which a displaced air parcel will oscillate when displaced
;   vertically within a statically stable environment.
;
; AMS Glossary:
; BruntV: http://glossary.ametsoc.org/wiki/Brunt-v%C3%A4is%C3%A4l%C3%A4_frequency
;
; Nomenclature:
;   th - potential temperature (degK); could also be virtual potential
; temperature
;   z  - geometric height (m)
;   opt- =0 return Brunt-Vaisala frequency only
;   opt- =1 return Brunt-Vaisala frequency and dthdz as part of a list variable
;
local dimth, dthdz , pmflag, g, buoy, brunt
begin
;;dimz    = dimsizes(z)
  dimth   = dimsizes(th)
;;rankz   = dimsizes(dimz)
;;rankth  = dimsizes(dimth)

  dthdz   = center_finite_diff_n(th, z, False, 0, ndimz)

 ;copy_VarCoords(th, dthdz)
 ;dthdz@long_name = "Vertical Gradient of potential temperature"
 ;dthdz@units     = "degK/m"
 ;print("brunt_vaisala_atm: dthdz: min="+min(dthdz)+"   max="+max(dthdz))

  g      = 9.80665                ; m/s2 at 45N
  buoy   = (g/th)*dthdz           ; 'buoyancy' term (N^2): [m/s2][1/K][K/m]=[1/s2]
                                  ; buoyancy can be negative if dthdz < 0
 ;buoy@long_name = "buoyancy"
 ;buoy@units     = "1/s^2"
 ;copy_VarCoords(th, buoy)
 ;print("buoyancy: min="+min(buoy)+"   max="+max(buoy))

  pmflag = new(dimth, "integer", -9999 )
  pmflag = where(buoy.lt.0, -1, 1)

  brunt  = sqrt(abs(buoy))
  brunt  = brunt*pmflag           ; add negative flag
  delete(pmflag)
  copy_VarCoords(th, brunt)
  brunt@long_name = "Brunt-Vaisala frequency"
  brunt@units     = "1/s"
  brunt@info      = "http://glossary.ametsoc.org/wiki/Brunt-v%C3%A4is%C3%A4l%C3%A4_frequency"
  brunt@sign      = "brunt<0 means the buoyancy was <0"
  brunt@sign_1    = "User could use where(brunt.lt.0, 0, brunt) to create only positive values "

  if (opt.eq.0) then
      return( brunt )
  else
      return( [/ brunt, dthdz /] )
  end if
end

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

        p = cdf_filepl->lev_p		; in hpa, or mb
        p!0="lev_p"
        levsizes = dimsizes(p)
        nlevels = filevardimsizes(cdf_filepl,"lev_p")
        nlats = filevardimsizes(cdf_filepl,"lat")
        nlons = filevardimsizes(cdf_filepl,"lon")

        lat = tofloat(cdf_filepl->lat)
        lat!0="lat"
        lon = tofloat(cdf_filepl->lon)
        lon!0="lon"

        U = cdf_filepl->U(:,:,:,:)
        Z = cdf_filepl->Z3
        Zg = Z * g
        T = cdf_filepl->T(:,:,:,:)
        QV = cdf_filepl->Q
        PV = cdf_filepl->PV
        copy_VarCoords(cdf_filepl->Z3,Zg)
       
    ; Set up some constants
        phi = lat*PI/180.0      ; Get latitude in radians
        cphi = cos(phi)
        c2phi = cphi * cphi
        acphi = a * cos(phi)
        asphi = a * sin(phi)
        f = 2*omega*sin(phi)
        a2 = a*a
        f2 = f * f

; Calculate first term: 1/f Del squared PHI
; = 1/f (d/d2x PHI + d/d2y PHI)
; Get distance of lats and lons for finite differences
        dlat = gc_latlon(lat(1),lon(0),lat(2),lon(0),0,3)

        PHIy = tofloat(center_finite_diff_n(Zg(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        copy_VarCoords(Zg,PHIy)
        PHIy2 = tofloat(center_finite_diff_n(PHIy(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        copy_VarCoords(Zg,PHIy2)

        PHIx = Zg
        do ilat = 0,nlats-1
            dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
            ; index for dimension still 2, as we have collapsed latitude dim
            PHIx(:,:,ilat,:) = tofloat(center_finite_diff_n(Zg(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
        end do
        copy_VarCoords(Zg,PHIx)
        PHIx2 = PHIx
        ; take second derivative
        do ilat = 0,nlats-1
            dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
            PHIx2(:,:,ilat,:) = tofloat(center_finite_diff_n(PHIx(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
        end do

        copy_VarCoords(PHIx,PHIx2)

        print(getvardims(PHIy2))
        print(getvardims(PHIx2))

        fi = conform(PHIy2,1/f,2)
        PV1 = fi * (PHIy2 + PHIx2)    

; Calculate 2nd, stretching term
; d/dp ( f0/s dPHI/dp)
    
        PHIp = center_finite_diff_n(Zg,p*100.0,False,0,1)

; Calculate static stability
        S           = static_stability(p,T,1,1)   ; variable of type list

        s           = S[0]    ; [...] is list syntax
        theta       = S[1]    ; theta = pot_tmp(p, t, npr, 0)
        dthdp       = S[2]    ; dthdp = center_finite_diff_n (theta,p,False,0,npr)
        s@_FillValue= 1e20
        delete(S)

        s   = where(s.eq.0, s@_FillValue, s)    ; safety
        con = 1/s
; Calculate term inside brackets
        f0SPHIp = conform(PHIp,f,2) * con * PHIp

; Take vertical gradient
        PV2 = center_finite_diff_n(f0SPHIp,p,False,0,1)

        QGPV = conform(PV1,f,2) + PV1 + PV2

        QGPV!0 = "time"
        QGPV!1 = "lev_p"
        QGPV!2 = "lat"
        QGPV!3 = "lon"

        QGPV@lev_p = p
        QGPV@lat = lat
        QGPV@lon = lon	


; Take meridional gradient
        PVy = tofloat(center_finite_diff_n(QGPV(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))

        QGKt2 = a2 * PVy/U
        copy_VarCoords(QGPV,QGKt2)

        QGKt = sqrt(QGKt2)

        copy_VarCoords(QGPV,QGKt)

; Calculate N and H
    ; Calculate virtual potential temperature
        vTHETA  = (1 + 0.61*QV) * theta  ; virtual potential temp, assuming
                ;unsaturated air: http://glossary.ametsoc.org/wiki/Virtual_potential_temperature
        copy_VarCoords(T,vTHETA)
    ; Calculate buoyancy freqency, N^2
    ; Should use geometric height, but estimating this as geopotential height:
    ; http://glossary.ametsoc.org/wiki/Geopotential_height
    ; states that the two are numerically interchangeable for most
    ; meteorological purposes

        dTHdZ = center_finite_diff_n(vTHETA(time|:,lev_p|:,lat|:,lon|:),Z, False,0, 1)
        copy_VarCoords(theta,dTHdZ)
        N2 = (g/vTHETA) * dTHdZ ; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5
        copy_VarCoords(theta,N2)
        N2zm = dim_avg_n_Wrap(N2,3)

        N2zm@long_name = "zonal mean Brunt-Vaisala frequency squared"
        N2zm@units = "1/s^2"
        N2zm@info = "http://glossary.ametsoc.org/wiki/Brunt-v%C3%A4is%C3%A4l%C3%A4_frequency"

        H = 8000.0 

        QGKs2 =((PVy/U) - conform(N2,f2,2)/(4 * N2 * H * H))
        QGKs = conform(QGKs2,acphi,2) * sqrt(QGKs2)

        copy_VarCoords(QGKt,QGKs)
        copy_VarCoords(QGKt,QGKs2)



; Calculate using NCL PV calculated on hybrid levels.

; Take meridional gradient
        ; first scale PV by rho0 1/dTHdZ
        
        PVscale = PV * rho0 / dTHdZ
        copy_VarCoords(QGKt,PVscale)

        PVy = tofloat(center_finite_diff_n(PVscale(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))

        Kt2 = (PVy / U)
        Kt = conform(Kt2,acphi,2) * sqrt(Kt2)

        Ks2 = ((PVy/U)* dTHdZ * 1/rho0 - conform(N2,f2,2)/(4 * N2 * H * H))
        Ks = conform(Ks2,acphi,2) * sqrt(Ks2)

        copy_VarCoords(QGKt,Kt)
        copy_VarCoords(QGKt,Ks)


    ;----------------------------------------------------------------------
    ; Write out results to a new netcdf file
    ;-----------------------------------------------------------------------

            filo = "KsKt_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h0.nc"
            system("/bin/rm -f " + Dir + filo)
            fout_std = addfile(Dir + filo, "c")

            setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
            fAtt = True
            fAtt@creation_date = systemfunc("date")
            fileattdef(fout_std,fAtt)

    ;set dimensions of output file
            dimNames = (/"time","lat","lon","lev_p"/)
            dimSizes = (/1,nlats,nlons,nlevels/)
            dimUnlim = (/False,False,False,False/)
            filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

            filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
            filevardef(fout_std,"level",typeof(p),getvardims(p))
            filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

            ;filevardef(fout_std,"Ks",typeof(Ks),getvardims(Ks))
            ;filevardef(fout_std,"Kt",typeof(Kt),getvardims(Kt))

            ;filevardef(fout_std,"U",typeof(Kt),getvardims(Kt))
            fout_std->U = U
            fout_std->QGKs = QGKs
            fout_std->QGKt = QGKt
            fout_std->Ks = Ks
            fout_std->Kt = Kt
 
            fout_std->PV = PVscale
            fout_std->QGPV = QGPV
            fout_std->PV1 = PV1
            fout_std->PV2 = PV2
            fout_std->Zg = Zg
            fout_std->s = s
            fout_std->PHIx=PHIx
            fout_std->PHIx2=PHIx2
            fout_std->PHIy=PHIy
            fout_std->PHIy2=PHIy2
            fout_std->PVy = PVy
            fout_std->N2 = N2
            fout_std->dTHdz = dTHdZ
            fout_std->theta = theta
            fout_std->fi = fi
            fout_std->lat = lat
            fout_std->p = p
            fout_std->lon = lon

            print("printed it")


    end do
end do

end
