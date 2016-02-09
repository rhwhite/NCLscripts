load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)


Experiments = (/"CESMnotopof19","CESM_onlyIM2","CESM_onlyITSh","CESM_onlyIT","CESM_onlyIT2","CESM_onlyITVVS","CESM_onlyIT4"/)

print(Experiments)

nexps = dimsizes(Experiments)

titles = new((/nexps/),typeof(Experiments))
titles(0) =  "NoTopo"
titles(1) =  "Thin Altai - NoTopo"
titles(2) =  "Thick Altai - NoTopo"
titles(3) =  "Tibet - NoTopo"
titles(4) =  "Thick high Altai - NoTopo"
titles(5) =  "Thick short Altai - NoTopo"
titles(6) =  "Thick narrow Altai - NoTopo"


diro = "/home/disk/rachel/CESM_outfiles/"
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

TS_mean = cdf_file->TS(0,:,:)
PS_mean = cdf_file->PS(0,:,:) / 100.0

ndims = dimsizes(TS_mean)
lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

TH = new((/nexps,nlats,nlons/),typeof(TS_mean))
TS = new((/nexps,nlats,nlons/),typeof(TS_mean))
PS = new((/nexps,nlats,nlons/),typeof(PS_mean))
PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file->PHIS))

PS(0,:,:) = cdf_file->PS
PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

TH(0,:,:) = TS_mean * (1013/PS_mean)^(kappa)
TS(0,:,:) = TS_mean

delete(TS_mean)
delete(PS_mean)
delete(cdf_file)


filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

levs_mean = cdf_file->lev_p

; Find 850hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_850 = -1
nlev_250 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 850 then
		nlev_850 = nl
	end if
	if levs_mean(nl) .EQ. 250 then
		nlev_250 = nl
	end if
end do

if (nlev_850 .LT. 0 .OR. nlev_250 .LT. 0) then
	print("didnt find a level")
	exit
end if
T850_mean = cdf_file->T(0,nlev_850,:,:)
T250_mean = cdf_file->T(0,nlev_250,:,:)

lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

TH850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
TH250 = new((/nexps,ndims(0),ndims(1)/),typeof(T250_mean))
U850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
U250 = new((/nexps,ndims(0),ndims(1)/),typeof(T250_mean))
V850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
V250 = new((/nexps,ndims(0),ndims(1)/),typeof(T250_mean))

dTHdy850 = new(dimsizes(TH850),typeof(TH850))
dTHdy250 = new(dimsizes(TH850),typeof(TH850))

dTHdx850 = new(dimsizes(TH850),typeof(TH850))
dTHdx250 = new(dimsizes(TH850),typeof(TH850))




TH850(0,:,:) = T850_mean * (1013/850)^(kappa)
TH850@_FillValue = 9.96921e+36

TH250(0,:,:) = T250_mean * (1013/250)^(kappa)
TH250@_FillValue = 9.96921e+36

U850(0,:,:) = cdf_file->U(0,nlev_850,:,:)
U250(0,:,:) = cdf_file->U(0,nlev_250,:,:)

V850(0,:,:) = cdf_file->V(0,nlev_850,:,:)
V250(0,:,:) = cdf_file->V(0,nlev_250,:,:)


delete(T850_mean)
delete(T250_mean)

delete(cdf_file)


blank = new((/nlats,nlons/),typeof(TH850))
blank = 0.0
print(dimsizes(TH850))

dTHdy850(0,:,:) = -1.0 * uv2dv_cfd(blank,TH850(0,:,:),lats,lons,1)
dTHdy250(0,:,:) = -1.0 * uv2dv_cfd(blank,TH250(0,:,:),lats,lons,1)

dTHdx850(0,:,:) = -1.0 * uv2dv_cfd(TH850(0,:,:),blank,lats,lons,1)
dTHdx250(0,:,:) = -1.0 * uv2dv_cfd(TH250(0,:,:),blank,lats,lons,1)





