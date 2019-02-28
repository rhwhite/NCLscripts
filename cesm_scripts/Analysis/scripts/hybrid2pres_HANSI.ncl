;load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/Functions/process.ncl"
begin

Direc = getenv("NCL_dir")
Experiment = getenv("NCL_exp")
print(Experiment)

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

Mtrans = getenv("NCL_Mtrans")
GW = getenv("NCL_GW")

timespans = (/"ann","DJF","JJA","MAM","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

do ts = 0,nts - 1

	timespan = timespans(ts)

	pnew           = (/  20, 50, 100,250 \
                     , 300,400,500,600,700,750,775,850,925,1000 /)

    Dir = (Direc + "/" + Experiment + "/")

    filename = (Dir + Experiment + ".cam." + tostring(startyr) + "-" + tostring(endyr) + "." + timespan + ".nc")

    cdf_file = addfile(filename,"r")

;-----------------------------------------------------------------------
;Create output file
;-----------------------------------------------------------------------
    filo = Dir + Experiment + ".cam." + tostring(startyr) + "-" + tostring(endyr) + ".PL." + timespan + ".nc"

    system("/bin/rm -f " + filo)
    fout = addfile(filo, "c")

    success = hybrid2pres(cdf_file,fout,pnew)

end do

end
