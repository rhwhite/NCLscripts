load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; Calculate various variables including PV, SF, divergences, MSE
; and add to monthly average files
; then calculate climatological means on monthly
; and annual resolution using NCO command line functions

begin

MET = getenv("NCL_Mtrans") ; Flag to calculate meridional potential energy transport, which isn't normally in the output files.
if (MET .EQ. 1) then
	print("Calculating all meridional transport terms")
end if
OZONE = getenv("NCL_Ozone") ; Flag to output ozone or not (only for WACCM)
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")
version=getenv("NCL_CESMversion")

if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

g = 9.80665
cp = 1004.0
lp = 2501000.0

do ne = 0,nexps-1
	Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

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

    system("mkdir " + Dir + "raw")
    system("mv " + Dir + Experiment + "." + camversion + ".h* " + Dir + "/raw/")

    Dirraw = Dir + "/raw/"
    ; make new temporary directories
	system("mkdir " + Dirraw + "TempDir")
	system("mkdir " + Dirraw + "Extra")

    ; move everything out of Extra
	system("mv " + Dirraw + "/Extra/" + Experiment + "." + camversion + ".h0.0* " + Dirraw + "/")

    ; move everything into TempDir
	system("mv " + Dirraw + Experiment + "." + camversion + ".h0.*" + ".nc " + Dirraw + "TempDir/")

    ; move selected files out of TempDir
	if (isfilepresent(Dirraw + Experiment + "." + camversion + ".h0." + startyr + "-01.nc")) then
		print("file not present" + Dirraw + Experiment + "." + camversion + ".h0." + startyr + "-01.nc")
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
				if iy .lt. 1000 then
					stringyear = "0" + tostring(iy)
				else
					stringyear = tostring(iy)
				end if
			end if
		end if
		
		system("mv " + Dirraw + "TempDir/" + Experiment + "." + camversion + ".h0." + stringyear + "-*" + ".nc " + Dirraw + "/")
        do im = 1,12
            if im .lt. 10 then
                stringmonth = "0" + tostring(im)
            else
                stringmonth = tostring(im)
            end if
	
            if (.not.isfilepresent(Dirraw + Experiment + "." + camversion + ".h0."+ stringyear + "-" + stringmonth + ".nc")) then
                print("file not present" + Dirraw + Experiment + "." + camversion + ".h0."+ stringyear + "-" + stringmonth + ".nc")
                exit
            end if

        end do
	end do

    ; Average months separately and multiply by annual weighting
    monthweights = (/31,28,31,30,31,30,31,31,30,31,30,31/)

    DJFtot = 31+31+28
    MAMtot = 31+30+31
    JJAtot = 30+31+31 
    SONtot = 30+31+30

    do im = 1,12
        monthwght = monthweights(im-1)

        system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-" + sprinti("%0.2i",im) + ".nc " + Dir + "Mon" + sprinti("%0.2i",im) + "_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

        ; weight by relative contribution of month to whole year average, because we average, not add, these files later
        system("ncflint -F -O -w " + tostring(12.0 * monthwght/365.0) + ",0 " + Dir + "Mon" + sprinti("%0.2i",im) + "_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc " + Dir + "Mon" + sprinti("%0.2i",im) + "_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc " + Dir + "Mon" + sprinti("%0.2i",im) + "_wght_temp.nc") 

    end do

    ; Now average these files
    ; DJF
    system("ncra -O " + Dir + "Mon12_wght_temp.nc " + Dir + "Mon01_wght_temp.nc " + Dir + "Mon02_wght_temp.nc " + Dir + "DJFwgt_temp.nc")
    ; re-weight because a season is not a quarter of a year
    system("ncflint -F -O -w " + tostring(365.0/(4*DJFtot)) + ",0 " + Dir + "DJFwgt_temp.nc " + Dir + "DJFwgt_temp.nc " + Dir + "DJF" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

    ; MAM
    system("ncra -O " + Dir + "Mon03_wght_temp.nc " + Dir + "Mon04_wght_temp.nc " + Dir + "Mon05_wght_temp.nc " + Dir + "MAMwgt_temp.nc")
    ; re-weight because a season is not a quarter of a year
    system("ncflint -F -O -w " + tostring(365.0/(4*MAMtot)) + ",0 " + Dir + "MAMwgt_temp.nc " + Dir + "MAMwgt_temp.nc " + Dir + "MAM" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
 

    ; JJA
    system("ncra -O " + Dir + "Mon06_wght_temp.nc " + Dir + "Mon07_wght_temp.nc " + Dir + "Mon08_wght_temp.nc " + Dir + "JJAwgt_temp.nc") 
    ; re-weight because a season is not a quarter of a year
    system("ncflint -F -O -w " + tostring(365.0/(4*JJAtot)) + ",0 " + Dir + "JJAwgt_temp.nc " + Dir + "JJAwgt_temp.nc " + Dir + "JJA" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

    ; SON
    system("ncra -O " + Dir + "Mon09_wght_temp.nc " + Dir + "Mon10_wght_temp.nc " + Dir + "Mon11_wght_temp.nc " + Dir + "SONwgt_temp.nc") 
    ; re-weight because a season is not a quarter of a year
    system("ncflint -F -O -w " + tostring(365.0/(4*SONtot)) + ",0 " + Dir + "SONwgt_temp.nc " + Dir + "SONwgt_temp.nc " + Dir + "SON" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
 
    ; Annual
    system("ncra -O " + Dir + "Mon??_wght_temp.nc " + Dir + "ANN_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

    system("rm " + Dir + "Mon??_wght_temp.nc")

    ; means without weighting for different length months	
	;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-12.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-01.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-02.nc " + Dir + "DJF_nowgt_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")	
	;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-03.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-04.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-05.nc " + Dir + "MAM_nowgt_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
	;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-06.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-07.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-08.nc " + Dir + "JJA_nowgt_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
	;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-09.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-10.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-11.nc " + Dir + "SON_nowgt_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")
    ;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*-07.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-08.nc " + Dirraw + Experiment + "." + camversion + ".h0.*-09.nc " + Dir + "JAS_nowgt_" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

	;system("ncra -O -x -v PV,THilev " + Dirraw + Experiment + "." + camversion + ".h0.*.nc " + Dir + "ANN_nowgt" + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc")

	;system("mv " + Dirraw + "TempDir/*.nc " + Dirraw + "/")

	print("finished with " + Experiment + " from " + tostring(startyr) + " to " + tostring(endyr))

end do

end
