load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMtopof19","CESMnoRTf19","CESMnoRf19","CESMnoTf19","CESMnoT2f19"/);,"CESMnotopof19"
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "JJA" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

ndims = dimsizes(cdf_file->U)

Rain = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->OMEGA))

Rain(0,:,:) = (cdf_file->PRECC(0,:,:) +  cdf_file->PRECL(0,:,:)) * secdays * 1000.0


lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "JJA" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	Rain(iexp,:,:) = (cdf_file->PRECT(0,:,:)) * secdays * 1000.0
	
	delete(cdf_file)

end do

toplot = new((/6,ndims(2),ndims(3)/),typeof(Rain))
toplot(0,:,:) = Rain(0,:,:)
toplot(1,:,:) =  Rain(0,:,:) - Rain(1,:,:)
toplot(2,:,:) =  Rain(0,:,:) - Rain(2,:,:)
toplot(3,:,:) =  Rain(0,:,:) - Rain(3,:,:)
toplot(4,:,:) =  Rain(0,:,:) - Rain(4,:,:)
toplot(5,:,:) =  (Rain(0,:,:) - Rain(1,:,:)) - (Rain(0,:,:) - Rain(2,:,:)) - (Rain(0,:,:) - Rain(3,:,:))


titles = new((/6/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "topo - noRT"
titles(2) =  "topo - noR" 
titles(3) =  "topo - noT" 
titles(4) =  "topo - noT2" 
titles(5) =  "(topo-noRT) - (topo-noR) - (topo-noT)"


toplot!1 = "lat"
toplot!2 = "lon"

toplot&lat = lats
toplot&lon = lons

toplot&lat@units="degree_north"
toplot&lon@units="degree_east"



; plot
; plot one = mb

 wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/JJA_Precip_40yrs_f19") ; open workstation

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
  res@gsnCenterString         = "Total Precip Rate, ms:S:-1:N:, " + titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 8.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;
  res@gsnCenterString         = "Total Precip Rate, mm day:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -1.5			; set the minimum contour level
  res@cnMaxLevelValF  = 1.5			; set the maximum contour level
  res@cnLevelSpacingF       = 0.3      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot(1,:,:),res) ;

  res@gsnCenterString         = "Total Precip Rate, mm day:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot(2,:,:),res) ;

  res@gsnCenterString         = "Total Precip Rate, mm day:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot(3,:,:),res) ;

  res@gsnCenterString         = "Total Precip Rate, mm day:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot(4,:,:),res) ;

  res@cnMinLevelValF  = -0.75			; set the minimum contour level
  res@cnMaxLevelValF  = 0.75			; set the maximum contour level
  res@cnLevelSpacingF       = 0.15      ; contour spacing

  res@gsnCenterString         = "Total Precip Rate, mm day:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot(5,:,:),res) ;

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
