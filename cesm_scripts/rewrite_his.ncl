load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

system("rm -f test_*.nc*")

Experiment = (/"CESMnoRf19"/) 
print(Experiment)
Base = (/"CESMtopof19"/) 

t1 = 0
t2 = -1
count = 1

nyears = 2
nm = 1

maxdays = (/31,28,31,30,31,30,31,31,30,31,30,31/)
secs = new((/2/),string)


iyear = 40
imonth = 12
iday = 27
secs(0) = ("00000")
secs(1) = ("43200")
nsec = 0

byear = 41
bmonth = 1



if (byear .LT. 10) then
	byearstring = ("0" + tostring(byear))
else
	byearstring = (tostring(byear))
end if
if (bmonth .LT. 10) then
	bmonthstring = ("0" + tostring(bmonth))
else
	bmonthstring = (tostring(bmonth))
end if

filebase = ("/home/disk/eos4/rachel/CESM_outfiles/" + Base + "/atm/hist/" + Base + ".cam2.h1.00" + byearstring +"-" + bmonthstring + "-01-00000.nc")  

base_file = addfile(filebase,"r")
print("base file read in")

basetimes  = base_file->time
ntim =dimsizes(basetimes)

print(ntim)

endt = ntim(0)
starttime = basetimes(0)
endtime = basetimes(endt-1)
print(endtime)

if (iyear .LT. 10) then
	yearstring = ("0" + tostring(iyear))
else
	yearstring = (tostring(iyear))
end if
if (imonth .LT. 10) then
	monthstring = ("0" + tostring(imonth))
else
	monthstring = (tostring(imonth))
end if
if (iday.LT. 10) then
	daystring = ("0" + tostring(iday))
else
	daystring = (tostring(iday))
end if



filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiment + "/atm/hist/" + Experiment + ".cam2.h1.00" + yearstring +"-" + monthstring + "-" + daystring + "-" + secs(nsec) + ".nc")

cdf_file = addfile(filename,"r")
print(filename)

times  = cdf_file->time
ntim =dimsizes(times)

do nt = 0,ntim
	if (times(nt) .EQ. starttime) then
		t1 = nt
		break
	end if
end do

do while (nm .LT. nyears) 

print(count)
if (iyear .LT. 10) then
	yearstring = ("0" + tostring(iyear))
else
	yearstring = (tostring(iyear))
end if
if (imonth .LT. 10) then
	monthstring = ("0" + tostring(imonth))
else
	monthstring = (tostring(imonth))
end if
if (iday.LT. 10) then
	daystring = ("0" + tostring(iday))
else
	daystring = (tostring(iday))
end if



filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiment + "/atm/hist/" + Experiment + ".cam2.h1.00" + yearstring +"-" + monthstring + "-" + daystring + "-" + secs(nsec) + ".nc")

cdf_file = addfile(filename,"r")
;print(filename)
delete(times)
times  = cdf_file->time
ntim =dimsizes(times)
lasttime = ntim(0)

;print(times(lasttime - 1)*1)

print(endtime*1)

if (times(lasttime - 1) .GE. endtime) then

	do nt = 0,lasttime-1
		if (times(nt) .EQ. endtime) then
			t2 = nt

			if (count .LT. 10) then
				system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_0" + tostring(count) + ".nc")
			else
				system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_" + tostring(count) + ".nc")
			end if
			system("ncrcat -O test_*.nc /home/disk/eos4/rachel/CESM_outfiles/" + Experiment + "/atm/hist/" + Experiment + ".cam2.h1.00" + byearstring +"-" + bmonthstring + "-01-00000.nc")
			system("rm -f test_*.nc*")
			count = 1
			
			if (nt .EQ. lasttime -1) then
				t1 = 0
				t2 = -1
			else
				t1 = nt+1
				t2 = lasttime - 1

				if (count .LT. 10) then
					system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_0" + tostring(count) + ".nc")
				else
					system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_" + tostring(count) + ".nc")
				end if
				count = count + 1
				t1 = 0
			end if

			if (nsec .EQ. 0) then			
				nsec = nsec + 1
				iday = iday + 7
				if iday .GT. maxdays(imonth-1) then
					iday = iday - maxdays(imonth-1)
					imonth = imonth + 1
					if imonth .GT. 12 then
						iyear = iyear + 1
						imonth = 1
					end if
				end if
			else
				nsec = 0
				iday = iday + 8
				if iday .GT. maxdays(imonth-1) then	
					iday = iday - maxdays(imonth-1)
					imonth = imonth + 1
					if imonth .GT. 12 then
						iyear = iyear + 1
						imonth = 1
					end if
				end if			
			end if

			byear = byear + 1
			
			if (byear .LT. 10) then
				byearstring = ("0" + tostring(byear))
			else
				byearstring = (tostring(byear))
			end if

			filebase = ("/home/disk/eos4/rachel/CESM_outfiles/" + Base + "/atm/hist/" + Base + ".cam2.h1.00" + byearstring +"-01-01-00000.nc")  

			base_file = addfile(filebase,"r")
			print(filebase)

			basetimes  = base_file->time
			ntim =dimsizes(basetimes)

			print(ntim)

			endt = ntim(0)
			endtime = basetimes(endt-1)
			print(endtime)
			nm = nm + 1
			break

		end if
	end do

else
	t2 = lasttime - 1
	if (count .LT. 10) then
		system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_0" + tostring(count) + ".nc")
		print(" test_0" + tostring(count) + ".nc")
	else
		system("ncks -O -d time," + t1 + "," + t2 + " " + filename + " test_" + tostring(count) + ".nc")
		print(" test_" + tostring(count) + ".nc")
	end if
	t1 = 0
		
	count = count + 1
	
	if (nsec .EQ. 0) then			
		nsec = nsec + 1
		iday = iday + 7
		if iday .GT. maxdays(imonth-1) then
			iday = iday - maxdays(imonth-1)
			imonth = imonth + 1
			if imonth .GT. 12 then
				iyear = iyear + 1
				imonth = 1
			end if
		end if
	else
		nsec = 0
		iday = iday + 8		
		if iday .GT. maxdays(imonth-1) then
			iday = iday - maxdays(imonth-1)
			imonth = imonth + 1
			if imonth .GT. 12 then
				iyear = iyear + 1
				imonth = 1
			end if
		end if			
	end if

	print(iday *1.0)
	print(imonth * 1.0)
	print(iyear * 1.0)


end if	

end do

end