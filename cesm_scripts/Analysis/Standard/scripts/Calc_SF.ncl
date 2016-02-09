load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_SF")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

timespans = (/"DJF","MAM","JJA","SON"/)
nts = dimsizes(timespans)
print(nts)

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

Ps = 1013.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	do its = 0,nts
		timespan = timespans(its)
		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + dirstr)
		print(Experiment)

		filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"

		cdf_file = addfile(filename,"r")

		levs_mean = cdf_file->lev_p
		lats = cdf_file->lat
		lons = cdf_file->lon

		nlats = dimsizes(lats)
		nlons = dimsizes(lons)

		nlevs = dimsizes(levs_mean)

		SF = new((/nlats,nlons/), typeof(cdf_file->U))
		temp = new((/nlats,nlons/),typeof(cdd_file->U))	
	
		uv2sfvpf(cdf_file->U(0,:,:,:),cdf_file->V(0,:,:,:),SF,temp)

		SFza = dim_rmvmean_Wrap(SF(time|:,lev_p|:,lat|:,lon|:)) 
		
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		; Calculate potential temperature
		T = cdf_file->T(0,:,:,:)
		THETA = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)
		THETAzm = dim_avg_Wrap(THETA)
		; Calculate d(THETA)/dp from vertical finite differences in log-pressure coordinates
		; noting that dT/dp = (1/p) * dT/d(lnp)
		loglevel = log(level)

		THETAp = center_finite_diff_n(THETAzm(time|:,lev_p|:,lat|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
		; named subscripting reorders the dimensions
		THETAp = THETAp / conform(THETAp,100.0 * level,1) ; converts "level" to pascals from millibars while dividing by pressure.
		copy_VarMeta(THETAzm,THETAp)

		; Calculate dTHdy
	        lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))
		THETAy = center_finite_diff_n(TH,lat_dist, False, 0, 0)
		
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
		filo = "SF_TH_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h0.nc"
		system("/bin/rm -f " + Dir + filo)
		fout_std = addfile(Dir + filo, "c")

		setfileoption(fout_std,"DefineMode",True)

	;set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout_std,fAtt)
		
	;set dimensions of output file
		dimNames = (/"lat","lon"/)
		dimSizes = (/ndims(0),ndims(1)/)
		dimUnlim = (/False,False/)
		filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

		filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
		filevardef(fout_std,"lon",typeof(lon),getvardims(lon))

		filevardef(fout_std,"SF",typeof(SF),getvardims(SF))
		filevardef(fout_std,"SFZA",typeof(SFZA),getvardims(SFZA))
		filevardef(fout_std,"THETA",typeof(THETA),getvardims(THETA))

                filevardef(fout_std,"THETAy",typeof(THETAy),getvardims(THETAy))
                filevardef(fout_std,"THETAp",typeof(THETAp),getvardims(THETAp))

		fout_std->lat = lats
		fout_std->lon = lons

		fout_std->THETA = THETA
                fout_std->THETAp = THETAp
                fout_std->THETAy = THETAy

		fout_std->SF = SF
		fout_std->SFZA = SFZA

	end do

end do

end
