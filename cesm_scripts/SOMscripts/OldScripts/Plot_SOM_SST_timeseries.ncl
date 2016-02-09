load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =30

plotlats = (/15.7, 60.3, 62.5,-30.0/)
plotlons = (/315.0, 345.0, 341.0, 250.0/)

npoints = dimsizes(plotlats)

print(dimsizes(plotlats))

;Directory1 = "/home/disk/eos4/rachel/CESM_outfiles/"
Directory1 = "/home/disk/rachel/CESM_outfiles/"
Experiments1 = (/"CESMSOM4topof19g16"/) 

Directory2 = "/home/disk/eos4/rachel/CESM_outfiles/"
;Directory2 = "/home/disk/rachel/CESM_outfiles/"
Experiments2 = (/"CESMSOM3topof19g16"/) 

Directory3 = "/home/disk/eos4/rachel/inputdata/ssts/"
Experiments3 = (/"sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"/) 


; Now read in all U,V and T/theta values before we subtract the mean values

iyear = 151
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = (Directory1 + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lat = cdf_file->lat
lon = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lat)
nlons = dimsizes(lon)

print(nlats)
print(nlons)

; find plotlons and plotlats

plotlonidx = new((/npoints/),integer)
plotlatidx = new((/npoints/),integer)


do ilat=1,nlats-1
	print(ilat*1)
	if (lat(ilat-1) .LT. plotlats(0) .AND. lat(ilat) .GE. plotlats(0))
		plotlatidx(0) = ilat
	end if
	if (lat(ilat-1) .LT. plotlats(1) .AND. lat(ilat) .GE. plotlats(1))
		plotlatidx(1) = ilat
	end if
	if (lat(ilat-1) .LT. plotlats(2) .AND. lat(ilat) .GE. plotlats(2))
		plotlatidx(2) = ilat
	end if
	if (lat(ilat-1) .LT. plotlats(3) .AND. lat(ilat) .GE. plotlats(3))
		plotlatidx(3) = ilat
	end if
end do

do ilon=1,nlons-1
	if (lon(ilon-1) .LT. plotlons(0) .AND. lon(ilon) .GE. plotlons(0))
		plotlonidx(0) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(1) .AND. lon(ilon) .GE. plotlons(1))
		plotlonidx(1) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(2) .AND. lon(ilon) .GE. plotlons(2))
		plotlonidx(2) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(3) .AND. lon(ilon) .GE. plotlons(3))
		plotlonidx(3) = ilon
	end if
end do

print(plotlatidx)
print(plotlonidx)

ntimes = nyears * 12

print(ntimes)
SSTs = new((/npoints*3,ntimes/),typeof(SST))
months = new(ntimes,integer)

count = 0

print(count)
  
do iyear=150,(150+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = (Directory1 + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SST = cdf_file->SST

	do n=0,npoints-1
		SSTs(n,count) = SST(0,plotlatidx(n),plotlonidx(n))
	end do

	months(count) = count + 1
	count = count + 1
	end do
end do

count = 0
do iyear=150,(150+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = (Directory2 + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SST = cdf_file->SST

	do n=0,npoints-1
		SSTs(n+npoints,count) = SST(0,plotlatidx(n),plotlonidx(n))
	end do

	months(count) = count + 1
	count = count + 1
	end do
end do
print(dimsizes(SST))

count = 0
do iyear=0,(nyears-1)
	print(iyear*1)

	filename = (Directory3 + Experiments3)

	cdf_file = addfile(filename,"r")

	do imonth = 0,11
	
		do n=0,npoints-1
			temp =  cdf_file->SST_cpl(imonth,plotlatidx(n),plotlonidx(n))
			SSTs(n+(2*npoints),count) = temp+273.15
			delete(temp)

		end do
		count = count + 1
		print(count)
	end do

end do


 wks   = gsn_open_wks ("eps","$HOME/Figures/SOMtest/SSTs_ts_"+nyears+"yrs" + Experiments1)                  ; open workstation

 res                   = True                      ; plot mods desired
 res@tiMainString      = Experiments1 + "(--), " + Experiments2 + "(.-), :C:" + Experiments3 + "(-)"        ; add title
res@tiMainFontHeightF  = 0.02
 ;res@pmLegendDisplayMode    = "Always"              ; turn on legend
 ;res@lgPerimOn              = False      ; No legend perimeter.
 ;res@pmLegendOrthogonalPosF = -0.005      ; Move closer to plot

; res@pmLegendHeightF        = 0.12                  ; height of legend.
; res@lgLabelFontHeightF     = .015                   ; change font height
; labels for the legend
; res@xyExplicitLegendLabels = (/"Eq Atl 44m MLD","Eq Pac 45m MLD","N Atl 260m MLD","N Atl 444m MLD","South Pac"/)

 res@xyLineColors      = (/"blue","red","green","purple","blue","red","green","purple","blue","red","green","purple"/)          ; change line color
 res@xyDashPatterns      = (/1,1,1,1,3,3,3,3,0,0,0,0/)          ; change line color

 plot  = gsn_csm_xy (wks,months,SSTs,res) ; create plot


