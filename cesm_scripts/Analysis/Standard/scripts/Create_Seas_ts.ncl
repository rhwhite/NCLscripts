load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; create timeseries of all years of monthly data for
; DJF, MAM, JJA and SON

begin

Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
	Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

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

	Dir = (Direc + Experiment + "/" + dirstr + "/raw/" )
    Dirout = (Direc + Experiment + "/" + dirstr )

	system("mkdir " + Dir + "TempDir")
	system("mkdir " + Dir + "Extra")

	system("mv " + Dir + "/Extra/" + Experiment + ".cam2.h0.0* " + Dir + "/")

	system("mv " + Dir + Experiment + ".cam2.h0.*" + ".nc " + Dir + "TempDir/")


	if startyr-1 .lt. 10
		startyrm1 = "000" + tostring(startyr - 1)
	else
		if (startyr-1) .lt. 100
			startyrm1 = "00" + tostring(startyr - 1) 
		else
			startyrm1 = "0" + tostring(startyr-1)
		end if
	end if
	if endyr .lt. 10
	        endyrst = "000" + num2str(endyr)
	else
	        if endyr .lt. 100
	                endyrst = "00" + tostring(endyr)
	        else
	                endyrst = "0" + tostring(endyr)
	        end if
	end if
	
	system("mv " + Dir + "TempDir/" + Experiment + ".cam2.h0." + startyrm1 + "-12*" + ".nc " + Dir + "/")
	
	if (isfilepresent(Dir + Experiment + ".cam2.h0." + startyrm1 + "-01.nc")) then
		print("file is present" + Dir + Experiment + "cam2.h0." + startyrm1 + "-01.nc")
		exit
	end if
	if (isfilepresent(Dir + Experiment + ".cam2.h0." + startyrm1 + "-02.nc")) then
		print("file is present" + Dir + Experiment + "cam2.h0." + startyrm1 + "-02.nc")
		exit
	end if

; No longer going to check for this, so we can start in year 1 if we want	
;	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0." + startyrm1 + "-12.nc")) then
;		print("file not present" + Dir + Experiment + ".cam2.h0." + startyrm1 + "-12.nc")
;		exit
;	end if
		
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
	
	system("mv " + Dir + "TempDir/" + Experiment + ".cam2.h0." + endyrst + "-*" + ".nc " + Dir + "/")
	system("mv " + Dir + Experiment + ".cam2.h0." + endyrst + "-12*" + ".nc " + Dir + "TempDir/")
	
	
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0." + endyrst + "-01.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0." + endyrst + "-01.nc")
		exit
	end if
	if (.not.isfilepresent(Dir + Experiment + ".cam2.h0." + endyrst + "-02.nc")) then
		print("file not present" + Dir + Experiment + ".cam2.h0." + endyrst + "-02.nc")
		exit
	end if
	if (isfilepresent(Dir + Experiment + ".cam2.h0." + endyrst + "-12.nc")) then
		print("file IS present" + Dir + Experiment + ".cam2.h0." + endyrst + "-12.nc")
		exit
	end if

    system("ncrcat -h -O -v TS,PS,TREFHT,FSNT,FLNT,CLDTOT,CLDLOW,CLDMED,FSNS,FLNS,QFLX,SHFLX,RHREFHT,QREFHT,TMQ,TAUX,TAUY,U10,U,V,T,Z3,Q,PS,PHIS,P0,lat,lon,hyam,hybm " + Dir + Experiment + ".cam2.h0.*-??.nc " + Dirout + "Annual" + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")

	system("ncrcat -h -O -v TS,PS,TREFHT,FSNT,FLNT,CLDTOT,CLDLOW,CLDMED,FSNS,FLNS,QFLX,SHFLX,RHREFHT,QREFHT,TMQ,TAUX,TAUY,U10,U,V,T,Z3,Q,PS,PHIS,P0,lat,lon,hyam,hybm " + Dir + Experiment + ".cam2.h0.*-12.nc " + Dir + Experiment + ".cam2.h0.*-01.nc " + Dir + Experiment + ".cam2.h0.*-02.nc " + Dirout + "DJF" + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")
	
	system("ncrcat -h -O -v TS,PS,TREFHT,FSNT,FLNT,CLDTOT,CLDLOW,CLDMED,FSNS,FLNS,QFLX,SHFLX,RHREFHT,QREFHT,TMQ,TAUX,TAUY,U10,U,V,T,Z3,Q,PS,PHIS,P0,lat,lon,hyam,hybm " + Dir + Experiment + ".cam2.h0.*-03.nc " + Dir + Experiment + ".cam2.h0.*-04.nc " + Dir + Experiment + ".cam2.h0.*-05.nc " + Dirout + "MAM" + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")
	
    system("ncrcat -h -O -v TS,PS,TREFHT,FSNT,FLNT,CLDTOT,CLDLOW,CLDMED,FSNS,FLNS,QFLX,SHFLX,RHREFHT,QREFHT,TMQ,TAUX,TAUY,U10,U,V,T,Z3,Q,PS,PHIS,P0,lat,lon,hyam,hybm " + Dir + Experiment + ".cam2.h0.*-06.nc " + Dir + Experiment + ".cam2.h0.*-07.nc " + Dir + Experiment + ".cam2.h0.*-08.nc " + Dirout + "JJA" + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")

    system("ncrcat -h -O -v TS,PS,TREFHT,FSNT,FLNT,CLDTOT,CLDLOW,CLDMED,FSNS,FLNS,QFLX,SHFLX,RHREFHT,QREFHT,TMQ,TAUX,TAUY,U10,U,V,T,Z3,Q,PS,PHIS,P0,lat,lon,hyam,hybm " + Dir + Experiment + ".cam2.h0.*-09.nc " + Dir + Experiment + ".cam2.h0.*-10.nc " + Dir + Experiment + ".cam2.h0.*-11.nc " + Dirout + "SON" + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")

	
	system("mv " + Dir + "TempDir/*.nc " + Dir + "/")


	print("finished with " + Experiment + " from " + tostring(startyr) + " to " + tostring(endyr))

end do

end
