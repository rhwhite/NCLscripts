load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
Experiments = (/"CESMtopof19","CESMnoRT2f19","CESMnoRf19","CESMnoT2f19","CESMnotopof19"/)

print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
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

nlats = ndims(2)
nlons = ndims(3)

SF850 = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))
SF250 = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))
SF_SFC = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))
PHIS = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))

sf = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))
vp = new((/ndims(2),ndims(3)/),typeof(cdf_file->U))

uv2sfvpf(cdf_file->U(0,nlev_850,:,:),cdf_file->V(0,nlev_850,:,:),sf,vp)

SF850(:,:) = sf
sf = 0.0
vp = 0.0

uv2sfvpf (cdf_file->U(0,nlev_250,:,:),cdf_file->V(0,nlev_250,:,:), sf,vp)

SF250(:,:) = sf
sf = 0.0
vp = 0.0


SF850_ZM = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
SF250_ZM = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))


do ilon = 0,nlons-1
	SF850_ZM(0,:,ilon) = SF850(:,ilon) - dim_avg_n(SF850,1)
	SF250_ZM(0,:,ilon) = SF250(:,ilon) - dim_avg_n(SF250,1)
end do




diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs = cdf_file->lev
nlev = dimsizes(levs)
if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
end if

print(levs(nlev-1) * 1.0)

uv2sfvpf (cdf_file->U(0,nlev-1,:,:),cdf_file->V(0,nlev-1,:,:), sf,vp)
PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

SF_SFC(:,:) = sf
sf = 0.0
vp = 0.0


SF_SFC_ZM = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))

do ilon = 0,nlons-1
	SF_SFC_ZM(0,:,ilon) = SF_SFC(:,ilon) - dim_avg_n(SF_SFC,1)

end do


lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
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

	SF850(:,:) = sf
	sf = 0.0
	vp = 0.0

	uv2sfvpf (cdf_file->U(0,nlev_250,:,:),cdf_file->V(0,nlev_250,:,:), sf,vp)

	SF250(:,:) = sf
	sf = 0.0
	vp = 0.0
	delete(cdf_file)


do ilon = 0,nlons-1
	SF850_ZM(iexp,:,ilon) = SF850(:,ilon) - dim_avg_n(SF850,1)
	SF250_ZM(iexp,:,ilon) = SF250(:,ilon) - dim_avg_n(SF250,1)
end do




end do

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs = cdf_file->lev
	nlev = dimsizes(levs)
	if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
	end if

	print(levs(nlev-1) * 1.0)

	uv2sfvpf (cdf_file->U(0,nlev-1,:,:),cdf_file->V(0,nlev-1,:,:), sf,vp)
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	SF_SFC(:,:) = sf
	sf = 0.0
	vp = 0.0


do ilon = 0,nlons-1
	SF_SFC_ZM(iexp,:,ilon) = SF_SFC(:,ilon) - dim_avg_n(SF_SFC,1)

end do


end do

toplot850 = new((/5,ndims(2),ndims(3)/),typeof(SF850_ZM))
toplot850(0,:,:) = SF850_ZM(0,:,:)
toplot850(1,:,:) =  SF850_ZM(0,:,:) - SF850_ZM(1,:,:)
toplot850(2,:,:) =  SF850_ZM(0,:,:) - SF850_ZM(2,:,:)
toplot850(3,:,:) =  SF850_ZM(0,:,:) - SF850_ZM(3,:,:)
toplot850(4,:,:) =  toplot850(1,:,:) - toplot850(2,:,:) - toplot850(3,:,:)


toplot250 = new((/5,ndims(2),ndims(3)/),typeof(SF250_ZM))
toplot250(0,:,:) = SF250_ZM(0,:,:)
toplot250(1,:,:) =  SF250_ZM(0,:,:) - SF250_ZM(1,:,:)
toplot250(2,:,:) =  SF250_ZM(0,:,:) - SF250_ZM(2,:,:)
toplot250(3,:,:) =  SF250_ZM(0,:,:) - SF250_ZM(3,:,:)
toplot250(4,:,:) =  toplot250(1,:,:) - toplot250(2,:,:) - toplot250(3,:,:)

