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

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

Mtrans = getenv("NCL_Mtrans")
GW = getenv("NCL_GW")

timespans = (/"Annual","DJF","JJA","MAM","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)
        pnew           = (/  20, 50, 100,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + "/atm/hist/")
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	  	cdf_file = addfile(filename,"r")
	
		lat = cdf_file->lat
		lon = cdf_file->lon
		P0mb = 0.01*cdf_file->P0
		U = cdf_file->U
		V = cdf_file->V
		T = cdf_file->T
		TH = cdf_file->TH
		dTHdp = cdf_file->dTHdp
		Z3 = cdf_file->Z3
		Q = cdf_file->Q
		Omega = cdf_file->OMEGA
		OmegaT = cdf_file->dOMEGATdp
		DTcond = cdf_file->DTCOND
		DTv = cdf_file->DTV
		QRL = cdf_file->QRL
		QRS = cdf_file->QRS
		RELHUM = cdf_file->RELHUM


		hyam = cdf_file->hyam
		hybm = cdf_file->hybm
		PS = cdf_file->PS

		dims1 = dimsizes(U)
		dimslev = dimsizes(pnew)

		Tpres = vinth2p(T,hyam,hybm,pnew,PS,1,P0mb,1,True)
                THpres = vinth2p(TH,hyam,hybm,pnew,PS,1,P0mb,1,True)
                dTHdppres = vinth2p(dTHdp,hyam,hybm,pnew,PS,1,P0mb,1,True)
		Upres = vinth2p(U,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Vpres = vinth2p(V,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Z3pres = vinth2p(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Qpres = vinth2p(Q,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Omegapres = vinth2p(Omega,hyam,hybm,pnew,PS,1,P0mb,1,True)
		OmegaTpres = vinth2p(OmegaT,hyam,hybm,pnew,PS,1,P0mb,1,True) 
                DTCONDpres = vinth2p(DTcond,hyam,hybm,pnew,PS,1,P0mb,1,True)
                DTVpres = vinth2p(DTv,hyam,hybm,pnew,PS,1,P0mb,1,True)
                QRLpres = vinth2p(QRL,hyam,hybm,pnew,PS,1,P0mb,1,True)
                QRSpres = vinth2p(QRS,hyam,hybm,pnew,PS,1,P0mb,1,True)
                RELHUMpres = vinth2p(RELHUM,hyam,hybm,pnew,PS,1,P0mb,1,True)


;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")
	
		setfileoption(fout,"DefineMode",True)
	
; set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout,fAtt)
	
;set dimensions of output file
		dimNames = (/"time","lev_p","lat","lon"/)
		dimSizes = (/dims1(0),dimslev(0),dims1(2),dims1(3)/)
		dimUnlim = (/True,False,False,False/)
		filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
		filevardef(fout,"lat",typeof(lat),getvardims(lat))
		filevardef(fout,"lon",typeof(lon),getvardims(lon))
		filevardef(fout,"lev_p",typeof(pnew),(/"lev_p"/))
	
		filevardef(fout,"U",typeof(Upres),getvardims(Upres))
		filevardef(fout,"V",typeof(Vpres),getvardims(Vpres))
		filevardef(fout,"T",typeof(Tpres),getvardims(Tpres))
                filevardef(fout,"TH",typeof(THpres),getvardims(THpres))
                filevardef(fout,"dTHdp",typeof(dTHdppres),getvardims(dTHdppres))
		filevardef(fout,"Z3",typeof(Z3pres),getvardims(Z3pres))
		filevardef(fout,"Q",typeof(Qpres),getvardims(Qpres))
		filevardef(fout,"OMEGA",typeof(Omegapres),getvardims(Omegapres))
                filevardef(fout,"dOMEGATdp",typeof(OmegaTpres),getvardims(OmegaTpres))
		filevardef(fout,"DTCOND",typeof(DTCONDpres),getvardims(DTCONDpres))
                filevardef(fout,"DTV",typeof(DTVpres),getvardims(DTVpres))
                filevardef(fout,"QRL",typeof(QRLpres),getvardims(QRLpres))
                filevardef(fout,"QRS",typeof(QRSpres),getvardims(QRSpres))
                filevardef(fout,"RELHUM",typeof(RELHUMpres),getvardims(RELHUMpres))

		fout ->lat    = (/lat/)
		fout ->lon    = (/lon/)
		fout ->lev_p    = (/pnew/)
	
		fout ->U      = (/Upres/)
		fout ->V      = (/Vpres/)
		fout ->T      = (/Tpres/)
                fout ->TH      = (/THpres/)
                fout ->dTHdp      = (/dTHdppres/)
		fout ->Z3      = (/Z3pres/)
		fout ->Q      = (/Qpres/)
		fout ->OMEGA      = (/Omegapres/)
                fout ->dOMEGATdp      = (/OmegaTpres/)
                fout ->DTCOND      = (/DTCONDpres/)
                fout ->DTV      = (/DTVpres/)
                fout ->QRL      = (/QRLpres/)
                fout ->QRS      = (/QRSpres/)
                fout ->RELHUM      = (/RELHUMpres/)


	
		delete(Experiment)
		delete([/lat,lon,P0mb,U,V,T,Q,Z3,hyam,hybm,PS,Omega,DTcond,DTv,QRL,QRS,RELHUM/])
		delete(filename)
		delete([/Tpres,Upres,Vpres,Qpres,Z3pres,Omegapres,OmegaTpres,DTCONDpres,DTVpres,QRLpres,QRSpres,RELHUMpres/])
	
	end do

end do

end
