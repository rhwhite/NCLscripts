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
filo = "DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs_mean = cdf_file->lev_p

; Find 250 and 850hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_250 = -1
nlev_850 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 250 then
		nlev_250 = nl
	end if
	if levs_mean(nl) .EQ. 850 then
		nlev_850 = nl
	end if
end do

if (nlev_250 .LT. 0 .OR. nlev_850 .LT. 0) then
	print("didnt find a level")
	exit
end if

ndims = dimsizes(cdf_file->U)

SF850 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
SF250 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
SF_SFC = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))

sf = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))
vp = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))

uv2sfvpf(cdf_file->U(0,nlev_850,:,:),cdf_file->V(0,nlev_850,:,:),sf,vp)

SF850(0,:,:) = sf
sf = 0.0
vp = 0.0

uv2sfvpf (cdf_file->U(0,nlev_250,:,:),cdf_file->V(0,nlev_250,:,:), sf,vp)

SF250(0,:,:) = sf
sf = 0.0
vp = 0.0


diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs = cdf_file->lev
nlev = dimsizes(levs)
if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
end if

print(levs(nlev-1) * 1.0)

uv2sfvpf (cdf_file->U(0,nlev-1,:,:),cdf_file->V(0,nlev-1,:,:), sf,vp)

SF_SFC(0,:,:) = sf
sf = 0.0
vp = 0.0


lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

; Check levs
	if levs_mean(nlev_250) .NE. 250 then
		print(levs_mean(nlev_250))
		print("should be 250!")
		exit
	end if
	if levs_mean(nlev_850) .NE. 850 then
		print(levs_mean(nlev_850))
		print("should be 850!")
		exit
	end if

	uv2sfvpf (cdf_file->U(0,nlev_850,:,:),cdf_file->V(0,nlev_850,:,:), sf,vp)

	SF850(iexp,:,:) = sf
	sf = 0.0
	vp = 0.0

	uv2sfvpf (cdf_file->U(0,nlev_250,:,:),cdf_file->V(0,nlev_250,:,:), sf,vp)

	SF250(iexp,:,:) = sf
	sf = 0.0
	vp = 0.0
	delete(cdf_file)

end do

do iexp = 1,nexps-1

	diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs = cdf_file->lev
	nlev = dimsizes(levs)
	if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
	end if

	print(levs(nlev-1) * 1.0)

	uv2sfvpf (cdf_file->U(0,nlev-1,:,:),cdf_file->V(0,nlev-1,:,:), sf,vp)

	SF_SFC(iexp,:,:) = sf
	sf = 0.0
	vp = 0.0

end do

toplot850 = new((/6,ndims(2),ndims(3)/),typeof(SF850))
toplot850(0,:,:) = SF850(0,:,:)
toplot850(1,:,:) =  SF850(0,:,:) - SF850(1,:,:)
toplot850(2,:,:) =  SF850(0,:,:) - SF850(2,:,:)
toplot850(3,:,:) =  SF850(0,:,:) - SF850(3,:,:)
toplot850(4,:,:) =  SF850(0,:,:) - SF850(4,:,:)
toplot850(5,:,:) =  (SF850(0,:,:) - SF850(1,:,:)) - (SF850(0,:,:) - SF850(2,:,:)) - (SF850(0,:,:) - SF850(3,:,:))



toplot250 = new((/6,ndims(2),ndims(3)/),typeof(SF250))
toplot250(0,:,:) = SF250(0,:,:)
toplot250(1,:,:) =  SF250(0,:,:) - SF250(1,:,:)
toplot250(2,:,:) =  SF250(0,:,:) - SF250(2,:,:)
toplot250(3,:,:) =  SF250(0,:,:) - SF250(3,:,:)
toplot250(4,:,:) =  SF250(0,:,:) - SF250(4,:,:)
toplot250(5,:,:) =  (SF250(0,:,:) - SF250(1,:,:)) - (SF250(0,:,:) - SF250(2,:,:)) - (SF250(0,:,:) - SF250(3,:,:))


toplotSFC = new((/6,ndims(2),ndims(3)/),typeof(SF_SFC))
toplotSFC(0,:,:) = SF_SFC(0,:,:)
toplotSFC(1,:,:) =  SF_SFC(0,:,:) - SF_SFC(1,:,:)
toplotSFC(2,:,:) =  SF_SFC(0,:,:) - SF_SFC(2,:,:)
toplotSFC(3,:,:) =  SF_SFC(0,:,:) - SF_SFC(3,:,:)
toplotSFC(4,:,:) =  SF_SFC(0,:,:) - SF_SFC(4,:,:)
toplotSFC(5,:,:) =  (SF_SFC(0,:,:) - SF_SFC(1,:,:)) - (SF_SFC(0,:,:) - SF_SFC(2,:,:)) - (SF_SFC(0,:,:) - SF_SFC(3,:,:))

titles = new((/6/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "topo - noRT"
titles(2) =  "topo - noR" 
titles(3) =  "topo - noT" 
titles(4) =  "topo - noT2" 
titles(5) =  "(topo-noRT) - (topo-noR) - (topo-noT)"


toplot850!1 = "lat"
toplot850!2 = "lon"

toplot850&lat = lats
toplot850&lon = lons

toplot850&lat@units="degree_north"
toplot850&lon@units="degree_east"

copy_VarCoords(toplot850,toplot250)
copy_VarCoords(toplot850,toplotSFC)



; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/SFavg_850mb_40yrs_f19")                  ; open workstation

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
  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -1.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 1.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0e6      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;
  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -6.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot850(4,:,:),res) ;

  res@cnMinLevelValF  = -3.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5e6      ; contour spacing

  res@gsnCenterString         = "mean SF at 850mb,ms:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot850(5,:,:),res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP) 

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot two = 250mb

  wks   = gsn_open_wks ("eps","Figures/SFavg_250mb_40yrs_f19")                  ; open workstation

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
  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -8.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 8.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0e7      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot250(0,:,:),res) ;
  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -6.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 6.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot250(1,:,:),res) ;

  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot250(2,:,:),res) ;

  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot250(3,:,:),res) ;

  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot250(4,:,:),res) ;

  res@cnMinLevelValF  = -3.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5e6      ; contour spacing

  res@gsnCenterString         = "mean SF at 250mb,ms:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot250(5,:,:),res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP) 

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


; plot three = 10m surface

  wks   = gsn_open_wks ("eps","Figures/SFavg_SFC_40yrs_f19")                  ; open workstation

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
  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(0)              ; add common title

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -2.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4e7      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplotSFC(0,:,:),res) ;
  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -2.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplotSFC(1,:,:),res) ;

  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplotSFC(2,:,:),res) ;

  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplotSFC(3,:,:),res) ;

  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplotSFC(4,:,:),res) ;

  res@cnMinLevelValF  = -1.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 1.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.2e6      ; contour spacing

  res@gsnCenterString         = "mean SF at SFC, ms:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplotSFC(5,:,:),res) ;

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