load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)


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
filo = Experiments(0) + "/atm/hist/Annual" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
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


filo = Experiments(0) + "/atm/hist/Annual" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

levs_mean = cdf_file->lev_p

; Find 850hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_850 = -1
nlev_925 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 850 then
		nlev_850 = nl
	end if
	if levs_mean(nl) .EQ. 925 then
		nlev_925 = nl
	end if
end do

if (nlev_850 .LT. 0 .OR. nlev_925 .LT. 0) then
	print("didnt find a level")
	exit
end if
T850_mean = cdf_file->T(0,nlev_850,:,:)
T925_mean = cdf_file->T(0,nlev_925,:,:)

lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

TH850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
TH925 = new((/nexps,ndims(0),ndims(1)/),typeof(T925_mean))
U850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
U925 = new((/nexps,ndims(0),ndims(1)/),typeof(T925_mean))
V850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
V925 = new((/nexps,ndims(0),ndims(1)/),typeof(T925_mean))

dTHdy850 = new(dimsizes(TH850),typeof(TH850))
dTHdy925 = new(dimsizes(TH850),typeof(TH850))

dTHdx850 = new(dimsizes(TH850),typeof(TH850))
dTHdx925 = new(dimsizes(TH850),typeof(TH850))




TH850(0,:,:) = T850_mean * (1013/850)^(kappa)
TH850@_FillValue = 9.96921e+36

TH925(0,:,:) = T925_mean * (1013/925)^(kappa)
TH925@_FillValue = 9.96921e+36

U850(0,:,:) = cdf_file->U(0,nlev_850,:,:)
U925(0,:,:) = cdf_file->U(0,nlev_925,:,:)

V850(0,:,:) = cdf_file->V(0,nlev_850,:,:)
V925(0,:,:) = cdf_file->V(0,nlev_925,:,:)


delete(T850_mean)
delete(T925_mean)

delete(cdf_file)


blank = new((/nlats,nlons/),typeof(TH850))
blank = 0.0
print(dimsizes(TH850))

dTHdy850(0,:,:) = -1.0 * uv2dv_cfd(blank,TH850(0,:,:),lats,lons,1)
dTHdy925(0,:,:) = -1.0 * uv2dv_cfd(blank,TH925(0,:,:),lats,lons,1)

dTHdx850(0,:,:) = -1.0 * uv2dv_cfd(TH850(0,:,:),blank,lats,lons,1)
dTHdx925(0,:,:) = -1.0 * uv2dv_cfd(TH925(0,:,:),blank,lats,lons,1)





do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 85000) then
			dTHdx850(0,ix,iy) = dTHdx850@_FillValue
                        dTHdy850(0,ix,iy) = dTHdy850@_FillValue

                        U850(0,ix,iy) = U850@_FillValue
                        V850(0,ix,iy) = V850@_FillValue

		end if
		if (PS(0,ix,iy) .LT. 92500) then
			dTHdx925(0,ix,iy) = dTHdx925@_FillValue
                        dTHdy925(0,ix,iy) = dTHdy925@_FillValue

                        U925(0,ix,iy) = U925@_FillValue
                        V925(0,ix,iy) = V925@_FillValue
		end if
	end do
end do

delete(PS)

