load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega = 7.2921E-5
pi = 3.1415
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

; Find 925hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_925 = -1
nlev_250 = -1
do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 925 then
		nlev_925 = nl
	end if
        if levs_mean(nl) .EQ. 250 then
                nlev_250 = nl
        end if
end do

if (nlev_925 .LT. 0 .OR. nlev_250 .LT. 0) then
	print("didnt find a level")
	exit
end if

print(nlev_925)
print(nlev_250)

U925_notopo = cdf_file->U(0,nlev_925,:,:)
U250_notopo = cdf_file->U(0,nlev_925,:,:)


lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

delete(cdf_file)

U250calc = new((/nexps,nlats,nlons/),"double")
f = new((/nlats,nlons/),"double")

do ilat=0,nlats-1
	f(ilat,:) = 2.0 * omega * sin(lats(ilat) * 2.0 * pi / 360.0)
end do

 ; wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/f_test")

 ; gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap

;  res                   = True                      ; plot mods desired
;  res@cnFillOn             = True                 ; turn on color fill
;  res@cnLinesOn            = False                ; turn off contour lines
;  res@gsnSpreadColors      = True                 ; use full colormap
;  res@gsnSpreadColorStart  = 10                   ; start at color 10
;  res@gsnSpreadColorEnd    = 96                   ; end at color 96
;  res@gsnAddCyclic         = True                 ; add cyclic point
;  res@lbOrientation   = "Vertical"                ; vertical label bar
;
;  plot  = gsn_csm_contour_map_ce (wks,f,res) ; create plot


blank = new(dimsizes(U250_notopo),typeof(U250calc))
blank = 0.0


do iexp = 0,nexps-1

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	Utemp = 0

;loop over levels
	do ilev = nlev_925,nlev_250+1,1

		p1 = cdf_file->lev_p(ilev)
                p2 = cdf_file->lev_p(ilev+1)
		p = (p1 + p2)/ 2.0
		dp = p1 - p2
		print(dp)
		T1 = cdf_file->T(0,ilev,:,:)
                T2 = cdf_file->T(0,ilev+1,:,:)

		dTHdy1 = uv2dv_cfd(blank,T1,lats,lons,1)
                dTHdy2 = uv2dv_cfd(blank,T1,lats,lons,1)

		dTHdy = (dTHdy1 + dTHdy2) / 2.0

		Utemp2 = Utemp + dp * (Rd * (dTHdy / (f * p)))
		delete(Utemp)
		Utemp = Utemp2
	end do

	U250calc(iexp,:,:) = Utemp

	delete(Utemp)		
	delete(cdf_file)

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PS(iexp,:,:) = cdf_file->PS
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8

	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(iexp,ix,iy) .LE. 92500) then
				U250calc(iexp,ix,iy) = U250calc@_FillValue
			end if
		end do
	end do

end do

toplot = new((/nexps,ndims(0),ndims(1)/),typeof(U250calc))

toplot(0,:,:) = U250calc(0,:,:)

do ep=1,nexps-1
	toplot(ep,:,:) = U250calc(ep,:,:)-U250calc(0,:,:)
end do

toplot3 = new((/nexps,ndims(0),ndims(1)/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep=1,nexps-1
	toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do


toplot!1 = "lat"
toplot!2 = "lon"

toplot&lat = lats
toplot&lon = lons

toplot&lat@units="degree_north"
toplot&lon@units="degree_east"

copy_VarCoords(toplot,toplot3)

; plot
; plot one = 850mb

npanels = floattoint(ceil(nexps/2.0))
print(npanels)

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/U250calc_40yrs_ITvsM") 

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
  res@cnMinLevelValF  = -10			; set the minimum contour level
  res@cnMaxLevelValF  = 200.0			; set the maximum contour level
  res@cnLevelSpacingF       = 20.0; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

  res@cnMinLevelValF  = -12			; set the minimum contour level
  res@cnMaxLevelValF  = 12			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing
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
  resP@txString   = "925-250mb thermal wind differences, ms:S:-1"
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
