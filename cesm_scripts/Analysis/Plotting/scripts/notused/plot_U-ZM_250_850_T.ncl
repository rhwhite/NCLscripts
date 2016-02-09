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

U850_ZM = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
U250_ZM = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))

U850 = cdf_file->U(0,nlev_850,:,:)
U250 = cdf_file->U(0,nlev_250,:,:)

do ilon = 0,nlons-1
	U850_ZM(0,:,ilon) = U850(:,ilon) - dim_avg_n(U850,1)
	U250_ZM(0,:,ilon) = U250(:,ilon) - dim_avg_n(U250,1)
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

	U850 = cdf_file->U(0,nlev_850,:,:)
	U250 = cdf_file->U(0,nlev_250,:,:)
	
	do ilon = 0,nlons-1
		U850_ZM(iexp,:,ilon) = U850(:,ilon) - dim_avg_n(U850,1)
		U250_ZM(iexp,:,ilon) = U250(:,ilon) - dim_avg_n(U250,1)
	end do

	delete(cdf_file)

end do

toplot850 = new((/8,ndims(2),ndims(3)/),typeof(U850_ZM))
toplot850(0,:,:) = U850_ZM(0,:,:)
toplot850(1,:,:) =  U850_ZM(1,:,:) - U850_ZM(2,:,:)
toplot850(2,:,:) =  U850_ZM(1,:,:)
toplot850(3,:,:) =  U850_ZM(0,:,:) - U850_ZM(1,:,:)
toplot850(4,:,:) =  U850_ZM(2,:,:)
toplot850(5,:,:) =  U850_ZM(0,:,:) - U850_ZM(2,:,:)
toplot850(6,:,:) =  U850_ZM(3,:,:)
toplot850(7,:,:) =  U850_ZM(0,:,:) - U850_ZM(3,:,:)


toplot250 = new((/8,ndims(2),ndims(3)/),typeof(U250_ZM))
toplot250(0,:,:) = U250_ZM(0,:,:)
toplot250(1,:,:) =  U250_ZM(1,:,:) - U250_ZM(2,:,:)
toplot250(2,:,:) =  U250_ZM(1,:,:)
toplot250(3,:,:) =  U250_ZM(0,:,:) - U250_ZM(1,:,:)
toplot250(4,:,:) =  U250_ZM(2,:,:)
toplot250(5,:,:) =  U250_ZM(0,:,:) - U250_ZM(2,:,:)
toplot250(6,:,:) =  U250_ZM(3,:,:)
toplot250(7,:,:) =  U250_ZM(0,:,:) - U250_ZM(3,:,:)


titles = new((/8/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(noT1 - noT2)"
titles(2) =  "(noT1)" 
titles(3) =  "(topo - noT1)"
titles(4) =  "(noT2)" 
titles(5) =  "(topo - noT2)" 
titles(6) =  "(noT3)" 
titles(7) =  "(topo - noT3)" 



toplot850!1 = "lat"
toplot850!2 = "lon"

toplot850&lat = lats
toplot850&lon = lons

toplot850&lat@units="degree_north"
toplot850&lon@units="degree_east"

copy_VarCoords(toplot850,toplot250)



; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/U-ZM_850mb_40yrs_TvsM")                  ; open workstation

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
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(0)              ; add common title
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing
  res@gsnPaperOrientation = "landscape"          

  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -4.0			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

  res@cnMinLevelValF  = -4.0			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot850(4,:,:),res) ;

  res@cnMinLevelValF  = -4.0			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot850(5,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(6)
  plot(6) = gsn_csm_contour_map_ce(wks,toplot850(6,:,:),res) ;

  res@cnMinLevelValF  = -4.0			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@gsnCenterString         = "mean U at 850mb,ms:S:-1:N:, " + titles(7)
  plot(7) = gsn_csm_contour_map_ce(wks,toplot850(7,:,:),res) ;





  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"          

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/4,2/),resP) 

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

; plot two = 250mb

  wks   = gsn_open_wks ("eps","Figures/U-ZM_250mb_40yrs_TvsM")                  ; open workstation

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
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(0)              ; add common title
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0


  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 30.0			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing
  res@gsnPaperOrientation = "landscape"          

  plot(0) = gsn_csm_contour_map_ce(wks,toplot250(0,:,:),res) ;
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(1)

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot250(1,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 30.0			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot250(2,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(3)
  plot(3) = gsn_csm_contour_map_ce(wks,toplot250(3,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 30.0			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(4)
  plot(4) = gsn_csm_contour_map_ce(wks,toplot250(4,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(5)
  plot(5) = gsn_csm_contour_map_ce(wks,toplot250(5,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 30.0			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(6)
  plot(6) = gsn_csm_contour_map_ce(wks,toplot250(6,:,:),res) ;

  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 10.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing
  res@gsnCenterString         = "mean U at 250mb,ms:S:-1:N:, " + titles(7)
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