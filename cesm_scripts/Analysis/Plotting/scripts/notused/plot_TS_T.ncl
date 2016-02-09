load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

Experiments = (/"CESMtopof19","CESMnoTf19","CESMnoT2f19","CESMnoT3f19"/)
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

TS_mean = cdf_file->TS(0,:,:)
PS_mean = cdf_file->PS(0,:,:)/100.0
PHIS_mean = cdf_file->PHIS(0,:,:) / 9.8


lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)
ndims = dimsizes(TS_mean)
TH = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))
TS = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))
PHIS = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))

TH(0,:,:) = TS_mean * (1013/PS_mean)^(kappa)
TS(0,:,:) = TS_mean
PHIS(0,:,:) = PHIS_mean

print(TS(0,50,50))
print(TH(0,50,50))
print(PS_mean(50,50))

delete(TS_mean)
delete(PS_mean)

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	TS_mean = cdf_file->TS(0,:,:)
	PS_mean = cdf_file->PS(0,:,:)/100.0
	PHIS_mean = cdf_file->PHIS(0,:,:) / 9.8
	
	TH(iexp,:,:) = TS_mean * (1013/PS_mean)^(kappa)
	TS(iexp,:,:) = TS_mean
	PHIS(iexp,:,:) = PHIS_mean

	delete(TS_mean)
	delete(PS_mean)
	
	delete(cdf_file)

end do

toplot = new((/8,ndims(0),ndims(1)/),typeof(TS))
toplot(0,:,:) = TS(0,:,:)
toplot(1,:,:) =  TS(1,:,:) - TS(2,:,:)
toplot(2,:,:) =  TS(1,:,:)
toplot(3,:,:) =  TS(0,:,:) - TS(1,:,:)
toplot(4,:,:) =  TS(2,:,:)
toplot(5,:,:) =  TS(0,:,:) - TS(2,:,:)
toplot(6,:,:) =  TS(3,:,:)
toplot(7,:,:) =  TS(0,:,:) - TS(3,:,:)

toplot2 = new((/8,ndims(0),ndims(1)/),typeof(TH))
toplot2(0,:,:) = TH(0,:,:)
toplot2(1,:,:) =  TH(1,:,:) - TH(2,:,:)
toplot2(2,:,:) =  TH(1,:,:)
toplot2(3,:,:) =  TH(0,:,:) - TH(1,:,:)
toplot2(4,:,:) =  TH(2,:,:)
toplot2(5,:,:) =  TH(0,:,:) - TH(2,:,:)
toplot2(6,:,:) =  TH(3,:,:)
toplot2(7,:,:) =  TH(0,:,:) - TH(3,:,:)

toplot3 = new((/8,ndims(0),ndims(1)/),typeof(PHIS))
toplot3(0,:,:) =  PHIS(0,:,:)
toplot3(1,:,:) =  PHIS(1,:,:) - PHIS(2,:,:)
toplot3(2,:,:) =  PHIS(0,:,:) - PHIS(1,:,:)
toplot3(3,:,:) =  PHIS(0,:,:) - PHIS(1,:,:)
toplot3(4,:,:) =  PHIS(0,:,:) - PHIS(2,:,:)
toplot3(5,:,:) =  PHIS(0,:,:) - PHIS(2,:,:)
toplot3(6,:,:) =  PHIS(0,:,:) - PHIS(3,:,:)
toplot3(7,:,:) =  PHIS(0,:,:) - PHIS(3,:,:)

titles = new((/8/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(noT1 - noT2)"
titles(2) =  "(noT1)" 
titles(3) =  "(topo - noT1)"
titles(4) =  "(noT2)" 
titles(5) =  "(topo - noT2)" 
titles(6) =  "(noT3)" 
titles(7) =  "(topo - noT3)" 

toplot!1 = "lat"
toplot!2 = "lon"

toplot&lat = lats
toplot&lon = lons

toplot&lat@units="degree_north"
toplot&lon@units="degree_east"

copy_VarCoords(toplot,toplot2)
copy_VarCoords(toplot,toplot3)

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/TS_Surf_40yrs_T2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(8,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = "TS, K " + titles(0)  
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar
  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot(1,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot(2,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot(3,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot(4,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(5)  
  plot(5) = gsn_csm_contour_map_ce(wks,toplot(5,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(6)  
  plot(6) = gsn_csm_contour_map_ce(wks,toplot(6,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(7)  
  plot(7) = gsn_csm_contour_map_ce(wks,toplot(7,:,:),res) 

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/1000.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1 	; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False

do pp = 0,7
	plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
	overlay(plot(pp),plot_ov)
end do

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/4,2/),resP) 

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/TH_Surf_40yrs_T2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(8,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = "TH Surface, K " + titles(0)  
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2(0,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot2(1,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot2(2,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot2(3,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot2(4,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(5)  
  plot(5) = gsn_csm_contour_map_ce(wks,toplot2(5,:,:),res) ;

  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0 			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0     ; contour spacing
  res@gsnCenterString         = titles(6)  
  plot(6) = gsn_csm_contour_map_ce(wks,toplot2(6,:,:),res) ;

  res@cnMinLevelValF  = -5.0			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(7)  
  plot(7) = gsn_csm_contour_map_ce(wks,toplot2(7,:,:),res) 

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/1000.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1 	; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False

do pp = 0,7
	plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
	overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/4,2/),resP) 

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)
end