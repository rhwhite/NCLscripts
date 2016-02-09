load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

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
filo = Experiments(0) + "/atm/hist/Z850_bpf_varDJF_" + tostring(nyears) + "_" + Experiments(0) + ".cam2.h1.nc"
cdf_file = addfile(diro + filo, "r")

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

Z850var = new((/nexps,nlats,nlons/),typeof(cdf_file->Z850bpf_var))
PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file->Z850bpf_var))


Z850var(0,:,:) = cdf_file->Z850bpf_var

delete(cdf_file)


filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

PS = cdf_file->PS
PHIS(0,:,:) = cdf_file->PHIS/9.8

delete(cdf_file)

do iy = 0,nlons-1
        do ix = 0,nlats-1
                if (PS(0,ix,iy) .LT. 85000) then
                        Zvar850(0,ix,iy) = Zvar850@_FillValue
                end if
        end do
end do

delete(PS)





do iexp = 1,nexps-1
	filo =  Experiments(iexp) + "/atm/hist/Z850_bpf_varDJF_" + tostring(nyears) + "_" + Experiments(iexp) + ".cam2.h1.nc"

	cdf_file = addfile(diro + filo, "r")
	
	Z850var(iexp,:,:) = cdf_file->Z850bpf_var
	delete(cdf_file)

        filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
        cdf_file = addfile(diro + filo, "r")
        PS = cdf_file->PS

        PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

        do iy = 0,nlons-1
                do ix = 0,nlats-1
                        if (PS(0,ix,iy) .LE. 85000) then
                               Z850var(iexp,ix,iy) = Z850var@_FillValue
                        end if
                end do
        end do

        delete(PS)
        delete(cdf_file)

end do

toplot = new((/nexps,nlats,nlons/),typeof(Z850var))

toplot(0,:,:) = Z850var(0,:,:)

do ep = 1,nexps-1
        toplot(ep,:,:) = Z850var(ep,:,:) - Z850var(0,:,:)
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

npanels = floattoint(ceil(nexps/2.0))

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/Zvar850_40yrs_ITvsM")   ; open workstation

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

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2800.0			; set the maximum contour level
  res@cnLevelSpacingF       = 200.0      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -400.0                 ; set the minimum contour level
  res@cnMaxLevelValF  = 400.0                   ; set the maximum contour level
  res@cnLevelSpacingF       = 50.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do
  
resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "Variance of Z at 850mb, m:S:2:N:, "

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end
