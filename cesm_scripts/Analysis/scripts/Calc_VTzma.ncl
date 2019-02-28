load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_VTmean_ZMA")
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

		filein = "ZMAs_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		cdf_file = addfile(Dir + filein,"r")
                times = cdf_file->time
                lat = cdf_file->lat
                lon = cdf_file->lon

		fordims = cdf_file->U850zma

	       inputvars = (/"UTH850","UTH250","VTH850","VTH250"/)
        ;Loop over variables
	        nvars = dimsizes(inputvars)


	        do ivar = 0,nvars -1
	                variable = inputvars(ivar)
			
			if (variable .eq. "UTH850") then
				prod = cdf_file->U850zma * cdf_file->TH850zma
			else if (variable .eq. "UTH250") then		
                                prod = cdf_file->U250zma * cdf_file->TH250zma
                        else if (variable .eq. "VTH850") then
                                prod = cdf_file->V850zma * cdf_file->TH850zma
                        else if (variable .eq. "VTH250") then
                                prod = cdf_file->V250zma * cdf_file->TH250zma
			else
				print("wrong variable chosen")
				print(variable)
				exit
			end if
			end if
			end if
			end if

			ndims = dimsizes(prod)
			ntimes = ndims(0)
		
		;**************************************
		; take mean over correct timespan
		;*************************************

			if (timespan .eq. "Annual") then
				prod_mean = dim_avg_n(prod,0)
			else if (timespan .eq. "DJF" .or. timespan .eq. "JJA") then
				count = 0
				prod_temp = new(dimsizes(prod),typeof(prod))
		
				do nt = 0,ntimes-1
			        	year = floor(times(nt)/10000.)
			        	month = floor((times(nt) - 10000. * year)/100.)
					if (month .gt. 12 .or. month .lt. 1) then
						print("months not quite right")
						print(month)
						exit
					end if
					
					if (timespan .eq. "DJF") then
			        		if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2) then
			        			prod_temp(count,:,:) = prod(nt,:,:)
			                	        count = count + 1
			       			end if
					else if (timespan .eq. "JJA") then
                                                if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8) then
                                                        prod_temp(count,:,:) = prod(nt,:,:)
                                                        count = count + 1
                                                end if
				        end if
					end if	
				end do
			        prod_mean = dim_avg_n(prod_temp(0:count,:,:),0)
				delete(prod_temp)
			else 
				print("unexpected timespan")
				print(timespan)
				exit
			end if
			end if
	
			ndims2 = dimsizes(prod_mean)
			prod_mean!0 = fordims!1
			prod_mean!1 = fordims!2
			
			delete(prod)

		;-----------------------------------------------------------------------
		; If first variable then create file
		;-----------------------------------------------------------------------
			if (ivar .eq. 0) then
				filo = "VTs_ZMAs_mean" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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
		
				filevardef(fout,"UTH850zma",typeof(prod_mean),getvardims(prod_mean))
        	                filevardef(fout,"UTH250zma",typeof(prod_mean),getvardims(prod_mean))
        	                filevardef(fout,"VTH850zma",typeof(prod_mean),getvardims(prod_mean))
        	                filevardef(fout,"VTH250zma",typeof(prod_mean),getvardims(prod_mean))
		
				fout ->lat    = (/lat/)
				fout ->lon    = (/lon/)
			end if		

                        if (variable .eq. "UTH850") then
                                fout->UTH850zma = (/prod_mean/)
                        else if (variable .eq. "UTH250") then
                                fout->UTH250zma = (/prod_mean/) 
			else if (variable .eq. "VTH850") then
                                fout->VTH850zma = (/prod_mean/)
                        else if (variable .eq. "VTH250") then
                                fout->VTH250zma = (/prod_mean/) 
                        else
                                print("wrong variable chosen")
                                print(variable)
                                exit
                        end if
                        end if
                        end if
                        end if
	
			delete(prod_mean)	
		end do	
	delete(times)
	delete(lat)
	delete(lon)
	delete(cdf_file)

	end do

end do

end
