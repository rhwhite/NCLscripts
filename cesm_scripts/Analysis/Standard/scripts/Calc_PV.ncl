load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Code to calculate Rossby refractive index based on waves on the zonal mean
; Follows derivation of Li et al 2007 ACP
; Using matlab code from http://khalilkarami.com/matlab-codes/refractive-index-of-rossby-waves/
; Calculate on model levels, and then move to pressure levels. This stops having the issue of 0s where the pressure level is below ground level?

begin

; Get experiment names

its = 1 ; climatology for 0, monthly timeseries for its = 1

print("Calc PV")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

lonstart = toint(getenv("NCL_ARG_lonstart"))
lonend = toint(getenv("NCL_ARG_lonend"))


nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

timespan = "DJF"

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/" + dirstr + "/")
	print(Experiment)

	if its .EQ. 0 then
		filenamepl = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
		filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc"
		filo = "PV_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc"

	else if its .EQ. 1 then
		filenamepl = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_Xpl_" + Experiment + ".cam2.h0.nc"
		filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc"
		filo = "PV_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc"
	end if
	end if

	cdf_filepl = addfile(filenamepl,"r")
	cdf_file = addfile(filename,"r")

	; get pressure levels

	hyam = cdf_file->hyam
	hybm = cdf_file->hybm
	p0 = cdf_file->P0
	ps = cdf_file->PS
	P0mb = 0.01*cdf_file->P0	; get P0 in mb

	p = pres_hybrid_ccm(ps,p0,hyam,hybm)

	nmlevels = filevardimsizes(cdf_file,"lev")
	nlat = filevardimsizes(cdf_file,"lat")
	nlon = filevardimsizes(cdf_file,"lon")
	ntimes = filevardimsizes(cdf_file,"time")


	mlevs = cdf_file->lev
	lat = tofloat(cdf_file->lat)
	lat!0="lat"
	lon = tofloat(cdf_file->lon)
	lon!0="lon"

	U = cdf_file->U(:,:,:,:)
	V = cdf_file->V(:,:,:,:)
	T = cdf_file->T(:,:,:,:)
	Z = cdf_file->Z3(:,:,:,:)

	if mlevs(0) .GT. mlevs(nmlevels-1) then
		TBOT = T(:,0,:,:)
	else
		TBOT = T(:,nmlevels-1,:,:)
	end if

	copy_VarCoords(U,p)

	PVlats = cdf_file->lat
	; Calculate PV
	gridtype = 1	; normal grid

	PV = pot_vort_hybrid(p,U,V,T,lat,gridtype,0)

	copy_VarCoords(U,PV)


	; convert to pressure coordinates

        plev           = (/ 10, 20,30,50,70,90,120,150,200,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)
	nplevels = dimsizes(plev)

        PHIS = cdf_file->PHIS
	PVpres = vinth2p_ecmwf(PV,hyam,hybm,plev,ps,1,P0mb,1,True,0,TBOT,PHIS)

;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------

	system("/bin/rm -f " + Dir + filo)
	fout_std = addfile(Dir + filo, "c")

	setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

	print(ntimes)
;set dimensions of output file
	dimNames = (/"time","lat","lon","lev_p","lev_m"/)
	dimSizes = (/ntimes,nlat,nlon,nplevels,nmlevels/)
	dimUnlim = (/False,False,False,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
        filevardef(fout_std,"lat",typeof(lon),getvardims(lon))

	filevardef(fout_std,"mlevs",typeof(mlevs),("lev_m"))
        filevardef(fout_std,"plevs",typeof(plev),("lev_p"))

        filevardef(fout_std,"PVm",typeof(PV),(/"time","lev_m","lat","lon"/))
        filevardef(fout_std,"PVp",typeof(PV),(/"time","lev_p","lat","lon"/))

	fout_std->lat = (/lat/)
        fout_std->lon = (/lon/)

	fout_std->mlevs =(/mlevs/)
        fout_std->plevs =(/plev/)

	fout_std->PVm = (/PV/)
	fout_std->PVp = (/PVpres/)
	
	print("printed it")


end do

end
