load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_UVTh_AZMs")
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

; Now read in all U,V and T/theta values and write out in one file 
       inputvars = (/"U850","U250","V850","V250","TH850","TH250"/)
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
                cdf_file = addfile(filename,"r")

                if (ivar .eq. 0) then
                        lat = cdf_file->lat
                        lon = cdf_file->lon
                        times  = cdf_file->date
                end if

                if (variable .eq. "U850") then
                        invar = cdf_file->U850
                else if (variable .eq. "U250") then
                        invar = cdf_file->U250
                else if (variable .eq. "V850") then
                        invar = cdf_file->V850
                else if (variable .eq. "V250") then
                        invar = cdf_file->V250
                else if (variable .eq. "TH850") then
                        invar = cdf_file->T850
		else if (variable .eq. "TH250") then
                        invar = cdf_file->T250
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

	                if (ivar .eq. 0) then
	                        time_temp2 = array_append_record(times,cdf_file->date,0)
	                        delete(times)
	                        times = time_temp2
	                        delete(time_temp2)
			end if
	
	                if (variable .eq. "U850") then
	                        invar2 = array_append_record(invar,cdf_file->U850,0)
	                        delete(invar)
	                        invar = invar2
	                        delete(invar2)
	                else if (variable .eq. "U250") then
	                        invar2 = array_append_record(invar,cdf_file->U250,0)
	                        delete(invar)
	                        invar = invar2
	                        delete(invar2)
	                else if (variable .eq. "V850") then
	                        invar2 = array_append_record(invar,cdf_file->V850,0)
	                        delete(invar)
	                        invar = invar2
	                        delete(invar2)
	                else if (variable .eq. "V250") then
	                        invar2 = array_append_record(invar,cdf_file->V250,0)
	                        delete(invar)
	                        invar = invar2
	                        delete(invar2)
	                else if (variable .eq. "TH850") then
	                        invar2 = array_append_record(invar,cdf_file->T850,0)
				delete(invar)
	                        invar = invar2
	                        delete(invar2)
	                else if (variable .eq. "TH250") then
		                invar2 = array_append_record(invar,cdf_file->T250,0)
				delete(invar)
	                        invar = invar2
	                        delete(invar2)
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
	
	        end do

		if (variable .eq. "TH850") then
                	print(variable)
		        invar = invar * (P1013/850.0)^kappa
		else if (variable .eq. "TH250") then
                        print(variable)
			invar = invar * (P1013/250.0)^kappa
		end if
		end if

                ndims = dimsizes(invar)
                ntimes = ndims(0)
                nlats = ndims(1)
                nlons = ndims(2)
;***************************************************
; Create zonal mean anomaly
;****************************************************
		invar_azm = new(dimsizes(invar),typeof(invar))

		do ilon = 0, nlons-1
			invar_azm(:,:,ilon) = invar(:,:,ilon) - dim_avg_n(invar,2)
		end do
;**************************************************************
; if first variable, create file
;*************************************************************
		if ivar .eq. 0

			filo = "ZMAs_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
			system("/bin/rm -f " + Dir + filo)
			fout = addfile(Dir + filo, "c")

			setfileoption(fout,"DefineMode",True)
	
	; set attributes of output file
			fAtt = True
			fAtt@creation_date = systemfunc("date")
			fileattdef(fout,fAtt)
	
	;set dimensions of output file
			dimNames = (/"time","lat","lon"/)
			dimSizes = (/ndims(0),ndims(1),ndims(2)/)
			dimUnlim = (/True,False,False/)
			filedimdef(fout,dimNames,dimSizes,dimUnlim)
	
			filevardef(fout,"time",typeof(times),getvardims(times))
			filevardef(fout,"lat",typeof(lat),getvardims(lat))
			filevardef(fout,"lon",typeof(lon),getvardims(lon))
	
			filevardef(fout,"U850zma",typeof(invar_azm),getvardims(invar))
			filevardef(fout,"U250zma",typeof(invar_azm),getvardims(invar))
			filevardef(fout,"V850zma",typeof(invar_azm),getvardims(invar))
			filevardef(fout,"V250zma",typeof(invar_azm),getvardims(invar))
			filevardef(fout,"TH850zma",typeof(invar_azm),getvardims(invar))
                        filevardef(fout,"TH250zma",typeof(invar_azm),getvardims(invar))

			fout ->time    = (/times/)
			fout ->lat    = (/lat/)
			fout ->lon    = (/lon/)
		end if
		delete(invar)

                if (variable .eq. "U850") then
                        fout->U850zma = (/invar_azm(:,:,:)/)
                else if (variable .eq. "U250") then
                        fout->U250zma = (/invar_azm(:,:,:)/)
                else if (variable .eq. "V850") then
                        fout->V850zma = (/invar_azm(:,:,:)/)
                else if (variable .eq. "V250") then
                        fout->V250zma = (/invar_azm(:,:,:)/)
                else if (variable .eq. "TH850") then
                        fout->TH850zma = (/invar_azm(:,:,:)/)
                else if (variable .eq. "TH250") then
                        fout->TH250zma = (/invar_azm(:,:,:)/)
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

		delete(invar_azm)
	end do
	delete(times)
	delete(Experiment)
	delete(Dir)
end do

end
