load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Code to calculate Rossby refractive index based on waves on the zonal mean
; Follows derivation of Li et al 2007 ACP
; Using matlab code from http://khalilkarami.com/matlab-codes/refractive-index-of-rossby-waves/
; Calculate on model levels, and then move to pressure levels. This stops having the issue of 0s where the pressure level is below ground level?

begin

; Get experiment names

numk = 8 ; number of zonal wavenumbers, starting from 1


print("Calc Rossby Refractive Index")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

lonstart = toint(getenv("NCL_ARG_lonstart"))
lonend = toint(getenv("NCL_ARG_lonend"))


nyears = endyr-startyr+1

timespan = "DJF"

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/atm/hist/")
	print(Experiment)


	filenamepl = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
	filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc"
	; open file with seasonal averages
	cdf_filepl = addfile(filenamepl,"r")
	cdf_file = addfile(filename,"r")

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
	V = cdf_filepl->V(:,:,:,:)
	T = cdf_filepl->T(:,:,:,:)
	Z = cdf_filepl->Z3(:,:,:,:)
	QV = cdf_filepl->Q(:,:,:,:)
	PS = cdf_file->PS(:,:,:)

; Calculate zonal mean U = Uzm

	Uzm = dim_avg_n_Wrap(U(time|:,lev_p|:,lat|:,lon|:),3); Uzm(time,lev,lat)
	Uzm@long_name = "zonal mean U"

; Calculate zonal mean Z = Zzm
	Zzm = dim_avg_n_Wrap(Z(time|:,lev_p|:,lat|:,lon|:),3);  Zzm(time,lev,lat)
	Zzm@long_name = "zonal mean Z"

; Calculate dUzm/dz
	dUzmdZ = center_finite_diff_n(Uzm,Zzm,False,0,1)
; Or calculate (dU/dZ)zm
	dUdZ = center_finite_diff_n(U(time|:,lev_p|:,lat|:,lon|:),Z(time|:,lev_p|:,lat|:,lon|:),False,0,1)
	copy_VarCoords(U,dUdZ)
	dUdZzm = dim_avg_n_Wrap(dUdZ,3)

; Calculate d2Uzm/dz2
	d2UzmdZ2 = center_finite_diff_n(dUzmdZ,Zzm,False,0,1)
	copy_VarCoords(Uzm,d2UzmdZ2)
; Calculate scale height from middle level - could maybe take this to just be 7.4km?
        midlevel = toint(nlevels/2)
	midlevel = 15
	loglevelsurf= log(conform(PS,level(midlevel)*100.0,-1)/PS)	; Convert level to Pa to match PS

	H = -Z(0,midlevel,:,:)/(conform(Z(0,midlevel,:,:),loglevelsurf(0,:,:),(/0,1/)))

	Hzm = dim_avg_Wrap(H)

; Set up some constants
        phi = lat*PI/180.0      ; Get latitude in radians
	cphi = cos(phi)
        acphi = a * cos(phi)
        asphi = a * sin(phi)
        f = 2*omega*sin(phi)
	a2 = a*a
	f2 = f * f

; Calculate potential temperature
        THETA = T
        THETA = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)

; Calculate virtual potential temperature
	vTHETA  = (1 + 0.61*QV) * THETA  ; virtual potential temp, assuming unsaturated air: http://glossary.ametsoc.org/wiki/Virtual_potential_temperature
	copy_VarCoords(T,vTHETA)
; Calculate buoyancy freqency, N^2
; Should use geometric height, but estimating this as geopotential height: http://glossary.ametsoc.org/wiki/Geopotential_height
; states that the two are numerically interchangeable for most meteorological purposes

	dTHdZ = center_finite_diff_n(vTHETA(time|:,lev_p|:,lat|:,lon|:),Z, False,0, 1)
	N2 = (g/vTHETA) * dTHdZ	; gives N^2, for N = (g/Theta * dTheta/dZ)^0.5
        copy_VarCoords(THETA,N2)
	N2zm = dim_avg_n_Wrap(N2,3)

	N2zm@long_name = "zonal mean Brunt-Vaisala frequency squared"
	N2zm@units = "1/s^2"
	N2zm@info = "http://glossary.ametsoc.org/wiki/Brunt-v%C3%A4is%C3%A4l%C3%A4_frequency"
	

