load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)


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
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

SWtemp = cdf_file->FSDSC(0,:,:)
print(dimsizes(SWtemp))

ndims = dimsizes(SWtemp)
lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)


SW = new((/nexps,ndims(0),ndims(1)/),typeof(SWtemp))
LW = new((/nexps,ndims(0),ndims(1)/),typeof(SWtemp))
PHIS = new((/nexps,ndims(0),ndims(1)/),typeof(cdf_file->PHIS))

PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

SW(0,:,:) = cdf_file->FSDSC
LW(0,:,:) = cdf_file->FLDSC

delete(cdf_file)


do iexp = 1,nexps-1
	filo =  Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	SW(iexp,:,:) = cdf_file->FSDSC(0,:,:)
	LW(iexp,:,:) = cdf_file->FLDSC(0,:,:)

	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8


	delete(cdf_file)


end do


toplot = new((/nexps,ndims(0),ndims(1)/),typeof(SW))
toplot2 = new((/nexps,ndims(0),ndims(1)/),typeof(LW))


toplot(0,:,:) = SW(0,:,:)
toplot2(0,:,:) = LW(0,:,:)

do ep = 1,nexps-1
	toplot(ep,:,:) = SW(ep,:,:) - SW(0,:,:)
        toplot2(ep,:,:) = LW(ep,:,:) - LW(0,:,:)

end do

toplot3 = new((/nexps,ndims(0),ndims(1)/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep = 1,nexps-1
	toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do

toplot!1 = "lat"
toplot!2 = "lon"

toplot&lat = lats
toplot&lon = lons

toplot&lat@units="degree_north"
toplot&lon@units="degree_east"

copy_VarCoords(toplot,toplot3)
copy_VarCoords(toplot,toplot2)


npanels = floattoint(ceil(nexps/2.0))

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/SW_CS_40yrs_TvsM")                  ; open workstation

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
  
  res@gsnLeftString  = ""
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 200.0			; set the maximum contour level
  res@cnLevelSpacingF       = 20.0      ; contour spacing

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

  res@gsnCenterString       = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@txString   = "SW W/m2"
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","b.","c.","d.","e.","f","g","h"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
     resP@amJust   = "TopLeft"
     panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)
  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot
; plot two

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/LW_CS_40yrs_TvsM")                  ; open workstation

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

  res@gsnLeftString  = ""
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 150.0                  ; set the minimum contour level
  res@cnMaxLevelValF  = 350.0                  ; set the maximum contour level
  res@cnLevelSpacingF       = 20.0     ; contour spacing

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

  res@gsnCenterString       = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2(0,:,:),res) ;

  res@cnMinLevelValF  = -20.0                   ; set the minimum contour level
  res@cnMaxLevelValF  = 20.0                    ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0        ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot2(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@txString   = "LW W/m2"
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","b.","c.","d.","e.","f","g","h"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
     resP@amJust   = "TopLeft"
     panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)
  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end
