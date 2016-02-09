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
system("mv " + Dir + Experiment + ".cam2.h1.0001-* " + Dir + "TempDir")

system("mv " + Dir + "Extra/" + Experiment + ".cam2.h0.0041* " + Dir)
system("mv " + Dir + Experiment + ".cam2.h0.0042-* " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".cam2.h0.0043-* " + Dir + "TempDir/")

system("mv " + Dir + Experiment + ".cam2.h1.0042-* " + Dir + "TempDir/")
system("mv " + Dir + Experiment + ".cam2.h1.0043-* " + Dir + "TempDir/")



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

system("ncrcat -v TS " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "TS_mon_40years_" + Experiment + ".cam2.h0.nc")
system("ncrcat -v T " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "T_mon_40years_" + Experiment + ".cam2.h0.nc")
system("ncrcat -v Q " + Dir + Experiment + ".cam2.h0.*.nc " + Dir + "Q_mon_40years_" + Experiment + ".cam2.h0.nc")

system("ncrcat -v U250 -d time,0,,4 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U250_daily_40years_" + Experiment + ".cam2.h1.nc")
system("ncrcat -v U850 -d time,0,,4 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U850_daily_40years_" + Experiment + ".cam2.h1.nc")
system("ncrcat -v V250 -d time,0,,4 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V250_daily_40years_" + Experiment + ".cam2.h1.nc")
system("ncrcat -v V850 -d time,0,,4 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V850_daily_40years_" + Experiment + ".cam2.h1.nc")

system("mv " + Dir + "TempDir/* " + Dir)

end do

end
