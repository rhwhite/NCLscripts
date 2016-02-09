load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMtopof19","CESMnoRTf19","CESMnoRf19","CESMnoTf19","CESMnoT2f19"/);,"CESMnotopof19"
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

ndims = dimsizes(cdf_file->TAUX)

TAUX = new((/nexps,ndims(1),ndims(2)/),typeof(cdf_file->TAUX))
TAUY = new((/nexps,ndims(1),ndims(2)/),typeof(cdf_file->TAUX))

TAUX(0,:,:) = cdf_file->TAUX(0,:,:)
TAUY(0,:,:) = cdf_file->TAUY(0,:,:)

lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	TAUX(iexp,:,:) = cdf_file->TAUX(0,:,:)
	TAUY(iexp,:,:) = cdf_file->TAUY(0,:,:)
	
	delete(cdf_file)

end do

toplotTX = new((/6,ndims(1),ndims(2)/),typeof(TAUX))
toplotTX(0,:,:) = TAUX(0,:,:)
toplotTX(1,:,:) =  TAUX(0,:,:) - TAUX(1,:,:)
toplotTX(2,:,:) =  TAUX(0,:,:) - TAUX(2,:,:)
toplotTX(3,:,:) =  TAUX(0,:,:) - TAUX(3,:,:)
toplotTX(4,:,:) =  TAUX(0,:,:) - TAUX(4,:,:)
toplotTX(5,:,:) =  toplotTX(1,:,:) - toplotTX(2,:,:) - toplotTX(3,:,:)

toplotTY = new((/6,ndims(1),ndims(2)/),typeof(TAUY))
toplotTY(0,:,:) = TAUY(0,:,:)
toplotTY(1,:,:) =  TAUY(0,:,:) - TAUY(1,:,:)
toplotTY(2,:,:) =  TAUY(0,:,:) - TAUY(2,:,:)
toplotTY(3,:,:) =  TAUY(0,:,:) - TAUY(3,:,:)
toplotTY(4,:,:) =  TAUY(0,:,:) - TAUY(4,:,:)
toplotTY(5,:,:) =  toplotTY(1,:,:) - toplotTY(2,:,:) - toplotTY(3,:,:)

titles = new((/6/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(topo - noRT)"
titles(2) =  "(topo - noR)" 
titles(3) =  "(topo - noT)" 
titles(4) =  "(topo - noT2)" 
titles(5) =  titles(1) + "-" + titles(2) + "-" + titles(3)

toplotTX!1 = "lat"
toplotTX!2 = "lon"

toplotTX&lat = lats
toplotTX&lon = lons

toplotTX&lat@units="degree_north"
toplotTX&lon@units="degree_east"

copy_VarCoords(toplotTX,toplotTY)

; plot
; plot one = TAUX

  wks   = gsn_open_wks ("eps","Figures/TAUX_40yrs_f19")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(6,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.25			; set the minimum contour level
  res@cnMaxLevelValF  = 0.25			; set the maximum contour level
  res@cnLevelSpacingF       = 0.05      ; contour spacing
  res@gsnPaperOrientation = "landscape"          

  plot(0) = gsn_csm_contour_map_ce(wks,toplotTX(0,:,:),res) ;
  res@gsnCenterString         = titles(1)

  res@cnMinLevelValF  = -0.125			; set the minimum contour level
  res@cnMaxLevelValF  = 0.125			; set the maximum contour level
  res@cnLevelSpacingF       = 0.025      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplotTX(1,:,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplotTX(2,:,:),res) ;

  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplotTX(3,:,:),res) ;

  res@gsnCenterString         = titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplotTX(4,:,:),res) ;

  res@cnMinLevelValF  = -0.075			; set the minimum contour level
  res@cnMaxLevelValF  = 0.075			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0125      ; contour spacing

  res@gsnCenterString         = titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplotTX(5,:,:),res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP) 

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot two = TAUY

  wks   = gsn_open_wks ("eps","Figures/TAUY_40yrs_f19")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(6,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.2			; set the minimum contour level
  res@cnMaxLevelValF  = 0.2			; set the maximum contour level
  res@cnLevelSpacingF       = 0.04      ; contour spacing
  res@gsnPaperOrientation = "landscape"          

  plot(0) = gsn_csm_contour_map_ce(wks,toplotTY(0,:,:),res) ;
  res@gsnCenterString         = titles(1)

  res@cnMinLevelValF  = -0.1			; set the minimum contour level
  res@cnMaxLevelValF  = 0.1			; set the maximum contour level
  res@cnLevelSpacingF       = 0.025      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplotTY(1,:,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplotTY(2,:,:),res) ;

  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplotTY(3,:,:),res) ;

  res@gsnCenterString         = titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplotTY(4,:,:),res) ;

  res@cnMinLevelValF  = -0.05			; set the minimum contour level
  res@cnMaxLevelValF  = 0.05			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0125      ; contour spacing

  res@gsnCenterString         = titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplotTY(5,:,:),res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP) 

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


end