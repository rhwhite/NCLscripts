load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

MET = getenv("NCL_Mtrans") ; Flag to calculate meridional potential energy transport, which isn't normally in the output files.
if (MET .EQ. 1) then
	print("Calculating all meridional transport terms")
end if
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

g = 9.80665
cp = 1004.0
lp = 2501000.0

do ne = 0,nexps-1
	Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

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

	system("mkdir " + Dir + "TempDir")
	system("mkdir " + Dir + "Extra")

	system("mv " + Dir + "/Extra/" + Experiment + ".cam2.h0.0* " + Dir + "/")

	system("mv " + Dir + Experiment + ".cam2.h0.*" + ".nc " + Dir + "TempDir/")

	if (isfilepresent(Dir + Experiment + ".cam2.h0." + startyr + "-01.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0." + startyr + "-01.nc")
		exit
	end if
		
	do iy = startyr,endyr
		print(tostring(iy))
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

			;       Now for each month calculate Streamfunction, PV, theta

	
	        end do
	end do
	
	system("ncra -O " + Dir + Experiment + ".cam2.h0.*-12.nc " + Dir + Experiment + ".cam2.h0.*-01.nc " + Dir + Experiment + ".cam2.h0.*-02.nc " + Dir + "DJF" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	system("ncra -O " + Dir + Experiment + ".cam2.h0.*-03.nc " + Dir + Experiment + ".cam2.h0.*-04.nc " + Dir + Experiment + ".cam2.h0.*-05.nc " + Dir + "MAM" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	system("ncra -O " + Dir + Experiment + ".cam2.h0.*-06.nc " + Dir + Experiment + ".cam2.h0.*-07.nc " + Dir + Experiment + ".cam2.h0.*-08.nc " + Dir + "JJA" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")
	
	system("ncra -O " + Dir + Experiment + ".cam2.h0.*-09.nc " + Dir + Experiment + ".cam2.h0.*-10.nc " + Dir + Experiment + ".cam2.h0.*-11.nc " + Dir + "SON" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")

        system("ncra -O -v TS,PRECT,Z3 " + Dir + Experiment + ".cam2.h0.*-07.nc " + Dir + Experiment + ".cam2.h0.*-08.nc " + Dir + Experiment + ".cam2.h0.*-09.nc " + Dir + "JAS" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")

	system("ncra -O " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "Annual" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc")

	system("mv " + Dir + "TempDir/*.nc " + Dir + "/")

	print("finished with " + Experiment + " from " + tostring(startyr) + " to " + tostring(endyr))

end do

end
