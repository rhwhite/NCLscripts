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

TS_mean = cdf_file->TREFHT(0,:,:)

ndims = dimsizes(TS_mean)
lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

TS = new((/nexps,ndims(0),ndims(1)/),typeof(TS_mean))
PHIS = new((/nexps,ndims(0),ndims(1)/),typeof(cdf_file->PHIS))

PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

TS(0,:,:) = TS_mean

delete(TS_mean)

delete(cdf_file)


do iexp = 1,nexps-1
	filo =  Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	TS(iexp,:,:) = cdf_file->TREFHT(0,:,:)
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	delete(cdf_file)

	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if abs(PHIS(0,ix,iy) - PHIS(iexp,ix,iy)) .GT. 0.1 then
				TS(iexp,ix,iy) = TS@_FillValue
			end if
		end do
	end do


end do


toplot = new((/nexps,ndims(0),ndims(1)/),typeof(TS))
toplot3 = new((/nexps,ndims(0),ndims(1)/),typeof(PHIS))

toplot(0,:,:) = TS(0,:,:)
toplot(1,:,:) = TS(1,:,:)

toplot3(0,:,:) =  0.0
toplot3(1,:,:) =  0.0


do ep = 2,(nexps/2)
	toplot((ep*2)-2,:,:) = TS(0,:,:) - TS((ep*2)-2,:,:)
        toplot((ep*2)-1,:,:) = TS(1,:,:) - TS((ep*2)-1,:,:)
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


npanels = floattoint(ceil(nexps/2.0))

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/TvM/TS_40yrs_CAM5")                  ; open workstation

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
  
  res@gsnLeftString  = ""
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 250.0			; set the minimum contour level
  res@cnMaxLevelValF  = 310.0			; set the maximum contour level
  res@cnLevelSpacingF       = 5.0      ; contour spacing

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

  res@gsnCenterString       = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;
  plot(1) = gsn_csm_contour_map_ce(wks,toplot(1,:,:),res) ;

  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.25      ; contour spacing

do pp = 2,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do

  resP                  = True                   ; modify the panel plot
  resP@txString   = "DJF TS, K"
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode

;     resP@gsnPanelFigureStrings= (/"a.","b.","c.","d.","e.","f","g","h"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
     resP@amJust   = "TopLeft"
     panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

      delete(resP@gsnPanelFigureStrings)
  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end
