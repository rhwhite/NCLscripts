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


Dir = (Directory + Experiment + "/atm/hist/")

system("mkdir " + Dir + "TempDir")
system("mkdir " + Dir + "Extra")

system("mv " + Dir + "/Extra/" + Experiment + ".cam2.h0.0041* " + Dir + "/")

system("mv " + Dir + Experiment + ".cam2.h0.0001-*" + ".nc " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".cam2.h0.0042-*" + ".nc " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".cam2.h0.0043-*" + ".nc " + Dir + "TempDir/")


do iy = 2,41
	if iy .LT. 10 then
		stringyear = "000" + tostring(iy)
	else
		stringyear = "00" + tostring(iy)
	end if
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-06.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-01.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-07.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-02.nc")
	exit
	end if	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0."+ stringyear + "-08.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0."+ stringyear + "-12.nc")
	exit
	end if	
end do

system("ncra -O " + Dir + Experiment + ".cam2.h0.*-06.nc " + Dir + Experiment + ".cam2.h0.*-07.nc " + Dir + Experiment + ".cam2.h0.*-08.nc " + Dir + "JJA40_mean_" + Experiment + ".cam2.h0.nc")

system("mv " + Dir + "TempDir/* " + Dir + "/")

end do

end
