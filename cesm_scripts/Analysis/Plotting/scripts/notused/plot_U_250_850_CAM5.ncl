load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
Experiments = (/"CESMtopof19","CAM5topo","CESMnoT4f19","CAM5_noM","CESMnoTf19","CAM5_noT"/)

print(Experiments)

nexps = dimsizes(Experiments)

titles = new((/nexps/),typeof(Experiments))
titles(0) =  "Topo"
titles(1) =  "CAM5 Topo"
titles(2) =  "Topo - noT4"
titles(3) =  "CAM5 Topo - noM"
titles(4) =  "Topo - noT"
titles(5) =  "CAM5 Topo - noT"

diro = "/home/disk/rachel/CESM_outfiles/"
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs_mean = cdf_file->lev_p

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

; Find 250 and 850hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_250 = -1

do nl = 0,nlevs-1
        if levs_mean(nl) .EQ. 250 then
                nlev_250 = nl
        end if
end do

nlev_850 = -1

do nl = 0,nlevs-1
        if levs_mean(nl) .EQ. 850 then
                nlev_850 = nl
        end if
end do

if (nlev_250 .LT. 0 .OR. nlev_850 .LT. 0) then
        print("didnt find a level")
        exit
end if

ndims2 = dimsizes(cdf_file->U)

U250 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))
U850 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))
PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file->U))

U850(0,:,:) = cdf_file->U(0,nlev_850,:,:)
U250(0,:,:) = cdf_file->U(0,nlev_250,:,:)

delete(cdf_file)


filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

PS = cdf_file->PS
PHIS(0,:,:) = cdf_file->PHIS/9.8

delete(cdf_file)

do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 85000) then
			U850(0,ix,iy) = U850@_FillValue
		end if
	end do
end do

delete(PS)

do iexp = 1,nexps-1

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"
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

	U250(iexp,:,:) = cdf_file->U(0,nlev_250,:,:)
        U850(iexp,:,:) = cdf_file->U(0,nlev_850,:,:)


	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")
	PS = cdf_file->PS

	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(0,ix,iy) .LE. 85000) then
				U850(iexp,ix,iy) = U850@_FillValue
			end if
		end do
	end do

	delete(PS)
	delete(cdf_file)

end do

toplot = new((/nexps,nlats,nlons/),typeof(U250))
toplot2 = new((/nexps,nlats,nlons/),typeof(U850))
toplot3 = new((/nexps,nlats,nlons/),typeof(PHIS))

toplot(0,:,:) = U250(0,:,:)
toplot(1,:,:) = U250(1,:,:)
toplot2(0,:,:) = U850(0,:,:)
toplot2(1,:,:) = U850(1,:,:)
toplot3(0,:,:) =  0.0
toplot3(1,:,:) =  0.0


do ep = 2,(nexps/2)
        toplot((ep*2)-2,:,:) = U250(0,:,:) - U250((ep*2)-2,:,:)
        toplot2((ep*2)-2,:,:) = U850(0,:,:) - U850((ep*2)-2,:,:)

        toplot((ep*2)-1,:,:) = U250(1,:,:) - U250((ep*2)-1,:,:)
        toplot2((ep*2)-1,:,:) = U850(1,:,:) - U850((ep*2)-1,:,:)

        toplot3((ep*2)-2,:,:) =  PHIS(0,:,:) - PHIS((ep*2)-2,:,:)
        toplot3((ep*2)-1,:,:) =  PHIS(1,:,:) - PHIS((ep*2)-1,:,:)

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

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/TvM/U850_40yrs_CAM5")   ; open workstation

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

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels 
  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 14.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2(0,:,:),res) ;
  plot(1) = gsn_csm_contour_map_ce(wks,toplot2(1,:,:),res) ;


  res@cnMinLevelValF  = -4.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.8      ; contour spacing

do pp = 2,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot2(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "U at 850mb, ms:S:-1:N:, "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 2 250mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/TvM/U250_40yrs_CAM5")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -10.0                   ; set the minimum contour level
  res@cnMaxLevelValF  = 40.0                    ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;
  plot(1) = gsn_csm_contour_map_ce(wks,toplot(1,:,:),res) ;

  res@cnMinLevelValF  = -8.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 8.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.6      ; contour spacing

do pp = 2,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "U at 250mb, ms:S:-1:N:, "

  resP@gsnDraw = False                           ; draw later, in maximize mode


;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
