load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =35
yearstart = 150

;Directory1 = "/home/disk/eos4/rachel/CESM_outfiles/"
Directory1 = "/home/disk/rachel/CESM_outfiles/"
Experiments1 = (/"CESMSOM4topof19g16"/) 

;Directory2 = "/home/disk/eos4/rachel/CESM_outfiles/"
Directory2 = "/home/disk/rachel/CESM_outfiles/"
Experiments2 = (/"CESMSOM3topof19g16"/) 

;Directory3 = "/home/disk/eos4/rachel/inputdata/ssts/"
;Experiments3 = (/"sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"/) 
Directory3 = "/home/disk/eos4/rachel/CESM_outfiles/"
Experiments3 = (/"CESMSOMtopof19g16"/) 


; Read in sea ice frac

iyear = yearstart
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = (Directory1 + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lat = cdf_file->lat
lon = cdf_file->lon
ICEFRAC = cdf_file->ICEFRAC

nlats = dimsizes(lat)
nlons = dimsizes(lon)

totalsize = nlats * nlons

print(nlats)
print(nlons)

; find plotlons and plotlats

ntimes = nyears * 12

print(ntimes)
CICE = new((/3,ntimes/),typeof(ICEFRAC))
months = new(ntimes,integer)

count = 0

print(count)
  
do iyear=yearstart,(yearstart+nyears-1)
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

	ICEFRAC = cdf_file->ICEFRAC

	CICE(0,count) = (sum(ICEFRAC))/totalsize

	months(count) = count + 1
	count = count + 1
	end do
end do
delete(ICEFRAC)

count = 0
do iyear=yearstart,(yearstart+nyears-1)
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

	ICEFRAC = cdf_file->ICEFRAC

	CICE(1,count) = (sum(ICEFRAC))/totalsize

	months(count) = count + 1
	count = count + 1
	end do
end do
print(dimsizes(CICE))
delete(ICEFRAC)

count = 0
do iyear=yearstart,(yearstart+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = (Directory3 + Experiments3 + "/atm/hist/" + Experiments3 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	ICEFRAC = cdf_file->ICEFRAC

	CICE(2,count) = (sum(ICEFRAC))/totalsize

	months(count) = count + 1
	count = count + 1
	end do
end do
print(dimsizes(CICE))
delete(ICEFRAC)


;count = 0
;do iyear=0,(nyears-1)
;	print(iyear*1)

;	filename = (Directory3 + Experiments3)

;	cdf_file = addfile(filename,"r")

;	do imonth = 0,11
;	
;		ICEFRAC =  cdf_file->ice_cov(imonth,:,:)
;		CICE(2,count) = (sum(ICEFRAC))/totalsize
;		delete(ICEFRAC)
;
;	count = count + 1
;	print(count)
;	end do
;
;end do


 wks   = gsn_open_wks ("eps","ICEFRAC_ts_"+nyears+"yrs" + Experiments1)                  ; open workstation

 res                   = True                      ; plot mods desired
 res@tiMainString      = "Earth fraction of Sea Ice, monthly"
 res@pmLegendDisplayMode    = "Always"              ; turn on legend
 res@lgPerimOn              = False      ; No legend perimeter.
 res@pmLegendOrthogonalPosF = -0.005      ; Move closer to plot

 res@trYMaxF = 0.16

 res@pmLegendHeightF        = 0.12                  ; height of legend.
 res@lgLabelFontHeightF     = .015                   ; change font height
; labels for the legend
 res@xyExplicitLegendLabels = (/Experiments1, Experiments2, Experiments3/)

 res@xyLineColors      = (/"blue","red","green"/)          ; change line color
; res@xyDashPatterns      = (/1,1,1,1,3,3,3,3,0,0,0,0/)          ; change line color

 plot  = gsn_csm_xy (wks,months,CICE,res) ; create plot


