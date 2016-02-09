load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

precipconst = 1000.0 * 86400.0
nyears =20

Experiments = (/"test1"/)
Experiments2 = (/"test1"/)

Experiments3 = (/"CESMtopof19"/) 

startyear = 160
syear = 2
yearstring = tostring(startyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
TEMP = cdf_file->PRECT

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(TEMP)

ntimes = nyears

print(ntimes)
Precip = new((/12,ndims(1),ndims(2),ntimes/),typeof(TEMP)) 

print(dimsizes(Precip))
count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
;	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	Precip(imonth-1,:,:,count) = cdf_file->PRECT(0,:,:)

	end do
	count = count + 1
end do

;create mean

Precip_clim_SOM1 = dim_avg(Precip) * precipconst

delete([/Precip/])


ndims = dimsizes(Precip_clim_SOM1)
print(ndims)


Precip = new((/12,ndims(1),ndims(2),ntimes/),typeof(TEMP)) 
count = 0

do iyear=startyear,(startyear+nyears-1)
;	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	Precip(imonth-1,:,:,count) = cdf_file->PRECT(0,:,:)

	end do
	count = count + 1
end do

;create mean

Precip_clim_SOM2 = dim_avg(Precip) * precipconst

delete([/Precip/])



Precip = new((/12,ndims(1),ndims(2),ntimes/),typeof(TEMP))
count = 0

;Get fluxes from fixed SST run

do iyear=syear,(syear+nyears-1)
;	print(iyear*1)
		if iyear .lt. 10
			yearstring = ("0" + tostring(iyear))
		else
			yearstring = tostring(iyear)
		end if
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if


	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments3 + "/atm/hist/" + Experiments3 + ".cam2.h0.00" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	Precip(imonth-1,:,:,count) = cdf_file->PRECT(0,:,:)

	end do

	count = count + 1

end do

;create mean

Precip_clim_HAD = dim_avg(Precip) * precipconst

Precip_clim_diff1 = Precip_clim_SOM1 - Precip_clim_HAD
Precip_clim_diff2 = Precip_clim_SOM2 - Precip_clim_HAD

Precip_seas_HAD = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas_SOM1 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas_SOM2 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas_diff1 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas_diff2 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))

Precip_seas2_HAD = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas2_SOM1 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas2_SOM2 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas2_diff1 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))
Precip_seas2_diff2 = new((/4,nlats,nlons/),typeof(Precip_clim_HAD))

plotmonth = 11

do plotseas = 0,3

	if plotmonth .GT. 11 then
		plotmonth = plotmonth-11
	end if
	plotmonth1 = plotmonth + 1
	if plotmonth1 .GT. 11 then
		plotmonth1 = plotmonth1-11
	end if
	plotmonth2 = plotmonth + 2
	if plotmonth2 .GT. 11 then
		plotmonth2 = plotmonth2-11
	end if

  Precip_seas_HAD(plotseas,:,:) = (Precip_clim_HAD(plotmonth,:,:)+Precip_clim_HAD(plotmonth1,:,:)+Precip_clim_HAD(plotmonth2,:,:))/3.0;
  Precip_seas_SOM1(plotseas,:,:) = (Precip_clim_SOM1(plotmonth,:,:)+Precip_clim_SOM1(plotmonth1,:,:)+Precip_clim_SOM1(plotmonth2,:,:))/3.0;
  Precip_seas_SOM2(plotseas,:,:) = (Precip_clim_SOM2(plotmonth,:,:)+Precip_clim_SOM2(plotmonth1,:,:)+Precip_clim_SOM2(plotmonth2,:,:))/3.0;

  Precip_seas_diff1(plotseas,:,:) = (Precip_clim_diff1(plotmonth,:,:)+Precip_clim_diff1(plotmonth1,:,:)+Precip_clim_diff1(plotmonth2,:,:))/3.0;
  Precip_seas_diff2(plotseas,:,:) = (Precip_clim_diff2(plotmonth,:,:)+Precip_clim_diff2(plotmonth1,:,:)+Precip_clim_diff2(plotmonth2,:,:))/3.0;

	plotmonth = plotmonth + 3
end do


plotmonth = 1

