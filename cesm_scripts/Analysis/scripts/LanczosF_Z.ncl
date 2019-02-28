load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter_Z")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

plev = toint(getenv("NCL_plev"))
print(plev)
print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

timespan = "Annual"

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")

	print(Experiment)

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
	;print("file read in")

	lat = cdf_file->lat
	lon = cdf_file->lon
	if plev .EQ. 850 then
		Z = cdf_file->Z850
	else if plev .EQ. 250 then
		Z = cdf_file->Z250
	else
		print("wrong level - only 850 or 250 permitted")
	end if
	end if

	time  = cdf_file->date
  
	ntim  = dimsizes(Z)
	;print(ntim)   

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
;	print("file read in")
		if plev .EQ. 850 then
			Z_temp = cdf_file->Z250
		else if plev .EQ. 250 then
			Z_temp = cdf_file->Z250
		end if
		end if

		time_temp  = cdf_file->date
 	 
		Z_temp2 = array_append_record(Z,Z_temp,0)
		time_temp2 = array_append_record(time,time_temp,0)
		delete(Z)
		delete(time)
		Z = Z_temp2
		time = time_temp2
		delete(Z_temp2)
		delete(time_temp2)
	
	end do

	ntim  = dimsizes(Z)
;print(ntim)   
print("now filter")

; ***********************************************
; create the filter weights and apply
; ***********************************************
	ihp     = 2                             ; band pass
	sigma   = 1.0                           ; Lanczos sigma

	nWgt    = 1461                           ; 1461 lose half a year at each end = 2*740+1 = 1461  

	dt = 0.25                                ; days per timestep
  
	fca     = dt/6.                        ; low freq, 6 days = 1/24 timesteps
	fcb     = dt/2.                        ; high freq = 2 days = 1/8 timesteps

	wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

	Zbpf_temp = Z
	Zbpf_temp(:,:,:) = 0.0

	do ilat = 0,ntim(1)-1
;	print(ilat * 1)
		do ilon = 0,ntim(2)-1
			Zbpf_temp(:,ilat,ilon) = wgt_runave (Z(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	ndims = dimsizes(Zbpf_temp)
	ntimes = ndims(0)

	Zbpf_temp!0 = Z!0
	Zbpf_temp!1 = Z!1
	Zbpf_temp!2 = Z!2
	delete(Z)


	if (timespan .eq. "Annual")
		ntimes2 = nyears*4*365;
	else if (timespan .eq. "DJF")
       		ntimes2 = nyears*4*(31+31+28);
	else if (timespan .eq. "JJA")
        	ntimes2 = nyears*4*(30+31+31);
	else
		print("timespan is wrong")
		exit
	end if
	end if
	end if

	ntimes2 = ntimes - (731*2)

	Zbpf = new((/ntimes2,ndims(1),ndims(2)/),typeof(Zbpf_temp))
	timebpf = new((/ntimes2/),typeof(time))

	count = 0

	do nt = 731,ntimes-732
		if (timespan .eq. "Annual") then
       	        	Zbpf(count,:,:) = Zbpf_temp(nt,:,:)
               		timebpf(count) = time(nt)
                	count = count + 1
		else
			print("timespan is wrong - only run annual and then select bits later")
		end if
	end do

	Zbpf!0 = Zbpf_temp!0
	Zbpf!1 = Zbpf_temp!1
	Zbpf!2 = Zbpf_temp!2

	delete(Zbpf_temp)
	ndims2 = dimsizes(Zbpf(0:count-1,:,:))
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	filo = "Z" + tostring(plev) + "_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	system("/bin/rm -f " + Dir + filo)
	fout = addfile(Dir + filo, "c")

	setfileoption(fout,"DefineMode",True)

; set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout,fAtt)
	
;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
	filevardef(fout,"time",typeof(timebpf),getvardims(timebpf))
	filevardef(fout,"lat",typeof(lat),getvardims(lat))
	filevardef(fout,"lon",typeof(lon),getvardims(lon))
	
	filevardef(fout,"Zbpf",typeof(Zbpf),getvardims(Zbpf))
	
	fout ->time    = (/timebpf/)
	fout ->lat    = (/lat/)
	fout ->lon    = (/lon/)
	
	fout ->Zbpf = (/Zbpf/)
	
	delete(Zbpf)
	delete(timebpf)
	delete(lat)
	delete(lon)
	delete(Z_temp)
	delete(time_temp)
	delete(time)
end do

end
