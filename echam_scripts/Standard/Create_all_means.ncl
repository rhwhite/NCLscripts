load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print(getenv("NCL_ARG_1"))
print(getenv("NCL_ARG_2"))
print(getenv("NCL_ARG_3"))
print(getenv("NCL_ARG_4"))
print(getenv("NCL_ARG_5"))
print(getenv("NCL_ARG_6"))


Dir = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
print(nexps)
Experiments = new(nexps,"string")

do ne = 0,nexps-1
	Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

print(Dir)
print(nexps)
print(Experiments)

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))

print(startyr)
print(endyr)
print(Experiments)

Directory = "/home/disk/" + Dir

do exps = 0,nexps-1

Experiment = Experiments(exps)
print(Experiment)

Dir = (Directory + Experiment + "/PProc/")

system("mkdir " + Dir + "TempDir")

system("mv " + Dir + Experiment + "_*.nc " + Dir + "TempDir/")
print(startyr)

if startyr-1 .LT. 10
	startyrm1 = "000" + tostring(startyr - 1)
else
	if (startyr-1) .LT. 100
		startyrm1 = "00" + tostring(startyr - 1) 
	else
		startyrm1 = "0" + tostring(startyr-1)
	end if
end if
if endyr+1 .LT. 10
        endyrst = "000" + num2str(endyr+1)
else
        if endyr .LT. 100
                endyrst = "00" + tostring(endyr+1)
        else
                endyrst = "0" + tostring(endyr+1)
        end if
end if

if (isfilepresent(Dir + Experiment + "_" + startyrm1 + ".nc")) then
	print("file is present" + Dir + Experiment + "_" + startyrm1 + ".nc")
	exit
end if

do iy = startyr,endyr
        if iy .LT. 10 then
                stringyear = "000" + tostring(iy)
	else 
		if iy .LT. 100 then
			stringyear = "00" + tostring(iy)
		else
			stringyear = "0" + tostring(iy)
		end if
	end if
	
	system("mv " + Dir + "TempDir/" + Experiment + "_"  + stringyear + ".nc " + Dir + "/")
  
	if (.not.isfilepresent(Dir + Experiment + "_" + stringyear + ".nc")) then
                print("file not present" + Dir + Experiment + "_" + stringyear + ".nc")
                exit
        end if
end do

if (isfilepresent(Dir + Experiment + endyrst + ".nc")) then
	print("file present" + Dir + Experiment + "_" + endyrst + ".nc")
	exit
end if

system("ncea -d time,0,11 -O " + Dir + Experiment + "*.nc " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

system("ncks -O -d time,11, -d time,0,1 " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "DJF_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc") 

system("ncra -O " + Dir + "DJF_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "DJF_mean_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

system("ncra -d time,2,4 -O " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "MAM_mean_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

system("ncra -d time,5,7 -O " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "JJA_mean_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

system("ncra -d time,8,10 -O " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "SON_mean_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

system("ncra -O " + Dir + "Clim_mean_" + tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc " + Dir + "Ann_mean_" +  tostring(startyr) + "to" + tostring(endyr) + "_" + Experiment + ".nc")

print("finished with " + Experiment + " from " + tostring(startyr) + " to " + tostring(endyr))

end do

end
