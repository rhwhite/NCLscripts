load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


print("Lanczos_Filter_AZM")
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
	
	filename = Dir + "UVTH_250_850_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"

	cdf_file2 = addfile(filename,"r")
;	print("file read in")

	lat = cdf_file2->lat
	lon = cdf_file2->lon
        sizearray = cdf_file->U850azm
        ndims = dimsizes(sizearray)


	time  = cdf_file2->time
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


;*******************************************
; define variables to loop over
;*******************************************
        inputvars = (/"U850","U250","V850","V250","TH850")
        ;Loop over variables
        nvars = dimsizes(inputvars)

        do ivar = 0,nvars -1
                variable = inputvars(ivar)
                
		if (variable .eq. "U850") then
                        invar = cdf_file->U850azm
                else if (variable .eq. "U250") then
                        invar = cdf_file->U250azm
                else if (variable .eq. "V850") then
                        invar = cdf_file->V850azm
                else if (variable .eq. "V250") then
                        invar = cdf_file->V250azm
                else if (variable .eq. "TH850") then
                        invar = cdf_file->TH850azm
                else
                        print("unrecognised variable requested")
                        print(variable)
                        exit
                end if
                end if
                end if
                end if
                end if

		bpf_temp = new(ndims,typeof(sizearray))
	
		do ilat = 0,ndims(1)-1
			do ilon = 0,ndims(2)-1
				bpf_temp(:,ilat,ilon) = wgt_runave (invar(:,ilat,ilon), wgt, 0 )
			end do
		end do

		ndims = dimsizes(bpf_times)
		ntimes = ndims(0)

		bpf_temp!0 = invar!0
		bpf_temp!1 = invar!1
		bpf_temp!2 = invar!2
		delete(invar)

	ZM_U850bpf = dim_avg_n_Wrap(U850bpf_temp,2)
	Udash850bpf = new((/ntimes-1462,ndims(1),ndims(2)/),typeof(U850bpf_temp))
	
	ilon = 1
	
	do ilon = 0,ndims(2)-1
		Udash850bpf(:,:,ilon) = U850bpf_temp(731:ntimes-732,:,ilon) - ZM_U850bpf(731:ntimes-732,:)
	end do
	
	timebpf = time(731:ntimes-732)
	delete(time)
	
	Udash850bpf!0 = U850bpf_temp!0
	Udash850bpf!1 = U850bpf_temp!1
	Udash850bpf!2 = U850bpf_temp!2
	delete(U850bpf_temp)
	ndims2 = dimsizes(Udash850bpf)
	
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	filo = "ZMA_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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
	
	filevardef(fout_std,"time",typeof(timebpf),getvardims(timebpf))
	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
	filevardef(fout_std,"lon",typeof(lon),getvardims(lon))
	
	filevardef(fout_std,"THdash850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"Udash850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"Vdash850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"Udash250bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"Vdash250bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	
	filevardef(fout_std,"Vdash2Udash2_850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"Vdash2Udash2_250bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"UdashVdash_850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"UdashVdash_250bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	filevardef(fout_std,"VdashTHdash_850bpf",typeof(Udash850bpf),getvardims(Udash850bpf))
	
	fout_std->time = timebpf
	delete(timebpf)

	fout_std->lat = lat
	fout_std->lon = lon
	
	delete(lat)
	delete(lon)
	
	fout_std->Udash850bpf = (/Udash850bpf(:,:,:)/)
	delete(Udash850bpf)
	
	print("processing V850")	
	V850 = cdf_file2->V850
	ndims = dimsizes(V850)
	
	V850bpf_temp = new(ndims,typeof(V850))
	
	do ilat = 0,ndims(1)-1
	        do ilon = 0,ndims(2)-1
	                V850bpf_temp(:,ilat,ilon) = wgt_runave (V850(:,ilat,ilon), wgt, 0 )      ;
	        end do
	end do
	
	ntimes = ndims(0)
	
	V850bpf_temp!0 = V850!0
	V850bpf_temp!1 = V850!1
	V850bpf_temp!2 = V850!2
	delete(V850)
	
	ZM_V850bpf = dim_avg_n_Wrap(V850bpf_temp,2)
	Vdash850bpf = new((/ntimes-1462,ndims(1),ndims(2)/),typeof(V850bpf_temp))
	
	do ilon = 0,ndims(2)-1
	        Vdash850bpf(:,:,ilon) = V850bpf_temp(731:ntimes-732,:,ilon) - ZM_V850bpf(731:ntimes-732,:)
	end do
	
	Vdash850bpf!0 = V850bpf_temp!0
	Vdash850bpf!1 = V850bpf_temp!1
	Vdash850bpf!2 = V850bpf_temp!2
	delete(V850bpf_temp)
	
	fout_std->Vdash850bpf = (/Vdash850bpf(:,:,:)/)
	delete(Vdash850bpf)
	
	print("processing U250")
	U250 = cdf_file2->U250
	ndims = dimsizes(U250)
	
	U250bpf_temp = new(ndims,typeof(U250))

	do ilat = 0,ndims(1)-1
	        do ilon = 0,ndims(2)-1
	                U250bpf_temp(:,ilat,ilon) = wgt_runave (U250(:,ilat,ilon), wgt, 0 )      ;
	        end do
	end do
	
	ntimes = ndims(0)
	
	U250bpf_temp!0 = U250!0
	U250bpf_temp!1 = U250!1
	U250bpf_temp!2 = U250!2
	delete(U250)
	
	ZM_U250bpf = dim_avg_n_Wrap(U250bpf_temp,2)
	Udash250bpf = new((/ntimes-1462,ndims(1),ndims(2)/),typeof(U250bpf_temp))
	
	do ilon = 0,ndims(2)-1
	        Udash250bpf(:,:,ilon) = U250bpf_temp(731:ntimes-732,:,ilon) - ZM_U250bpf(731:ntimes-732,:)
	end do
	
	Udash250bpf!0 = U250bpf_temp!0
	Udash250bpf!1 = U250bpf_temp!1
	Udash250bpf!2 = U250bpf_temp!2
	delete(U250bpf_temp)
	
	fout_std->Udash250bpf = (/Udash250bpf(:,:,:)/)
	delete(Udash250bpf)
	
	print("processing V250")	
	V250 = cdf_file2->V250
	ndims = dimsizes(V250)
	
	V250bpf_temp = new(ndims,typeof(V250))
	
	do ilat = 0,ndims(1)-1
	        do ilon = 0,ndims(2)-1
	                V250bpf_temp(:,ilat,ilon) = wgt_runave (V250(:,ilat,ilon), wgt, 0 )      ;
	        end do
	end do
	
	ntimes = ndims(0)
	
	V250bpf_temp!0 = V250!0
	V250bpf_temp!1 = V250!1
	V250bpf_temp!2 = V250!2
	delete(V250)
	
	ZM_V250bpf = dim_avg_n_Wrap(V250bpf_temp,2)
	Vdash250bpf = new((/ntimes-1462,ndims(1),ndims(2)/),typeof(V250bpf_temp))
	
	do ilon = 0,ndims(2)-1
	        Vdash250bpf(:,:,ilon) = V250bpf_temp(731:ntimes-732,:,ilon) - ZM_V250bpf(731:ntimes-732,:)
	end do
	
	Vdash250bpf!0 = V250bpf_temp!0
	Vdash250bpf!1 = V250bpf_temp!1
	Vdash250bpf!2 = V250bpf_temp!2
	delete(V250bpf_temp)
	
	fout_std->Vdash250bpf = (/Vdash250bpf(:,:,:)/)
	delete(Vdash250bpf)
	
	print("processing TH850")	
	TH850 = cdf_file2->TH850
	ndims = dimsizes(TH850)
	
	TH850bpf_temp = new(ndims,typeof(TH850))
	
	do ilat = 0,ndims(1)-1
	        do ilon = 0,ndims(2)-1
	                TH850bpf_temp(:,ilat,ilon) = wgt_runave (TH850(:,ilat,ilon), wgt, 0 )      ;
	        end do
	end do
	
	ntimes = ndims(0)
	
	TH850bpf_temp!0 = TH850!0
	TH850bpf_temp!1 = TH850!1
	TH850bpf_temp!2 = TH850!2
	delete(TH850)
	
	ZM_TH850bpf = dim_avg_n_Wrap(TH850bpf_temp,2)
	THdash850bpf = new((/ntimes-1462,ndims(1),ndims(2)/),typeof(TH850bpf_temp))
	
	do ilon = 0,ndims(2)-1
	        THdash850bpf(:,:,ilon) = TH850bpf_temp(731:ntimes-732,:,ilon) - ZM_TH850bpf(731:ntimes-732,:)
	end do
	
	THdash850bpf!0 = TH850bpf_temp!0
	THdash850bpf!1 = TH850bpf_temp!1
	THdash850bpf!2 = TH850bpf_temp!2
	delete(TH850bpf_temp)
	
	fout_std->THdash850bpf = (/THdash850bpf(:,:,:)/)
	delete(THdash850bpf)
	
        
	print("calc V^2 - U^2 850")	
	Vdash2Udash2_850bpf = (fout_std->Vdash850bpf*fout_std->Vdash850bpf) - (fout_std->Udash850bpf*fout_std->Udash850bpf)
	
	Vdash2Udash2_850bpf!0 = fout_std->Udash850bpf!0
	Vdash2Udash2_850bpf!1 = fout_std->Udash850bpf!1
	Vdash2Udash2_850bpf!2 = fout_std->Udash850bpf!2
	
	fout_std ->Vdash2Udash2_850bpf = (/Vdash2Udash2_850bpf/)
	print("printed it")
	delete(Vdash2Udash2_850bpf)

        
	print("calc V^2 - U^2 250")
	Vdash2Udash2_250bpf = (fout_std->Vdash250bpf*fout_std->Vdash250bpf) - (fout_std->Udash250bpf*fout_std->Udash250bpf)

	Vdash2Udash2_250bpf!0 = fout_std->Udash250bpf!0
	Vdash2Udash2_250bpf!1 = fout_std->Udash250bpf!1
	Vdash2Udash2_250bpf!2 = fout_std->Udash250bpf!2
	
	ndims  = dimsizes(Vdash2Udash2_250bpf)

	fout_std ->Vdash2Udash2_250bpf = (/Vdash2Udash2_250bpf/)
	print("printed it")
	delete(Vdash2Udash2_250bpf)

        
	print("calc UdashVdash")
	UdashVdash_850bpf = fout_std->Vdash850bpf * fout_std->Udash850bpf

	UdashVdash_850bpf!0 = fout_std->Udash850bpf!0
	UdashVdash_850bpf!1 = fout_std->Udash850bpf!1
	UdashVdash_850bpf!2 = fout_std->Udash850bpf!2
	
	fout_std ->UdashVdash_850bpf = (/UdashVdash_850bpf/)
	print("printed it")
	delete(UdashVdash_850bpf)


        print("calc UdashVdash")
	UdashVdash_250bpf = fout_std->Vdash250bpf * fout_std->Udash250bpf

	UdashVdash_250bpf!0 = fout_std->Udash250bpf!0
	UdashVdash_250bpf!1 = fout_std->Udash250bpf!1
	UdashVdash_250bpf!2 = fout_std->Udash250bpf!2

	fout_std ->UdashVdash_250bpf = (/UdashVdash_250bpf/)
	print("printed it")
	delete(UdashVdash_250bpf)


	print("calc VdashTHdash")
	VdashTHdash_850bpf = fout_std->Vdash850bpf * fout_std->THdash850bpf

	VdashTHdash_850bpf!0 = fout_std->Udash850bpf!0
	VdashTHdash_850bpf!1 = fout_std->Udash850bpf!1
	VdashTHdash_850bpf!2 = fout_std->Udash850bpf!2
	
	fout_std ->VdashTHdash_850bpf = (/VdashTHdash_850bpf/)
	print("printed it")
	delete(VdashTHdash_850bpf)


end do

end
