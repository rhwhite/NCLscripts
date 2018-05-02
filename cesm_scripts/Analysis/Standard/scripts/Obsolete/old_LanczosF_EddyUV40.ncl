load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Lanczos_Filter_Eddy")
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

do exps = 0,nexps-1
        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")
        print(Experiment)

	filename = Dir + "Eddy_250_850_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"

	cdf_file = addfile(filename,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	U850eddy = cdf_file->U850eddy

	ndims = dimsizes(U850eddy)

	time  = cdf_file->time
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

	U850bpf_temp = U850eddy
	U850bpf_temp(:,:,:) = 0.0

	do ilat = 0,ndims(1)-1
		do ilon = 0,ndims(2)-1
			U850bpf_temp(:,ilat,ilon) = wgt_runave (U850eddy(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	ndims = dimsizes(U850bpf_temp)
	ntimes = ndims(0)

	U850bpf_temp!0 = U850eddy!0
	U850bpf_temp!1 = U850eddy!1
	U850bpf_temp!2 = U850eddy!2
	delete(U850eddy)
	
	count = 0
	if (timespan .eq. "Annual") then
	        ntAnn = nyears*4*(365);
       		U850bpf = new((/ntAnn,ndims(1),ndims(2)/),typeof(U850bpf_temp))
        	timebpf = new((/ntAnn/),typeof(time))
        	do nt = 731,ntimes-731
                        U850bpf(count,:,:) = U850bpf_temp(nt,:,:)
                        timebpf(count) = time(nt)
                        count = count + 1
		end do
	else if (timespan .eq. "DJF") then
	        nDJF = nyears*4*(31+28+31);
       		U850bpf = new((/nDJF,ndims(1),ndims(2)/),typeof(U850bpf_temp))
        	timebpf = new((/nDJF/),typeof(time))

		do nt = 731,ntimes-731
		        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)
			if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
				U850bpf(count,:,:) = U850bpf_temp(nt,:,:)
				timebpf(count) = time(nt)
				count = count + 1
                        else if (month .gt. 12 .or. month .lt. 1)
                                print("months not quite right!")
                                exit
                                end if
                        end if
		end do
	else if (timespan .eq. "JJA") then
                nJJA = nyears*4*(31+28+31);
                U850bpf = new((/nJJA,ndims(1),ndims(2)/),typeof(U850bpf_temp))
                timebpf = new((/nJJA/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                                U850bpf(count,:,:) = U850bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
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
	
	U850bpf!0 = U850bpf_temp!0
	U850bpf!1 = U850bpf_temp!1
	U850bpf!2 = U850bpf_temp!2
	
	delete(U850bpf_temp)
	ndims2 = dimsizes(U850bpf(0:count-1,:,:))
	
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	filo = "EKE_EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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

	filevardef(fout_std,"time",typeof(time),getvardims(time))
	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
	filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

	filevardef(fout_std,"U850Ebpf",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"U250Ebpf",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"V850Ebpf",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"V250Ebpf",typeof(U850bpf),getvardims(U850bpf))
	
	filevardef(fout_std,"U850Ebpf_2",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"U250Ebpf_2",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"V850Ebpf_2",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"V250Ebpf_2",typeof(U850bpf),getvardims(U850bpf))
	
	filevardef(fout_std,"EKE850bpf",typeof(U850bpf),getvardims(U850bpf))
	filevardef(fout_std,"EKE250bpf",typeof(U850bpf),getvardims(U850bpf))
	
	
	fout_std->time = timebpf(0:count-1)

	fout_std->lat = lat
	fout_std->lon = lon

	fout_std->U850Ebpf = (/U850bpf(0:count-1,:,:)/)
	delete([/lat,lon,timebpf,U850bpf/])
	
	U850bpf_2 = fout_std->U850Ebpf*fout_std->U850Ebpf
	U850bpf_2!0 = fout_std->U850Ebpf!0
	U850bpf_2!1 = fout_std->U850Ebpf!1
	U850bpf_2!2 = fout_std->U850Ebpf!2
	print("calc U^2 850")

	fout_std->U850Ebpf_2 = (/U850bpf_2/)

	delete(U850bpf_2)


	V850eddy = cdf_file->V850eddy

	V850bpf_temp = V850eddy
	V850bpf_temp(:,:,:) = 0.0
	
	do ilat = 0,ndims(1)-1
		do ilon = 0,ndims(2)-1
			V850bpf_temp(:,ilat,ilon) = wgt_runave (V850eddy(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do
	
	ndims = dimsizes(V850bpf_temp)
	ntimes = ndims(0)
	
	V850bpf_temp!0 = V850eddy!0
	V850bpf_temp!1 = V850eddy!1
	V850bpf_temp!2 = V850eddy!2
	delete(V850eddy)
	
	
        count = 0
        if (timespan .eq. "Annual") then
                ntAnn = nyears*4*(365);
                V850bpf = new((/ntAnn,ndims(1),ndims(2)/),typeof(V850bpf_temp))
                timebpf = new((/ntAnn/),typeof(time))
                do nt = 731,ntimes-731
                        V850bpf(count,:,:) = V850bpf_temp(nt,:,:)
                        timebpf(count) = time(nt)
                        count = count + 1
                end do
        else if (timespan .eq. "DJF") then
                nDJF = nyears*4*(31+28+31);
                V850bpf = new((/nDJF,ndims(1),ndims(2)/),typeof(V850bpf_temp))
                timebpf = new((/nDJF/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
                                V850bpf(count,:,:) = V850bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
                                count = count + 1
                        else if (month .gt. 12 .or. month .lt. 1)
                                print("months not quite right!")
                                exit
                                end if
                        end if
                end do
        else if (timespan .eq. "JJA") then
                nJJA = nyears*4*(31+28+31);
                V850bpf = new((/nJJA,ndims(1),ndims(2)/),typeof(V850bpf_temp))
                timebpf = new((/nJJA/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                                V850bpf(count,:,:) = V850bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
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

	V850bpf!0 = V850bpf_temp!0
	V850bpf!1 = V850bpf_temp!1
	V850bpf!2 = V850bpf_temp!2
	delete(V850bpf_temp)

	fout_std->V850Ebpf = (/V850bpf(0:count-1,:,:)/)
	delete(V850bpf)

	V850bpf_2 = fout_std->V850Ebpf*fout_std->V850Ebpf
	V850bpf_2!0 = fout_std->V850Ebpf!0
	V850bpf_2!1 = fout_std->V850Ebpf!1
	V850bpf_2!2 = fout_std->V850Ebpf!2
	print("calc V^2 850")

	fout_std->V850Ebpf_2 = (/V850bpf_2/)

	delete(V850bpf_2)


	U250eddy = cdf_file->U250eddy
	U250bpf_temp = U250eddy
	U250bpf_temp(:,:,:) = 0.0

	do ilat = 0,ndims(1)-1
		do ilon = 0,ndims(2)-1
			U250bpf_temp(:,ilat,ilon) = wgt_runave (U250eddy(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	ndims = dimsizes(U250bpf_temp)
	ntimes = ndims(0)

	U250bpf_temp!0 = U250eddy!0
	U250bpf_temp!1 = U250eddy!1
	U250bpf_temp!2 = U250eddy!2
	delete(U250eddy)

        count = 0
        if (timespan .eq. "Annual") then
                ntAnn = nyears*4*(365);
                U250bpf = new((/ntAnn,ndims(1),ndims(2)/),typeof(U250bpf_temp))
                timebpf = new((/ntAnn/),typeof(time))
                do nt = 731,ntimes-731
                        U250bpf(count,:,:) = U250bpf_temp(nt,:,:)
                        timebpf(count) = time(nt)
                        count = count + 1
                end do
        else if (timespan .eq. "DJF") then
                nDJF = nyears*4*(31+28+31);
                U250bpf = new((/nDJF,ndims(1),ndims(2)/),typeof(U250bpf_temp))
                timebpf = new((/nDJF/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
                                U250bpf(count,:,:) = U250bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
                                count = count + 1
                        else if (month .gt. 12 .or. month .lt. 1)
                                print("months not quite right!")
                                exit
                                end if
                        end if
                end do
        else if (timespan .eq. "JJA") then
                nJJA = nyears*4*(31+28+31);
                U250bpf = new((/nJJA,ndims(1),ndims(2)/),typeof(U250bpf_temp))
                timebpf = new((/nJJA/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                                U250bpf(count,:,:) = U250bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
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

	U250bpf!0 = U250bpf_temp!0
	U250bpf!1 = U250bpf_temp!1
	U250bpf!2 = U250bpf_temp!2
	delete(U250bpf_temp)

	fout_std->U250Ebpf = (/U250bpf(0:count-1,:,:)/)
	delete(U250bpf)

	U250bpf_2 = fout_std->U250Ebpf*fout_std->U250Ebpf
	U250bpf_2!0 = fout_std->U250Ebpf!0
	U250bpf_2!1 = fout_std->U250Ebpf!1
	U250bpf_2!2 = fout_std->U250Ebpf!2
	print("calc U^2 250")

	fout_std->U250Ebpf_2 = (/U250bpf_2/)

	delete(U250bpf_2)

; V250
	V250eddy = cdf_file->V250eddy
	V250bpf_temp = V250eddy
	V250bpf_temp(:,:,:) = 0.0

	do ilat = 0,ndims(1)-1
		do ilon = 0,ndims(2)-1
			V250bpf_temp(:,ilat,ilon) = wgt_runave (V250eddy(:,ilat,ilon), wgt, 0 )      ;
		end do
	end do

	ndims = dimsizes(V250bpf_temp)
	ntimes = ndims(0)

	V250bpf_temp!0 = V250eddy!0
	V250bpf_temp!1 = V250eddy!1
	V250bpf_temp!2 = V250eddy!2
	delete(V250eddy)
        
	count = 0
        if (timespan .eq. "Annual") then
                ntAnn = nyears*4*(365);
                V250bpf = new((/ntAnn,ndims(1),ndims(2)/),typeof(V250bpf_temp))
                timebpf = new((/ntAnn/),typeof(time))
                do nt = 731,ntimes-731
                        V250bpf(count,:,:) = V250bpf_temp(nt,:,:)
                        timebpf(count) = time(nt)
                        count = count + 1
                end do
        else if (timespan .eq. "DJF") then
                nDJF = nyears*4*(31+28+31);
                V250bpf = new((/nDJF,ndims(1),ndims(2)/),typeof(V250bpf_temp))
                timebpf = new((/nDJF/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
                                V250bpf(count,:,:) = V250bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
                                count = count + 1
                        else if (month .gt. 12 .or. month .lt. 1)
                                print("months not quite right!")
                                exit
                                end if
                        end if
                end do
        else if (timespan .eq. "JJA") then
                nJJA = nyears*4*(31+28+31);
                V250bpf = new((/nJJA,ndims(1),ndims(2)/),typeof(V250bpf_temp))
                timebpf = new((/nJJA/),typeof(time))

                do nt = 731,ntimes-731
                        year = floor(time(nt)/10000.)
                        month = floor((time(nt) - 10000. * year)/100.)

                        if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                                V250bpf(count,:,:) = V250bpf_temp(nt,:,:)
                                timebpf(count) = time(nt)
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

	V250bpf!0 = V250bpf_temp!0
	V250bpf!1 = V250bpf_temp!1
	V250bpf!2 = V250bpf_temp!2
	delete(V250bpf_temp)

	fout_std->V250Ebpf = (/V250bpf(0:count-1,:,:)/)
	delete(V250bpf)

	V250bpf_2 = fout_std->V250Ebpf*fout_std->V250Ebpf
	V250bpf_2!0 = fout_std->V250Ebpf!0
	V250bpf_2!1 = fout_std->V250Ebpf!1
	V250bpf_2!2 = fout_std->V250Ebpf!2
	print("calc V^2 250")
	
	fout_std->V250Ebpf_2 = (/V250bpf_2/)

	delete(V250bpf_2)

	print("calculated all bpf eddy winds squared")
	delete(cdf_file)

; Calc EKEs

	EKE850bpf = 0.5 * fout_std->U850Ebpf_2 + fout_std->V850Ebpf_2
	print("calc U^2 + V^2 850")

	EKE850bpf!0 = fout_std->U850Ebpf_2!0
	EKE850bpf!1 = fout_std->U850Ebpf_2!1
	EKE850bpf!2 = fout_std->U850Ebpf_2!2

	fout_std ->EKE850bpf = (/EKE850bpf/)
	print("printed it")
	delete(EKE850bpf)


	EKE250bpf = 0.5 * fout_std->U250Ebpf_2 + fout_std->V250Ebpf_2
	print("calc U^2 + V^2 250")
	
	EKE250bpf!0 = fout_std->U250Ebpf_2!0
	EKE250bpf!1 = fout_std->U250Ebpf_2!1
	EKE250bpf!2 = fout_std->U250Ebpf_2!2
	
	fout_std ->EKE250bpf = (/EKE250bpf/)
	delete(EKE250bpf)
	print("printed it")

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
        filo = "VTdash_time_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std2,"DefineMode",True)

;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std2,fAtt)

;set dimensions of output file
        dimNames = (/"time","lat","lon"/)
        dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
        dimUnlim = (/True,False,False/)
        filedimdef(fout_std2,dimNames,dimSizes,dimUnlim)

        filevardef(fout_std2,"time",typeof(time),getvardims(time))
        filevardef(fout_std2,"lat",typeof(lat),getvardims(lat))
        filevardef(fout_std2,"lon",typeof(lon),getvardims(lon))

        filevardef(fout_std2,"VT850bpf",typeof(U850bpf),getvardims(U850bpf))
        filevardef(fout_std2,"VT250bpf",typeof(U850bpf),getvardims(U850bpf))

        fout_std2->time = timebpf(0:count-1)

        fout_std2->lat = lat
        fout_std2->lon = lon

end do

end
