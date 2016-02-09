load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_VT_EKE")
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

timespans= (/"DJF"/)
ntdims = dimsizes(timespans)
nts = ntdims(0)


do ts = 0,nts-1

	timespan = timespans(ts)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		print(Experiment)
                Dir = (Direc + Experiment + "/atm/hist/")

                ; Get time mean fields
		filein = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"
		cdf_file = addfile(Dir + filein,"r")
                lat = cdf_file->lat
                lon = cdf_file->lon
		levs_mean = cdf_file->lev_p
		nlevs = dimsizes(levs_mean)

		; find right pressure level
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
		
		tmeanT250 = cdf_file->T(0,nlev_250,:,:)
		tmeanT850 = cdf_file->T(0,nlev_850,:,:)
		tmeanV250 = cdf_file->V(0,nlev_250,:,:)
		tmeanV850 = cdf_file->V(0,nlev_850,:,:)
		tmeanU250 = cdf_file->U(0,nlev_250,:,:)
		tmeanU850 = cdf_file->U(0,nlev_850,:,:)

		EKE250 = new(dimsizes(tmeanT250),typeof(tmeanU250))
                EKE850 = new(dimsizes(tmeanT250),typeof(tmeanU250))
		VprTpr250 = new(dimsizes(tmeanT250),typeof(tmeanV250))
		VprTpr850 = new(dimsizes(tmeanT850),typeof(tmeanV250))

		EKE250(:,:) = 0.0
		EKE850(:,:) = 0.0
		VprTpr250(:,:) = 0.0
		VprTpr850(:,:) = 0.0

		count = 0.0

                do iyear = startyr,endyr
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
			ntimes = dimsizes(times)
			print(ntimes)
			print(iyear)

			do nt = 0,ntimes-1
				year = floor(times(nt)/10000.)
				month = floor((times(nt) - 10000. * year)/100.)
                                
				if (timespan .eq. "DJF") then	
					if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2) then
						EKE250temp = ((cdf_file->U250(nt,:,:) - tmeanU250) * (cdf_file->U250(nt,:,:) - tmeanU250)) + ((cdf_file->V250(nt,:,:) - tmeanV250) * (cdf_file->V250(nt,:,:) - tmeanV250)) 	
                                                EKE850temp = ((cdf_file->U850(nt,:,:) - tmeanU850) * (cdf_file->U850(nt,:,:) - tmeanU850)) + ((cdf_file->V850(nt,:,:) - tmeanV850) * (cdf_file->V850(nt,:,:) - tmeanV850))
						VprTpr250temp = ((cdf_file->V250(nt,:,:) - tmeanV250) * (cdf_file->T250(nt,:,:) - tmeanT250))
                                                VprTpr850temp = ((cdf_file->V850(nt,:,:) - tmeanV850) * (cdf_file->T850(nt,:,:) - tmeanT850))

						EKE250 = EKE250 + EKE250temp
						EKE850 = EKE850 + EKE850temp
						VprTpr250 = VprTpr250 + VprTpr250temp
						VprTpr850 = VprTpr850 + VprTpr850temp

						count = count + 1.0
					else if (month .gt. 12 .or. month .lt. 1) then
						print("months not quite right!")
						exit
						end if
					end if
				else
					print("incompatible season")
					exit
				end if	
			end do
			print(max(EKE250) * 1.0)
			print(count)
		end do
	
		print(count)
  		EKE250 = EKE250/count
		EKE850 = EKE850/count
		VprTpr250 = VprTpr250/count
		VprTpr850 = VprTpr850/count
	
		ndims2 = dimsizes(EKE250)
		print(ndims2)	
		;-----------------------------------------------------------------------
		; Create output file
		;-----------------------------------------------------------------------
		filo = "EKE_mean_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")

		setfileoption(fout,"DefineMode",True)

	; set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout,fAtt)

	;set dimensions of output file
		dimNames = (/"time","lat","lon"/)
		dimSizes = (/1,ndims2(0),ndims2(1)/)
		dimUnlim = (/True,False,False/)
		filedimdef(fout,dimNames,dimSizes,dimUnlim)

		filevardef(fout,"lat",typeof(lat),getvardims(lat))
		filevardef(fout,"lon",typeof(lon),getvardims(lon))

		filevardef(fout,"EKE850",typeof(EKE850),getvardims(tmeanU250))
		filevardef(fout,"EKE250",typeof(EKE250),getvardims(tmeanU250))
		filevardef(fout,"VprTpr850",typeof(EKE850),getvardims(tmeanU250))
		filevardef(fout,"VprTpr250",typeof(EKE250),getvardims(tmeanU250))

		fout ->lat    = (/lat/)
		fout ->lon    = (/lon/)

		fout->EKE850 = (/EKE850/)
		fout->EKE250 = (/EKE250/) 
		fout->VprTpr850 = (/VprTpr850/)
		fout->VprTpr250 = (/VprTpr250/) 
	

		delete([/EKE850,EKE250,VprTpr850,VprTpr250,times,lat,lon,tmeanU250,tmeanU850,tmeanV250,tmeanV850,tmeanT250,tmeanT850/])
		delete(cdf_file)

	end do

end do

end
