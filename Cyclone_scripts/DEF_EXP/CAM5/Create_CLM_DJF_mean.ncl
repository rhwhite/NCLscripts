load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

Directory = "/home/disk/rachel/CESM_outfiles/"
Experiments = (/"CAM5topo","CAM5def1"/)

nexps = dimsizes(Experiments)

do exps = 0,nexps-1

Experiment = Experiments(exps)
print(Experiment)

Dir = (Directory + Experiment + "/lnd/hist/")

system("mkdir " + Dir + "TempDir")
system("mkdir " + Dir + "Extra")

system("mv " + Dir + "/Extra/" + Experiment + ".clm2.h0.0041* " + Dir + "/")

system("mv " + Dir + Experiment + ".clm2.h0.0001-*" + ".nc " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".clm2.h0.0042-*" + ".nc " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".clm2.h0.0043-*" + ".nc " + Dir + "TempDir/")

system("mv " + Dir + "TempDir/" + Experiment + ".clm2.h0.0001-12*" + ".nc " + Dir + "/")
system("mv " + Dir + Experiment + ".clm2.h0.0041-12*" + ".nc " + Dir + "TempDir/")


if (isfilepresent(Dir + Experiment + ".clm2.h0.0001-01.nc")) then
	print("file is present" + Dir + Experiment + "clm2.h0.0001-01.nc")
	exit
end if
if (isfilepresent(Dir + Experiment + ".clm2.h0.0001-02.nc")) then
	print("file is present" + Dir + Experiment + "clm2.h0.0001-02.nc")
	exit
end if

if (.not.isfilepresent(Dir + Experiment + ".clm2.h0.0001-12.nc")) then
	print("file not present" + Dir + Experiment + ".clm2.h0.0001-12.nc")
	exit
end if

do iy = 2,40
	if iy .LT. 10 then
		stringyear = "000" + tostring(iy)
	else
		stringyear = "00" + tostring(iy)
	end if
	if (.not.isfilepresent(Dir + Experiment + ".clm2.h0."+ stringyear + "-01.nc")) then
		print("file not present" + Dir + Experiment + ".clm2.h0."+ stringyear + "-01.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".clm2.h0."+ stringyear + "-02.nc")) then
		print("file not present" + Dir + Experiment + ".clm2.h0."+ stringyear + "-02.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".clm2.h0."+ stringyear + "-12.nc")) then
		print("file not present" + Dir + Experiment + ".clm2.h0."+ stringyear + "-12.nc")
	exit
	end if	
end do

if (.not.isfilepresent(Dir + Experiment + ".clm2.h0.0041-01.nc")) then
	print("file not present" + Dir + Experiment + ".clm2.h0.0041-01.nc")
	exit
end if
if (.not.isfilepresent(Dir + Experiment + ".clm2.h0.0041-02.nc")) then
	print("file not present" + Dir + Experiment + ".clm2.h0.0041-02.nc")
	exit
end if
if (isfilepresent(Dir + Experiment + ".clm2.h0.0041-12.nc")) then
	print("file IS present" + Dir + Experiment + ".clm2.h0.0041-12.nc")
	exit
end if

system("ncra -O " + Dir + Experiment + ".clm2.h0.*-12.nc " + Dir + Experiment + ".clm2.h0.*-01.nc " + Dir + Experiment + ".clm2.h0.*-02.nc " + Dir + "DJF40_CLM_mean_" + Experiment + ".clm2.h0.nc")

system("mv " + Dir + "TempDir/* " + Dir + "/")

end do

end
