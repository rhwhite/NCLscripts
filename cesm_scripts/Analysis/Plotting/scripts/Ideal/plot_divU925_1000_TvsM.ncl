load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Use centred finite differences as this allows for missing values, and doesn't create such wave-like effects.

nyears = 40

secdays = 86400.0
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
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs_mean = cdf_file->lev_p

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

; Find 1000 and 925hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_1000 = -1

do nl = 0,nlevs-1
        if levs_mean(nl) .EQ. 1000 then
                nlev_1000 = nl
        end if
end do

nlev_925 = -1

do nl = 0,nlevs-1
        if levs_mean(nl) .EQ. 925 then
                nlev_925 = nl
        end if
end do

if (nlev_1000 .LT. 0 .OR. nlev_925 .LT. 0) then
        print("didnt find a level")
        exit
end if

ndims2 = dimsizes(cdf_file->U)

U1000 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))
U925 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))

V1000 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))
V925 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))

divU1000 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))
divU925 = new((/nexps,nlats,nlons/),typeof(cdf_file->U))

PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file->U))

U925(0,:,:) = cdf_file->U(0,nlev_925,:,:)
U1000(0,:,:) = cdf_file->U(0,nlev_1000,:,:)

V925(0,:,:) = cdf_file->V(0,nlev_925,:,:)
V1000(0,:,:) = cdf_file->V(0,nlev_1000,:,:)

delete(cdf_file)


filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

PS = cdf_file->PS
PHIS(0,:,:) = cdf_file->PHIS/9.8

delete(cdf_file)


divU1000(0,:,:) = uv2dv_cfd(U1000(0,:,:),V1000(0,:,:),lats,lons,1)
divU925(0,:,:) = uv2dv_cfd(U925(0,:,:),V925(0,:,:),lats,lons,1)


do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 92500) then
			divU925(0,ix,iy) = U925@_FillValue
		end if
	end do
end do

delete(PS)

do iexp = 1,nexps-1

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

; Check levs
	if levs_mean(nlev_1000) .NE. 1000 then
		print(levs_mean(nlev_1000))
		print("should be 1000!")
		exit
	end if
        if levs_mean(nlev_925) .NE. 925 then
                print(levs_mean(nlev_925))
                print("should be 925!")
                exit
        end if

	U1000(iexp,:,:) = cdf_file->U(0,nlev_1000,:,:)
        U925(iexp,:,:) = cdf_file->U(0,nlev_925,:,:)

        V1000(iexp,:,:) = cdf_file->V(0,nlev_1000,:,:)
        V925(iexp,:,:) = cdf_file->V(0,nlev_925,:,:)


	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")
	PS = cdf_file->PS

	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	delete(cdf_file)

	divU1000(iexp,:,:) = uv2dv_cfd(U1000(iexp,:,:),V1000(iexp,:,:),lats,lons,1)
	divU925(iexp,:,:) = uv2dv_cfd(U925(iexp,:,:),V925(iexp,:,:),lats,lons,1)


        do iy = 0,nlons-1
                do ix = 0,nlats-1
                        if (PS(0,ix,iy) .LE. 92500) then
                                divU925(iexp,ix,iy) = divU925@_FillValue
                        end if
                end do
        end do

	delete(PS)

end do


toplot = new((/nexps,nlats,nlons/),typeof(divU1000))
toplot2 = new((/nexps,nlats,nlons/),typeof(divU925))

toplot(0,:,:) = divU1000(0,:,:)
toplot2(0,:,:) = divU925(0,:,:)

do ep = 1,nexps-1
        toplot(ep,:,:) = divU1000(ep,:,:) - divU1000(0,:,:)
        toplot2(ep,:,:) = divU925(ep,:,:) - divU925(0,:,:)
end do

toplot3 = new((/nexps,nlats,nlons/),typeof(PHIS))
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
; plot one = 925mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/DivU925_40yrs_ITvsM")   ; open workstation

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
  res@cnMinLevelValF  = -3.0E-6			; set the minimum contour level
  res@cnMaxLevelValF  = 3.0E-6			; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-6      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2(0,:,:),res) ;

  res@cnMinLevelValF  = -2.0E-6                    ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-6                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.25E-6      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot2(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "DivU at 925mb, s:S:-1:N:, "

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 2 1000mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/DivU1000_40yrs_ITvsM")   ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -3.0E-6                   ; set the minimum contour level
  res@cnMaxLevelValF  = 3.0E-6                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-6      ; contour spacing


  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -2.0E-6                    ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-6                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.25E-6      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "divU at 1000mb, s:S:-1:N:, "

  resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
;     resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
