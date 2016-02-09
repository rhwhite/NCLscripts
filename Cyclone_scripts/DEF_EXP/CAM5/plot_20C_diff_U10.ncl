load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears =25
startyear = 2

Experiment = "CAM5topo"

diro = "$HOME/Yellowstone/"
filo = "Clims_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
fout_std2 = addfile(diro + filo,"r")

lats2 = fout_std2->lat
lons2 = fout_std2->lon

SSTs_clim2 = fout_std2->SSTs_clim
T2m_clim2 = fout_std2->T2m_clim 
U10_clim2 = fout_std2->U10_clim 
Precip_clim2 = fout_std2->Precip_clim 

landmask2 = fout_std2->landmask 
oceanmask2 = fout_std2->oceanmask

Experiment2 = (/"b.e11.B20TRC5CN.f09_g16.001"/)
filo = "Clims_" + tostring(nyears) + "_" + Experiment2 + ".cam2.h1.nc"
fout_std1 = addfile(diro + filo,"r")

lats1 = fout_std1->lat
lons1 = fout_std1->lon

SSTs_clim1 = fout_std1->SSTs_clim
T2m_clim1 = fout_std1->T2m_clim
U10_clim1 = fout_std1->U10_clim
Precip_clim1 = fout_std1->Precip_clim

landmask1 = fout_std1->landmask
oceanmask1 = fout_std1->oceanmask

;Regrid 1 degree onto 2 degree grid

SSTs_clim1_2 = area_conserve_remap_Wrap(lons1,lats1,SSTs_clim1,lons2,lats2,False) - SSTs_clim2
T2m_clim1_2 = area_conserve_remap_Wrap(lons1,lats1,T2m_clim1,lons2,lats2,False) - T2m_clim2
U10_clim1_2 = area_conserve_remap_Wrap(lons1,lats1,U10_clim1,lons2,lats2,False) - U10_clim2
Precip_clim1_2 = area_conserve_remap_Wrap(lons1,lats1,Precip_clim1,lons2,lats2,False) - Precip_clim2


toplotAnn = oceanmask2 * dim_avg_n(U10_clim2,0)
toplotJJA = oceanmask2 *(U10_clim2(5,:,:) + U10_clim2(6,:,:) + U10_clim2(7,:,:))/3.0
toplotDJF = oceanmask2 *(U10_clim2(11,:,:) + U10_clim2(0,:,:) + U10_clim2(1,:,:))/3.0

toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats2
toplotAnn&lon = lons2

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

toplotAnn2 = oceanmask1 * dim_avg_n(U10_clim1,0)
toplotJJA2 = oceanmask1 *(U10_clim1(5,:,:) + U10_clim1(6,:,:) + U10_clim1(7,:,:))/3.0
toplotDJF2 = oceanmask1 *(U10_clim1(11,:,:) + U10_clim1(0,:,:) + U10_clim1(1,:,:))/3.0

toplotAnn2!0 = "lat"
toplotAnn2!1 = "lon"

toplotAnn2&lat = lats1
toplotAnn2&lon = lons1

toplotAnn2&lat@units="degrees_north"
toplotAnn2&lon@units="degrees_east"

copy_VarCoords(toplotAnn2,toplotJJA2)
copy_VarCoords(toplotAnn2,toplotDJF2)


toplotAnn3 = oceanmask2 * dim_avg_n(U10_clim1_2,0)
toplotJJA3 = oceanmask2 *(U10_clim1_2(5,:,:) + U10_clim1_2(6,:,:) + U10_clim1_2(7,:,:))/3.0
toplotDJF3 = oceanmask2 *(U10_clim1_2(11,:,:) + U10_clim1_2(0,:,:) + U10_clim1_2(1,:,:))/3.0

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)

copy_VarCoords(toplotAnn,toplotAnn3)
copy_VarCoords(toplotAnn,toplotJJA3)
copy_VarCoords(toplotAnn,toplotDJF3)



wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/U10_" + startyear + "_" + nyears +"_Coupled-Fixed")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(9,graphic)                          ; create a plot array

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

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 0.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 14.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual U10, m/s from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;
  res@gsnCenterString         = "JJA U10, m/s from " + Experiment
  plot(3) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;
  res@gsnCenterString         = "DJF U10, m/s from " + Experiment
  plot(6) = gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  res@gsnCenterString         = "Annual U10, m/s from " + Experiment2 
  plot(1) = gsn_csm_contour_map_ce(wks,toplotAnn2,res) ;
  res@gsnCenterString         = "JJA U10, m/s from " + Experiment2
  plot(4) = gsn_csm_contour_map_ce(wks,toplotJJA2,res) ;
  res@gsnCenterString         = "DJF U10, m/s from " + Experiment2
  plot(7) = gsn_csm_contour_map_ce(wks,toplotDJF2,res) ;

  res@cnMinLevelValF  = -1.5                    ; set the minimum contour level
  res@cnMaxLevelValF  = 1.5                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.25      ; contour spacing

  res@gsnCenterString         = "Annual U10, m/s from " + Experiment2 + "-" + Experiment
  plot(2) = gsn_csm_contour_map_ce(wks,toplotAnn3,res) ;
  res@gsnCenterString         = "JJA U10, m/s from " + Experiment2 + "-" + Experiment
  plot(5) = gsn_csm_contour_map_ce(wks,toplotJJA3,res) ;
  res@gsnCenterString         = "DJF U10, m/s from " + Experiment2 + "-" + Experiment
  plot(8) = gsn_csm_contour_map_ce(wks,toplotDJF3,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,3/),resP)

  gsn_panel(wks,plot,(/3,3/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


end



