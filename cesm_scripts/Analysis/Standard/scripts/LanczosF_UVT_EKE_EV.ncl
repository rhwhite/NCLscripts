load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;**************************************************************
; Calculate Lanczos filter instead of calculating time anomalies
; Don't need to do this from time mean anomalies, as the filtering
; process is a more sophisticated way of doing this.
;****************************************************************

print("Lanczos_Filter_Time")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
    Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do


startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsecs")

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

        filename = (Dir + "/raw/" + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
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

            filename = (Dir + "/raw/" + Experiment + ".cam2.h1." + yearstring +"-01-01-" + secs + ".nc")
            cdf_file = addfile(filename,"r")

            if (ivar .eq. 0) then
                time_temp2 = array_append_record(times,cdf_file->date,0)
                delete(times)
                times = time_temp2
                delete(time_temp2)
            end if

            if (variable .eq. "U850") then
                invar2 = array_append_record(invar,cdf_file->U850,0) 
            else if (variable .eq. "U250") then
                invar2 = array_append_record(invar,cdf_file->U250,0)
            else if (variable .eq. "V850") then
                invar2 = array_append_record(invar,cdf_file->V850,0)
            else if (variable .eq. "V250") then
                invar2 = array_append_record(invar,cdf_file->V250,0)
            else if (variable .eq. "TH850") then
                invar2 = array_append_record(invar,cdf_file->T850,0)
            else if (variable .eq. "TH250") then
                invar2 = array_append_record(invar,cdf_file->T250,0)
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
            delete(invar)
            invar = invar2
            delete(invar2)

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

		bpf_temp = new(ndims,typeof(invar))	
		do ilat = 0,nlats-1
			do ilon = 0,nlons-1
				bpf_temp(:,ilat,ilon) = wgt_runave (invar(:,ilat,ilon), wgt, 0 )      ;
			end do
		end do
	
		bpf_temp!0 = invar!0
		bpf_temp!1 = invar!1
		bpf_temp!2 = invar!2
		delete(invar)
		
		count = 0
		if (timespan .eq. "Annual") then
            ntAnn = nyears*4*(365);
            bpf = new((/ntAnn,ndims(1),ndims(2)/),typeof(bpf_temp))
            timebpf = new((/ntAnn/),typeof(times))
            do nt = 731,ntimes-731
                bpf(count,:,:) = bpf_temp(nt,:,:)
                timebpf(count) = times(nt)
                count = count + 1
            end do
		else if (timespan .eq. "DJF") then
            nDJF = nyears*4*(31+28+31);
            bpf = new((/nDJF,ndims(1),ndims(2)/),typeof(bpf_temp))
            timebpf = new((/nDJF/),typeof(times))
	
			do nt = 731,ntimes-731
                year = floor(times(nt)/10000.)
                month = floor((times(nt) - 10000. * year)/100.)
				
                if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2) then
					bpf(count,:,:) = bpf_temp(nt,:,:)
					timebpf(count) = times(nt)
					count = count + 1
                else if (month .gt. 12 .or. month .lt. 1) then
                    print("months not quite right!")
                    exit
                end if
        	    end if
			end do

        else if (timespan .eq. "MAM") then
            nMAM = nyears*4*(31+30+31);
            bpf = new((/nMAM,ndims(1),ndims(2)/),typeof(bpf_temp))
            timebpf = new((/nMAM/),typeof(times))

            do nt = 731,ntimes-731
                year = floor(times(nt)/10000.)
                month = floor((times(nt) - 10000. * year)/100.)

                if (month .eq. 3 .or. month .eq. 4 .or. month .eq. 5) then
                    bpf(count,:,:) = bpf_temp(nt,:,:)
                    timebpf(count) = times(nt)
                    count = count + 1
                else if (month .gt. 12 .or. month .lt. 1) then
                    print("months not quite right!")
                    exit
                end if
                end if
            end do

		else if (timespan .eq. "JJA") then
            nJJA = nyears*4*(30+31+31);
            bpf = new((/nJJA,ndims(1),ndims(2)/),typeof(bpf_temp))
            timebpf = new((/nJJA/),typeof(times))

            do nt = 731,ntimes-731
                year = floor(times(nt)/10000.)
                month = floor((times(nt) - 10000. * year)/100.)

                if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                        bpf(count,:,:) = bpf_temp(nt,:,:)
                        timebpf(count) = times(nt)
                        count = count + 1
                else if (month .gt. 12 .or. month .lt. 1)
                        print("months not quite right!")
                        exit
                end if
                end if
            end do
        else if (timespan .eq. "SON") then
            nSON = nyears*4*(30+31+30);
            bpf = new((/nSON,ndims(1),ndims(2)/),typeof(bpf_temp))
            timebpf = new((/nSON/),typeof(times))
            
            do nt = 731,ntimes-731
                year = floor(times(nt)/10000.)
                month = floor((times(nt) - 10000. * year)/100.)
                
                if (month .eq. 9 .or. month .eq. 10 .or. month .eq. 11)
                        bpf(count,:,:) = bpf_temp(nt,:,:)
                        timebpf(count) = times(nt)
                        count = count + 1
                else if (month .gt. 12 .or. month .lt. 1)
                        print("months not quite right!")
                        exit
                end if  
                end if  
            end do

		else
			print("timespan incorrect, options Annual, DJF,MAM, JJA or SON")
	
		end if
		end if
		end if
	    end if
        end if
	
		bpf!0 = bpf_temp!0
		bpf!1 = bpf_temp!1
		bpf!2 = bpf_temp!2	

		timebpf!0 = times!0
	
		delete(bpf_temp)
		ndims2 = dimsizes(bpf(0:count-1,:,:))
		
	
    	; if first variable, then create file
		if ivar .eq. 0 then
			filo = "EKE_VT_EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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
		
			filevardef(fout_std,"times",typeof(timebpf),getvardims(timebpf(0:count-1)))
			filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
			filevardef(fout_std,"lon",typeof(lon),getvardims(lon))
		
			filevardef(fout_std,"U850tdash_bpf",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"U250tdash_bpf",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"V850tdash_bpf",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"V250tdash_bpf",typeof(bpf),getvardims(bpf))
			
			filevardef(fout_std,"U850tdash_bpf_2",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"U250tdash_bpf_2",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"V850tdash_bpf_2",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"V250tdash_bpf_2",typeof(bpf),getvardims(bpf))

            filevardef(fout_std,"TH850tdash_bpf",typeof(bpf),getvardims(bpf))
            filevardef(fout_std,"TH250tdash_bpf",typeof(bpf),getvardims(bpf))
		
			filevardef(fout_std,"EKE850tdash_bpf",typeof(bpf),getvardims(bpf))
			filevardef(fout_std,"EKE250tdash_bpf",typeof(bpf),getvardims(bpf))
		
		    ; write standard outputs
			fout_std->times = timebpf(0:count-1)
	
			fout_std->lat = lat
			fout_std->lon = lon
		end if

        if (variable .eq. "U850") then
            fout_std->U850tdash_bpf = (/bpf(0:count-1,:,:)/)
        else if (variable .eq. "U250") then
            fout_std->U250tdash_bpf = (/bpf(0:count-1,:,:)/)
		else if (variable .eq. "V850") then
            fout_std->V850tdash_bpf = (/bpf(0:count-1,:,:)/)
        else if (variable .eq. "V250") then
            fout_std->V250tdash_bpf = (/bpf(0:count-1,:,:)/)
        else if (variable .eq. "TH850") then
            fout_std->TH850tdash_bpf = (/bpf(0:count-1,:,:)/)
        else if (variable .eq. "TH250") then
            fout_std->TH250tdash_bpf = (/bpf(0:count-1,:,:)/)
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
	
		delete([/bpf/])
	
	end do
    delete([/lat,lon,timebpf/])
	delete(times)
	delete(cdf_file)
	
