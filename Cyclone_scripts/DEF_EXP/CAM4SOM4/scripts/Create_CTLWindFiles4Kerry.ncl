load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin



Directory = "/home/disk/rachel/CESM_outfiles/"
Experiments = (/"CAM4SOM4topo"/) ;"CAM4SOM4def1"/)

starts = (/11,20/)
ends = (/40,49/)

nexps = dimsizes(Experiments)
print(nexps)


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

	system("ncrcat -O -v U250 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U250_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O -v U850 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "U850_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O -v V250 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V250_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
	system("ncrcat -O  -v V850 " + Dir + Experiment + ".cam2.h1.*.nc " + Dir + "V850_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")


; Now change from 6-hourly data to daily data by averaging

Filein = Dir + "U250_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc"
cdf_file=addfile(Filein,"r")
times = cdf_file->time
ntime = dimsizes(times)
print(ntime)

system("rm " + Dir + "temp_????_daily*.nc") 

do ii = 0,ntime-4,4
	iistr = sprinti("%0.6i",ii)
	ii2 = ii + 3
	system("ncra -O -d time," + ii + "," + ii2 + " " + Dir + "U250_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc " + Dir + "temp_U250_daily_" + iistr + ".nc")
        system("ncra -O -d time," + ii + "," + ii2 + " " + Dir + "U850_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc " + Dir + "temp_U850_daily_" + iistr + ".nc")
        system("ncra -O -d time," + ii + "," + ii2 + " " + Dir + "V250_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc " + Dir + "temp_V250_daily_" + iistr + ".nc")
        system("ncra -O -d time," + ii + "," + ii2 + " " + Dir + "V850_6hrly_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc " + Dir + "temp_V850_daily_" + iistr + ".nc")

end do

	system("ncrcat -O " + Dir + "temp_U250_daily_??????.nc " + Dir + "U250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncrcat -O " + Dir + "temp_U850_daily_??????.nc " + Dir + "U850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncrcat -O " + Dir + "temp_V250_daily_??????.nc " + Dir + "V250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")
        system("ncrcat -O " + Dir + "temp_V850_daily_??????.nc " + Dir + "V850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h1.nc")

	system("rm " + Dir + "temp_????_daily_??????.nc")

        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v U250 " + Dir + Experiment + ".cam2.h0.0020(:49)-01(:12).nc" + quote + " " + Dir + "U250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h0.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v U850 " + Dir + Experiment + ".cam2.h0.0020(:49)-01(:12).nc" + quote + " " + Dir + "U850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h0.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v V250 " + Dir + Experiment + ".cam2.h0.0020(:49)-01(:12).nc" + quote + " " + Dir + "V250_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h0.nc")
        system("ncatted -O -h -a history,global,m,c," + quote + "ncrcat -v V850 " + Dir + Experiment + ".cam2.h0.0020(:49)-01(:12).nc" + quote + " " + Dir + "V850_daily_" + expstart + "_" + nyears + "yrs_" + Experiment + ".cam2.h0.nc")



end do

end
