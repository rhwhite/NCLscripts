load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;**************************************************************
; take anomalies from the timespan mean, i.e. if running DJF
; then anomalies are from the DJF mean
;****************************************************************

print("Vpr_THpr_Upr")
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

timespan = "Annual"

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

P0 = 1000.0
kappa = 0.286

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

	tmeanTH250 = tofloat(cdf_file->TH(0,nlev_250,:,:))
	tmeanTH850 = tofloat(cdf_file->TH(0,nlev_850,:,:))
	tmeanV250 = cdf_file->V(0,nlev_250,:,:)
	tmeanV850 = cdf_file->V(0,nlev_850,:,:)
	tmeanU250 = cdf_file->U(0,nlev_250,:,:)
	tmeanU850 = cdf_file->U(0,nlev_850,:,:)

	printVarSummary(tmeanV250)

	inputvars = (/"U850","U250","V850","V250","TH250","TH850"/)
	;Loop over variables
	nvars = dimsizes(inputvars)
 
	
	do ivar = 0,nvars -1
                variable = inputvars(ivar)
	
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
		print(filename)
        	cdf_file = addfile(filename,"r")

		if (ivar .eq. 0) then
        		lat = cdf_file->lat
        		lon = cdf_file->lon
        		times  = cdf_file->date
		end if

		if (variable .eq. "U850") then
			tempinvar = cdf_file->U850
			dims = dimsizes(tempinvar)
			do nt = 0,dims(0)-1
				tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanU850(:,:)
			end do
		else if (variable .eq. "U250") then
			tempinvar = cdf_file->U250
                        dims = dimsizes(tempinvar)
                        do nt = 0,dims(0)-1
                                tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanU250(:,:)
                        end do
		else if (variable .eq. "V850") then
			tempinvar = cdf_file->V850
                        dims = dimsizes(tempinvar)
                        do nt = 0,dims(0)-1
                                tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanV850(:,:)
                        end do
		else if (variable .eq. "V250") then
			tempinvar = cdf_file->V250
                        dims = dimsizes(tempinvar)
                        do nt = 0,dims(0)-1
                                tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanV250(:,:)
                        end do
		else if (variable .eq. "TH850") then
			tempinvar = cdf_file->T850 * (P0/850.0)^kappa
			printVarSummary(tempinvar)
			printVarSummary(cdf_file->T850)
			printVarSummary(tmeanTH850)
                        dims = dimsizes(tempinvar)
                        do nt = 0,dims(0)-1
                                tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanTH850(:,:)
                        end do
		else if (variable .eq. "TH250") then
			tempinvar = cdf_file->T250 * (P0/250.0)^kappa
                        dims = dimsizes(tempinvar)
                        do nt = 0,dims(0)-1
                                tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanTH250(:,:)
                        end do
		else
			print("unrecognised variable requested")
			print(variable)	
			exit
		end if
		end if
		end if
		end if
		end if
		end if
	
		invar = tempinvar
		delete(tempinvar)
	


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
                	print(filename)
			cdf_file = addfile(filename,"r")

	                if (ivar .eq. 0) then
	                	time_temp2 = array_append_record(times,cdf_file->date,0)
	                	delete(times)
	                	times = time_temp2
	                	delete(time_temp2)
	                end if
		
			if (variable .eq. "U850") then
				tempinvar = cdf_file->U850
                        	dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanU850(:,:)
				end do
			else if (variable .eq. "U250") then
				tempinvar = cdf_file->U250
                        	dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanU250(:,:)
				end do
			else if (variable .eq. "V850") then
				tempinvar = cdf_file->V850
                                dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanV850(:,:)
				end do
			else if (variable .eq. "V250") then
				tempinvar = cdf_file->V250
                                dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanV250(:,:)
				end do
			else if (variable .eq. "TH850") then
				tempinvar = cdf_file->T850 * (P0/850.0)^kappa
                                dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanTH850(:,:)
				end do
			else if (variable .eq. "TH250") then
				tempinvar = cdf_file->T250 * (P0/250.0)^kappa
                                dims = dimsizes(tempinvar)
				do nt = 0,dims(0)-1
					tempinvar(nt,:,:) = tempinvar(nt,:,:) - tmeanTH250(:,:)
				end do
			else
				print("unrecognised variable requested")
				print(variable)
				exit
			end if
			end if
			end if
			end if
			end if
			end if

                	invar2 = array_append_record(invar,tempinvar,0)
                	delete(tempinvar)
 			delete(invar)
			invar = invar2
			delete(invar2)
		end do


                ndims = dimsizes(invar)
                ntimes = ndims(0)
		nlats = ndims(1)
		nlons = ndims(2)

	; if first variable, then create file
		if ivar .eq. 0 then
			filo = "Upr_Vpr_THpr_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
			system("/bin/rm -f " + Dir + filo)
			fout_std = addfile(Dir + filo, "c")
	
			setfileoption(fout_std,"DefineMode",True)
	
		;set attributes of output file
			fAtt = True
			fAtt@creation_date = systemfunc("date")
			fileattdef(fout_std,fAtt)
		
		;set dimensions of output file
			dimNames = (/"time","lat","lon"/)
			dimSizes = (/ntimes,nlats,nlons/)
			dimUnlim = (/True,False,False/)
			filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
		
			filevardef(fout_std,"times",typeof(times),getvardims(times))
			filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
			filevardef(fout_std,"lon",typeof(lon),getvardims(lon))
		
			filevardef(fout_std,"Upr850",typeof(invar),getvardims(invar))
			filevardef(fout_std,"Vpr850",typeof(invar),getvardims(invar))
			filevardef(fout_std,"Upr250",typeof(invar),getvardims(invar))
			filevardef(fout_std,"Vpr250",typeof(invar),getvardims(invar))
			filevardef(fout_std,"THpr850",typeof(invar),getvardims(invar))
			filevardef(fout_std,"THpr250",typeof(invar),getvardims(invar))
		
		; write standard outputs
			fout_std->times = times
	
			fout_std->lat = lat
			fout_std->lon = lon
		end if

	        if (variable .eq. "U850") then
		        fout_std->Upr850 = (/invar/)
	        else if (variable .eq. "U250") then
	                fout_std->Upr250 = (/invar/)
		else if (variable .eq. "V850") then
	                fout_std->Vpr850 = (/invar/)
	        else if (variable .eq. "V250") then
	                fout_std->Vpr250 = (/invar/)
	        else if (variable .eq. "TH850") then
	                fout_std->THpr850 = (/invar/)
	        else if (variable .eq. "TH250") then
	                fout_std->THpr250 = (/invar/)
	        else
	                print("unrecognised variable requested for writing")
	                print(variable)
	                exit
	        end if
        	end if
        	end if
        	end if
        	end if
        	end if
	
		delete([/invar/])
		
	
	end do
        delete([/lat,lon/])
	delete(times)
	delete(cdf_file)
	
end do

end
