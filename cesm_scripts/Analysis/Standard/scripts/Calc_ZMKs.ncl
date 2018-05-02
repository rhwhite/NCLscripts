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
begin

; Get experiment names

print("Calc Rossby Refractive Index")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

dirstr = getenv("NCL_dirstr")
outdirstr = getenv("NCL_outdirstr")


do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

timespan = getenv("NCL_season")

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
        loglevel = log(level)
		level!0="lev_p"
		levsizes = dimsizes(level)
		ntimes = filevardimsizes(cdf_filepl,"time")
		nlevels = filevardimsizes(cdf_filepl,"lev_p")
		nlat = filevardimsizes(cdf_filepl,"lat")
		nlon = filevardimsizes(cdf_filepl,"lon")

		lat = tofloat(cdf_filepl->lat)
		lat!0="lat"
		lon = tofloat(cdf_filepl->lon)
		lon!0="lon"

		U = dim_avg_n_Wrap(cdf_filepl->U,3) ; get zonal mean U
        QV = dim_avg_n_Wrap(cdf_filepl->Q,3) ; get zonal mean RH
        TH = dim_avg_n_Wrap(cdf_filepl->TH,3) ; get zonal mean TH
        Z = dim_avg_n_Wrap(cdf_filepl->Z3,3) ; get zonal mean Z


	; Set up some constants
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
    ; Calculate virtual potential temperature
        vTHETA  = (1 + 0.61*QV) * TH  ; virtual potential temp, assuming
        ;unsaturated air: http://glossary.ametsoc.org/wiki/Virtual_potential_temperature
        copy_VarCoords(TH,vTHETA)

    ; Calculate buoyancy freqency, N^2
    ; Should use geometric height, but estimating this as geopotential height:
    ; http://glossary.ametsoc.org/wiki/Geopotential_height
    ; states that the two are numerically interchangeable for most
    ; meteorological purposes

        ;dTHdZ = center_finite_diff_n(vTHETA(time|:,lev_p|:,lat|:),Z,False,0, 1)
        dTHdZ = center_finite_diff_n(TH(time|:,lev_p|:,lat|:),Z,False,0, 1)
        copy_VarCoords(TH,dTHdZ)

        ;N2 = (g/vTHETA) * dTHdZ ; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5
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

		filo = ("KsZM_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" +  Experiment + ".cam2.h0.nc")
	
		system("/bin/rm -f " + Dir + filo)
		fout_std = addfile(Dir + filo, "c")

		setfileoption(fout_std,"DefineMode",True)

	;set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fAtt@history = "created by Calc_ZMKs.ncl"
        fileattdef(fout_std,fAtt)

	;set dimensions of output file
		dimNames = (/"time","lat","lon","lev_p"/)
		dimSizes = (/ntimes,nlat,nlon,nlevels/)
		dimUnlim = (/True,False,False,False/)
		filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

		fout_std->U = U
		fout_std->Ks = Ks
        
        fout_std->Ks2 = Ks2
        fout_std->Ks2a2 = Ks2a2
        fout_std->q1 = q1
        fout_std->q2 = q2
        fout_std->q3 = q3
        fout_std->q4 = q4
        
        fout_std->Ks_dqterm = Ks_dqterm
        fout_std->Ks_dqUterm = Ks_dqUterm
        fout_std->Ks_dudzterm = Ks_dudzterm

        fout_std->Ks_qaterm = Ks_qaterm
        fout_std->Ks_Uterm = Ks_Uterm


		fout_std->lat = (/lat/)
		fout_std->level = level
		
        
        print("printed it")


	end do
end do

end
