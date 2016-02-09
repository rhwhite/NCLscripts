load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin



Directory = "/home/disk/rachel/CESM_outfiles/"
Experiments = (/"CAM4SOM4def1"/)

starts = (/20/)
ends = (/49/)

nexps = dimsizes(Experiments)
print(nexps)


quote = inttochar(34) 

do exps = 0,nexps-1

	expstart = starts(exps)
	expend = ends(exps)
	nyears = expend - expstart + 1

	print(nyears)

	Experiment = Experiments(exps)
	print(Experiment)

	Dir = (Directory + Experiment + "/atm/hist/")

	system("cd " + Dir)

	system("mkdir " + Dir + "TempDir")

	system("mv " + Dir + "Extra/" + Experiment + ".cam2.h* " + Dir)

	system("mv " + Dir + Experiment + ".cam2.h0.* " + Dir + "TempDir")
	system("mv " + Dir + Experiment + ".cam2.h1.* " + Dir + "TempDir")


	do iy = expstart,expend
		if iy .LT. 10 then
			stringyear = "000" + tostring(iy)
		else
			stringyear = "00" + tostring(iy)
		end if

		system("mv " + " " + Dir + "/TempDir/" + Experiment + ".cam2.h?." + stringyear + "*.nc " + Dir)
	end do


	do iy = expstart,expend
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
		if (.not.isfilepresent(Dir + Experiment + ".cam2.h1."+ stringyear + "-01-01-00000.nc")) then
			print("file not present" + Dir + Experiment + ".cam2.h1."+ stringyear + "-01-01-00000.nc")
			exit
		end if
	end do

	system("ncrcat -O -v U250 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O -v U850 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O -v V250 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O -v V850 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")

	system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v U250 /home/disk/rachel/CESM_outfiles/CAM4SOM4def1/atm/hist/CAM4SOM4def1.cam2.h1.0020(:49)-01(:12).nc" + quote + " " + Dir + "U250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v U850 /home/disk/rachel/CESM_outfiles/CAM4SOM4def1/atm/hist/CAM4SOM4def1.cam2.h1.0020(:49)-01(:12).nc" + quote + " " + Dir + "U850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v V250 /home/disk/rachel/CESM_outfiles/CAM4SOM4def1/atm/hist/CAM4SOM4def1.cam2.h1.0020(:49)-01(:12).nc" + quote + " " + Dir + "V250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v V850 /home/disk/rachel/CESM_outfiles/CAM4SOM4def1/atm/hist/CAM4SOM4def1.cam2.h1.0020(:49)-01(:12).nc" + quote + " " + Dir + "V850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")

end do

end
