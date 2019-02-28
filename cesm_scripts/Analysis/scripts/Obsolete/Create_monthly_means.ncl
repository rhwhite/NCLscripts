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

if startyr .lt. 10 then
	startyrst = "000" + tostring(startyr)
else
	if startyr .lt. 100 then
		startyrst = "00" + tostring(startyr)
	else
		startyrst = "0" + tostring(startyr)
	end if
end if
if endyr .lt. 10 then
        endyrst = "000" + tostring(endyr)
else
        if endyr .lt. 100 then
                endyrst = "00" + tostring(endyr)
        else
                endyrst = "0" + tostring(endyr)
        end if
end if

nexps2 = dimsizes(Experiments)
if(nexps2 .NE. nexps)
	print(nexp2)
	print(nexps)
	exit
end if

do exps = 0,nexps-1

	Experiment = Experiments(exps)
	print(Experiment)

	Dir = (Direc + Experiment + "/atm/hist/")

	system("mkdir " + Dir + "TempDir")
	system("mkdir " + Dir + "Extra")

	system("mv " + Dir + "/Extra/" + Experiment + ".cam2.h0.0* " + Dir + "/")

	system("mv " + Dir + Experiment + ".cam2.h0.*" + ".nc " + Dir + "TempDir/")


	do iy = startyr,endyr
	        if iy .lt. 10 then
	                stringyear = "000" + tostring(iy)
		else 
			if iy .lt. 100 then
				stringyear = "00" + tostring(iy)
			else
				stringyear = "0" + tostring(iy)
			end if
		end if
		
		system("mv " + Dir + "TempDir/" + Experiment + ".cam2.h0." + stringyear + "-*" + ".nc " + Dir + "/")
       		do im = 1,12
       	        	if im .lt. 10 then
                	        stringmonth = "0" + tostring(im)
                	else
                	        stringmonth = tostring(im)
                	end if
	
	                if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-" + stringmonth + ".nc")) then
	                        print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-" + stringmonth + ".nc")
	                        exit
	                end if
	        end do
	end do
	
	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0." + startyrst + "-01.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0." + startyrst + "-01.nc")
		exit
	end if
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0." + endyrst + "-12.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0." + endyrst + "-12.nc")
		exit
	end if

	do imonth=1,12
		if imonth .lt. 10 then
			stringmonth = "0" + tostring(imonth)
		else
			stringmonth = tostring(imonth)
		end if
		
		system("ncra -O " + Dir + Experiment + ".cam2.h0.*-" + stringmonth + ".nc " + Dir + "MonMean_" + tostring(startyr) + "_" + tostring(nyears) + "_" + stringmonth + "_" + Experiment + ".cam2.h0.nc")
	end do
		system("ncra -O " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "Annual" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")

	system("mv " + Dir + "TempDir/*.nc " + Dir + "/")

	print("finished with " + Experiment + " from " + tostring(startyr) + " to " + tostring(endyr))

end do

end
