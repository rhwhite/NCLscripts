load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_meanEKE")
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
	
	cdf_EKE = addfile(filename1,"r")
	
	temp250 = cdf_EKE->EKE250tdash_bpf
	timebpf = cdf_EKE->time
	lats = cdf_EKE->lat
	lons = cdf_EKE->lon
	ndims = dimsizes(temp250)
	ntimes = ndims(0)
	nlons = ndims(1)
	nlats = ndims(2)

	
	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		print(Experiment)
	        Dir = (Direc + Experiment + "/atm/hist/")

;Read in EKE values
		fili = "EKE_VT_EV_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		filename1 = Dir + fili

		cdf_EKE = addfile(filename1,"r")

; read in data and take time mean
; DJF is already dealt with in input file, so just need to take time mean
		EKE250 = dim_avg_n(cdf_EKE->EKE250tdash_bpf,0)
		EKE850 = dim_avg_n(cdf_EKE->EKE850tdash_bpf,0)
		
		VT250 = dim_avg_n(cdf_EKE->U250tdash_bpf * cdf_EKE->TH250tdash_bpf,0)
                VT850 = dim_avg_n(cdf_EKE->U850tdash_bpf * cdf_EKE->TH850tdash_bpf,0)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
		filo = "EKE_mean_bpf_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_"+ Experiment +".cam2.h1.nc"
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
                filevardef(fout_std,"EKE_bpf250",typeof(EKE250),(/"lat","lon"/))
                filevardef(fout_std,"EKE_bpf850",typeof(EKE250),(/"lat","lon"/))
                filevardef(fout_std,"VprTpr_bpf250",typeof(EKE250),(/"lat","lon"/)) 
                filevardef(fout_std,"VprTpr_bpf850",typeof(EKE250),(/"lat","lon"/)) 
	


		fout_std->lat = (/lats/)
		fout_std->lon = (/lons/)
		

		fout_std->EKE_bpf250 = (/EKE250/)
		fout_std->EKE_bpf850 = (/EKE850/)
		fout_std->VprTpr_bpf250 = (/VT250/)
		fout_std->VprTpr_bpf850 = (/VT850/)	
		print("written everything")

	end do

end do

end
