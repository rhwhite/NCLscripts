load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

Mtrans = getenv("NCL_Mtrans")

;timespans = (/"Annual","DJF","JJA","MAM","SON"/)
timespans = (/"Annual","DJF"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

; Set some constants
PI = 3.14159265358979
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
g = 9.81

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	pnew = (/ 10, 20,30,50,70,90,120,150,200,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

	p_int = 10^fspan(1,3,15)   ; interpolation targets
        p_int!0 = "lev_int" 
	dimslevint = dimsizes(p_int)
		
	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + dirstr)
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	  	cdf_file = addfile(filename,"r")
	
		lat = cdf_file->lat
		lon = cdf_file->lon
		P0mb = 0.01*cdf_file->P0
		U = cdf_file->U
		V = cdf_file->V
		T = cdf_file->T
		Z3 = cdf_file->Z3
		Q = cdf_file->Q
		Omega = cdf_file->OMEGA
;		OmegaT = cdf_file->dOMEGATdp
		RELHUM = cdf_file->RELHUM

		PHIS = cdf_file->PHIS

		if (Mtrans .EQ. 1) then
			VV = cdf_file->VV
                        VU = cdf_file->VU
                        VT = cdf_file->VT
                        VQ = cdf_file->VQ
                        VZ = cdf_file->VZ
		end if


		levs = cdf_file->lev
		nlevs = dimsizes(levs)
		print(nlevs)

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
		Omegapres = vinth2p_ecmwf(Omega,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)
		;	OmegaTpres = vinth2p_ecmwf(OmegaT,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
                RELHUMpres = vinth2p_ecmwf(RELHUM,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS)

                ; Calculate Potential temperature
                TH = Tpres * (conform(Tpres,pnew,1)/1000.0)^(-1.0 * kappa)
		copy_VarCoords(Tpres,TH)
                ; Calculate d(TH)/dp from vertical finite differences in log-pressure coordinates
                ; noting that dTH/dp = (1/p) * dTH/d(lnp)
                loglevel = log(pnew)
		printVarSummary(TH)
                THp = center_finite_diff_n(TH(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
                THp = THp / conform(THp,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
                copy_VarMeta(TH,THp)


		; Calculate OMEGAp
		OMEGAp = center_finite_diff_n(Omegapres(time|:,lev_p|:,lat|:,lon|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
                OMEGAp = OMEGAp / conform(OMEGAp,100.0 * pnew,1) ; converts "level" to pascals from millibars while dividing by pressure.
                copy_VarMeta(Omegapres,OMEGAp)

                SFpres = new(dimsizes(Upres), typeof(Upres))
                temp = new(dimsizes(Upres),typeof(Upres))

                uv2sfvpf(Upres,Vpres,SFpres,temp)
		copy_VarMeta(Upres,SFpres)

		SFza = dim_rmvmean_Wrap(SFpres(time|:,lev_p|:,lat|:,lon|:))

; Get gradients of U using spherical harmonics: near the surface this might look funky

		Ux = Upres
		Uy = Upres
		gradsf(Upres,Ux,Uy)
                copy_VarMeta(Upres,Ux)
                copy_VarMeta(Upres,Uy)
		Ux@longname = "longitudinal gradient of U"
		Uy@longname = "latitudinal gradient of U"
		Ux@units = "1/s"
		Uy@units = "1/s"
; Do the same for V
                Vx = Vpres 
                Vy = Vpres 
                gradsf(Vpres,Vx,Vy)
                copy_VarMeta(Vpres,Vx)
                copy_VarMeta(Vpres,Vy)
                Vx@longname = "longitudinal gradient of V"
                Vy@longname = "latitudinal gradient of V"
                Vx@units = "1/s"
                Vy@units = "1/s"
; Do the same for TH
                THx = TH 
                THy = TH 
                gradsf(TH,THx,THy)
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
                gradsf(Z3pres*g,PSIx,PSIy)

		copy_VarMeta(Z3pres,PSIx)
		copy_VarMeta(Z3pres,PSIy)
                PSIx@longname = "longitudinal gradient of PSI"
                PSIy@longname = "latitudinal gradient of PSI"
                PSIx@units = "m/s2"
                PSIy@units = "m/s2"


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


;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")
	
		setfileoption(fout,"DefineMode",True)
	
; set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout,fAtt)
	
;set dimensions of output file
		dimNames = (/"time","lev_p","lev_int","lat","lon"/)
		dimSizes = (/dims1(0),dimslev(0),dimslevint,dims1(2),dims1(3)/)
		dimUnlim = (/True,False,False,False,False/)
		filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
		filevardef(fout,"lat",typeof(lat),getvardims(lat))
		filevardef(fout,"lon",typeof(lon),getvardims(lon))
		filevardef(fout,"lev_p",typeof(pnew),(/"lev_p"/))
                filevardef(fout,"lev_int",typeof(p_int),(/"lev_int"/))
	
		filevardef(fout,"U",typeof(Upres),getvardims(Upres))
		filevardef(fout,"V",typeof(Vpres),getvardims(Vpres))
		filevardef(fout,"T",typeof(Tpres),getvardims(Tpres))
                filevardef(fout,"TH",typeof(TH),getvardims(TH))
                filevardef(fout,"THp",typeof(THp),getvardims(THp))
		filevardef(fout,"Z3",typeof(Z3pres),getvardims(Z3pres))
                filevardef(fout,"PSI",typeof(PSI),getvardims(PSI))
		filevardef(fout,"Q",typeof(Qpres),getvardims(Qpres))
		filevardef(fout,"OMEGA",typeof(Omegapres),getvardims(Omegapres))
                filevardef(fout,"OMEGAp",typeof(OMEGAp),getvardims(OMEGAp))
                filevardef(fout,"RELHUM",typeof(RELHUMpres),getvardims(RELHUMpres))

                filevardef(fout,"SF",typeof(SFpres),getvardims(SFpres))
                filevardef(fout,"SFza",typeof(SFza),getvardims(SFza))

                filevardef(fout,"Ux",typeof(Ux),getvardims(Ux))
                filevardef(fout,"Uy",typeof(Uy),getvardims(Uy))
                filevardef(fout,"Vx",typeof(Vx),getvardims(Vx))
                filevardef(fout,"Vy",typeof(Vy),getvardims(Vy))
                filevardef(fout,"THx",typeof(THx),getvardims(THx))
                filevardef(fout,"THy",typeof(THy),getvardims(THy))
                filevardef(fout,"PSIx",typeof(PSIx),getvardims(PSIx))
                filevardef(fout,"PSIy",typeof(PSIy),getvardims(PSIy))

                if (Mtrans .EQ. 1) then
	               filevardef(fout,"VV",typeof(VVpres),getvardims(VVpres))
                       filevardef(fout,"VU",typeof(VUpres),getvardims(VUpres))
                       filevardef(fout,"VT",typeof(VTpres),getvardims(VTpres))
                       filevardef(fout,"VQ",typeof(VQpres),getvardims(VQpres))
                       filevardef(fout,"VZ",typeof(VZpres),getvardims(VZpres))

                       filevardef(fout,"VVint",typeof(VVpresInt),getvardims(VVpresInt))
                       filevardef(fout,"VUint",typeof(VUpresInt),getvardims(VUpresInt))
                       filevardef(fout,"VTint",typeof(VTpresInt),getvardims(VTpresInt))
                       filevardef(fout,"VQint",typeof(VQpresInt),getvardims(VQpresInt))
                       filevardef(fout,"VZint",typeof(VZpresInt),getvardims(VZpresInt))
                       
                end if


		fout ->lat    = lat
		fout ->lon    = lon
		fout ->lev_p    = pnew
	
		fout ->U      = Upres
		fout ->V      = Vpres
		fout ->T      = Tpres
                fout ->TH      = TH
                fout ->THp      = THp
		fout ->Z3      = Z3pres
		fout ->PSI	= PSI
		fout ->Q      = Qpres
		fout ->OMEGA      = Omegapres
                fout ->OMEGAp      = OMEGAp
                fout ->RELHUM      = RELHUMpres

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
 
		delete(Experiment)
		delete([/lat,lon,P0mb,U,V,T,Q,Z3,hyam,hybm,PS,Omega,RELHUM/])
		delete(filename)
		delete([/Tpres,Upres,Vpres,Qpres,Z3pres,Omegapres,RELHUMpres/])
	
	end do

end do

end
