load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$HOME/git/NCL/functions.ncl"
; Code to calculate Rossby stationary wave number, including vertical
; propagation, following Hu and Tung 2002 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (dq/dphi)/u - (f/2NH)2
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

; Get experiment names

print("Calc Rossby Refractive Index")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

dirstr = getenv("NCL_dirstr")
outdirstr = getenv("NCL_outdirstr")


do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

timespan = getenv("NCL_season")

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)


;timespans = (/"Annual","DJF","JJA","MAM","SON"/)
timespans = (/"DJF","MAM","JJA","SON"/)
;timespan = getenv("NCL_season")
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

    timespan = timespans(ts)
    dimsexps = dimsizes(Experiments)
    nexps = dimsexps(0)

    do exps = 0,nexps-1
        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")
        print(Experiment)

        filenamepl = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_Xpl_" + Experiment + ".cam2.h0.nc"
        ; open file with seasonal averages
        cdf_filepl = addfile(filenamepl,"r")

		; get pressure levels

		level = cdf_filepl->lev_p		; in hpa, or mb
        loglevel = log(level)
		level!0="lev_p"
		levsizes = dimsizes(level)
		ntimes = filevardimsizes(cdf_filepl,"time")
		nlevels = filevardimsizes(cdf_filepl,"lev_p")
		nlat = filevardimsizes(cdf_filepl,"lat")
		nlon = filevardimsizes(cdf_filepl,"lon")

		lat = tofloat(cdf_filepl->lat)
		lat!0="lat"
		lon = tofloat(cdf_filepl->lon)
		lon!0="lon"

		U = dim_avg_n_Wrap(cdf_filepl->U,3) ; get zonal mean U
        TH = dim_avg_n_Wrap(cdf_filepl->TH,3) ; get zonal mean TH
        Z = dim_avg_n_Wrap(cdf_filepl->Z3,3) ; get zonal mean Z

		filo = (Dir + "KsZM_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_ERAIlev.nc")
	
		system("/bin/rm -f " + filo)

        returned = calcZMKs(U,TH,Z,level,lat,filo)

        if (returned .ne. 1) then
            print(returned)
            exit
        end if

	end do
end do

end
