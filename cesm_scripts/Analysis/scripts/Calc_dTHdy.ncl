load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_dTHdy")
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

timespan = "DJF"


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
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/atm/hist/")
	print(Experiment)

	filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"

	cdf_file = addfile(filename,"r")

	levs_mean = cdf_file->lev_p
	lats = cdf_file->lat
	lons = cdf_file->lon

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

; Find 250 and 850hpa levels
	levsizes = dimsizes(levs_mean)
	nlevs = levsizes(0)

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

	lat = cdf_file->lat
	lon = cdf_file->lon

	U250 = cdf_file->U(0,nlev_250,:,:)
	V250 = cdf_file->V(0,nlev_250,:,:)
	Z250 = cdf_file->Z3(0,nlev_250,:,:)
	T250 = cdf_file->T(0,nlev_250,:,:)
	TH250 = T250 * (1013.0/250.0)^(kappa)

	U850 = cdf_file->U(0,nlev_850,:,:)
        V850 = cdf_file->V(0,nlev_850,:,:)
	T850 =  cdf_file->T(0,nlev_850,:,:)
	TH850 = T850 * (1013.0/850.0)^(kappa)

; Calculate dThdy at all latitudes
        lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

	dTHdy250 = center_finite_diff_n(TH250,lat_dist, False, 0, 0)
        dTHdy850 = center_finite_diff_n(TH850,lat_dist, False, 0, 0)

	dTHdx250 = new(dimsizes(dTHdy250),typeof(dTHdy250))
        dTHdx850 = new(dimsizes(dTHdy850),typeof(dTHdy850))

	ndims = dimsizes(dTHdx250)

	do iy=0,nlats-1
		lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
		dTHdx850(iy,:) = center_finite_diff_n(TH850(iy:iy,:),lon_dist, False, 0, 1)
		dTHdx250(iy,:) = center_finite_diff_n(TH250(iy:iy,:),lon_dist, False, 0, 1)
	end do

	UdivTH250 = (U250 * dTHdx250) + (V250 * dTHdy250)
        UdivTH850 = (U850 * dTHdx850) + (V850 * dTHdy850)

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
	filo = "GradTH_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h0.nc"
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

	print(getvardims(T250))
	
	filevardef(fout_std,"dTHdx250",typeof(dTHdy250),getvardims(T250))
	filevardef(fout_std,"dTHdx850",typeof(dTHdy250),getvardims(T250))
	filevardef(fout_std,"dTHdy250",typeof(dTHdy250),getvardims(T250))
	filevardef(fout_std,"dTHdy850",typeof(dTHdy250),getvardims(T250))

        filevardef(fout_std,"UdivTH250",typeof(dTHdy250),getvardims(T250))
        filevardef(fout_std,"UdivTH850",typeof(dTHdy250),getvardims(T250))

        filevardef(fout_std,"U250",typeof(dTHdy250),getvardims(T250))
        filevardef(fout_std,"U850",typeof(dTHdy250),getvardims(T250))
        filevardef(fout_std,"V250",typeof(dTHdy250),getvardims(T250))
        filevardef(fout_std,"V850",typeof(dTHdy250),getvardims(T250))


	fout_std->lat = lats
	fout_std->lon = lons

	fout_std->dTHdy250 = (/dTHdy250/)
        fout_std->dTHdx250 = (/dTHdx250/)
        fout_std->dTHdy850 = (/dTHdy850/)
        fout_std->dTHdx850 = (/dTHdx850/)
        fout_std->U250 = (/U250/)
        fout_std->U850 = (/U850/)
        fout_std->V250 = (/V250/)
        fout_std->V850 = (/V850/)




        fout_std->UdivTH250 = (/UdivTH250/)
        fout_std->UdivTH850 = (/UdivTH850/)


end do

end
