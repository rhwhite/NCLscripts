load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_EV_P")
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

timespans = (/"DJF"/)
ntdims = dimsizes(timespans)
nts = ntdims(0)

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

deltap1 = 450
deltap2 = 150

lambda_l = 0.35
lambda_s = 0.7

daysecs = 86400

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

;get dims
filo = "ZMA_bpf_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiments(0) + ".cam2.h1.nc"
filename1 = Direc + Experiments(0) + "/atm/hist/" + filo

cdf_EV = addfile(filename1,"r")
print(filename1)

vth = cdf_EV->VdashTHdash_850bpf
lats = cdf_EV->lat
lons = cdf_EV->lon
ndims = dimsizes(vth)
ntimes = ndims(0)

uP = new((/nexps,ndims(1),ndims(2)/),typeof(vth))

delete([/cdf_EV,vth/])

;Calculate lambda
filename_f19 = "/home/disk/eos4/rachel/inputdata/topo/landmask_1.9_2.5.nc"
cdf_mask = addfile(filename_f19,"r")

lm_f19 = cdf_mask->landmask

delete(cdf_mask)

lam_lnd = 0.35 * lm_f19
lam_ocn = -0.7 * (lm_f19 - 1.0)

lambda_f19 = lam_lnd + lam_ocn
delete([/lam_lnd,lam_ocn,lm_f19/])

do ts = 0,nts-1

        timespan = timespans(ts)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		print(Experiment)
	        Dir = (Direc + Experiment + "/atm/hist/")

;Read in EKE values
		filo = "ZMA_bpf_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		filename1 = Dir + filo

		cdf_EV = addfile(filename1,"r")

		vth = cdf_EV->VdashTHdash_850bpf
		ndims2 = dimsizes(vth)
		nlats = ndims2(1)
		nlons = ndims2(2)
		timebpf = cdf_EV->time

; calculate mean
		if (timespan .eq. "Annual") then
			vth_avg = dim_avg_n(vth,0)
        	else if (timespan .eq. "DJF") then
        	        count = 0
                        vth_temp = new(dimsizes(vth),typeof(vth))
                        do nt = 0,ntimes-1
                                year = floor(timebpf(nt)/10000.)
                                month = floor((timebpf(nt) - 10000. * year)/100.)

                                if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
                                        vth_temp(count,:,:) = vth(nt,:,:)
                                        count = count + 1
                                else if (month .gt. 12 .or. month .lt. 1)
                                        print("months not quite right!")
                                        exit
                                end if
                                end if
                        end do
                        vth_avg = dim_avg_n(vth_temp(0:count,:,:),0)
                        print(count)
                        delete(vth_temp)
                else if (timespan .eq. "JJA") then
                        count = 0
                        vth_temp = new(dimsizes(vth),typeof(vth))
                        do nt = 0,ntimes-1
                                year = floor(timebpf(nt)/10000.)
                                month = floor((timebpf(nt) - 10000. * year)/100.)
                                print(month)

                                if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                                        vth_temp(count,:,:) = vth(nt,:,:)
                                        count = count + 1
                                else if (month .gt. 12 .or. month .lt. 1)
                                        print("something wrong with months")
                                        exit
                                end if
                                end if

                        end do
                        print(count)
                        vth_avg = dim_avg_n(vth_temp(0:count,:,:),0)
                        delete(vth_temp)
                else
                        print("other timespan expected, only Annual,DJF and JJA allowed")
                        exit
                end if
                end if
                end if

; Calculate f at all latitudes
		fc = new((/nlats,nlons/),typeof(vth))

		do nlat = 0,nlats-1
			fc(nlat,:) = tofloat(2 * omega * sin(lats(nlat)*pi/180.0))
		end do

		delete(vth)

; Read in and calculate dTH/dp from mean values

		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"
		cdf_file = addfile(Dir + filo, "r")
	
		levs_mean = cdf_file->lev_p
	
		levsizes = dimsizes(levs_mean)
		nlevs = levsizes(0)
	
; Find 925 and 775 pressure levels
	
		nlev_775 = -1
		nlev_925 = -1
	
		do nl = 0,nlevs-1
			if levs_mean(nl) .eq. 775 then
				nlev_775 = nl
			end if
			if levs_mean(nl) .eq. 925 then
				nlev_925 = nl
			end if
		end do
	
		if (nlev_775 .lt. 0 .or. nlev_925 .lt. 0) then
			print("didnt find a level")
			exit
		end if
	
		T925 = cdf_file->T(0,nlev_925,:,:)
		T775 = cdf_file->T(0,nlev_775,:,:) 
		TH925 = T925 * ((1013.0/925.0)^(kappa))
		TH775 = T775 * ((1013.0/775.0)^(kappa))
	
		delete([/T925,T775/])

		dTHdp = (TH925 - TH775)/(925.0 - 775.0)

		EVp_bpf850 =  fc * vth_avg / ( dTHdp)
		uP_bpf850 = daysecs * lambda_f19 * fc * vth_avg / ( dTHdp * deltap2 )

		delete([/dTHdp,nlats/])


;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
		filo = "EV_P_AZM_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_"+ Experiment +".cam2.h1.nc"
		system("/bin/rm -f " + Dir + filo)
		fout_std = addfile(Dir + filo, "c")

		setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout_std,fAtt)
	
;set dimensions of output file
		dimNames = (/"lat","lon"/)
		dimSizes = (/ndims(1),ndims(2)/)
		dimUnlim = (/False,False/)
		filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

		filevardef(fout_std,"lat",typeof(lats),getvardims(lats))
		filevardef(fout_std,"lon",typeof(lons),getvardims(lons))
	
		filevardef(fout_std,"EVp_bpf850",typeof(EVp_bpf850),(/"lat","lon"/))
		filevardef(fout_std,"uP_bpf850",typeof(uP_bpf850),(/"lat","lon"/))

		fout_std->lat = (/lats/)
		fout_std->lon = (/lons/)
	
		fout_std->uP_bpf850 = (/uP_bpf850/)
		fout_std->EVp_bpf850 = (/EVp_bpf850/)
		
		print("written everything")

		delete([/uP_bpf850,EVp_bpf850/])

	end do
end do

end
