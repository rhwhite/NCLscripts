load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

Experiments = (/"CESMtopof19","CESMnoRT2f19","CESMnoRf19","CESMnoT2f19"/);,"CESMnotopof19"

print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

print("file read in")

levs_mean = cdf_file->lev_p

; Find 775 and 850hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_775 = -1
nlev_850 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 775 then
		nlev_775 = nl
	end if
	if levs_mean(nl) .EQ. 850 then
		nlev_850 = nl
	end if
end do

if (nlev_775 .LT. 0 .OR. nlev_850 .LT. 0) then
	print("didnt find a level")
	exit
end if

T850_mean = cdf_file->T(0,nlev_850,:,:)
T775_mean = cdf_file->T(0,nlev_775,:,:)

lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)
ndims = dimsizes(T850_mean)
TH850 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
TH775 = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))
PHIS = new((/nexps,ndims(0),ndims(1)/),typeof(T850_mean))


TH850(0,:,:) = T850_mean * (1013/850)^(kappa)
TH775(0,:,:) = T775_mean * (1013/775)^(kappa)
TH850@_FillValue = 9.96921e+36
TH775@_FillValue = 9.96921e+36


delete(T850_mean)
delete(T775_mean)

delete(cdf_file)


diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

PS = cdf_file->PS
print(dimsizes(PS))

do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LE. 85000) then
			TH850(0,ix,iy) = TH850@_FillValue
		end if
		if (PS(0,ix,iy) .LE. 77500) then
			TH775(0,ix,iy) = TH775@_FillValue
		end if
	end do
end do


delete(cdf_file)
delete(PS)

do iexp = 1,nexps-1

	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"

	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

	; Check 775 and 850hpa levels
	if (levs_mean(nlev_775) .NE. 775) then
		print("775 level is")
		print(levs_mean(nlev_775))
		exit
	end if
	if (levs_mean(nlev_850) .NE. 850) then
		print("850 level is")
		print(levs_mean(nlev_850))
		exit
	end if

	T850_mean = cdf_file->T(0,nlev_850,:,:)
	T775_mean = cdf_file->T(0,nlev_775,:,:)

	TH850(iexp,:,:) = T850_mean * (1013/850)^(kappa)
	TH775(iexp,:,:) = T775_mean * (1013/775)^(kappa)

	delete(T850_mean)
	delete(T775_mean)
	
	delete(cdf_file)


	diro = "/home/disk/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PS = cdf_file->PS
	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8
	do iy = 0,nlons-1
		do ix = 0,nlats-1
			if (PS(0,ix,iy) .LE. 85000) then
				TH850(iexp,ix,iy) = TH850@_FillValue
			end if
			if (PS(0,ix,iy) .LE. 77500) then
				TH775(iexp,ix,iy) = TH775@_FillValue
			end if
		end do
	end do

	delete(PS)

end do

dTHdy850 = new(dimsizes(TH850),typeof(TH850))
dTHdy775 = new(dimsizes(TH850),typeof(TH850))

do ilat = 1,nlats-2
	do ilon = 1,nlons-2

		temp = gc_latlon(lats(ilat-1),lons(ilon),lats(ilat),lons(ilon),2,4)
		dy = tofloat(temp@spacing)
		dTHdy850(:,ilat,ilon) = (0.5/dy) * (TH850(:,ilat+1,ilon) - TH850(:,ilat-1,ilon))
		dTHdy775(:,ilat,ilon) = (0.5/dy) * (TH775(:,ilat+1,ilon) - TH775(:,ilat-1,ilon))

	end do
end do


do ilat = 1,nlats-2
	temp = gc_latlon(lats(ilat-1),lons(ilon),lats(ilat),lons(ilon),2,4)
	dy = tofloat(temp@spacing)

	dTHdy850(:,ilat,0) = (0.5/dy) * (TH850(:,ilat+1,0) - TH850(:,ilat-1,0))
	dTHdy850(:,ilat,nlons-1) = (0.5/dy) * (TH850(:,ilat+1,nlons-2) - TH850(:,ilat-1,nlons-2))
	dTHdy775(:,ilat,0) = (0.5/dy) * (TH775(:,ilat+1,0) - TH775(:,ilat-1,0))
	dTHdy775(:,ilat,nlons-1) = (0.5/dy) * (TH775(:,ilat+1,nlons-2) - TH775(:,ilat-1,nlons-2))

end do


toplot850 = new((/5,ndims(0),ndims(1)/),typeof(dTHdy850))
toplot850(0,:,:) = dTHdy850(0,:,:)
toplot850(1,:,:) =  dTHdy850(0,:,:) - dTHdy850(1,:,:)
toplot850(2,:,:) =  dTHdy850(0,:,:) - dTHdy850(2,:,:)
toplot850(3,:,:) =  dTHdy850(0,:,:) - dTHdy850(3,:,:)
toplot850(4,:,:) =  toplot850(1,:,:) - toplot850(2,:,:) - toplot850(3,:,:)

toplot775 = new((/5,ndims(0),ndims(1)/),typeof(dTHdy775))
toplot775(0,:,:) = dTHdy775(0,:,:)
toplot775(1,:,:) =  dTHdy775(0,:,:) - dTHdy775(1,:,:)
toplot775(2,:,:) =  dTHdy775(0,:,:) - dTHdy775(2,:,:)
toplot775(3,:,:) =  dTHdy775(0,:,:) - dTHdy775(3,:,:)
toplot775(4,:,:) =  toplot775(1,:,:) - toplot775(2,:,:) - toplot775(3,:,:)

toplot3 = new((/5,ndims(0),ndims(1)/),typeof(PHIS))
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

copy_VarCoords(toplot850,toplot775)
copy_VarCoords(toplot850,toplot3)

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/dTHdy_850mb_40yrs_RT2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(6,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = "dTH/dy at 850mb,K/km " + titles(0)  
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.002      ; contour spacing
  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;

  res@cnMinLevelValF  = -0.0025			; set the minimum contour level
  res@cnMaxLevelValF  = 0.0025			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0005      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

  res@cnMinLevelValF  = -0.001			; set the minimum contour level
  res@cnMaxLevelValF  = 0.001			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0002      ; contour spacing
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

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/dTHdy_775mb_40yrs_RT2")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(6,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@gsnCenterString         = "dTH/dy at 775mb,K/km " + titles(0)  
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01 			; set the maximum contour level
  res@cnLevelSpacingF       = 0.002     ; contour spacing
  plot(0) = gsn_csm_contour_map_ce(wks,toplot775(0,:,:),res) ;

  res@cnMinLevelValF  = -0.0025			; set the minimum contour level
  res@cnMaxLevelValF  = 0.0025			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0005      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot775(1,:,:),res) ;

  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot775(2,:,:),res) ;

  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot775(3,:,:),res) ;

  res@cnMinLevelValF  = -0.001			; set the minimum contour level
  res@cnMaxLevelValF  = 0.001			; set the maximum contour level
  res@cnLevelSpacingF       = 0.0002      ; contour spacing
  res@gsnCenterString         = titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot775(4,:,:),res) ;

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