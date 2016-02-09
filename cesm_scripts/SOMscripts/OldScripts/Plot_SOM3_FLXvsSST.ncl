load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears = 20 
startyear = 160
Experiments1 = (/"CESMSOMtopof19g16"/)
Experiments2 = (/"CESMSOM3topof19g16"/)

iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(SST)

ntimes = nyears

print(ntimes)
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM1 = dim_avg(SSTs)
SST_avg_SOM1 = dim_avg_n(SSTs_clim_SOM1,0)

delete([/SSTs/])



iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(SST)

ntimes = nyears

print(ntimes)
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM2 = dim_avg(SSTs)
SST_avg_SOM2 = dim_avg_n(SSTs_clim_SOM2,0)

delete([/SSTs/])

;get difference

SSTs_diffs = SST_avg_SOM2 - SST_avg_SOM1

; Read is flux differences
filein = "$HOME/inputdata/som/pop_V15-CTL.nc"
cdf_file = addfile(filein,"r")

qdp_diffs = cdf_file->qdp(0,:,:)

nlons = dimsizes(qdp_diffs,0)
nlats = dimsizes(qdp_diffs,1)

print(nlons)
print(nlats)
count = 0

nlons2 = dimsizes(SSTs_diffs)
print(nlons2)

scatter1 = new(nlons*nlats,typeof(qdp_diffs))
scatter2 = new(nlons*nlats,typeof(SSTs_diffs))

do ilon = 0,nlons-1
	do ilat = 0,nlats-1
		if (.not.ismissing(qdp_diffs(ilon,ilat)))
			scatter1(count) = qdp_diffs(ilon,ilat)
			scatter2(count) = SSTs_diffs(ilat,ilon)
			count = count + 1
		end if
	end do
end do
 
print(count)

 wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/SOMtest/test1_SSTs_vs_FLXES_" + Experiments1 + "_" + Experiments2 + "_" + nyears)                  ; open workstation
 res                   = True                      ; plot mods desired
 res@tiMainString      = "Qfluxes vs SST diffs"
res@tiMainFontHeightF  = 0.02

 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker
 res@xyMarkerColor     = "blue"                    ; Marker color
 res@xyMarkerSizeF     = 0.001                     ; Marker size (default 0.01)

 plot  = gsn_csm_y(wks,scatter1(0:count),res) ; create plot


 wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/SOMtest/SSTs_vs_FLXES_" + Experiments1 + "_" + Experiments2 + "_" + nyears)                  ; open workstation
 res                   = True                      ; plot mods desired
 res@tiMainString      = "Qfluxes vs SST diffs"
res@tiMainFontHeightF  = 0.02

 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker  
 res@xyMarkerColor     = "blue"                    ; Marker color
 res@xyMarkerSizeF     = 0.001                     ; Marker size (default 0.01)

 plot  = gsn_csm_xy(wks,scatter2(0:count),scatter1(0:count),res) ; create plot


