;load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

Mtrans = getenv("NCL_Mtrans")
GW = getenv("NCL_GW")

timespans = (/"Annual","DJF","JJA","MAM","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

	timespan = timespans(ts)
	dimsexps = dimsizes(Experiments)
	nexps = dimsexps(0)

	pnew           = (/  20, 50, 100,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		Dir = (Direc + Experiment + "/atm/hist/")
	
		print(Experiment)

		filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	  	cdf_file = addfile(filename,"r")
	
;-----------------------------------------------------------------------
;Create output file
;-----------------------------------------------------------------------
		filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_pl_" + Experiment + ".cam2.h0.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")
	
		
        delete(Experiment)
		delete(filename)
	
	end do

end do

end
