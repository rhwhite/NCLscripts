load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; Calculate various variables including PV, SF, divergences, MSE
; and add to monthly average files
; then calculate climatological means on monthly
; and annual resolution using NCO command line functions

begin

MET = getenv("NCL_Mtrans") ; Flag to calculate meridional potential energy transport, which isn't normally in the output files.
if (MET .EQ. 1) then
	print("Calculating all meridional transport terms")
end if
OZONE = getenv("NCL_Ozone") ; Flag to output ozone or not (only for WACCM)
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

g = 9.80665
cp = 1004.0
lp = 2501000.0

do ne = 0,nexps-1
	Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

dirstr = getenv("NCL_dirstr")

nyears = endyr-startyr+1

print(startyr*1)
print(endyr*1)


nexps2 = dimsizes(Experiments)
if(nexps2 .NE. nexps)
	print(nexp2)
	print(nexps)
	exit
end if

do exps = 0,nexps-1

	Experiment = Experiments(exps)
	print(Experiment)

	Dir = (Direc + Experiment + dirstr)

    filename = (Dir + "Z3_10mb_" + Experiment + ".cam2.h2.0001-0041.nc")

    cdf_file = addfile(filename,"w")
    
    PHI = cdf_file->Z3
    lapl = lapsG(PHI)
    
    f = coriolis_param(cdf_file->lat)

    vort = (1/conform(lapl,f,2)) * lapl

    printVarSummary(PHI)
    copy_VarCoords(PHI,vort)
    printVarSummary(vort)
    cdf_file->vort = vort    	

end do

end
