load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMtopof19","CESMnoTf19","CESMnoT2f19","CESMnoT3f19"/)
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "EV_H_" + tostring(nyears) + "yrs_" + Experiments(0) + ".cam2.h1.nc"
cdf_file = addfile(diro + filo, "r")

ndims = dimsizes(cdf_file->uH_bpf250)

uH250 = new((/nexps,ndims(0),ndims(1)/),typeof(cdf_file->uH_bpf250))

uH250(0,:,:) = cdf_file->uH_bpf250

lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
filo = "EV_H_" + tostring(nyears) + "yrs_" + Experiments(iexp) + ".cam2.h1.nc"

	cdf_file = addfile(diro + filo, "r")
	
	uH250(iexp,:,:) = cdf_file->uH_bpf250
	
	delete(cdf_file)

end do

toplot250 = new((/8,ndims(0),ndims(1)/),typeof(uH250))
toplot250(0,:,:) = uH250(0,:,:)
toplot250(1,:,:) =  uH250(1,:,:) - uH250(2,:,:)
toplot250(2,:,:) =  uH250(1,:,:)
toplot250(3,:,:) =  uH250(0,:,:) - uH250(1,:,:)
toplot250(4,:,:) =  uH250(2,:,:)
toplot250(5,:,:) =  uH250(0,:,:) - uH250(2,:,:)
toplot250(6,:,:) =  uH250(3,:,:)
toplot250(7,:,:) =  uH250(0,:,:) - uH250(3,:,:)


titles = new((/8/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(noT1 - noT2)"
titles(2) =  "(noT1)" 
titles(3) =  "(topo - noT1)"
titles(4) =  "(noT2)" 
titles(5) =  "(topo - noT2)" 
titles(6) =  "(noT3)" 
titles(7) =  "(topo - noT3)" 


toplot250!1 = "lat"
toplot250!2 = "lon"

toplot250&lat = lats
toplot250&lon = lons

toplot250&lat@units="degree_north"
toplot250&lon@units="degree_east"


; plot
; plot one = 250mb

  wks   = gsn_open_wks ("eps","Figures/Uh_250mb_40yrs_TvsM")                  ; open workstation

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
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@gsnCenterString         = "mean uH at 250mb, ms:S:-1:N:, " + titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -6.0			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot250(0,:,:),res) ;
  res@gsnCenterString         = "mean uH at 250mb, ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -3.0			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot250(1,:,:),res) ;

  res@cnMinLevelValF  = -6.0			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         =titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot250(2,:,:),res) ;

  res@cnMinLevelValF  = -3.0			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot250(3,:,:),res) ;

  res@cnMinLevelValF  = -6.0			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         =  titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot250(4,:,:),res) ;

  res@cnMinLevelValF  = -3.0			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         =  titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot250(5,:,:),res) ;

  res@cnMinLevelValF  = -6.0			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = titles(6)
  plot(6) = gsn_csm_contour_map_ce(wks,toplot250(6,:,:),res) ;

  res@cnMinLevelValF  = -3.0			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         = titles(7)
  plot(7) = gsn_csm_contour_map_ce(wks,toplot250(7,:,:),res) ;


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