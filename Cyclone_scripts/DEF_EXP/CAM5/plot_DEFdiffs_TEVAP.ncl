load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears =40

Experiments = (/"CAM5topo","CAM5def1"/);

diri = "/home/disk/rachel/CESM_outfiles/";

; DJF
fili = Experiments(0) + "/lnd/hist/DJF40_CLM_mean_" + Experiments(0) + ".clm2.h0.nc"
CTL_DJF = addfile(diri + fili,"r")

fili = Experiments(0) + "/lnd/hist/JJA40_CLM_mean_" + Experiments(0) + ".clm2.h0.nc"
CTL_JJA = addfile(diri + fili,"r")

fili = Experiments(0) + "/lnd/hist/Annual40_CLM_mean_" + Experiments(0) + ".clm2.h0.nc"
CTL_Ann = addfile(diri + fili,"r")


fili = Experiments(1) + "/lnd/hist/DJF40_CLM_mean_" + Experiments(1) + ".clm2.h0.nc"
DEF_DJF = addfile(diri + fili,"r")

fili = Experiments(1) + "/lnd/hist/JJA40_CLM_mean_" + Experiments(1) + ".clm2.h0.nc"
DEF_JJA = addfile(diri + fili,"r")

fili = Experiments(1) + "/lnd/hist/Annual40_CLM_mean_" + Experiments(1) + ".clm2.h0.nc"
DEF_Ann = addfile(diri + fili,"r")


lats = CTL_JJA->lat
lons = CTL_JJA->lon

seasons = (/"JJA","DJF","Ann"/)

nseasons = dimsizes(seasons)

	CTL_DJF_TEVAP = CTL_DJF->FCTR(0,:,:) + CTL_DJF->FCEV(0,:,:) + CTL_DJF->FGEV(0,:,:)
	Diff_DJF_TEVAP = (DEF_DJF->FCTR(0,:,:) + DEF_DJF->FCEV(0,:,:) + DEF_DJF->FGEV(0,:,:)) - (CTL_DJF->FCTR(0,:,:) + CTL_DJF->FCEV(0,:,:) + CTL_DJF->FGEV(0,:,:))

        CTL_JJA_TEVAP = CTL_JJA->FCTR(0,:,:) + CTL_JJA->FCEV(0,:,:) + CTL_JJA->FGEV(0,:,:)
        Diff_JJA_TEVAP = (DEF_JJA->FCTR(0,:,:) + DEF_JJA->FCEV(0,:,:) + DEF_JJA->FGEV(0,:,:)) - (CTL_JJA->FCTR(0,:,:) + CTL_JJA->FCEV(0,:,:) + CTL_JJA->FGEV(0,:,:))

        CTL_Ann_TEVAP = CTL_Ann->FCTR(0,:,:) + CTL_Ann->FCEV(0,:,:) + CTL_Ann->FGEV(0,:,:)
        Diff_Ann_TEVAP = (DEF_Ann->FCTR(0,:,:) + DEF_Ann->FCEV(0,:,:) + DEF_Ann->FGEV(0,:,:)) - (CTL_Ann->FCTR(0,:,:) + CTL_Ann->FCEV(0,:,:) + CTL_Ann->FGEV(0,:,:))

	print(dimsizes(CTL_DJF_TEVAP))
	CTL_DJF_TEVAP!0 = "lat"
	CTL_DJF_TEVAP!1 = "lon"

	CTL_DJF_TEVAP&lat = lats
	CTL_DJF_TEVAP&lon = lons

	CTL_DJF_TEVAP&lat@units="degrees_north"
	CTL_DJF_TEVAP&lon@units="degrees_east"

	copy_VarMeta(CTL_DJF_TEVAP,CTL_JJA_TEVAP)
	copy_VarMeta(CTL_DJF_TEVAP,CTL_Ann_TEVAP)
        copy_VarMeta(CTL_DJF_TEVAP,Diff_DJF_TEVAP)
        copy_VarMeta(CTL_DJF_TEVAP,Diff_JJA_TEVAP)
        copy_VarMeta(CTL_DJF_TEVAP,Diff_Ann_TEVAP)


	wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/DEF1-CTL_TEVAP")   ; open workstation

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
  	res@lbOrientation   = "Vertical"                ; vertical label bar
	res@cnInfoLabelOn       = False        ; no info label
	res@gsnLeftString  = ""
  	
	res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources

  	res@cnMinLevelValF  = 0.0                    ; set the minimum contour level
  	res@cnMaxLevelValF  = 100.0                     ; set the maximum contour level
  	res@cnLevelSpacingF = 10.0      ; contour spacing

  	res@gsnCenterString         = "Annual TEVAP (FCTR+FCEV+FGEV), W/m2 " + Experiments(0)
  	plot(0) = gsn_csm_contour_map_ce(wks,CTL_Ann_TEVAP,res) ;
        res@gsnCenterString         = "DJF TEVAP, W/m2 " + Experiments(0)
        plot(2) = gsn_csm_contour_map_ce(wks,CTL_DJF_TEVAP,res) ;
        res@gsnCenterString         = "JJA TEVAP, W/m2 " + Experiments(0)
        plot(4) = gsn_csm_contour_map_ce(wks,CTL_JJA_TEVAP,res) ;

       res@cnMinLevelValF  = -20.0                    ; set the minimum contour level
       res@cnMaxLevelValF  = 20.0                     ; set the maximum contour level
       res@cnLevelSpacingF = 4.0      ; contour spacing

        res@gsnCenterString         = "Annual TEVAP, W/m2 " + Experiments(1) + " - " + Experiments(0)
        plot(1) = gsn_csm_contour_map_ce(wks,Diff_Ann_TEVAP,res) ;
        res@gsnCenterString         = "DJF TEVAP, W/m2 " + Experiments(1) + " - " + Experiments(0)
        plot(3) = gsn_csm_contour_map_ce(wks,Diff_DJF_TEVAP,res) ;
        res@gsnCenterString         = "JJA TEVAP, W/m2 " + Experiments(1) + " - " + Experiments(0)
        plot(5) = gsn_csm_contour_map_ce(wks,Diff_JJA_TEVAP,res) ;



  	resP                  = True                   ; modify the panel plot
  	resP@gsnFrame         = False                  ; don't advance panel plot
  	resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  	resP@gsnPaperOrientation = "landscape"

      	resP@gsnDraw = False                           ; draw later, in maximize mode
      	panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP)
  	gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      	mres = True
      	maximize_output(wks,mres)


end