do iexp = 1,nexps-1
	filo = Experiments(iexp) + "/atm/hist/Annual" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

	; Check 850hpa levels
	if (levs_mean(nlev_850) .NE. 850) then
		print("850 level is")
		print(levs_mean(nlev_850))
		exit
	end if
	if (levs_mean(nlev_925) .NE. 925) then
		print("925 level is")
		print(levs_mean(nlev_925))
		exit
	end if

	T850_mean = cdf_file->T(0,nlev_850,:,:)

	TH850(iexp,:,:) = T850_mean * (1013/850)^(kappa)
	delete(T850_mean)

	T925_mean = cdf_file->T(0,nlev_925,:,:)

	TH925(iexp,:,:) = T925_mean * (1013/925)^(kappa)
	delete(T925_mean)	

        U850(iexp,:,:) = cdf_file->U(0,nlev_850,:,:)
        V850(iexp,:,:) = cdf_file->V(0,nlev_850,:,:)

        U925(iexp,:,:) = cdf_file->U(0,nlev_925,:,:)
        V925(iexp,:,:) = cdf_file->V(0,nlev_925,:,:)

	delete(cdf_file)

	filo = Experiments(iexp) + "/atm/hist/Annual" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PS = cdf_file->PS
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	dTHdy850(iexp,:,:) = -1.0 * uv2dv_cfd(blank,TH850(iexp,:,:),lats,lons,1)
	dTHdy925(iexp,:,:) = -1.0 * uv2dv_cfd(blank,TH925(iexp,:,:),lats,lons,1)

	dTHdx850(iexp,:,:) = -1.0 * uv2dv_cfd(TH850(iexp,:,:),blank,lats,lons,1)
	dTHdx925(iexp,:,:) = -1.0 * uv2dv_cfd(TH925(iexp,:,:),blank,lats,lons,1)



	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(0,ix,iy) .LE. 85000) then
				dTHdx850(iexp,ix,iy) = dTHdx850@_FillValue
                                dTHdy850(iexp,ix,iy) = dTHdy850@_FillValue

                                U850(iexp,ix,iy) = U850@_FillValue
                                V850(iexp,ix,iy) = V850@_FillValue

			end if
			if (PS(0,ix,iy) .LE. 92500) then
				dTHdx925(iexp,ix,iy) = dTHdx925@_FillValue
                                dTHdy925(iexp,ix,iy) = dTHdy925@_FillValue

                                U925(iexp,ix,iy) = U925@_FillValue
                                V925(iexp,ix,iy) = V925@_FillValue
			end if
		end do
	end do

	delete(PS)

end do

toplot850 = new((/nexps,nlats,nlons/),typeof(TH850))
toplot925 = new((/nexps,nlats,nlons/),typeof(TH850))

toplot850(0,:,:) = (U850(0,:,:) * dTHdx850(0,:,:)) + V850(0,:,:) * dTHdy850(0,:,:)
toplot925(0,:,:) = (U925(0,:,:) * dTHdx925(0,:,:)) + V925(0,:,:) * dTHdy925(0,:,:)


do ep=1,nexps-1
	toplot850(ep,:,:) = (U850(ep,:,:) * dTHdx850(ep,:,:)) - (U850(0,:,:) * dTHdx850(0,:,:)) + (V850(ep,:,:) * dTHdy850(ep,:,:)) - (V850(0,:,:) * dTHdy850(0,:,:))
	toplot925(ep,:,:) = (U925(ep,:,:) * dTHdx925(ep,:,:)) - (U925(0,:,:) * dTHdx925(0,:,:)) + (V925(ep,:,:) * dTHdy925(ep,:,:)) - (V925(0,:,:) * dTHdy925(0,:,:))

end do

toplot3 = new((/nexps,nlats,nlons/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep = 1,nexps-1
        toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do

toplot850!1 = "lat"
toplot850!2 = "lon"

toplot850&lat = lats
toplot850&lon = lons

toplot850&lat@units="degree_north"
toplot850&lon@units="degree_east"

copy_VarCoords(toplot850,toplot3)
copy_VarCoords(toplot850,toplot925)

; plot
; plot one = 850mb

npanels = floattoint(ceil(nexps/2.0))
print(npanels)

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Tadv_Ann_850_40yrs_ITvsM")                  ; open workstation

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
  res@cnMinLevelValF  = -5E-4			; set the minimum contour level
  res@cnMaxLevelValF  = 5E-4			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;
  
  res@cnMinLevelValF  = -1.0E-4                    ; set the minimum contour level
  res@cnMaxLevelValF  = 1.0E-4                     ; set the maximum contour level
  res@cnLevelSpacingF       = 2.0E-5      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot850(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "Tadv at 850mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

;plot 2: 925mb


  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Tadv_Ann_925_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -5.0E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 5.0E-4                  ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0E-4      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot925(0,:,:),res) ;

  res@cnMinLevelValF  = -1.0E-4                    ; set the minimum contour level
  res@cnMaxLevelValF  = 1.0E-4                     ; set the maximum contour level
  res@cnLevelSpacingF       = 2.0E-5      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot925(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPaperOrientation = "landscape"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  resP@txString   = "Tadv at 925mb, Ks:S:-1:N:"

;      resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
      resP@amJust   = "TopLeft"
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end