do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 85000) then
			dTHdx850(0,ix,iy) = dTHdx850@_FillValue
                        dTHdy850(0,ix,iy) = dTHdy850@_FillValue

                        U850(0,ix,iy) = U850@_FillValue
                        V850(0,ix,iy) = V850@_FillValue

		end if
		if (PS(0,ix,iy) .LT. 25000) then
			dTHdx250(0,ix,iy) = dTHdx250@_FillValue
                        dTHdy250(0,ix,iy) = dTHdy250@_FillValue

                        U250(0,ix,iy) = U250@_FillValue
                        V250(0,ix,iy) = V250@_FillValue
		end if
	end do
end do

delete(PS)

do iexp = 1,nexps-1
	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

	; Check 850hpa levels
	if (levs_mean(nlev_850) .NE. 850) then
		print("850 level is")
		print(levs_mean(nlev_850))
		exit
	end if
	if (levs_mean(nlev_250) .NE. 250) then
		print("250 level is")
		print(levs_mean(nlev_250))
		exit
	end if

	T850_mean = cdf_file->T(0,nlev_850,:,:)

	TH850(iexp,:,:) = T850_mean * (1013/850)^(kappa)
	delete(T850_mean)

	T250_mean = cdf_file->T(0,nlev_250,:,:)

	TH250(iexp,:,:) = T250_mean * (1013/250)^(kappa)
	delete(T250_mean)	

        U850(iexp,:,:) = cdf_file->U(0,nlev_850,:,:)
        V850(iexp,:,:) = cdf_file->V(0,nlev_850,:,:)

        U250(iexp,:,:) = cdf_file->U(0,nlev_250,:,:)
        V250(iexp,:,:) = cdf_file->V(0,nlev_250,:,:)

	delete(cdf_file)

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PS = cdf_file->PS
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	dTHdy850(iexp,:,:) = -1.0 * uv2dv_cfd(blank,TH850(iexp,:,:),lats,lons,1)
	dTHdy250(iexp,:,:) = -1.0 * uv2dv_cfd(blank,TH250(iexp,:,:),lats,lons,1)

	dTHdx850(iexp,:,:) = -1.0 * uv2dv_cfd(TH850(iexp,:,:),blank,lats,lons,1)
	dTHdx250(iexp,:,:) = -1.0 * uv2dv_cfd(TH250(iexp,:,:),blank,lats,lons,1)



	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(0,ix,iy) .LE. 85000) then
				dTHdx850(iexp,ix,iy) = dTHdx850@_FillValue
                                dTHdy850(iexp,ix,iy) = dTHdy850@_FillValue

                                U850(iexp,ix,iy) = U850@_FillValue
                                V850(iexp,ix,iy) = V850@_FillValue

			end if
			if (PS(0,ix,iy) .LE. 25000) then
				dTHdx250(iexp,ix,iy) = dTHdx250@_FillValue
                                dTHdy250(iexp,ix,iy) = dTHdy250@_FillValue

                                U250(iexp,ix,iy) = U250@_FillValue
                                V250(iexp,ix,iy) = V250@_FillValue
			end if
		end do
	end do

	delete(PS)

end do

toplotU850 = new((/nexps,nlats,nlons/),typeof(TH850))
toplotU250 = new((/nexps,nlats,nlons/),typeof(TH850))
toplotV850 = new((/nexps,nlats,nlons/),typeof(TH850))
toplotV250 = new((/nexps,nlats,nlons/),typeof(TH850))
toplotUV850 = new((/nexps,nlats,nlons/),typeof(TH850))
toplotUV250 = new((/nexps,nlats,nlons/),typeof(TH850))



toplotU850(0,:,:) = U850(0,:,:) * dTHdx850(0,:,:)
toplotU250(0,:,:) = U250(0,:,:) * dTHdx250(0,:,:)

toplotV850(0,:,:) = V850(0,:,:) * dTHdy850(0,:,:)
toplotV250(0,:,:) = V250(0,:,:) * dTHdy250(0,:,:)


toplotUV850(0,:,:) = (U850(0,:,:) * dTHdx850(0,:,:) +  V850(0,:,:) * dTHdy850(0,:,:))
toplotUV250(0,:,:) = (U250(0,:,:) * dTHdx250(0,:,:) + V250(0,:,:) * dTHdy250(0,:,:))


