load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;**************************************************************
; Calculate Lanczos filter instead of calculating time anomalies
; Don't need to do this from time mean anomalies, as the filtering
; process is a more sophisticated way of doing this.
;****************************************************************

print("VprTpr")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do


startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

timespan = "DJF"

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

P1013 = 1013.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

do exps = 0,nexps-1

	Experiment = Experiments(exps)
	print(Experiment)
	Dir = (Direc + Experiment + "/atm/hist/")

	; Open prime file
	filein = "Upr_Vpr_Tpr_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	cdf_file = addfile(Dir + filein,"r")
	lat = cdf_file->lat
	lon = cdf_file->lon
	times = cdf_file->times

	print("read in file")

	; read in individual data 

	THpr250 = cdf_file->THpr250
	THpr850 = cdf_file->THpr850

	Vpr250 = cdf_file->Vpr250
	Vpr850 = cdf_file->Vpr850

	print("read in individual data")

	; Create products

	VprTHpr250 = Vpr250 * THpr250
	VprTHpr850 = Vpr250 * THpr850

	print("created products")

	delete(THpr850)
	delete(Vpr250)
	delete(Vpr850)	


; Lanczos filter


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


        ndims = dimsizes(VprTHpr250)
	ntimes = ndims(0)
	nlats = ndims(1)
	nlons = ndims(2)

	bpf_t250 = new(ndims,typeof(VprTHpr250))
	bpf_t850 = new(ndims,typeof(VprTHpr850))

	print("starting bpf")

	do ilat = 0,nlats-1
		do ilon = 0,nlons-1
			bpf_t250(:,ilat,ilon) = wgt_runave (VprTHpr250(:,ilat,ilon), wgt, 0 )      ;
			bpf_t850(:,ilat,ilon) = wgt_runave (VprTHpr850(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	print("completed bpf")

	delete(VprTHpr250)
	delete(VprTHpr850)

	count = 0
	if (timespan .eq. "Annual") then
		ntfin = nyears*4*(365);
	else if (timespan .eq. "DJF") then
		ntfin = nyears*4*(31+28+31);
	else if (timespan .eq. "JJA") then
		ntfin = nyears*4*(31+28+31);
	else
		print("incorrect timespan, only Annual, DJF or JJA currently allowed")
		print(timespan)
		exit
	end if
	end if
	end if

	bpf_250 = new((/ntfin,ndims(1),ndims(2)/),typeof(bpf_t250))
	bpf_850 = new((/ntfin,ndims(1),ndims(2)/),typeof(bpf_t850))
	timebpf = new((/ntfin/),typeof(times))

	print("starting timespan filtering")

	do nt = 731,ntimes-731
		year = floor(times(nt)/10000.)
		month = floor((times(nt) - 10000. * year)/100.)                
		include = False
		if (month .gt. 12 .or. month .lt. 1) then
			print("months not right")
			print(month)
			exit
		end if

		if (timespan .eq. "Annual") then
			include=True
		else if (timespan .eq. "DJF") then
			if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2) then
				include = True
			end if
		else if (timespan .eq. "JJA") then
			if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
				include = True
			end if
		end if
		end if
		end if

		print(include)

		if (include) then
			bpf_250(count,:,:) = bpf_t250(nt,:,:)
			bpf_850(count,:,:) = bpf_t850(nt,:,:)
			timebpf(count) = times(nt)
			count = count + 1
		end if        
	end do

        delete(bpf_t250)
        delete(bpf_t850)

	print("finished timespan filtering")

	bpf_250!0 = THpr250!0
	bpf_250!1 = THpr250!1
	bpf_250!2 = THpr250!2

	bpf_850!0 = THpr250!0
	bpf_850!1 = THpr250!1
	bpf_850!2 = THpr250!2

	delete(THpr250)

	timebpf!0 = times!0

	ndims250 = dimsizes(bpf_250(0:count-1,:,:))
	ndims850 = dimsizes(bpf_850(0:count-1,:,:))

	print(ndims250)
	print(ndims850)

	mean_bpf_850 = dim_avg_n(bpf_850(0:count-1,:,:),0)	
        mean_bpf_250 = dim_avg_n(bpf_250(0:count-1,:,:),0)

	print(getvardims(mean_bpf_850))
	print(getvardims(bpf_850))
        mean_bpf_250!0 = bpf_250!1
        mean_bpf_250!1 = bpf_250!2

        mean_bpf_850!0 = bpf_850!1
        mean_bpf_850!1 = bpf_850!2
        print(getvardims(mean_bpf_850))


	ntimes_out = ndims250(0)
	nlats_out = ndims250(1)
	nlons_out = ndims250(2)

	; create file
	filo = "VprTpr_bpf" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	system("/bin/rm -f " + Dir + filo)
	fout_std = addfile(Dir + filo, "c")

	setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ntimes_out,nlats_out,nlons_out/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"times",typeof(times),getvardims(times))
	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
	filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

	filevardef(fout_std,"VprTHpr850bpf",typeof(bpf_850),getvardims(bpf_850))
	filevardef(fout_std,"VprTHpr250bpf",typeof(bpf_250),getvardims(bpf_250))
	filevardef(fout_std,"meanVprTHpr850bpf",typeof(mean_bpf_850),getvardims(mean_bpf_850))
	filevardef(fout_std,"meanVprTHpr250bpf",typeof(mean_bpf_250),getvardims(mean_bpf_250))

	print("output file created, starting write")

; write standard outputs
        fout_std->times = timebpf(0:count-1)

	fout_std->lat = lat
	fout_std->lon = lon

	fout_std->VprTHpr850bpf = (/bpf_850(0:count-1,:,:)/)
	fout_std->VprTHpr250bpf = (/bpf_250(0:count-1,:,:)/)

        fout_std->meanVprTHpr850bpf = (/mean_bpf_850(:,:)/)
        fout_std->meanVprTHpr250bpf = (/mean_bpf_250(:,:)/)
	
	print("finished write")

	delete(bpf_850)
	delete(bpf_250)
	delete(mean_bpf_250)
	delete(mean_bpf_850)

end do

end
