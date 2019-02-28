;load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Calculate climatological mean vertical gradients of omega,
; T, TH and omegaT NOT on pressure levels

begin


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

timespans = (/"Annual","DJF","JJA","MAM","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + dirstr)
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	  	cdf_file = addfile(filename,"w")
	
		P0 = cdf_file->P0
        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        PS = cdf_file->PS

		T = cdf_file->T
		OMEGAT = cdf_file->OMEGAT
		print(dimsizes(T))

		pm = pres_hybrid_ccm(PS,P0,hyam,hybm)
		print(dimsizes(pm))
;------------------------------------------------------
; calculate potential temperature and then
; calculate differences over dimension 1, model levels
;------------------------------------------------------
		TH = tofloat(T*(P0/pm)^0.286)
		dTHdp = tofloat(center_finite_diff_n(TH,pm,False,0,1))

		dOMEGATdp = tofloat(center_finite_diff_n(OMEGAT,pm,False,0,1))

		copy_VarCoords(T,TH)
		copy_VarCoords(T,dTHdp)

		print(dimsizes(dTHdp))

;-----------------------------------------------------------------------
;Write variables to netcdf file
;-----------------------------------------------------------------------
        setfileoption(cdf_file,"DefineMode",True)

        filevardef(cdf_file,"TH",typeof(TH),getvardims(T))
        filevardef(cdf_file,"dTHdp",typeof(TH),getvardims(T))
		filevardef(cdf_file,"dOMEGATdp",typeof(OMEGAT),getvardims(T))

		cdf_file ->TH       = (/TH/)
		cdf_file ->dTHdp    = (/dTHdp/)
		cdf_file ->dOMEGATdp = (/dOMEGATdp/)		

		delete(cdf_file)
		delete(Experiment)
		delete([/TH,dTHdp,pm,P0,PS,hyam,hybm/])
		delete(filename)
	
	end do

end do

end
