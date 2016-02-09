load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

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

print(startyr*1)
print(endyr*1)

nexps2 = dimsizes(Experiments)
if(nexps2 .NE. nexps)
	print(nexp2)
	print(nexps)
	exit
end if

Months = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

do iexp=1,2
	do imonth=0,11
		print(Months(imonth))
		system("ncdiff " + Direc + Months(imonth) + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc " + Direc + Months(imonth) + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc " + Direc + Months(imonth) + tostring(startyr) + "_" + tostring(nyears) + "_diffs_" + Experiments(iexp) + ".nc")
	end do
end do

	print("finished from " + tostring(startyr) + " to " + tostring(endyr))
end
