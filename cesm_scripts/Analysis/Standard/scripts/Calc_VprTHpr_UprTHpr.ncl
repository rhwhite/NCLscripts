load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("VprTHpr")
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

Rd = 287.0

do exps = 0,nexps-1

	Experiment = Experiments(exps)
	print(Experiment)
	Dir = (Direc + Experiment + "/atm/hist/")

	; Open prime file
	filein = "Upr_Vpr_THpr_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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

        Upr250 = cdf_file->Upr250
        Upr850 = cdf_file->Upr850

	print("read in individual data")

        ndims = dimsizes(Vpr250)
	ntimes = ndims(0)
	nlats = ndims(1)
	nlons = ndims(2)

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

	VprTHpr_250 = new((/ntfin,ndims(1),ndims(2)/),typeof(Vpr250))
	VprTHpr_850 = new((/ntfin,ndims(1),ndims(2)/),typeof(Vpr850))
 
        UprTHpr_250 = new((/ntfin,ndims(1),ndims(2)/),typeof(Upr250))
        UprTHpr_850 = new((/ntfin,ndims(1),ndims(2)/),typeof(Upr850))
 

print(ntfin)

	time = new((/ntfin/),typeof(times))

	print("starting timespan filtering")

	do nt = 0,ntimes-1
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

		if (include) then
			
			if (month .ne. 12 .and. month .ne. 1 .and. month .ne. 2) then
				print("ooops")
				print(month)
				exit
			end if

			VprTHpr_250(count,:,:) = Vpr250(nt,:,:) * THpr250(nt,:,:)
			VprTHpr_850(count,:,:) = Vpr850(nt,:,:) * THpr850(nt,:,:)
	
                        UprTHpr_250(count,:,:) = Upr250(nt,:,:) * THpr250(nt,:,:)
                        UprTHpr_850(count,:,:) = Upr850(nt,:,:) * THpr850(nt,:,:)


			time(count) = times(nt)
			count = count + 1
		end if        
	end do

	print(count)

	VprTHpr_250!0 = THpr250!0
	VprTHpr_250!1 = THpr250!1
	VprTHpr_250!2 = THpr250!2

	copy_VarCoords(VprTHpr_250,VprTHpr_850)
        copy_VarCoords(VprTHpr_250,UprTHpr_250)
        copy_VarCoords(VprTHpr_250,UprTHpr_850)

	delete(THpr250)
	delete(THpr850)
	delete(Vpr250)
	delete(Vpr850)
        delete(Upr250)
        delete(Upr850)


	time!0 = times!0

	ndims250 = dimsizes(VprTHpr_250(0:count-1,:,:))
	ndims850 = dimsizes(VprTHpr_850(0:count-1,:,:))

	print(count)

	mean_VprTHpr_850 = dim_avg_n(VprTHpr_850(0:count-1,:,:),0)	
        mean_VprTHpr_250 = dim_avg_n(VprTHpr_250(0:count-1,:,:),0)

        mean_UprTHpr_850 = dim_avg_n(UprTHpr_850(0:count-1,:,:),0)
        mean_UprTHpr_250 = dim_avg_n(UprTHpr_250(0:count-1,:,:),0)


        mean_VprTHpr_250!0 = VprTHpr_250!1
        mean_VprTHpr_250!1 = VprTHpr_250!2

	copy_VarCoords(mean_VprTHpr_250,mean_VprTHpr_850)
        copy_VarCoords(mean_VprTHpr_250,mean_UprTHpr_250)
        copy_VarCoords(mean_VprTHpr_250,mean_UprTHpr_850)

	ntimes_out = ndims250(0)
	nlats_out = ndims250(1)
	nlons_out = ndims250(2)

	; create file
	filo = "VprTHpr_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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

;	filevardef(fout_std,"VprTpr850",typeof(VprTpr_850),getvardims(VprTpr_850))
;	filevardef(fout_std,"VprTpr250",typeof(VprTpr_250),getvardims(VprTpr_250))
	filevardef(fout_std,"meanVprTHpr850",typeof(mean_VprTHpr_850),getvardims(mean_VprTHpr_850))
	filevardef(fout_std,"meanVprTHpr250",typeof(mean_VprTHpr_250),getvardims(mean_VprTHpr_250))

        filevardef(fout_std,"meanUprTHpr850",typeof(mean_UprTHpr_850),getvardims(mean_UprTHpr_850))
        filevardef(fout_std,"meanUprTHpr250",typeof(mean_UprTHpr_250),getvardims(mean_UprTHpr_250))

	print("output file created, starting write")

; write standard outputs
        fout_std->times = time(0:count-1)

	fout_std->lat = lat
	fout_std->lon = lon

;	fout_std->VprTHpr850 = (/VprTHpr_850(0:count-1,:,:)/)
;	fout_std->VprTHpr250 = (/VprTHpr_250(0:count-1,:,:)/)

        fout_std->meanVprTHpr850 = (/mean_VprTHpr_850(:,:)/)
        fout_std->meanVprTHpr250 = (/mean_VprTHpr_250(:,:)/)
	
        fout_std->meanUprTHpr850 = (/mean_UprTHpr_850(:,:)/)
        fout_std->meanUprTHpr250 = (/mean_UprTHpr_250(:,:)/)

	print("finished write")

	delete(VprTHpr_850)
	delete(VprTHpr_250)
        delete(UprTHpr_850)
        delete(UprTHpr_250)

	delete(mean_VprTHpr_250)
	delete(mean_VprTHpr_850)
        delete(mean_UprTHpr_250)
        delete(mean_UprTHpr_850)


end do

end