do plotseas = 0,3

	if plotmonth .GT. 11 then
		plotmonth = plotmonth-11
	end if
	plotmonth1 = plotmonth + 1
	if plotmonth1 .GT. 11 then
		plotmonth1 = plotmonth1-11
	end if
	plotmonth2 = plotmonth + 2
	if plotmonth2 .GT. 11 then
		plotmonth2 = plotmonth2-11
	end if

  Precip_seas2_HAD(plotseas,:,:) = (Precip_clim_HAD(plotmonth,:,:)+Precip_clim_HAD(plotmonth1,:,:)+Precip_clim_HAD(plotmonth2,:,:))/3.0;
  Precip_seas2_SOM1(plotseas,:,:) = (Precip_clim_SOM1(plotmonth,:,:)+Precip_clim_SOM1(plotmonth1,:,:)+Precip_clim_SOM1(plotmonth2,:,:))/3.0;
  Precip_seas2_SOM2(plotseas,:,:) = (Precip_clim_SOM2(plotmonth,:,:)+Precip_clim_SOM2(plotmonth1,:,:)+Precip_clim_SOM2(plotmonth2,:,:))/3.0;

  Precip_seas2_diff1(plotseas,:,:) = (Precip_clim_diff1(plotmonth,:,:)+Precip_clim_diff1(plotmonth1,:,:)+Precip_clim_diff1(plotmonth2,:,:))/3.0;
  Precip_seas2_diff2(plotseas,:,:) = (Precip_clim_diff2(plotmonth,:,:)+Precip_clim_diff2(plotmonth1,:,:)+Precip_clim_diff2(plotmonth2,:,:))/3.0;
	plotmonth = plotmonth + 3
end do



Precip_seas_HAD!0="time"
Precip_seas_HAD!1="lat"
Precip_seas_HAD!2="lon"

Precip_seas_HAD&lat = lats
Precip_seas_HAD&lon = lons

Precip_seas_HAD&lat@units="degree_north"
Precip_seas_HAD&lon@units="degree_east"

copy_VarCoords(Precip_seas_HAD,Precip_seas_SOM1)
copy_VarCoords(Precip_seas_HAD,Precip_seas_SOM2)
copy_VarCoords(Precip_seas_HAD,Precip_seas_diff1)
copy_VarCoords(Precip_seas_HAD,Precip_seas_diff2)
copy_VarCoords(Precip_seas_HAD,Precip_seas2_HAD)
copy_VarCoords(Precip_seas_HAD,Precip_seas2_SOM1)
copy_VarCoords(Precip_seas_HAD,Precip_seas2_SOM2)
copy_VarCoords(Precip_seas_HAD,Precip_seas2_diff1)
copy_VarCoords(Precip_seas_HAD,Precip_seas2_diff2)


seasons = (/"DJF","MAM","JJA","SON"/)
seasons2 = (/"FMA","MJJ","ASO","NDJ"/)

do seas = 0,3

  wks   = gsn_open_wks ("eps","Precip_" + nyears + "_" + seasons(seas) + "_" + Experiments + "_" + Experiments2)                  ; open workstation


  colors = (/"white","black","blueviolet","blue","deepskyblue","green","greenyellow","grey90","grey90","yellow1","goldenrod2","tomato","firebrick1","deeppink"/)
  rgb = span_named_colors(colors,False)
  gsn_define_colormap(wks,colors)

;  gsn_define_colormap(wks,rgb)
;  gsn_define_colormap(wks,"NCV_jaisnd")         ; choose colormap
  plot = new(4,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnAddCyclic         = True                 ; add cyclic point

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

  res@gsnCenterString         = seasons(seas) + " " + Experiments3
  plot(0) = gsn_csm_contour_map_ce(wks,Precip_seas_HAD(seas,:,:),res);
  res@gsnCenterString         = Experiments
  plot(1) = gsn_csm_contour_map_ce(wks,Precip_seas_SOM1(seas,:,:),res);
  res@gsnCenterString         = Experiments2
  plot(2) = gsn_csm_contour_map_ce(wks,Precip_seas_SOM2(seas,:,:),res);

  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4      ; contour spacing

  res@gsnCenterString         = Experiments2 + "-" + Experiments3
  plot(3) = gsn_csm_contour_map_ce(wks,Precip_seas_diff2(seas,:,:),res);

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/2,2/),resP) 

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end do



do seas = 0,3

  wks   = gsn_open_wks ("eps","Precip_" + nyears + "_" + seasons2(seas) + "_" + Experiments + "_" + Experiments2)                  ; open workstation
  gsn_define_colormap(wks,colors)

;  gsn_define_colormap(wks,"NCV_jaisnd")         ; choose colormap
  plot = new(4,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnAddCyclic         = True                 ; add cyclic point

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

  res@gsnCenterString         = seasons2(seas) + " " + Experiments3
  plot(0) = gsn_csm_contour_map_ce(wks,Precip_seas2_HAD(seas,:,:),res);
  res@gsnCenterString         = Experiments
  plot(1) = gsn_csm_contour_map_ce(wks,Precip_seas2_SOM1(seas,:,:),res);
  res@gsnCenterString         = Experiments2
  plot(2) = gsn_csm_contour_map_ce(wks,Precip_seas2_SOM2(seas,:,:),res);

  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4      ; contour spacing

  res@gsnCenterString         = Experiments2 + "-" + Experiments3
  plot(3) = gsn_csm_contour_map_ce(wks,Precip_seas2_diff2(seas,:,:),res);

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/2,2/),resP) 

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end do