; Calculate products

	U850bpf_2 = fout_std->U850tdash_bpf*fout_std->U850tdash_bpf
	U850bpf_2!0 = fout_std->U850tdash_bpf!0
	U850bpf_2!1 = fout_std->U850tdash_bpf!1
	U850bpf_2!2 = fout_std->U850tdash_bpf!2
	print("calc U^2 850")

	fout_std->U850tdash_bpf_2 = (/U850bpf_2/)

	delete(U850bpf_2)

	V850bpf_2 = fout_std->V850tdash_bpf*fout_std->V850tdash_bpf
	V850bpf_2!0 = fout_std->V850tdash_bpf!0
	V850bpf_2!1 = fout_std->V850tdash_bpf!1
	V850bpf_2!2 = fout_std->V850tdash_bpf!2
	print("calc V^2 850")

	fout_std->V850tdash_bpf_2 = (/V850bpf_2/)

	delete(V850bpf_2)

	U250bpf_2 = fout_std->U250tdash_bpf*fout_std->U250tdash_bpf
	U250bpf_2!0 = fout_std->U250tdash_bpf!0
	U250bpf_2!1 = fout_std->U250tdash_bpf!1
	U250bpf_2!2 = fout_std->U250tdash_bpf!2
	print("calc U^2 250")

	fout_std->U250tdash_bpf_2 = (/U250bpf_2/)

	delete(U250bpf_2)

	V250bpf_2 = fout_std->V250tdash_bpf*fout_std->V250tdash_bpf
	V250bpf_2!0 = fout_std->V250tdash_bpf!0
	V250bpf_2!1 = fout_std->V250tdash_bpf!1
	V250bpf_2!2 = fout_std->V250tdash_bpf!2
	print("calc V^2 250")
	
	fout_std->V250tdash_bpf_2 = (/V250bpf_2/)

	delete(V250bpf_2)

	print("calculated all bpf eddy winds squared")

; Calc EKEs

	EKE850bpf = 0.5 * fout_std->U850tdash_bpf_2 + fout_std->V850tdash_bpf_2
	print("calc U^2 + V^2 850")

	EKE850bpf!0 = fout_std->U850tdash_bpf_2!0
	EKE850bpf!1 = fout_std->U850tdash_bpf_2!1
	EKE850bpf!2 = fout_std->U850tdash_bpf_2!2

	fout_std ->EKE850tdash_bpf = (/EKE850bpf/)
	delete(EKE850bpf)

	EKE250bpf = 0.5 * fout_std->U250tdash_bpf_2 + fout_std->V250tdash_bpf_2
	print("calc U^2 + V^2 250")
	
	EKE250bpf!0 = fout_std->U250tdash_bpf_2!0
	EKE250bpf!1 = fout_std->U250tdash_bpf_2!1
	EKE250bpf!2 = fout_std->U250tdash_bpf_2!2
	
	fout_std ->EKE250tdash_bpf = (/EKE250bpf/)
	delete(EKE250bpf)
	print("printed it")
end do

end
