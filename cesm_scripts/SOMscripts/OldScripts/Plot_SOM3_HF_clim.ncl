load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =5
startyear = 151
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
LH = cdf_file->LHFLX

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(LH)

ntimes = nyears

print(ntimes)
HFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(LH))

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

	HFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:) +  cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1
end do

;create mean

HFs_clim_SOM1 = dim_avg(HFs)
HF_avg_SOM1 = dim_avg_n(HFs_clim_SOM1,0)

delete([/HFs/])


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
LH = cdf_file->LHFLX

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(LH)

ntimes = nyears

print(ntimes)
HFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(LH))

print(dimsizes(HFs))
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

	HFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:) +  cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1
end do

;create mean

HFs_clim_SOM2 = dim_avg(HFs)
HF_avg_SOM2 = dim_avg_n(HFs_clim_SOM2,0)

delete([/HFs/])


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
LH = cdf_file->LHFLX

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(LH)

ntimes = nyears

print(ntimes)
HFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(LH))

print(dimsizes(HFs))
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

	HFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:) +  cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1
end do

;create mean

HFs_clim_SOM3 = dim_avg(HFs)
HF_avg_SOM3 = dim_avg_n(HFs_clim_SOM3,0)

delete([/HFs/])




nyears =5

Experiments = (/"CESMtopof19"/)

startyear = 2
iyear = startyear
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.000" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
LH = cdf_file->LHFLX

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(LH)

ntimes = nyears

print(ntimes)
HFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(LH))

print(dimsizes(HFs))
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

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.000" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	HFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:) +  cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1
end do

;create mean

HFs_clim_HAD = dim_avg(HFs)
HF_avg_HAD = dim_avg_n(HFs_clim_HAD,0)

delete([/HFs/])


HF_diffs1 = HF_avg_HAD - HF_avg_SOM1
HF_diffs2 = HF_avg_HAD - HF_avg_SOM2
HF_diffs3 = HF_avg_HAD - HF_avg_SOM3

ndims2 = dimsizes(HF_avg_SOM1)
print(ndims2)

HF_avg_HAD!0="lat"
HF_avg_HAD!1="lon"

HF_avg_HAD&lat = lats
HF_avg_HAD&lon = lons

HF_avg_HAD&lat@units="degree_north"
HF_avg_HAD&lon@units="degree_east"


copy_VarCoords(HF_avg_HAD,HF_avg_SOM1)
copy_VarCoords(HF_avg_HAD,HF_diffs1)
copy_VarCoords(HF_avg_HAD,HF_diffs2)
copy_VarCoords(HF_avg_HAD,HF_diffs3)



  wks   = gsn_open_wks ("eps","HFs_diffs_SOM_Exps1-3_5yr")                  ; open workstation

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
  res@cnMinLevelValF  = -20.0			; set the minimum contour level
  res@cnMaxLevelValF  = 200.0			; set the maximum contour level
  res@cnLevelSpacingF       = 20.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,HF_avg_HAD,res) ;

  res@cnMinLevelValF  = -30.0			; set the minimum contour level
  res@cnMaxLevelValF  = 30.0			; set the maximum contour level
  res@cnLevelSpacingF       = 5.0      ; contour spacing
 
 plot(1) = gsn_csm_contour_map_ce(wks,HF_diffs1,res) ;
 plot(2) = gsn_csm_contour_map_ce(wks,HF_diffs2,res) ;
 plot(3) = gsn_csm_contour_map_ce(wks,HF_diffs3,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "HFs"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= (/"HAD fixed HF","SOM1 differences","SOM2 differences","SOM3 differences"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
