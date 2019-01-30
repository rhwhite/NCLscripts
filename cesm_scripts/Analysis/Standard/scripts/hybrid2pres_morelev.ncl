load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; convert many variables onto hybrid levels from monthly resolution data
; including caluclation of potential temperaturei, PV, etc and vertical gradients etc 
; Calculates new variables ON pressure levels, rather than calculating on
; hybrid levels and then converting

begin

Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

version=getenv("NCL_CESMversion")

if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

Mtrans = getenv("NCL_Mtrans")
GW = getenv("NCL_GW")
O3 = getenv("NCL_Ozone")
xrad = getenv("NCL_xrad")
diabatic = getenv("NCL_dia")

print(diabatic)
timespans = (/"DJF","Annual","JJA","MAM","SON"/)
;timespan = getenv("NCL_season")
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

; Set some constants
PI = 3.14159265358979
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
g = 9.81

;pnew  = (/1,2,3,4,5,6,8, 10, 15,20,25,30,40,50,70,100,150,200,250 \
;         , 300,400,500,600,700,750,775,850,925,1000 /)

pnew  = (/1000,925,850,775,750,600,500,400,300,250,200,150,100, \
            50,30,25,10,7.5,5,3,2,1,0.75,0.5,0.3,0.2, \
            0.1,0.075,0.05,0.03,0.02,0.01,0.0075,0.005,0.0003,0.0002,0.0001 /)



p_int = 10^fspan(-3,3,60)   ; interpolation targets
p_int!0 = "lev_int" 
dimslevint = dimsizes(p_int)

do ts = 0,nts - 1

	timespan = timespans(ts)
    print(timespan)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + dirstr)
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
	
	  	cdf_file = addfile(filename,"r")
	
		lat = cdf_file->lat
		lon = cdf_file->lon
		nlats = dimsizes(lat)
		nlons = dimsizes(lon)
		P0mb = 0.01*cdf_file->P0
		U = cdf_file->U
		V = cdf_file->V
        T = cdf_file->T
		Z3 = cdf_file->Z3
		Q = cdf_file->Q
