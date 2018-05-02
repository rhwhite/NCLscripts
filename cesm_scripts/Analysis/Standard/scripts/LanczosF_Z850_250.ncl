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

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsecs")

;print(startyr*1)
;print(endyr*1)

nyears = endyr-startyr+1

timespan = "Annual"

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
    Dir = (Direc + Experiment + "/atm/hist/raw/")

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
	Z850 = cdf_file->Z850
    Z250 = cdf_file->Z250

	time  = cdf_file->date
  
	ntim  = dimsizes(Z850)
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

		Z850_temp = cdf_file->Z850
        Z250_temp = cdf_file->Z250

		time_temp  = cdf_file->date
 	 
		Z850_temp2 = array_append_record(Z850,Z850_temp,0)
        Z250_temp2 = array_append_record(Z250,Z250_temp,0)

		time_temp2 = array_append_record(time,time_temp,0)
		delete(Z850)
        delete(Z250)
		delete(time)
		Z850 = Z850_temp2
        Z250 = Z250_temp2
		time = time_temp2
		delete(Z850_temp2)
        delete(Z250_temp2)
		delete(time_temp2)
	
	end do

	ntim  = dimsizes(Z850)

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

	Z850bpf_temp = Z850
	Z850bpf_temp(:,:,:) = 0.0

    Z250bpf_temp = Z250
    Z250bpf_temp(:,:,:) = 0.0


	do ilat = 0,ntim(1)-1
;	print(ilat * 1)
		do ilon = 0,ntim(2)-1
			Z850bpf_temp(:,ilat,ilon) = wgt_runave (Z850(:,ilat,ilon), wgt, 0 )
            Z250bpf_temp(:,ilat,ilon) = wgt_runave (Z250(:,ilat,ilon), wgt, 0 )      ;

		end do
	end do

	ndims = dimsizes(Z850bpf_temp)
	ntimes = ndims(0)

	Z850bpf_temp!0 = Z850!0
	Z850bpf_temp!1 = Z850!1
	Z850bpf_temp!2 = Z850!2
	delete(Z850)

    Z250bpf_temp!0 = Z250!0
    Z250bpf_temp!1 = Z250!1
    Z250bpf_temp!2 = Z250!2
    delete(Z250)


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

	Z850bpf = new((/ntimes2,ndims(1),ndims(2)/),typeof(Z850bpf_temp))
    Z250bpf = new((/ntimes2,ndims(1),ndims(2)/),typeof(Z250bpf_temp))

	timebpf = new((/ntimes2/),typeof(time))

	count = 0

	do nt = 731,ntimes-732
		if (timespan .eq. "Annual") then
       	        	Z850bpf(count,:,:) = Z850bpf_temp(nt,:,:)
                    Z250bpf(count,:,:) = Z250bpf_temp(nt,:,:)
               		timebpf(count) = time(nt)
                	count = count + 1
		else
			print("timespan is wrong - only run annual and then select bits later")
		end if
	end do

	Z850bpf!0 = Z850bpf_temp!0
	Z850bpf!1 = Z850bpf_temp!1
	Z850bpf!2 = Z850bpf_temp!2

    Z250bpf!0 = Z250bpf_temp!0
    Z250bpf!1 = Z250bpf_temp!1
    Z250bpf!2 = Z250bpf_temp!2
 
	delete(Z850bpf_temp)
    delete(Z250bpf_temp)

	ndims2 = dimsizes(Z850bpf(0:count-1,:,:))

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	filo = "Z850_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	system("/bin/rm -f " + Dir + filo)
    setfileoption("nc","format","netcdf4")	; allow us to write variables >2GB

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
	
	;filevardef(fout,"Z850bpf",typeof(Z850bpf),getvardims(Z850bpf))
    ;filevardef(fout,"Z850bpf",typeof(Z850bpf),getvardims(Z850bpf))
	
	fout ->time    = (/timebpf/)
	fout ->lat    = (/lat/)
	fout ->lon    = (/lon/)
	
	fout ->Z850bpf = Z850bpf
    fout ->Z250bpf = Z250bpf

	delete(Z850bpf)
    delete(Z250bpf)
	delete(timebpf)
	delete(lat)
	delete(lon)
	delete(Z850_temp)
    delete(Z250_temp)
	delete(time_temp)
	delete(time)
end do

end
