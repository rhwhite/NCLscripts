load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

startyr = 20
nyears = 30

DirFrom = "/home/disk/rachel/CESM_outfiles/DEF-CTL/"

Vars = (/"U250","U850","V250","V850"/)
FileVars = (/"U","U","V","V"/)

nvars = dimsizes(Vars)

DEFname = "_Regrid_MonMean_DEF-CTL_" + tostring(startyr) + "_" + tostring(nyears) + ".nc"

daysinmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

do ivar = 0,nvars-1
	print(Vars(ivar))
	print(FileVars(ivar))

	if (Vars(ivar) .EQ. "U250")
                FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/uwnd_250_1948-2014.nc"
                Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_uwnd250_1948-2014.nc"
        else if (Vars(ivar) .EQ. "U850")
                FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/uwnd_850_1948-2014.nc"
                Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_uwnd850_1948-2014.nc"
        else if (Vars(ivar) .EQ. "V250")
                FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/vwnd_250_1948-2014.nc"
                Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_vwnd250_1948-2014.nc"
        else if (Vars(ivar) .EQ. "V850")
                FileNCEP = "/home/disk/eos4/rachel/Deforestation/NCEP/CTL/vwnd_850_1948-2014.nc"
                Fileto = "/home/disk/eos4/rachel/Deforestation/NCEP/CAM4SOM4/NCEP_DEF_" + tostring(startyr) + "_" + tostring(nyears) + "_vwnd850_1948-2014.nc"
	end if
	end if
	end if
	end if

	cdf_file_NCEP = addfile(FileNCEP,"r")
	cdf_file_DEF = addfile(DirFrom + Vars(ivar) + DEFname, "r")


        if (Vars(ivar) .EQ. "U250" .OR. Vars(ivar) .EQ. "U850") then
                NCEPin = cdf_file_NCEP->uwnd
                DEFin = cdf_file_DEF->uwnd
        else if (Vars(ivar) .EQ. "V250" .OR. Vars(ivar) .EQ. "V850") then
                NCEPin = cdf_file_NCEP->vwnd
                DEFin = cdf_file_DEF->vwnd
	end if
	end if


	NCEPout = NCEPin

	NCEPtimes = cdf_file_NCEP->time
 	ntimes = dimsizes(NCEPtimes)
	ndims = dimsizes(NCEPin)

 
        ; do months since 1948-01-01 so that 1+mod(month,12) is 1 for first, january.
	NCEP_dates = cd_calendar(NCEPtimes,0)

	NCEP_months = NCEP_dates(:,1)
	NCEP_days = NCEP_dates(:,2)
	NCEP_hours = NCEP_dates(:,3)

;	NCEP_months = cd_convert( NCEPtimes, "months since 1948-01-01 00:00" )                 
;        NCEP_days = cd_convert( NCEPtimes, "days since 1948-01-01 00:00" )

	print("files read in")

	print(ntimes)

	do itime=0,ntimes-1

		month = NCEP_months(itime)
		dayidx = tofloat(NCEP_days(itime)-1) + (NCEP_hours(itime)/24.0)

		;print("month: " + tostring(month))
		;print("day: " + tostring(dayidx))
		if (month .eq. 2 .and. dayidx .gt. 28) then
			print("leapyear, switching:")
			print("month " + tostring(month) + ", day " + tostring(dayidx))
                        dayidx = 28.0

			print("to month " + tostring(month) + ", day " + tostring(dayidx))
		end if
	
		monthidx = tointeger(month-1)

		maxday = tofloat(daysinmonth(monthidx))
		midday = maxday/2.0

;Get pre, mid, and post indices
		mid_idx = monthidx
		post_idx = monthidx + 1
		pre_idx = monthidx - 1

		if (post_idx .gt. 11) then
			post_idx = 0
		end if
		if (pre_idx .lt. 0) then
			pre_idx = 11
		end if


;		print("indices: " + tostring(pre_idx) + ", " + tostring(mid_idx) + ", " + tostring(post_idx))

; Get weights
; max value of 1.0 in weightmid is included (via min function: if value > 1.0 then 1.0 is used)
; to allow for leap years: 
; day 29.5 in Feb (dayidx = 28.5) will lead to midday = 28/2 = 14. 1.0 - dayidx/midday is -1.04
; this will be shifted back to 1.0, and 29.5 will behave as for 28.
                weightpre = max((/0,(0.5 * (1.0 - dayidx/midday))/))
                weightmid = 1.0 - 0.5 * min((/1.0,abs(1.0 - dayidx/midday)/))
		weightpost = max((/0, 0.5 * (dayidx/midday - 1.0)/))

		weightmidtest = 1.0 - weightpost - weightpre

;                print(tostring(weightpre) + "; " + tostring(weightmid) + "; " + tostring(weightpost))


		if (weightmidtest .NE. weightmid) then
			print("problem with weights!")
			print(tostring(weightpre) + "; " + tostring(weightmid) + "; " + tostring(weightpost))
			print(tostring(weightmid) + "; " + tostring(weightmidtest))
			exit
		end if



		NCEPout(itime,:,:,:) = NCEPout(itime,:,:,:) + weightpre * DEFin(pre_idx,:,:,:) + weightmid * DEFin(mid_idx,:,:,:) + weightpost * DEFin(post_idx,:,:,:)


	end do

	print("last month is " + tostring(monthidx + 1))

        ;-----------------------------------------------------------------------
        ;Write variables to a new netcdf file
        ;-----------------------------------------------------------------------
        system("/bin/rm -f " + Fileto)

        setfileoption("nc","Format","LargeFile")

        fout_std = addfile(Fileto, "c")

        setfileoption(fout_std,"DefineMode",True)
;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

;set dimensions of output file
        dimNames = (/"time","level","lat","lon"/)
        dimSizes = (/ndims(0),ndims(1),ndims(2),ndims(3)/)
        dimUnlim = (/True,False,False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)


        if (FileVars(ivar) .EQ. "V") then
                filevardef(fout_std,"vwnd",typeof(NCEPout),getvardims(NCEPout))
        else if (FileVars(ivar) .EQ. "U") then
                filevardef(fout_std,"uwnd",typeof(NCEPout),getvardims(NCEPout))
        end if
        end if


        if (FileVars(ivar) .EQ. "V") then
                fout_std->vwnd = (NCEPout)
        else if (FileVars(ivar) .EQ. "U") then
                fout_std->uwnd = (NCEPout)
	end if
	end if

	delete([/NCEPin,NCEPout,DEFin,NCEPtimes,NCEP_months/])

end do
end