;		OmegaT = cdf_file->dOMEGATdp

		PHIS = cdf_file->PHIS

		if (Mtrans .EQ. 1) then
			VV = cdf_file->VV
            VU = cdf_file->VU
            VT = cdf_file->VT
            VQ = cdf_file->VQ
            VZ = cdf_file->VZ
		end if

        if (diabatic .EQ. 1) then
            DTCOND = cdf_file->DTCOND
            DTV = cdf_file->DTV
            QRL = cdf_file->QRL
            QRS = cdf_file->QRS
        end if

		levs = cdf_file->lev
		nlevs = dimsizes(levs)

		if levs(0) .GT. levs(nlevs-1) then
			TBOT = T(:,0,:,:)
		else
			TBOT = T(:,nlevs-1,:,:)
		end if

		hyam = cdf_file->hyam
		hybm = cdf_file->hybm
		PS = cdf_file->PS

		dims1 = dimsizes(U)
		dimslev = dimsizes(pnew)

		Tpres = vinth2p_ecmwf(T,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,PHIS)
		Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
		Vpres = vinth2p_ecmwf(V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
		Z3pres = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True,-1,TBOT,PHIS) 
		Qpres = vinth2p_ecmwf(Q,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
		Omegapres = vinth2p_ecmwf(cdf_file->OMEGA,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
		;	OmegaTpres = vinth2p_ecmwf(OmegaT,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
        RELHUMpres = vinth2p_ecmwf(cdf_file->RELHUM,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
        
        if O3 .EQ. 1 then
            O3pres = vinth2p_ecmwf(cdf_file->O3,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            CH4pres = vinth2p_ecmwf(cdf_file->CH4,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            CO2pres = vinth2p_ecmwf(cdf_file->CO2,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            N2Opres = vinth2p_ecmwf(cdf_file->N2O,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
        end if
        if xrad .EQ. 1 then
            NETDTpres = vinth2p_ecmwf(cdf_file->NETDT,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
        end if

        ; Calculate Potential temperature
        TH = Tpres * (conform(Tpres,pnew,1)/1000.0)^(-1.0 * kappa)
		copy_VarCoords(Tpres,TH)
        ; Calculate d(TH)/dp from vertical finite differences in log-pressure coordinates
        ; noting that dTH/dp = (1/p) * dTH/d(lnp)
        loglevel = log(pnew)
        THp = center_finite_diff_n(TH(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
        THp = THp / conform(THp,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
        copy_VarMeta(TH,THp)

        Up = center_finite_diff_n(Upres(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
        Up = Up / conform(Up,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
        copy_VarMeta(Upres,Up)

        Vp = center_finite_diff_n(Vpres(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
        Vp = Vp / conform(Vp,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
        copy_VarMeta(Vpres,Vp)

		; Calculate OMEGAp
		OMEGAp = center_finite_diff_n(Omegapres(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
        OMEGAp = OMEGAp / conform(OMEGAp,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
        copy_VarMeta(Omegapres,OMEGAp)

        SFpres = new(dimsizes(Upres), typeof(Upres))
        temp = new(dimsizes(Upres),typeof(Upres))

        uv2sfvpf(Upres,Vpres,SFpres,temp)
		copy_VarMeta(Upres,SFpres)

		SFza = dim_rmvmean_Wrap(SFpres(time|:,lev_p|:,lat|:,lon|:))

; Get distance of lats and lons for finite differences
		dlat = gc_latlon(lat(1),lon(0),lat(2),lon(0),0,3)
; Get gradients of U using spherical harmonics: near the surface this might look funky

		Ux = Upres
		Uy = Upres
		Uy = tofloat(center_finite_diff_n(Upres(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        do ilat = 0,nlats-1
			dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
			Ux(:,:,ilat,:) = tofloat(center_finite_diff_n(Upres(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
		end do
		copy_VarMeta(Upres,Ux)
        copy_VarMeta(Upres,Uy)
		Ux@longname = "longitudinal gradient of U"
		Uy@longname = "latitudinal gradient of U"
		Ux@units = "1/s"
		Uy@units = "1/s"
; Do the same for V
        Vx = Vpres 
        Vy = Vpres
        Vy = tofloat(center_finite_diff_n(Vpres(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        do ilat = 0,nlats-1
            dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
            Vx(:,:,ilat,:) = tofloat(center_finite_diff_n(Vpres(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
        end do 
        copy_VarMeta(Vpres,Vx)
        copy_VarMeta(Vpres,Vy)
        Vx@longname = "longitudinal gradient of V"
        Vy@longname = "latitudinal gradient of V"
        Vx@units = "1/s"
        Vy@units = "1/s"
; Do the same for TH
        THx = TH 
        THy = TH 
        THy = tofloat(center_finite_diff_n(TH(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        do ilat = 0,nlats-1
            dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
            THx(:,:,ilat,:) = tofloat(center_finite_diff_n(TH(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
        end do
		copy_VarMeta(TH,THx)
        copy_VarMeta(TH,THy)

        THx@longname = "longitudinal gradient of TH"
        THy@longname = "latitudinal gradient of TH"
        THx@units = "K/m"
        THy@units = "K/m"

; Do the same for Z
		PSI = Z3pres * g
		copy_VarMeta(Z3pres,PSI)
		PSI@units = "m2/s2"

        PSIx = Z3pres
        PSIy = Z3pres 
        PSIy = tofloat(center_finite_diff_n(PSI(time|:,lev_p|:,lat|:,lon|:),dlat,False,0,2))
        do ilat = 0,nlats-1
            dlon = gc_latlon(lat(ilat),lon(0),lat(ilat),lon(1),0,3)
            PSIx(:,:,ilat,:) = tofloat(center_finite_diff_n(PSI(time|:,lev_p|:,lat|ilat,lon|:),dlon,True,0,2))
        end do

		copy_VarMeta(Z3pres,PSIx)
		copy_VarMeta(Z3pres,PSIy)
        PSIx@longname = "longitudinal gradient of PSI"
        PSIy@longname = "latitudinal gradient of PSI"
        PSIx@units = "m/s2"
        PSIy@units = "m/s2"

		PVdtdx = Tpres
		PVdtdy = Tpres
		PVdtdx@long_name = "longitudinal gradient (derivative)"
		PVdtdy@long_name = "latitudinal gradient (derivative)"
		PVdtdx@units     = "K/m"
		PVdtdy@units     = "K/m"

		PVvr = uv2vrF_Wrap(Upres,Vpres)
		gradsf(Tpres,PVdtdx,PVdtdy)

		PVdudp = center_finite_diff_n (    Upres,pnew*100.0,False,0,1)
        PVdvdp = center_finite_diff_n (    Vpres,pnew*100.0,False,0,1)
		PVdTHdp = center_finite_diff_n (TH,pnew*100.0,False,0, 1)
		PVs = -(Tpres/TH) * PVdTHdp
		
		PV = pot_vort_isobaric(pnew * 100.0,Upres,Vpres,Tpres,lat,1,0)	

		copy_VarCoords(PVvr,PVdudp)
        copy_VarCoords(PVvr,PVdvdp)
        copy_VarCoords(PVvr,PVdTHdp)
        copy_VarCoords(PVvr,PVs)

        if (GW .EQ. 1) then
            UTGWOROpres = vinth2p_ecmwf(cdf_file->UTGWORO,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VTGWOROpres = vinth2p_ecmwf(cdf_file->VTGWORO,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            UTGWSPECpres = vinth2p_ecmwf(cdf_file->UTGWSPEC,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VTGWSPECpres = vinth2p_ecmwf(cdf_file->VTGWSPEC,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)

        end if

        if (Mtrans .EQ. 1) then
            VVpres = vinth2p_ecmwf(VV,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VUpres = vinth2p_ecmwf(VU,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VTpres = vinth2p_ecmwf(VT,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VQpres = vinth2p_ecmwf(VQ,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VZpres = vinth2p_ecmwf(VZ,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)

            VVpresInt = vinth2p_ecmwf(VV,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VUpresInt = vinth2p_ecmwf(VU,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VTpresInt = vinth2p_ecmwf(VT,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VQpresInt = vinth2p_ecmwf(VQ,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)
            VZpresInt = vinth2p_ecmwf(VZ,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)

		end if

        if (diabatic .EQ. 1) then
            DTCONDpres = vinth2p_ecmwf(DTCOND,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            DTVpres = vinth2p_ecmwf(DTV,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            QRLpres = vinth2p_ecmwf(QRL,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
            QRSpres = vinth2p_ecmwf(QRS,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)

            DIA = DTCOND + DTV + QRL + QRS
            DIApres = vinth2p_ecmwf(DIA,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)


            copy_VarCoords(Upres,DTCONDpres)
            copy_VarCoords(Upres,DTVpres)
            copy_VarCoords(Upres,QRLpres)
            copy_VarCoords(Upres,QRSpres)
            copy_VarCoords(Upres,DIApres)
        end if

        Tlog = vinth2p_ecmwf(T,hyam,hybm,p_int,PS,1,P0mb,1,True,1,TBOT,PHIS)
        Ulog = vinth2p_ecmwf(U,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)
        Vlog = vinth2p_ecmwf(V,hyam,hybm,p_int,PS,1,P0mb,1,True,0,TBOT,PHIS)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + "." + camversion + ".h0.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")
	
		setfileoption(fout,"DefineMode",True)
	
; set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout,fAtt)
	
;set dimensions of output file
	
		fout ->U      = Upres
		fout ->V      = Vpres
		fout ->T      = Tpres
        fout ->TH      = TH
        fout ->THp      = THp
        fout ->Up      = Up
        fout ->Vp      = Vp

		fout ->Z3      = Z3pres
		fout ->PSI	= PSI
		fout ->Q      = Qpres
		fout ->OMEGA      = Omegapres
        fout ->OMEGAp      = OMEGAp
        fout ->RELHUM      = RELHUMpres

        if xrad .EQ. 1 then
            fout ->NETDT    = NETDTpres
        end if
        if O3 .EQ. 1 then
            fout ->O3       = O3pres
            fout ->CO2 = CO2pres
            fout ->CH4 = CH4pres
            fout ->N2O = N2Opres
        end if

        fout ->SF      = SFpres
        fout ->SFza      = SFza

        fout ->Ux      = Ux
        fout ->Uy      = Uy
        fout ->Vx      = Vx
        fout ->Vy      = Vy
        fout ->PSIx      = PSIx
        fout ->PSIy      = PSIy
        fout ->THx      = THx
        fout ->THy      = THy

		fout ->PVvr 	= PVvr
		fout ->PVdtdx 	= PVdtdx
		fout ->PVdtdy 	= PVdtdy

		fout ->PVdudp = PVdudp
        fout ->PVdvdp = PVdvdp
        fout ->PVdTHdp = PVdTHdp
        fout ->PVs	= PVs 
        fout ->PV      = PV

        if (GW .EQ. 1) then
            fout->UTGWORO = UTGWOROpres
            fout->VTGWORO = VTGWOROpres
            fout->UTGWSPEC = UTGWSPECpres
            fout->VTGWSPEC = VTGWSPECpres
        end if

        if (Mtrans .EQ. 1) then
			fout ->VV = VVpres
            fout ->VU = VUpres
            fout ->VT = VTpres
            fout ->VQ = VQpres
            fout ->VZ = VZpres

            fout ->VVint = VVpresInt
            fout ->VUint = VUpresInt
            fout ->VTint = VTpresInt
            fout ->VQint = VQpresInt
            fout ->VZint = VZpresInt
        end if
        
        if (diabatic .EQ. 1) then
            fout ->DTCOND = DTCONDpres
            fout ->DTV = DTVpres
            fout ->QRL = QRLpres
            fout ->QRS = QRSpres
            fout ->DIA = DIApres
        end if

        fout->T_logp = Tlog
        fout->U_logp = Ulog
        fout->V_logp = Vlog

 
		delete(Experiment)
		delete([/lat,lon,P0mb,U,V,T,Q,Z3,hyam,hybm,PS/])
		delete(filename)
		delete([/Tpres,Upres,Vpres,Qpres,Z3pres,Omegapres,RELHUMpres/])

        print("next")	
	end do

end do

end
