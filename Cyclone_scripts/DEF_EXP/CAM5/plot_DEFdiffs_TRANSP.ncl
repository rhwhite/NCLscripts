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

	CTL_DJF_TRANSP = CTL_DJF->FCTR(0,:,:)
	Diff_DJF_TRANSP = DEF_DJF->FCTR(0,:,:) - CTL_DJF->FCTR(0,:,:)

        CTL_JJA_TRANSP = CTL_JJA->FCTR(0,:,:)
        Diff_JJA_TRANSP = DEF_JJA->FCTR(0,:,:) - CTL_JJA->FCTR(0,:,:)

        CTL_Ann_TRANSP = CTL_Ann->FCTR(0,:,:)
        Diff_Ann_TRANSP = DEF_Ann->FCTR(0,:,:) - CTL_Ann->FCTR(0,:,:)

	print(dimsizes(CTL_DJF_TRANSP))
	CTL_DJF_TRANSP!0 = "lat"
	CTL_DJF_TRANSP!1 = "lon"

	CTL_DJF_TRANSP&lat = lats
	CTL_DJF_TRANSP&lon = lons

	CTL_DJF_TRANSP&lat@units="degrees_north"
	CTL_DJF_TRANSP&lon@units="degrees_east"

	copy_VarMeta(CTL_DJF_TRANSP,CTL_JJA_TRANSP)
	copy_VarMeta(CTL_DJF_TRANSP,CTL_Ann_TRANSP)
        copy_VarMeta(CTL_DJF_TRANSP,Diff_DJF_TRANSP)
        copy_VarMeta(CTL_DJF_TRANSP,Diff_JJA_TRANSP)
        copy_VarMeta(CTL_DJF_TRANSP,Diff_Ann_TRANSP)


	wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/DEF1-CTL_TRANSP")   ; open workstation

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

  	res@gsnCenterString         = "Annual TRANSP (FCTR), " + Experiments(0)
  	plot(0) = gsn_csm_contour_map_ce(wks,CTL_Ann_TRANSP,res) ;
        res@gsnCenterString         = "DJF TRANSP (FCTR), " + Experiments(0)
        plot(2) = gsn_csm_contour_map_ce(wks,CTL_DJF_TRANSP,res) ;
        res@gsnCenterString         = "JJA TRANSP (FCTR), " + Experiments(0)
        plot(4) = gsn_csm_contour_map_ce(wks,CTL_JJA_TRANSP,res) ;

       res@cnMinLevelValF  = -20.0                    ; set the minimum contour level
       res@cnMaxLevelValF  = 20.0                     ; set the maximum contour level
       res@cnLevelSpacingF = 4.0      ; contour spacing

        res@gsnCenterString         = "Annual TRANSP (FCTR), " + Experiments(1) + " - " + Experiments(0)
        plot(1) = gsn_csm_contour_map_ce(wks,Diff_Ann_TRANSP,res) ;
        res@gsnCenterString         = "DJF TRANSP (FCTR), " + Experiments(1) + " - " + Experiments(0)
        plot(3) = gsn_csm_contour_map_ce(wks,Diff_DJF_TRANSP,res) ;
        res@gsnCenterString         = "JJA TRANSP (FCTR),  " + Experiments(1) + " - " + Experiments(0)
        plot(5) = gsn_csm_contour_map_ce(wks,Diff_JJA_TRANSP,res) ;



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



