load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;**************************************************************
; Calculate Lanczos filter instead of calculating time anomalies
; Don't need to do this from time mean anomalies, as the filtering
; process is a more sophisticated way of doing this.
;****************************************************************

print("Make Precip Array")
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
        Dir = (Direc + Experiment + "/atm/hist/")
        print(Experiment)
        	
	iyear = startyr

	if iyear .lt. 10 then
		yearstring = ("000" + tostring(iyear))
	else if iyear .lt. 100 then
		yearstring = ("00" + tostring(iyear))
	else if iyear .lt. 1000 then
		yearstring = ("0" + tostring(iyear))
	end if
	end if
	end if

	filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	times  = cdf_file->date

	fordims = cdf_file->PRECC(0:2,:,:)
	invar = cdf_file->PRECC + cdf_file->PRECL

	do iyear = startyr+1,endyr
		if iyear .lt. 10 then
			yearstring = ("000" + tostring(iyear))
		else if iyear .lt. 100 then
			yearstring = ("00" + tostring(iyear))
		else if iyear .lt. 1000 then
			yearstring = ("0" + tostring(iyear))
		end if
		end if
		end if

		filename = (Dir + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
		cdf_file = addfile(filename,"r")

		time_temp2 = array_append_record(times,cdf_file->date,0)
		delete(times)
		times = time_temp2
		delete(time_temp2)

		invar2 = array_append_record(invar,cdf_file->PRECC + cdf_file->PRECL,0)
		delete(invar)
		invar = invar2
		delete(invar2)

	end do

	temp = invar

	ndims = dimsizes(invar)
	ntimes = ndims(0)
	nlats = ndims(1)
	nlons = ndims(2)

	count = 0
	if (timespan .eq. "Annual") then
		ntAnn = nyears*4*(365);
		final = new((/ntAnn,ndims(1),ndims(2)/),typeof(temp))
		time = new((/ntAnn/),typeof(times))
		do nt = 731,ntimes-731
			final(count,:,:) = temp(nt,:,:)
			time(count) = times(nt)
			count = count + 1
		end do
	else if (timespan .eq. "DJF") then
		nDJF = nyears*4*(31+28+31);
		final = new((/nDJF,ndims(1),ndims(2)/),typeof(temp))
		time = new((/nDJF/),typeof(times))

		do nt = 731,ntimes-731
			year = floor(times(nt)/10000.)
			month = floor((times(nt) - 10000. * year)/100.)
			if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2) then
				final(count,:,:) = temp(nt,:,:)
				time(count) = times(nt)
				count = count + 1
			else if (month .gt. 12 .or. month .lt. 1) then
				print("months not quite right!")
				exit
				end if
			end if
		end do
	else if (timespan .eq. "JJA") then
		nJJA = nyears*4*(31+28+31);
		final = new((/nJJA,ndims(1),ndims(2)/),typeof(temp))
		time = new((/nJJA/),typeof(times))

		do nt = 731,ntimes-731
			year = floor(times(nt)/10000.)
			month = floor((times(nt) - 10000. * year)/100.)

			if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
				final(count,:,:) = temp(nt,:,:)
				time(count) = times(nt)
				count = count + 1
			else if (month .gt. 12 .or. month .lt. 1)
				print("months not quite right!")
				exit
			end if
			end if
		end do
	else
		print("timespan incorrect, options Annual, DJF or JJA")

	end if
	end if
	end if
	
	print(fordims!0)
	print(fordims!1)
	print(fordims!2)

	final!0 = fordims!0
	final!1 = fordims!1
	final!2 = fordims!2	

	time!0 = times!0

	delete(temp)
	ndims2 = dimsizes(final(0:count-1,:,:))

; if first variable, then create file
	filo = "Precip_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
	system("/bin/rm -f " + Dir + filo)
	fout_std = addfile(Dir + filo, "c")

	setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

;set dimensions of output file
	dimNames = (/"time","lat","lon"/)
	dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"times",typeof(time),getvardims(time(0:count-1)))
	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
	filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

	filevardef(fout_std,"Precip",typeof(final),getvardims(final))

; write standard outputs
	fout_std->times = time(0:count-1)

	fout_std->lat = lat
	fout_std->lon = lon

	fout_std->Precip = (/final(0:count-1,:,:)/)

	delete(final)
	delete(times)
	delete(cdf_file)
	

end do

end
