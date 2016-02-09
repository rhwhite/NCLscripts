load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
begin
;**********************************************************
; open file and read required data
;**********************************************************
nyears = 40

secdays = 86400.0

;Experiments = (/"CESMnotopof19","CESM_onlyIM2","CESM_onlyIM3","CESM_onlyIT2","CESM_onlyIT","CESM_onlyITVS","CESM_onlyITVVS","CESM_onlyIT4"/)
Experiments = (/"CESMnotopof19"/)
diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"

filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"

  f = addfile(diro + filo, "r")


  hya  = f->hyam                       ; hybrid coef
  hyb  = f->hybm 
  ps   = f->PS                         ; surface pressure [Pa]
  p0   = 100000.                       ; since ps is in Pa or [ f*>P0]

  T    = f->T                          ; temperature at hybrid levels
;***********************************************************
; Calculate pressure at each level at all grid points
;***********************************************************
  ph           = T                                         ; transfer meta data
  ph           = pres_hybrid_ccm (ps, p0, hya, hyb)        ; ph(ntim,klvl,nlat,mlon)
  ph@long_name = "pressure at each hybrid level"
  ph@units     = ps@units
;***********************************************************
; Calculate potential temperature at each level aat all grid points
;***********************************************************
  theta           = T                                      ; create/transfer meta data
  theta           = T*(101300/ph)^0.286                    ; calculate potential temperature
;***********************************************************
; User specified isentropic levels
;***********************************************************
  lvl           = ispan(400,280,10)*1.                     ; specify desired isentropic levels
;**********************************************************
; Read in a variable to be interpolated
;**********************************************************
  x    = ph                                              ; pressure
;**********************************************************  
; As of V5.2.0, use this, but then xlvl will be dimensioned 
; time x level x lat x lon, so you need to change code
; below accordingly.
  xlvl = int2p_n (theta, x, lvl, 0, 1)

; Change units from Pa to mb
 xlvl = xlvl / 100.0

;*********************************************************
; Assign meta data to the derived variable data object
;*********************************************************
; For V5.2.0 or higher
 xlvl!0    = "time"                     ; name dimensions
 xlvl!1    = "lvl"                      
 xlvl!2    = "lat"
 xlvl!3    = "lon"

;  xlvl!0    = "time"                     ; name dimensions
;  xlvl!1    = "lat"
;  xlvl!2    = "lon"
;  xlvl!3    = "lvl"
  xlvl&time =  x&time                    ; assign coordinates
  xlvl&lvl  =  lvl                       ; isentropic levels
  xlvl&lat  =  x&lat
  xlvl&lon  =  x&lon
  xlvl@long_name = x@long_name           ; attributes
  xlvl@units     = "mb"
;*********************************************************
; create plot
;*********************************************************
  wks  = gsn_open_wks("eps","isent_test")                 
  gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap

  plot = new(3,graphic)                          ; create a plot array
  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame

  res@cnFillOn        = True                     ; turn on color
  res@cnLinesOn       = False                    ; turn off contour lines
  res@gsnSpreadColors = True                     ; use full range of colormap
  res@tiMainString    = "Isentropic Level of 310"; title


  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0


;  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = 300                   ; set the minimum contour level
;  res@cnMaxLevelValF  = 1000                    ; set the maximum contour level
;  res@cnLevelSpacingF       = 50      ; contour spacing
 


 plot(0) = gsn_csm_contour_map_ce(wks,xlvl(0,{310},:,:),res)  
    
  res@tiMainString    = "Isentropic Level of 320"; title
 plot(1) = gsn_csm_contour_map_ce(wks,xlvl(0,{320},:,:),res)

  res@tiMainString    = "Difference between 320 and 310 Isentropic Levels"; title
 plot(2) = gsn_csm_contour_map_ce(wks,xlvl(0,{320},:,:)-xlvl(0,{310},:,:),res)

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,1/),resP)

  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


end