; Calculate vertical shear in N2zm, dN2zmdZ
	dN2zmdZ = center_finite_diff_n(N2zm,Zzm,False,0,1)

; Calculate d(Uzm * cphi)/dphi
	UzmCphi = Uzm * conform(Uzm,cphi,2)
	dUzmCphidphi = center_finite_diff_n(UzmCphi,conform(UzmCphi,phi,2),False,0,2)
; Calculate d(dUzmCphidphi/cphi)/dphi
	Uzmcphietc = center_finite_diff_n(dUzmCphidphi / conform(dUzmCphidphi,cphi,2),conform(dUzmCphidphi,phi,2),False,0,2)


; Now calculate different terms in the refractive index equation.
; First, get qphi = (2omega/a)cos(phi) - 1/a2((ucos(phi)phi)/cos(phi))phi + Uzm(f2/HN2) + Uzm(f2/N4)(dN2/dZ) - (f2/N2)d2U/dZ2

	qphi1 = 2.0 * omega * cphi / a
	qphi2 = (1.0 / a2) * Uzmcphietc

	qphi3 = dUzmdZ * conform(Uzm,f2,2)  * (1/(conform(Uzm,Hzm,2) * N2zm))
	qphi4 = dUzmdZ * conform(Uzm,f2,2) * (1/(N2zm * N2zm)) * dN2zmdZ
	qphi5 = conform(Uzm,f2,2) * (1/N2zm) * d2UzmdZ2

	qphitemp = conform(qphi3,qphi1,2) - qphi2 + qphi3 + qphi4 - qphi5

	qphi = qphitemp(:,:,1:nlat-2)

	qphi@long_name = "meridional gradient of zonal mean PV"

        qphi!0 = "time"
        qphi!1 = "lev_p"
        qphi!2 = "lat"

        qphi@lev_p = level
        qphi@lat = lat(1:nlat-2)	


; Now calculate refractive index squared
; nk2(y,z) = qphi/Uzm - (k/acos(phi))^2 - (f/2NH)^2
; Loop over different k's
; Don't calculate for 1st and last latitude, as Uzm goes to zero here (not sure why, perhaps by definition of the grid!)
; First define array to fill
	arrsize = dimsizes(Uzm)
	
	nk2 = new((/numk,arrsize(0),arrsize(1),arrsize(2)-2/),float)
	zwn = new(numk,integer)
	nkt1 = qphi/Uzm(time|:,lev_p|:,lat|1:nlat-2)

	nkt3 = (conform(N2zm(time|:,lev_p|:,lat|1:nlat-2),f2(1:nlat-2),2)) / (4 * N2zm(time|:,lev_p|:,lat|1:nlat-2) * conform(N2zm(time|:,lev_p|:,lat|1:nlat-2),Hzm(1:nlat-2),2) * conform(N2zm(time|:,lev_p|:,lat|1:nlat-2),Hzm(1:nlat-2),2))

	do k = 1,8
	
		nkt2 = conform(acphi(1:nlat-2),k*k,-1)/(acphi(1:nlat-2)*acphi(1:nlat-2))
		nk2(k-1,:,:,:) = nkt1 - conform(nkt1,nkt2,2) - nkt3
		zwn(k-1) = k
		delete(nkt2)
	end do

	nk2!0 = "k"
	nk2!1 = "time"
	nk2!2 = "lev_p"
	nk2!3 = "lat"

	nk2@k = zwn
	nk2@lev_p = level
	nk2@lat = lat(1:nlat-2)

	zwn!0 = "k"
	zwn@k = zwn

;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------

        filo = "Ridx_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_orig_" + Experiment + ".cam2.h0.nc"
        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

;set dimensions of output file
        dimNames = (/"k","time","lat","lev_p"/)
        dimSizes = (/numk,1,nlat-2,nlevels/)
        dimUnlim = (/False,False,False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

        filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
        filevardef(fout_std,"level",typeof(level),getvardims(level))
        filevardef(fout_std,"k",typeof(zwn),getvardims(zwn))

        filevardef(fout_std,"qphi",typeof(qphi),getvardims(qphi))
        filevardef(fout_std,"nk2",typeof(nk2),getvardims(nk2))

	fout_std->k = zwn
        fout_std->lat = (/lat(1:nlat-2)/)
        fout_std->level = level
        fout_std->qphi = qphi
        fout_std->nk2 = nk2

        print("printed it")


end do

end
