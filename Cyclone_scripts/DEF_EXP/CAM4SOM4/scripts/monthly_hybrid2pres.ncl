;load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
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

pnew = (/1000,925,850,700,600,500,400,300,250,200,150,100,70,50,30,20,10/)
pnewSH = (/1000,925,850,700,600,500,400,300/)


do imonth = 1,12
	if imonth .lt. 10 then
		stringmonth = "0" + tostring(imonth)
	else
		stringmonth = tostring(imonth)
	end if
	
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + "/atm/hist/")
	
		print(Experiment)

		filename = (Dir + "MonMean_" + tostring(startyr) + "_" + tostring(nyears) + "_" + stringmonth + "_" + Experiment + ".cam2.h0.nc")
	
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
		SST = cdf_file->SST
		ICEFRAC = cdf_file->ICEFRAC

		hyam = cdf_file->hyam
		hybm = cdf_file->hybm
		PS = cdf_file->PS

		dims1 = dimsizes(U)
		dimslev = dimsizes(pnew)
		dimslevSH = dimsizes(pnewSH)

		Tpres = vinth2p(T,hyam,hybm,pnew,PS,1,P0mb,1,True)
		Upres = vinth2p(U,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Vpres = vinth2p(V,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Z3pres = vinth2p(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True) 
		Qpres = vinth2p(Q,hyam,hybm,pnewSH,PS,1,P0mb,1,True) 
		Omegapres = vinth2p(Omega,hyam,hybm,pnew,PS,1,P0mb,1,True) 

		copy_VarAtts(T,Tpres)
                copy_VarAtts(U,Upres)
                copy_VarAtts(V,Vpres)
                copy_VarAtts(Z3,Z3pres)
                copy_VarAtts(Q,Qpres)
                copy_VarAtts(Omega,Omegapres)

		delete(Tpres&time)
                delete(Qpres&time)
                delete(Upres&time)
                delete(Vpres&time)
                delete(Z3pres&time)
                delete(Omegapres&time)


		if Qpres@units .EQ. "kg/kg"
			print("converting units")
			Qpres = Qpres * 1000.0 ;
			Qpres@units = "g/kg"
		end if 

;-----------------------------------------------------------------------
;Write variables to a new netcdf file, all expect SH 
;-----------------------------------------------------------------------
		filo = "MonMean_pl_" + tostring(startyr) + "_" + tostring(nyears) + "_" + stringmonth + "_" + Experiment + ".cam2.h0.nc"
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
		filevardef(fout,"OMEGA",typeof(Omegapres),getvardims(Omegapres))

		fout ->lat    = (/lat/)
		fout ->lon    = (/lon/)
		fout ->lev_p    = (/pnew/)
	
		fout ->U      = (Upres)
		fout ->V      = (Vpres)
		fout ->T      = (Tpres)
		fout ->Z3      = (Z3pres)
		fout ->OMEGA      = (Omegapres)


                
;-----------------------------------------------------------------------
;Repeat for SH 
;-----------------------------------------------------------------------
                filo = "MonMean_SH_pl_" + tostring(startyr) + "_" + tostring(nyears) + "_" + stringmonth + "_" + Experiment + ".cam2.h0.nc"  
                system("/bin/rm -f " + Dir + filo)
                fout = addfile(Dir + filo, "c")
                
                setfileoption(fout,"DefineMode",True)
                
; set attributes of output file
                fAtt = True
                fAtt@creation_date = systemfunc("date")
                fileattdef(fout,fAtt)
                
;set dimensions of output file
                dimNames = (/"time","lev_p","lat","lon"/)
                dimSizes = (/dims1(0),dimslevSH(0),dims1(2),dims1(3)/)
                dimUnlim = (/True,False,False,False/)
                filedimdef(fout,dimNames,dimSizes,dimUnlim)
                
                filevardef(fout,"lat",typeof(lat),getvardims(lat))
                filevardef(fout,"lon",typeof(lon),getvardims(lon))
                filevardef(fout,"lev_p",typeof(pnewSH),(/"lev_p"/))
                
                filevardef(fout,"Q",typeof(Qpres),getvardims(Qpres))
                
                fout ->lat    = (/lat/)
                fout ->lon    = (/lon/)
                fout ->lev_p    = (/pnewSH/)

                fout ->Q      = (Qpres)



	
; Now do something similar with the SST and ICEFRAC fields, so we get them without the time variables

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
                filoS = "MonMean_Surf_" + tostring(startyr) + "_" + tostring(nyears) + "_" + stringmonth + "_" + Experiment + ".cam2.h0.nc"
                system("/bin/rm -f " + Dir + filoS)
                foutS = addfile(Dir + filoS, "c")

                setfileoption(foutS,"DefineMode",True)

; set attributes of output file
                fAtt = True
                fAtt@creation_date = systemfunc("date")
                fileattdef(foutS,fAtt)

;set dimensions of output file
                dimNamesS = (/"time","lat","lon"/)
                dimSizesS = (/dims1(0),dims1(2),dims1(3)/)
                dimUnlimS = (/True,False,False/)
                filedimdef(foutS,dimNamesS,dimSizesS,dimUnlimS)

                filevardef(foutS,"lat",typeof(lat),getvardims(lat))
                filevardef(foutS,"lon",typeof(lon),getvardims(lon))

                filevardef(foutS,"SST",typeof(SST),getvardims(SST))
                filevardef(foutS,"ICEFRAC",typeof(ICEFRAC),getvardims(ICEFRAC))

                foutS ->lat    = (/lat/)
                foutS ->lon    = (/lon/)

                foutS ->SST      = (/SST/)
                foutS ->ICEFRAC      = (/ICEFRAC/)

                delete(Experiment)
                delete([/lat,lon,P0mb,U,V,T,Q,Z3,hyam,hybm,PS,Omega/])
                delete(filename)
                delete([/Tpres,Upres,Vpres,Qpres,Z3pres,Omegapres/])
		delete([/SST,ICEFRAC/])
	
	end do

end do

end
