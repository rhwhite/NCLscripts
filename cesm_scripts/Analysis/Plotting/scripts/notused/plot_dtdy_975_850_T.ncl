load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

Experiments = (/"CESMtopof19","CESMnoTf19","CESMnoT2f19","CESMnoT3f19"/)
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


toplot850 = new((/8,ndims(0),ndims(1)/),typeof(dTHdy850))
toplot850(0,:,:) = dTHdy850(0,:,:)
toplot850(1,:,:) =  dTHdy850(1,:,:) - dTHdy850(2,:,:)
toplot850(2,:,:) =  dTHdy850(1,:,:)
toplot850(3,:,:) =  dTHdy850(0,:,:) - dTHdy850(1,:,:)
toplot850(4,:,:) =  dTHdy850(2,:,:)
toplot850(5,:,:) =  dTHdy850(0,:,:) - dTHdy850(2,:,:)
toplot850(6,:,:) =  dTHdy850(3,:,:)
toplot850(7,:,:) =  dTHdy850(0,:,:) - dTHdy850(3,:,:)

toplot775 = new((/8,ndims(0),ndims(1)/),typeof(dTHdy775))
toplot775(0,:,:) = dTHdy775(0,:,:)
toplot775(1,:,:) =  dTHdy775(1,:,:) - dTHdy775(2,:,:)
toplot775(2,:,:) =  dTHdy775(1,:,:)
toplot775(3,:,:) =  dTHdy775(0,:,:) - dTHdy775(1,:,:)
toplot775(4,:,:) =  dTHdy775(2,:,:)
toplot775(5,:,:) =  dTHdy775(0,:,:) - dTHdy775(2,:,:)
toplot775(6,:,:) =  dTHdy775(3,:,:)
toplot775(7,:,:) =  dTHdy775(0,:,:) - dTHdy775(3,:,:)

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

copy_VarCoords(toplot850,toplot775)

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/dTHdy_850mb_40yrs_TvsM")                  ; open workstation

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
  res@gsnCenterString         = "dTH/dy at 850mb,K/km " + titles(0)  
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005      ; contour spacing
  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005      ; contour spacing
  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005      ; contour spacing
  res@gsnCenterString         = titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot850(4,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(5)  
  plot(5) = gsn_csm_contour_map_ce(wks,toplot850(5,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005      ; contour spacing
  res@gsnCenterString         = titles(6)  
  plot(6) = gsn_csm_contour_map_ce(wks,toplot850(6,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(7)  
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

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/dTHdy_775mb_40yrs_TvsM")                  ; open workstation

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
  res@gsnCenterString         = "dTH/dy at 775mb,K/km " + titles(0)  
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01 			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005     ; contour spacing
  plot(0) = gsn_csm_contour_map_ce(wks,toplot775(0,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(1)  
  plot(1) = gsn_csm_contour_map_ce(wks,toplot775(1,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005     ; contour spacing
  res@gsnCenterString         = titles(2)  
  plot(2) = gsn_csm_contour_map_ce(wks,toplot775(2,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot775(3,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005     ; contour spacing
  res@gsnCenterString         = titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot775(4,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(5)  
  plot(5) = gsn_csm_contour_map_ce(wks,toplot775(5,:,:),res) ;

  res@cnMinLevelValF  = -0.01			; set the minimum contour level
  res@cnMaxLevelValF  = 0.01			; set the maximum contour level
  res@cnLevelSpacingF       = 0.005      ; contour spacing
  res@gsnCenterString         = titles(6)  
  plot(6) = gsn_csm_contour_map_ce(wks,toplot775(6,:,:),res) ;

  res@cnMinLevelValF  = -0.005			; set the minimum contour level
  res@cnMaxLevelValF  = 0.005			; set the maximum contour level
  res@cnLevelSpacingF       = 0.001      ; contour spacing
  res@gsnCenterString         = titles(7)  
  plot(7) = gsn_csm_contour_map_ce(wks,toplot775(7,:,:),res) 

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