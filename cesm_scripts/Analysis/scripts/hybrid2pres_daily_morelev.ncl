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

timespans = (/"Annual"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)


cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	pnew           = (/ 10, 20,30,50,70,90,120,150,200,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

	do exps = 0,nexps-1
		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + "/atm/hist/")

		print(Experiment)
                filePHIS = (Dir + Experiment + ".cam2.h0.0002-01.nc")

		do iyear = startyr,endyr
			print(tostring(iyear))
			if iyear .LT. 10
				syear = "0" + tostring(iyear)
			else
				syear = tostring(iyear)
			end if

			filename = (Dir + Experiment + ".cam2.h2.00" + syear + "-01-01-00000.nc")
		
			cdf_file = addfile(filename,"r")
            cdf_file_PHIS = addfile(filePHIS,"r")


			timesin = cdf_file->time
			datesin = cdf_file->date
			lat = cdf_file->lat
			lon = cdf_file->lon
			P0mb = 0.01*cdf_file->P0
			U = cdf_file->U
			V = cdf_file->V
			T = cdf_file->T
			Z3 = cdf_file->Z3
			TBOT = cdf_file->TBOT

			PHIS = cdf_file_PHIS->PHIS(0,:,:)
                        PS = cdf_file->PS
	
			levs = cdf_file->lev
			nlevs = dimsizes(levs)

			hyam = cdf_file->hyam
			hybm = cdf_file->hybm
			
			p0 = tofloat(cdf_file->P0)

		        p = pres_hybrid_ccm(PS,p0,hyam,hybm)

			dims1 = dimsizes(U)
			dimslev = dimsizes(pnew)

			; Calculate PV
			gridtype = 1    ; normal grid

			PV = pot_vort_hybrid(p,U,V,T,lat,gridtype,0)

			copy_VarCoords(U,PV)


			Tpres = vinth2p_ecmwf(T,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
			Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
			Vpres = vinth2p_ecmwf(V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
			PVpres = vinth2p_ecmwf(PV,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
			;Z3pres = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True,-1,TBOT,conform(PS,PHIS,(/1,2/))) 
			;Qpres = vinth2p_ecmwf(Q,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 

        		THETA = Tpres * (conform(Tpres,pnew,1)/1000.0)^(-1.0 * kappa)
			copy_VarCoords(Tpres,THETA)
		        Uza = dim_rmvmean_Wrap(Upres(time|:,lev_p|:,lat|:,lon|:))   ; removes mean of rightmost dimension
		        Vza = dim_rmvmean_Wrap(Vpres(time|:,lev_p|:,lat|:,lon|:))   ; removes mean of rightmost dimension
		        THETAza = dim_rmvmean_Wrap(THETA(time|:,lev_p|:,lat|:,lon|:))

		        UV = Uza * Vza
        		copy_VarMeta(Uza,UV)

		        VTHETA = Vza * THETAza
        		copy_VarCoords(Vza,VTHETA)


	;-----------------------------------------------------------------------
	;Write variables to a new netcdf file, for stat fits in matlab
	;-----------------------------------------------------------------------
			filo = "Daily_mean_yr" + syear + "_Xpl_" + Experiment + ".cam2.h2.nc"
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
		
			filevardef(fout,"time",typeof(timesin),getvardims(timesin))
			filevardef(fout,"date",typeof(datesin),getvardims(datesin))
			filevardef(fout,"lat",typeof(lat),getvardims(lat))
			filevardef(fout,"lon",typeof(lon),getvardims(lon))
			filevardef(fout,"lev_p",typeof(pnew),(/"lev_p"/))
		
			filevardef(fout,"U",typeof(Upres),getvardims(Upres))
			filevardef(fout,"V",typeof(Vpres),getvardims(Vpres))
			filevardef(fout,"T",typeof(Tpres),getvardims(Tpres))
                        filevardef(fout,"PV",typeof(PVpres),getvardims(PVpres))

			filevardef(fout,"UV",typeof(UV),getvardims(UV))
			filevardef(fout,"VTHETA",typeof(VTHETA),getvardims(VTHETA))

			fout ->lat    = (/lat/)
			fout ->lon    = (/lon/)
			fout ->lev_p    = (/pnew/)
			fout ->time = timesin
			fout ->date = datesin
			fout ->U = Upres
			fout ->T      = Tpres
			fout ->UV      = UV
			fout ->VTHETA      = VTHETA
			fout ->PV	= PVpres
	
		end do	
	end do

end do

end
