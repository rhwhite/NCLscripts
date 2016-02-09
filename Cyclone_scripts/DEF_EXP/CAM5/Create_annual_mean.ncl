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

system("mv " + Dir + Experiment + ".cam2.h0.0001-* " + Dir + "TempDir")

system("mv " + Dir + "Extra/" + Experiment + ".cam2.h0.0041* " + Dir)
system("mv " + Dir + Experiment + ".cam2.h0.0042-* " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".cam2.h0.0043-* " + Dir + "TempDir/")


do iy = 2,41
	if iy .LT. 10 then
		stringyear = "000" + tostring(iy)
	else
		stringyear = "00" + tostring(iy)
	end if
	
	do im = 1,12
		if im .LT. 10 then
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

system("ncra -O " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "Annual40_mean_" + Experiment + ".cam2.h0.nc")

system("mv " + Dir + "TempDir/* " + Dir)

end do

end
