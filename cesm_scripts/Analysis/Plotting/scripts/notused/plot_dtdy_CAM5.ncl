load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

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

TH = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))
TS = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))
PS = new((/nexps,ndims(0),ndims(1)/),typeof(PS_mean))
PHIS = new((/nexps,ndims(0),ndims(1)/),typeof(cdf_file->PHIS))

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
nlev_925 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 850 then
		nlev_850 = nl
	end if
end do

if (nlev_850 .LT. 0) then
	print("didnt find a level")
	exit
end if
T850_mean = cdf_file->T(0,nlev_850,:,:)

lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

TH850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))


TH850(0,:,:) = T850_mean * (1013/850)^(kappa)
TH850@_FillValue = 9.96921e+36


delete(T850_mean)

delete(cdf_file)

do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 85000) then
			TH850(0,ix,iy) = TH850@_FillValue
		end if
	end do
end do

delete(PS)

do iexp = 1,nexps-1
	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	TS_mean = cdf_file->TS(0,:,:)
	PS_mean = cdf_file->PS(0,:,:)/100.0
	
	TH(iexp,:,:) = TS_mean * (1013/PS_mean)^(kappa)
	TS(iexp,:,:) = TS_mean

	delete(TS_mean)
	delete(PS_mean)
	
	delete(cdf_file)


	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

	; Check 850hpa levels
	if (levs_mean(nlev_850) .NE. 850) then
		print("850 level is")
		print(levs_mean(nlev_850))
		exit
	end if

	T850_mean = cdf_file->T(0,nlev_850,:,:)

	TH850(iexp,:,:) = T850_mean * (1013/850)^(kappa)
	delete(T850_mean)
	
	delete(cdf_file)

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PS = cdf_file->PS
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(0,ix,iy) .LE. 85000) then
				TH850(iexp,ix,iy) = TH850@_FillValue
			end if
		end do
	end do

	delete(PS)

end do

dTHdy850 = new(dimsizes(TH850),typeof(TH850))
dTHdySURF = new(dimsizes(TH),typeof(TH))

blank = new(dimsizes(TH850),typeof(TH850))
blank = 0.0
print(dimsizes(TH850))

dTHdy850 = uv2dv_cfd(blank,TH850,lats,lons,1)
dTHdySURF = uv2dv_cfd(blank,TH,lats,lons,1)

do iexp = 1,nexps-1
        do iy = 0,nlons-1
                do ix = 0,nlats-1
                        if abs(PHIS(0,ix,iy) - PHIS(iexp,ix,iy)) .GT. 0.1 then
                                dTHdySURF(iexp,ix,iy) = dTHdySURF@_FillValue
                        end if
                end do
        end do
end do



toplot = new((/nexps,ndims(0),ndims(1)/),typeof(dTHdy850))
toplot2 = new((/nexps,ndims(0),ndims(1)/),typeof(dTHdy850))
toplot3 = new((/nexps,ndims(0),ndims(1)/),typeof(PHIS))

toplot(0,:,:) = dTHdy850(0,:,:)
toplot(1,:,:) = dTHdy850(1,:,:)

toplot2(0,:,:) = dTHdySURF(0,:,:)
toplot2(1,:,:) = dTHdySURF(1,:,:)

toplot3(0,:,:) =  0.0
toplot3(1,:,:) =  0.0

do ep = 2,(nexps/2)
	toplot((ep*2)-2,:,:) = dTHdy850(0,:,:) - dTHdy850((ep*2)-2,:,:)
        toplot((ep*2)-1,:,:) = dTHdy850(1,:,:) - dTHdy850((ep*2)-1,:,:)

	toplot2((ep*2)-1,:,:) = dTHdySURF(0,:,:) - dTHdySURF((ep*2)-2,:,:)
        toplot2((ep*2)-1,:,:) = dTHdySURF(1,:,:) - dTHdySURF((ep*2)-1,:,:)

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



; plot
; plot one = 850mb

npanels = floattoint(ceil(nexps/2.0))
print(npanels)

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/TvM/dTdy_850_40yrs_CAM5") 

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

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels
  res@cnMinLevelValF  = -1E-4			; set the minimum contour level
  res@cnMaxLevelValF  = 0.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1E-5; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -2E-6			; set the minimum contour level
  res@cnMaxLevelValF  = 2E-6			; set the maximum contour level
  res@cnLevelSpacingF       = 4E-7      ; contour spacing
  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@txString   = "DJF dTH/dy at 850mb, Km:S:-1:N:"
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

  resP@gsnDraw = False                           ; draw later, in maximize mode
;  resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

;  delete(resP@gsnPanelFigureStrings)
  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)

; plot 2, surface
  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/TvM/dTdy_SFC_40yrs_CAM5")  

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

  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels
  res@cnMinLevelValF  = -1E-4                   ; set the minimum contour level
  res@cnMaxLevelValF  = 0                    ; set the maximum contour level
  res@cnLevelSpacingF       = 1E-5; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot2(0,:,:),res) ;

  res@cnMinLevelValF  = -4E-6                  ; set the minimum contour level
  res@cnMaxLevelValF  = 4E-6                   ; set the maximum contour level
  res@cnLevelSpacingF       = 5E-7      ; contour spacing
  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot2(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do


  resP                  = True                   ; modify the panel plot
  resP@txString   = "DJF dTH/dy at surface, Km:S:-1:N:"  
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

  resP@gsnDraw = False                           ; draw later, in maximize mode
;  resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

;  delete(resP@gsnPanelFigureStrings)
  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)

end
