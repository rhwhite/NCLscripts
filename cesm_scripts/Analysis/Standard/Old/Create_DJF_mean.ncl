load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 20
startyear = 160

Directory = "/home/disk/rachel/CESM_outfiles/"
Experiments = (/"CESMSOMtopof19g16","CESMSOM2topof19g16","CESMSOM4topof19g16"/)

nexps = dimsizes(Experiments)

do exps = 0,nexps-1

Experiment = Experiments(exps)
print(Experiment)

Dir = (Directory + Experiment + "/atm/hist/")

if (isfilepresent(Dir + Experiment + ".cam2.h0.0159-01.nc")) then
	print("file is present" + Dir + Experiment + ".cam2.h0.0159-01.nc")
	exit
end if
if (isfilepresent(Dir + Experiment + ".cam2.h0.0159-02.nc")) then
	print("file is present" + Dir + Experiment + ".cam2.h0.0159-01.nc")
	exit
end if

if (.not.isfilepresent(Dir + Experiment + ".cam2.h0.0159-12.nc")) then
	print("file not present" + Dir + Experiment + ".cam2.h0.0159-12.nc")
	exit
end if

do iy = startyear,startyear+nyears-2
	stringyear = "0" + tostring(iy)

	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-01.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-01.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-02.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-02.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-12.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-12.nc")
	exit
	end if	
end do
iy = startyear + nyears - 1

	stringyear = "0" + tostring(iy)

if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-01.nc")) then
	print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-01.nc")
	exit
end if
if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-02.nc")) then
	print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-02.nc")
	exit
end if
if (isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-12.nc")) then
	print("file IS present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-12.nc")
	exit
end if

system("ncra -O " + Dir + Experiment + ".cam2.h0.*-12.nc " + Dir + Experiment + ".cam2.h0.*-01.nc " + Dir + Experiment + ".cam2.h0.*-02.nc " + Dir + "DJF"+nyears +"_mean_" + Experiment + ".cam2.h0.nc")

end do

end