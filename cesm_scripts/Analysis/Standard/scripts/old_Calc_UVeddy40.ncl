load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_UVeddy")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

P1013 = 1013.0

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

timespan = "Annual"

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")
	print(Experiment)
; Read in annual mean data

	filename1 = (Dir + "/Annual" + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc")
	cdf_mean = addfile(filename1,"r")
	levs_mean = cdf_mean->lev_p

; Find 250 and 850hpa levels
	levsizes = dimsizes(levs_mean)
	nlevs = levsizes(0)
	
	nlev_250 = -1
	nlev_850 = -1

	do nl = 0,nlevs-1
		if levs_mean(nl) .eq. 250 then
			nlev_250 = nl
		end if
		if levs_mean(nl) .eq. 850 then
			nlev_850 = nl
		end if
	end do

	if (nlev_250 .lt. 0 .or. nlev_850 .lt. 0) then
		print("didnt find a level")
		exit
	end if

	U250_mean = cdf_mean->U(0,nlev_250,:,:)
	U850_mean = cdf_mean->U(0,nlev_850,:,:)
	V250_mean = cdf_mean->V(0,nlev_250,:,:)
	V850_mean = cdf_mean->V(0,nlev_850,:,:)
	T850_mean = cdf_mean->T(0,nlev_850,:,:)

; now calculate potential temperature
	TH850_mean = T850_mean * (P1013/850.0)^(kappa)
	delete(T850_mean)

; Now read in all U,V and T/theta values at 6-hourly intervals before we subtract the mean values

        iyear = startyr
        if iyear .lt. 10
                yearstring = ("000" + tostring(iyear))
        else if iyear .lt. 100
                yearstring = ("00" + tostring(iyear))
        else if iyear .lt. 1000
                yearstring = ("0" + tostring(iyear))
        end if
        end if
        end if

        filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")

	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	U850 = cdf_file->U850
	U250 = cdf_file->U250

	times  = cdf_file->date
 
	do iyear = startyr+1,endyr
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else if iyear .lt. 1000
                        yearstring = ("0" + tostring(iyear))
                end if
                end if
                end if

                filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
 
		cdf_file = addfile(filename,"r")

		fordims = cdf_file->U850
		U850_temp = cdf_file->U850
		U850_temp2 = array_append_record(U850,U850_temp,0)
		delete(U850)
		U850 = U850_temp2
		delete([/U850_temp,U850_temp2/])
	
		U250_temp = cdf_file->U250
		U250_temp2 = array_append_record(U250,U250_temp,0)
		delete(U250)
		U250 = U250_temp2
		delete([/U250_temp,U250_temp2/])

		time_temp  = cdf_file->date
	  	time_temp2 = array_append_record(times,time_temp,0)
		delete(times)
		times = time_temp2
		delete(time_temp2)
	end do

	ntim  = dimsizes(U850)

;Subtract mean values
	U250eddy = new(dimsizes(U250),typeof(U250))
	U850eddy = new(dimsizes(U850),typeof(U850))

	do nt = 0,ntim(0)-1
		U250eddy(nt,:,:) = U250(nt,:,:) - U250_mean
		U850eddy(nt,:,:) = U850(nt,:,:) - U850_mean
	end do
	
;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
	filo = "Eddy_250_850_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	system("/bin/rm -f " + Dir + filo)
	fout = addfile(Dir + filo, "c")

	setfileoption(fout,"DefineMode",True)
	
; set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout,fAtt)
	
