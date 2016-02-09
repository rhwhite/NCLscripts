load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears =30
startyear = 88

precipconst = 1000.0 * 86400.0

endyear = startyear + nyears -1

Experiment = "PDO_fSST"

diro = "/home/disk/eos4/rachel/MPIESM/ECHAM4.6/echam_" + Experiment + "/output/" + Experiment + "/PProc/"
filo = "Ann_mean_" + tostring(startyear) + "to" + tostring(endyear) + "_" + Experiment + ".nc"
fout_std = addfile(diro + filo,"r")

Ann_precip = fout_std->precip*precipconst
 
filo = "DJF_mean_" + tostring(startyear) + "to" + tostring(endyear) + "_" + Experiment + ".nc"
fout_std = addfile(diro + filo,"r")

DJF_precip = fout_std->precip*precipconst

filo = "MAM_mean_" + tostring(startyear) + "to" + tostring(endyear) + "_" + Experiment + ".nc"
fout_std = addfile(diro + filo,"r")

MAM_precip = fout_std->precip*precipconst

filo = "JJA_mean_" + tostring(startyear) + "to" + tostring(endyear) + "_" + Experiment + ".nc"
fout_std = addfile(diro + filo,"r")

JJA_precip = fout_std->precip*precipconst

filo = "SON_mean_" + tostring(startyear) + "to" + tostring(endyear) + "_" + Experiment + ".nc"
fout_std = addfile(diro + filo,"r")

SON_precip = fout_std->precip*precipconst


diro = "/home/disk/eos4/rachel/MPIESM/ECHAM4.6/echam_test1/echam4_ini/T42/"
filo = "jan42m.nc" 
fin_lm = addfile(diro + filo,"r")

lats = fin_lm->lat
lons = fin_lm->lon
landmask2 = fin_lm->SLM

DJF_precip!0="time"
DJF_precip!1="lat"
DJF_precip!2="lon"

DJF_precip&lat = lats
DJF_precip&lon = lons

DJF_precip&lat@units="degree_north"
DJF_precip&lon@units="degree_east"
copy_VarCoords(DJF_precip,Ann_precip)
copy_VarCoords(DJF_precip,MAM_precip)
copy_VarCoords(DJF_precip,JJA_precip)
copy_VarCoords(DJF_precip,SON_precip)



wks = gsn_open_wks ("eps","$HOME/Figures/DEF_ECHAM/Precip_ECHAM_" + Experiment + "_" + startyear + "_" + nyears +"_SOM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(3,graphic)                          ; create a plot array

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
  res@cnMaxLevelValF  = 12.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual Precip, mm/day from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,Ann_precip(0,:,:),res) ;
  res@gsnCenterString         = "JJA Precip, mm/day from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,JJA_precip(0,:,:),res) ;
  res@gsnCenterString         = "DJF Precip, mm/day from " + Experiment
  plot(2) = gsn_csm_contour_map_ce(wks,DJF_precip(0,:,:),res) ;

  res@cnMinLevelValF  = -3.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 3.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "portrait"

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,1/),resP)

  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


end



