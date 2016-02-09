load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_EV")
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

deltap1 = 450
deltap2 = 150

lambda_l = 0.35
lambda_s = 0.7

daysecs = 86400
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

do ts = 0,nts-1

        timespan = timespans(ts)

	;get dims
	fili = "EKE_VT_EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiments(0) + ".cam2.h1.nc"
	filename1 = Direc + Experiments(0) + "/atm/hist/" + fili
	
	cdf_EV = addfile(filename1,"r")
	
	temp = cdf_EV->U250tdash_bpf
	timebpf = cdf_EV->time
	lats = cdf_EV->lat
	lons = cdf_EV->lon
	ndims = dimsizes(temp)
	ntimes = ndims(0)
	nlons = ndims(1)
	nlats = ndims(2)

	nlats = ndims(1)                
	nlons = ndims(2)
	
	;Calculate lambda = 1/kappa
	filename_f19 = "/home/disk/eos4/rachel/inputdata/topo/landmask_1.9_2.5.nc"
	cdf_mask = addfile(filename_f19,"r")
	
	lm_f19 = cdf_mask->landmask
	
	delete(cdf_mask)
	
	lam_lnd = 0.35 * lm_f19
	lam_ocn = -0.7 * (lm_f19 - 1.0)
	
	lambda_f19 = lam_lnd + lam_ocn
	delete([/lam_lnd,lam_ocn,lm_f19/])
	
	; Calculate f at all latitudes
	fc = new((/nlats,nlons/),typeof(temp))
	do ilat = 0,nlats-1
		fc(ilat,:) = tofloat(2 * omega * sin(lats(ilat)*pi/180.0))
	end do

        delete([/cdf_EV,temp/])
	
	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		print(Experiment)
	        Dir = (Direc + Experiment + "/atm/hist/")

;Read in EKE values
		fili = "EKE_VT_EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		filename1 = Dir + fili

		cdf_EV = addfile(filename1,"r")

		v2u2 = cdf_EV->V250tdash_bpf_2 - cdf_EV->U250tdash_bpf_2
		uv = cdf_EV->U250tdash_bpf * cdf_EV->V250tdash_bpf
		
                vth = cdf_EV->V850tdash_bpf * cdf_EV->TH850tdash_bpf

; calculate time mean
; timespan is already dealt with in incoming file
; Just need to average over all time

		Ex = dim_avg_n(v2u2,0)
		Ey = -1.0 * dim_avg_n(uv,0)
		Ep_tmp = dim_avg_n(vth,0)

		delete([/uv,v2u2/])

; calculate divergence for U_H	
		divEV_bpf250 = uv2dvF(Ex,Ey)

; multiple by deltap1/deltap2 and corresponding lambda.

		u_H_bpf250 = daysecs * (deltap1/deltap2) * divEV_bpf250 * lambda_f19

; Read in and calculate dTH/dp from mean values

                fili = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"
                cdf_file = addfile(Dir + fili, "r")

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

                Ep =  fc * Ep_tmp / ( dTHdp)
                u_P_bpf850 = daysecs * lambda_f19 * Ep / deltap2

                delete([/dTHdp, Ep_tmp/])

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
		filo = "EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_"+ Experiment +".cam2.h1.nc"
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
                filevardef(fout_std,"EVx_bpf250",typeof(u_H_bpf250),(/"lat","lon"/))
                filevardef(fout_std,"EVy_bpf250",typeof(u_H_bpf250),(/"lat","lon"/))
                filevardef(fout_std,"EVp_bpf850",typeof(u_H_bpf250),(/"lat","lon"/))

		filevardef(fout_std,"divEV_bpf250",typeof(u_H_bpf250),(/"lat","lon"/))
		filevardef(fout_std,"u_H_bpf250",typeof(u_H_bpf250),(/"lat","lon"/))
                filevardef(fout_std,"u_P_bpf850",typeof(u_H_bpf250),(/"lat","lon"/))
		
		
		fout_std->lat = (/lats/)
		fout_std->lon = (/lons/)
		

		fout_std->EVx_bpf250 = (/Ex/)
		fout_std->EVy_bpf250 = (/Ey/)
		fout_std->EVp_bpf850 = (/Ep/)
		fout_std->u_H_bpf250 = (/u_H_bpf250/)
                fout_std->u_P_bpf850 = (/u_P_bpf850/)
		fout_std->divEV_bpf250 = (/divEV_bpf250/)
	
		print("written everything")

	end do

end do

end
