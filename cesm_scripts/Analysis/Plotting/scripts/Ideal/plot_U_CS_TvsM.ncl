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
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
filo2 = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")
cdf_file2 = addfile(diro + filo2, "r")

ndims = dimsizes(cdf_file->U)
lats = cdf_file->lat
lons = cdf_file->lon
nlats = dimsizes(lats)
nlons = dimsizes(lons)
nlevs = ndims(1)

levs_mean = cdf_file->lev_p

U = new((/nexps,nlevs,nlats,nlons/),typeof(cdf_file->U))
PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file2->PHIS))

U(0,:,:,:) = cdf_file->U(0,:,:,:)
PHIS(0,:,:) = cdf_file2->PHIS(0,:,:)
PS = cdf_file2->PS(0,:,:) / 100.0

delete(cdf_file)

do iy = 0,nlons-1
        do ix = 0,nlats-1
                do il = 0,nlevs -1
                        if (PS(ix,iy) .LT. levs_mean(il)) then
                                U(0,il,ix,iy) = U@_FillValue
                        end if
                end do
        end do
end do



do iexp = 1,nexps-1

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"
	filo2 = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")
	cdf_file2 = addfile(diro + filo2, "r")

	U(iexp,:,:,:) = cdf_file->U(0,:,:,:)
	PHIS(iexp,:,:) = cdf_file2->PHIS(0,:,:)
	PS = cdf_file2->PS(0,:,:) / 100.0
	
	delete(cdf_file)
	delete(cdf_file2)

	do iy = 0,nlons-1
        	do ix = 0,nlats-1
                	do il = 0,nlevs -1
				if (PS(ix,iy) .LT. levs_mean(il)) then
                        		U(iexp,il,ix,iy) = U@_FillValue
                		end if
			end do
        	end do
	end do

end do


; find longitudes: between 50 and 70E

do nl = 0,nlons-2
	if lons(nl) .LE. 50.0 .AND. lons(nl+1) .GT. 50.0 then
		nlonstart = nl
	end if
	if lons(nl) .LE. 70.0 .AND. lons(nl+1) .GT. 70.0 then
		nlonend = nl+1
	end if
end do

print(nlonstart * 1)
print(nlonend * 1)

U_CS_US = dim_avg_n(U(:,:,:,nlonstart:nlonend),3)

delete(nlonstart)
delete(nlonend)

; find longitudes: between 90 and 110E

do nl = 0,nlons-2
	if lons(nl) .LE. 90.0 .AND. lons(nl+1) .GT. 90.0 then
		nlonstart = nl
	end if
	if lons(nl) .LE. 110.0 .AND. lons(nl+1) .GT. 110.0 then
		nlonend = nl+1
	end if
end do

print(nlonstart * 1)
print(nlonend * 1)

U_CS_MNT = dim_avg_n(U(:,:,:,nlonstart:nlonend),3)

delete(nlonstart)
delete(nlonend)

; find longitudes: between 130 and 150E

do nl = 0,nlons-2
	if lons(nl) .LE. 130.0 .AND. lons(nl+1) .GT. 130.0 then
		nlonstart = nl
	end if
	if lons(nl) .LE. 150.0 .AND. lons(nl+1) .GT. 150.0 then
		nlonend = nl+1
	end if
end do


print(nlonstart * 1)
print(nlonend * 1)

U_CS_DS = dim_avg_n(U(:,:,:,nlonstart:nlonend),3)

delete(nlonstart)
delete(nlonend)

toplot_US = new((/nexps,nlevs,nlats/),typeof(U_CS_US))
toplot_MNT = new((/nexps,nlevs,nlats/),typeof(U_CS_US))
toplot_DS = new((/nexps,nlevs,nlats/),typeof(U_CS_US))

toplot_US(0,:,:) =  U_CS_US(0,:,:)
toplot_MNT(0,:,:) =  U_CS_MNT(0,:,:)
toplot_DS(0,:,:) =  U_CS_DS(0,:,:)

do ep=1,nexps-1
        toplot_US(ep,:,:) = U_CS_US(ep,:,:) - U_CS_US(0,:,:)
        toplot_MNT(ep,:,:) = U_CS_MNT(ep,:,:) - U_CS_MNT(0,:,:)
        toplot_DS(ep,:,:) = U_CS_DS(ep,:,:) - U_CS_DS(0,:,:)
end do

toplot_US!1 = "lev"
toplot_US!2 = "lat"

toplot_US&lev = levs_mean
toplot_US&lat = lats

toplot_US&lat@units="degrees_north"
toplot_US&lev@units="mb"

copy_VarCoords(toplot_US,toplot_MNT)
copy_VarCoords(toplot_US,toplot_DS)


; plot
; plot one = 850mb

npanels = floattoint(ceil(nexps/2.0))

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/U_UpSt_40yrs_ITvsM")                  ; open workstation

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
  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@trYMinF = 50.0
  res@trYMaxF = 1000.0

  res@trXMinF = 48.0
  res@trXMaxF = 96.0

  res@tmXBMode        = "Explicit"	
  res@tmXBValues      = (/120.0,140.0,160.0,180.0,200.0,220.0,241.0/)
  res@tmXBLabels      = (/"0N","15N","30N","45N","60N","75N","90N"/)

  res@lbLabelAutoStride    = True                 ; optimal labels

  res@tmYRMode             = "Automatic"          ; turn off special labels on right axis


  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0			; set the minimum contour level
  res@cnMaxLevelValF  = 40.0			; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_pres_hgt(wks,toplot_US(0,:,:),res) ;

  res@cnMinLevelValF  = -8.0			; set the minimum contour level
  res@cnMaxLevelValF  = 8.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_pres_hgt(wks,toplot_US(pp,:,:),res) ;
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "U (m/s), Up-stream (50-70E)"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


; plot 2 mid-mountain
  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/U_MidMnt_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array



  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0                   ; set the minimum contour level
  res@cnMaxLevelValF  = 40.0                   ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_pres_hgt(wks,toplot_MNT(0,:,:),res) ;

  res@cnMinLevelValF  = -8.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 8.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_pres_hgt(wks,toplot_MNT(pp,:,:),res) ;
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "U (m/s), Mid-mountain (90-110E)"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)



; plot 3 Down-stream
  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/U_DownSt_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array



  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0                   ; set the minimum contour level
  res@cnMaxLevelValF  = 40.0                   ; set the maximum contour level
  res@cnLevelSpacingF       = 4.0      ; contour spacing

  res@gsnCenterString         = titles(0)
  plot(0) = gsn_csm_pres_hgt(wks,toplot_DS(0,:,:),res) ;

  res@cnMinLevelValF  = -8.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 8.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0     ; contour spacing

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)
  plot(pp) = gsn_csm_pres_hgt(wks,toplot_DS(pp,:,:),res) ;
end do

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = "U (m/s), Down-stream (130-150E)"

  resP@gsnDraw = False                           ; draw later, in maximize mode
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
