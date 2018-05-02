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

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

nts = 1

; Set some constants
PI = 3.14159265358979
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
g = 9.81

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

pnew = (/1.0,2.0,3.0,4.0,5.0,6.0,8.0,10.0,15.0,20.0,25.0,30.0,40.0,50.0,100.0,150.0,200.0,250.0,300.0,400.0,500.0,600.0,700.0,800.0,850.0,900.0,975.0/)

p_int = 10^fspan(1,3,15)   ; interpolation targets 
p_int!0 = "lev_int" 
dimslevint = dimsizes(p_int)


do iexp = 0,nexps-1
	Experiment = Experiments(iexp)
	Dir = (Direc + Experiment + dirstr)
	DirO = (Direc + Experiment + dirstr)	
	print(Experiment)

	do iyear = startyr,endyr
		print(iyear * 1)
        if iyear .LT. 10 then
			yrstr = "0" + tostring(iyear)
		else
			yrstr = tostring(iyear)
		end if

		do imonth = 1,12
			if imonth .LT. 10 then
				monstr = "0" + tostring(imonth)
			else
				monstr = tostring(imonth)
			end if
			filename = (Dir + "/" + Experiments(iexp) + ".cam2.h0.00" + yrstr + "-" + monstr + ".nc")
		
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
			PHIS = cdf_file->PHIS

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

			; Calculate Potential temperature
			TH = Tpres * (conform(Tpres,pnew,1)/1000.0)^(-1.0 * kappa)
			copy_VarCoords(Tpres,TH)

			PV = pot_vort_isobaric(pnew * 100.0,Upres,Vpres,Tpres,lat,1,0)

            NdTHdZ = brunt_vaisala_atm(TH, Z3pres, 1, 1)    ; calculate both
            N = NdTHdZ[0]
            dTHdZ = NdTHdZ[1]
            copy_VarCoords(N,dTHdZ)
	;-----------------------------------------------------------------------
	;Write variables to a new netcdf file, for stat fits in matlab
	;-----------------------------------------------------------------------
            fileo = (DirO + "/NCLoutput_TH_T_Z3_PV_N_" + Experiments(iexp) + ".00" + yrstr + "-" + monstr + ".nc")

			system("/bin/rm -f " + fileo)
			fout = addfile(fileo, "c")
		
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
		
			;filevardef(fout,"lat",typeof(lat),getvardims(lat))
			;filevardef(fout,"lon",typeof(lon),getvardims(lon))
			;filevardef(fout,"lev_p",typeof(pnew),(/"lev_p"/))
		
			;filevardef(fout,"T",typeof(Tpres),getvardims(Tpres))
			;filevardef(fout,"TH",typeof(TH),getvardims(TH))
			;filevardef(fout,"Z3",typeof(Z3pres),getvardims(Z3pres))
			;filevardef(fout,"PV",typeof(PV),getvardims(PV))

			fout ->lat    = lat
			fout ->lon    = lon
			fout ->lev_p    = pnew
		
			fout ->T      = Tpres
			fout ->TH      = TH
            fout ->dTHdZ = dTHdZ
            fout ->N    = N
			fout ->Z3      = Z3pres
			fout ->PV      = PV

		end do
	end do
    delete(Experiment)

end do

end
