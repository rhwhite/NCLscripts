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

timespans = (/"DJF"/) ;,"JJA","MAM","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	pnew           = (/ 10, 20,30,50,70,90,120,150,200,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + "/" + dirstr + "/")
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")
	
	  	cdf_file = addfile(filename,"r")
	
		lat = cdf_file->lat
		lon = cdf_file->lon
		P0mb = 0.01*cdf_file->P0
		U = cdf_file->U
		V = cdf_file->V
		T = cdf_file->T
		Z3 = cdf_file->Z3
		Q = cdf_file->Q

		PHIS = cdf_file->PHIS
		
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


;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_Xpl_" + Experiment + ".cam2.h0.nc"
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
		filevardef(fout,"Z3",typeof(Z3pres),getvardims(Z3pres))
		filevardef(fout,"Q",typeof(Qpres),getvardims(Qpres))

		fout ->lat    = (/lat/)
		fout ->lon    = (/lon/)
		fout ->lev_p    = (/pnew/)
	
		fout ->U      = (/Upres/)
		fout ->V      = (/Vpres/)
		fout ->T      = (/Tpres/)
		fout ->Z3      = (/Z3pres/)
		fout ->Q      = (/Qpres/)

		delete(Experiment)
		delete([/lat,lon,P0mb,U,V,T,Q,Z3,hyam,hybm,PS/])
		delete(filename)
		delete([/Tpres,Upres,Vpres,Qpres,Z3pres/])
	
	end do

end do

end
