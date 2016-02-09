load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
begin
;**********************************************************
; open file and read required data
;**********************************************************
nyears = 40

secdays = 86400.0
lvl           = (/300,310,320,330/)                     ; specify desired isentropic levels


Experiments = (/"CESMnotopof19","CESM_onlyIM2","CESM_onlyIM3","CESM_onlyIT2","CESM_onlyIT","CESM_onlyITVS","CESM_onlyITSh","CESM_onlyIT4","CESM_onlyIRGH","CESM_onlyITNSM"/)

print(Experiments)

nexps = dimsizes(Experiments)

titles = new((/nexps/),typeof(Experiments))
titles(0) =  "NoTopo"
titles(1) =  "IdealM-N - NoTopo"
titles(2) =  "IdealM-S - NoTopo"
titles(3) =  "IdealT-N - NoTopo"
titles(4) =  "IdealT-S - NoTopo"
titles(5) =  "IdealT-N_Vshort - NoTopo"
titles(6) =  "IdealT-N_shortRGH - NoTopo"
titles(7) =  "IdealT-N_thin - NoTopo"
titles(8) =  "IdealN_RGH - NoTopo"
titles(9) =  "IdealN_SMH - NoTopo"

diro = "/home/disk/rachel/CESM_outfiles/"

filo =  Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"

f = addfile(diro + filo, "r")

T    = f->T                          ; temperature at hybrid levels
lats = f->lat
lons = f->lon

nlats = dimsizes(lats)
nlons = dimsizes(lons)

HGT330_320 = new((/nexps,nlats,nlons/),typeof(T))
HGT330_310 = new((/nexps,nlats,nlons/),typeof(T))
HGT320_310 = new((/nexps,nlats,nlons/),typeof(T))
HGT310_300 = new((/nexps,nlats,nlons/),typeof(T))


PHIS = new((/nexps,nlats,nlons/),typeof(T))

 
do iexp = 0,nexps-1
        filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"

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


HGT330_320(iexp,:,:) = xlvl(0,2,:,:) - xlvl(0,3,:,:)
HGT330_310(iexp,:,:) = xlvl(0,1,:,:) - xlvl(0,3,:,:)
HGT320_310(iexp,:,:) = xlvl(0,1,:,:) - xlvl(0,2,:,:)
HGT310_300(iexp,:,:) = xlvl(0,0,:,:) - xlvl(0,1,:,:)
 

        PHIS(iexp,:,:) = f->PHIS(0,:,:) / 9.8

delete(f)


end do

toplot3_2= new((/nexps,nlats,nlons/),typeof(HGT330_320))
toplot3_1 = new((/nexps,nlats,nlons/),typeof(HGT330_320))
toplot2_1 = new((/nexps,nlats,nlons/),typeof(HGT330_320))
toplot1_0 = new((/nexps,nlats,nlons/),typeof(HGT310_300))



toplot3_2(0,:,:) = HGT330_320(0,:,:)
toplot3_1(0,:,:) = HGT330_310(0,:,:)
toplot2_1(0,:,:) = HGT320_310(0,:,:)
toplot1_0(0,:,:) = HGT310_300(0,:,:)


do ep=1,nexps-1
        toplot3_2(ep,:,:) = HGT330_320(ep,:,:) - HGT330_320(0,:,:)
        toplot3_1(ep,:,:) = HGT330_310(ep,:,:) - HGT330_310(0,:,:)
        toplot2_1(ep,:,:) = HGT320_310(ep,:,:) - HGT320_310(0,:,:)
        toplot1_0(ep,:,:) = HGT310_300(ep,:,:) - HGT310_300(0,:,:)

end do

toplot3 = new((/nexps,nlats,nlons/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep = 1,nexps-1
        toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do



toplot3_2!1    = "lat"                      
toplot3_2!2    = "lon"

toplot3_2&lat = lats
toplot3_2&lon = lons

toplot3_2&lat@units="degree_north"
toplot3_2&lon@units="degree_east"

copy_VarCoords(toplot3_2,toplot3_1)
copy_VarCoords(toplot3_2,toplot2_1)
copy_VarCoords(toplot3_2,toplot1_0)
copy_VarCoords(toplot3_2,toplot3)

npanels = floattoint(ceil(nexps/2.0))


;*********************************************************
; create plot
;*********************************************************

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Isent_330-320_40yrs_ITvsM")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar
  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = 0.0                 ; set the minimum contour level
  res@cnMaxLevelValF  = 150.0                  ; set the maximum contour level
  res@cnLevelSpacingF       = 10.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot3_2(0,:,:),res) ;

  res@cnMinLevelValF  = -22.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 22.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot3_2(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "Difference between 330 and 320 isentropes, mb "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot 2
  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Isent_330-310_40yrs_ITvsM")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)      

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = 0.0                 ; set the minimum contour level
  res@cnMaxLevelValF  = 150.0                  ; set the maximum contour level
  res@cnLevelSpacingF       = 10.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot3_1(0,:,:),res) ;

  res@cnMinLevelValF  = -22.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 22.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot3_1(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "Difference between 330 and 310 isentropes, mb "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 3

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Isent_320-310_40yrs_ITvsM")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = 0.0                 ; set the minimum contour level
  res@cnMaxLevelValF  = 150.0                  ; set the maximum contour level
  res@cnLevelSpacingF       = 10.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2_1(0,:,:),res) ;

  res@cnMinLevelValF  = -22.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 22.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot2_1(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "Difference between 320 and 310 isentropes, mb "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)
copy_VarCoords(toplot3_2,toplot2_1)

;plot 3

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Isent_310-300_40yrs_ITvsM")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = 0.0                 ; set the minimum contour level
  res@cnMaxLevelValF  = 150.0                  ; set the maximum contour level
  res@cnLevelSpacingF       = 10.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot1_0(0,:,:),res) ;

  res@cnMinLevelValF  = -22.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 22.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot1_0(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "Difference between 310 and 300 isentropes, mb "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)



end