do ep=1,nexps-1
	toplotU850(ep,:,:) = (U850(ep,:,:) - U850(0,:,:)) * dTHdx850(0,:,:)
	toplotU250(ep,:,:) = (U250(ep,:,:) - U250(0,:,:)) * dTHdx250(0,:,:)

	toplotV850(ep,:,:) = (V850(ep,:,:) - V850(0,:,:)) * dTHdy850(0,:,:)
	toplotV250(ep,:,:) = (V250(ep,:,:) - V250(0,:,:)) * dTHdy250(0,:,:)

        toplotUV850(ep,:,:) = ((U850(ep,:,:) - U850(0,:,:)) * dTHdx850(0,:,:) + (V850(ep,:,:) - V850(0,:,:)) * dTHdy850(0,:,:))
        toplotUV250(ep,:,:) = ((U250(ep,:,:) - U250(0,:,:)) * dTHdx250(0,:,:) + (V250(ep,:,:) - V250(0,:,:)) * dTHdy250(0,:,:))



end do

toplot3 = new((/nexps,nlats,nlons/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep = 1,nexps-1
        toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do

toplotU850!1 = "lat"
toplotU850!2 = "lon"

toplotU850&lat = lats
toplotU850&lon = lons

toplotU850&lat@units="degree_north"
toplotU850&lon@units="degree_east"

copy_VarCoords(toplotU850,toplot3)
copy_VarCoords(toplotU850,toplotU250)
copy_VarCoords(toplotU850,toplotV850)
copy_VarCoords(toplotU850,toplotV250)
copy_VarCoords(toplotU850,toplotUV850)
copy_VarCoords(toplotU850,toplotUV250)


; plot
; plot one = 850mb

npanels = floattoint(ceil(nexps/2.0))
print(npanels)

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/UdashdThdx_850_40yrs_ITvsM")                  ; open workstation

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

  resOv                  = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels
  res@cnMinLevelValF  = -2E-5			; set the minimum contour level
  res@cnMaxLevelValF  = 2E-5			; set the maximum contour level
  res@cnLevelSpacingF       = 0.25E-5      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotU850(0,:,:),res) ;
  
  res@cnMinLevelValF  = -1.0E-5                    ; set the minimum contour level
  res@cnMaxLevelValF  = 1.0E-5                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.125E-5      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotU850(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F25:U':F25:d:F33:q:F25:/dx:F25: at 850mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

;plot 2: 250mb


  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/UdashdTHdx_250_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -2.0E-5                   ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-5                  ; set the maximum contour level
  res@cnLevelSpacingF       = 0.25E-5      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotU250(0,:,:),res) ;

  res@cnMinLevelValF  = -1.0E-5                    ; set the minimum contour level
  res@cnMaxLevelValF  = 1.0E-5                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.125E-5      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotU250(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F25:U':F25:d:F33:q:F25:/dx:F25: at 250mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

;plot 3 V850

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/VdashdTHdy_850_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -4.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotV850(0,:,:),res) ;

  res@cnMinLevelValF  = -2.0E-4                ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-4                    ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotV850(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F25:V':F25:d:F33:q:F25:/dy:F25: at 850mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 4 V250


  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/VdashdTHdy_250_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -4.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotV250(0,:,:),res) ;
  
  res@cnMinLevelValF  = -2.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.25E-4      ; contour spacing


do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotV250(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F25:V':F25:d:F33:q:F25:/dy:F25: at 250mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 4 V250


  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/UVdashdTHdy_250_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -4.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotUV250(0,:,:),res) ;

  res@cnMinLevelValF  = -4.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing


do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotUV250(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F26:U':F18:V:F25:d:F33:q:F25:/d:F26:x:F25: at 250mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


;plot 3 V850

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/UVdashdTHdy_850_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -4.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 4.0E-4                   ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplotUV850(0,:,:),res) ;

  res@cnMinLevelValF  = -2.0E-4                ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0E-4                    ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5E-4      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplotUV850(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "- :F26:U':F18:V:F25:d:F33:q:F25:/d:F26:x:F25: at 850mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)




end