;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ntim(0),ntim(1),ntim(2)/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout,dimNames,dimSizes,dimUnlim)

	filevardef(fout,"time",typeof(times),getvardims(times))
	filevardef(fout,"lat",typeof(lat),getvardims(lat))
	filevardef(fout,"lon",typeof(lon),getvardims(lon))
	
	filevardef(fout,"U850eddy",typeof(U850eddy),getvardims(fordims))
	filevardef(fout,"U250eddy",typeof(U850eddy),getvardims(fordims))
	filevardef(fout,"V850eddy",typeof(U850eddy),getvardims(fordims))
	filevardef(fout,"V250eddy",typeof(U850eddy),getvardims(fordims))
	filevardef(fout,"TH850eddy",typeof(U850eddy),getvardims(fordims))
	
	fout ->time    = (/times/)
	fout ->lat    = (/lat/)
	fout ->lon    = (/lon/)
	
	fout ->U850eddy = (/U850eddy/)
	fout ->U250eddy = (/U250eddy/)
	
	print("U out file written")
	
	delete([/U850,U250/])
	delete([/U850eddy,U250eddy/])
	delete([/U850_mean,U250_mean/])
	
	delete(times)
	delete(lat)
	delete(lon)
	delete(fordims)
	
	print("repeat for V")
        iyear = startyr
        if iyear .lt. 10
                yearstring = ("000" + tostring(iyear))
        else if iyear .lt. 100
                yearstring = ("00" + tostring(iyear))
        else if iyear .lt. 1000
                yearstring = ("0" + tostring(iyear))
        end if
        end if
        end if

        filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	V850 = cdf_file->V850
	V250 = cdf_file->V250
  
        do iyear = startyr+1,endyr
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else if iyear .lt. 1000
                        yearstring = ("0" + tostring(iyear))
                end if
                end if
                end if

                filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")

		cdf_file = addfile(filename,"r")

		V850_temp = cdf_file->V850
		V850_temp2 = array_append_record(V850,V850_temp,0)
		delete(V850)
		V850 = V850_temp2
		delete([/V850_temp,V850_temp2/])

		V250_temp = cdf_file->V250
		V250_temp2 = array_append_record(V250,V250_temp,0)
		delete(V250)
		V250 = V250_temp2
		delete([/V250_temp,V250_temp2/])
	end do

	ntim  = dimsizes(V850)

;Subtract mean values
	V250eddy = new(dimsizes(V250),typeof(V250))
	V850eddy = new(dimsizes(V850),typeof(V850))
	
	do nt = 0,ntim(0)-1
		V250eddy(nt,:,:) = V250(nt,:,:) - V250_mean
		V850eddy(nt,:,:) = V850(nt,:,:) - V850_mean
	end do
	
	fout ->V850eddy = (/V850eddy/)
	fout ->V250eddy = (/V250eddy/)
	
	print("V eddies written")
	
	delete([/V850,V250/])
	delete([/V850eddy,V250eddy/])
	delete([/V850_mean,V250_mean/])

;repeat for Theta
	print("repeat for Theta")
	
	iyear = startyr
        if iyear .lt. 10
                yearstring = ("000" + tostring(iyear))
        else if iyear .lt. 100
                yearstring = ("00" + tostring(iyear))
        else if iyear .lt. 1000
                yearstring = ("0" + tostring(iyear))
        end if
        end if
        end if

        filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
 
	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	T850 = cdf_file->T850
	TH850 = T850 * ((P1013/850.0)^(kappa))
	
	delete(T850)

	ntim  = dimsizes(TH850)

        do iyear = startyr+1,endyr
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else if iyear .lt. 1000
                        yearstring = ("0" + tostring(iyear))
                end if
                end if
                end if

                filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
		cdf_file = addfile(filename,"r")

		T850_temp = cdf_file->T850
		TH850_temp = T850_temp * (P1013/850.0)^(kappa)
		TH850_temp2 = array_append_record(TH850,TH850_temp,0)
		delete(TH850)
		TH850 = TH850_temp2
		delete([/TH850_temp,TH850_temp2,T850_temp/])
	
	end do

	ntim  = dimsizes(TH850)

;Subtract mean values
	TH850eddy = new(dimsizes(TH850),typeof(TH850))

	do nt = 0,ntim(0)-1
		TH850eddy(nt,:,:) = TH850(nt,:,:) - TH850_mean
	end do

	fout ->TH850eddy = (/TH850eddy/)

	print(" Theta written")

	delete([/TH850/])
	delete([/TH850eddy/])
	delete([/TH850_mean/])
	
end do

end
