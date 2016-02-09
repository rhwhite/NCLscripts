load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =5
startyear = 150
Experiments = (/"CESMSOMtopof19g16"/)

iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

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

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM1 = dim_avg(SSTs)
SST_avg_SOM1 = dim_avg_n(SSTs_clim_SOM1,0)

delete([/SSTs/])


nyears =5

Experiments = (/"CESMSOM2topof19g16"/)

iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

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

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM2 = dim_avg(SSTs)
SST_avg_SOM2 = dim_avg_n(SSTs_clim_SOM2,0)

delete([/SSTs/])


nyears =5

Experiments = (/"CESMSOM3topof19g16"/)

iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

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

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM3 = dim_avg(SSTs)
SST_avg_SOM3 = dim_avg_n(SSTs_clim_SOM3,0)

delete([/SSTs/])

filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"
cdf_file = addfile(filename,"w")
print(filename)

SSTs_HAD = cdf_file->SST_cpl + 273.15


;create mean

SST_avg_HAD = dim_avg_n(SSTs_HAD,0)

print(dimsizes(SST_avg_HAD))
print(dimsizes(SST_avg_SOM1))


SST_diffs1 = SST_avg_HAD - SST_avg_SOM1
SST_diffs2 = SST_avg_HAD - SST_avg_SOM2
SST_diffs3 = SST_avg_HAD - SST_avg_SOM3

ndims2 = dimsizes(SST_avg_SOM1)
print(ndims2)

SST_avg_HAD!0="lat"
SST_avg_HAD!1="lon"

SST_avg_HAD&lat = lats
SST_avg_HAD&lon = lons

SST_avg_HAD&lat@units="degree_north"
SST_avg_HAD&lon@units="degree_east"


copy_VarCoords(SST_avg_HAD,SST_avg_SOM1)
copy_VarCoords(SST_avg_HAD,SST_diffs1)
copy_VarCoords(SST_avg_HAD,SST_diffs2)
copy_VarCoords(SST_avg_HAD,SST_diffs3)



  wks   = gsn_open_wks ("eps","SSTs_diffs_SOM_Exps1-3_1yr")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(4,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 273.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0			; set the maximum contour level
  res@cnLevelSpacingF       = 3.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,SST_avg_HAD,res) ;

  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.2      ; contour spacing
 
 plot(1) = gsn_csm_contour_map_ce(wks,SST_diffs1,res) ;
 plot(2) = gsn_csm_contour_map_ce(wks,SST_diffs2,res) ;
 plot(3) = gsn_csm_contour_map_ce(wks,SST_diffs3,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "SSTs"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
;  resP@gsnPanelFigureStrings= (/"HAD fixed SST","SOM1 differences","SOM2 differences","SOM3 differences"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