toplotSFC = new((/5,ndims(2),ndims(3)/),typeof(SF_SFC_ZM))
toplotSFC(0,:,:) = SF_SFC_ZM(0,:,:)
toplotSFC(1,:,:) =  SF_SFC_ZM(0,:,:) - SF_SFC_ZM(1,:,:)
toplotSFC(2,:,:) =  SF_SFC_ZM(0,:,:) - SF_SFC_ZM(2,:,:)
toplotSFC(3,:,:) =  SF_SFC_ZM(0,:,:) - SF_SFC_ZM(3,:,:)
toplotSFC(4,:,:) =  toplotSFC(1,:,:) - toplotSFC(2,:,:) - toplotSFC(3,:,:)

toplot3 = new((/5,ndims(2),ndims(3)/),typeof(PHIS))
toplot3(0,:,:) = PHIS(0,:,:)
toplot3(1,:,:) =  PHIS(0,:,:) - PHIS(1,:,:)
toplot3(2,:,:) =  PHIS(0,:,:) - PHIS(2,:,:)
toplot3(3,:,:) =  PHIS(0,:,:) - PHIS(3,:,:)
toplot3(4,:,:) =  toplot3(1,:,:) - toplot3(2,:,:) - toplot3(3,:,:)


titles = new((/5/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(topo - noRT2)"
titles(2) =  "(topo - noR)" 
titles(3) =  "(topo - noT2)" 
titles(4) =  titles(1) + "-" + titles(2) + "-" + titles(3)


toplot850!1 = "lat"
toplot850!2 = "lon"

toplot850&lat = lats
toplot850&lon = lons

toplot850&lat@units="degree_north"
toplot850&lon@units="degree_east"

copy_VarCoords(toplot850,toplot250)
copy_VarCoords(toplot850,toplotSFC)
copy_VarCoords(toplot850,toplot3)



; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/SF_ZM_850mb_40yrs_RT2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(5,graphic)                          ; create a plot array

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
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -2.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0e6      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;
  res@gsnCenterString         = titles(1)

  res@cnMinLevelValF  = -1.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 1.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

  res@cnMinLevelValF  = -5.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0e6      ; contour spacing
  res@gsnCenterString         = titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot850(4,:,:),res) ;

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/1000.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1 	; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False

do pp = 0,4
	plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
	overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/5,1/),resP) 

  gsn_panel(wks,plot,(/5,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot two = 250mb

  wks   = gsn_open_wks ("eps","Figures/SF_ZM_250mb_40yrs_RT2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(5,graphic)                          ; create a plot array

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
  res@cnMinLevelValF  = -1.4e8			; set the minimum contour level
  res@cnMaxLevelValF  = 1.4e8			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0e7      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot250(0,:,:),res) ;
  res@gsnCenterString         = titles(1)

  res@cnMinLevelValF  = -1.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 1.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot250(1,:,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot250(2,:,:),res) ;

  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot250(3,:,:),res) ;

  res@cnMinLevelValF  = -5.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 5.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0e6      ; contour spacing
  res@gsnCenterString         = titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot250(4,:,:),res) ;


  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/1000.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1 	; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False

do pp = 0,4
	plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
	overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/5,1/),resP) 

  gsn_panel(wks,plot,(/5,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


; plot three = 10m surface

  wks   = gsn_open_wks ("eps","Figures/SF_SFC_ZM_40yrs_RT2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(5,graphic)                          ; create a plot array

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
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -2.0e7			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0e7			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4e7      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplotSFC(0,:,:),res) ;
  res@gsnCenterString         = titles(1)

  res@cnMinLevelValF  = -4.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5e6      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplotSFC(1,:,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplotSFC(2,:,:),res) ;

  res@gsnCenterString         = titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplotSFC(3,:,:),res) ;

  res@cnMinLevelValF  = -2.0e6			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0e6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4e6      ; contour spacing
  res@gsnCenterString         = titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplotSFC(4,:,:),res) ;

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/1000.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1 	; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False

do pp = 0,4
	plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
	overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/5,1/),resP) 

  gsn_panel(wks,plot,(/5,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end