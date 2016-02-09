load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears =40

Experiments = (/"CAM5topo","CAM5def1"/);

diri = "/home/disk/rachel/CESM_outfiles/";

; DJF
fili = Experiments(0) + "/atm/hist/DJF40_mean_" + Experiments(0) + ".cam2.h0.nc"
CTL_DJF = addfile(diri + fili,"r")

fili = Experiments(0) + "/atm/hist/JJA40_mean_" + Experiments(0) + ".cam2.h0.nc"
CTL_JJA = addfile(diri + fili,"r")

fili = Experiments(0) + "/atm/hist/Annual40_mean_" + Experiments(0) + ".cam2.h0.nc"
CTL_Ann = addfile(diri + fili,"r")


fili = Experiments(1) + "/atm/hist/DJF40_mean_" + Experiments(1) + ".cam2.h0.nc"
DEF_DJF = addfile(diri + fili,"r")

fili = Experiments(1) + "/atm/hist/JJA40_mean_" + Experiments(1) + ".cam2.h0.nc"
DEF_JJA = addfile(diri + fili,"r")

fili = Experiments(1) + "/atm/hist/Annual40_mean_" + Experiments(1) + ".cam2.h0.nc"
DEF_Ann = addfile(diri + fili,"r")


lats = CTL_JJA->lat
lons = CTL_JJA->lon

seasons = (/"JJA","DJF","Ann"/)

nseasons = dimsizes(seasons)

	CTL_DJF_ALB = (CTL_DJF->FSDSC(0,:,:) - CTL_DJF->FSNSC(0,:,:))/mask(CTL_DJF->FSDSC(0,:,:),CTL_DJF->FSDSC(0,:,:) .LE. 0,False)
	Diff_DJF_ALB =((DEF_DJF->FSDSC(0,:,:) - DEF_DJF->FSNSC(0,:,:))/mask(DEF_DJF->FSDSC(0,:,:),DEF_DJF->FSDSC(0,:,:) .LE. 0,False)) - ((CTL_DJF->FSDSC(0,:,:) - CTL_DJF->FSNSC(0,:,:))/mask(CTL_DJF->FSDSC(0,:,:),CTL_DJF->FSDSC(0,:,:) .LE. 0,False))

        CTL_JJA_ALB = (CTL_JJA->FSDSC(0,:,:) - CTL_JJA->FSNSC(0,:,:))/mask(CTL_JJA->FSDSC(0,:,:),CTL_JJA->FSDSC(0,:,:) .LE. 0,False)
        Diff_JJA_ALB =((DEF_JJA->FSDSC(0,:,:) - DEF_JJA->FSNSC(0,:,:))/mask(DEF_JJA->FSDSC(0,:,:),DEF_JJA->FSDSC(0,:,:) .LE. 0,False)) - ((CTL_JJA->FSDSC(0,:,:) - CTL_JJA->FSNSC(0,:,:))/mask(CTL_JJA->FSDSC(0,:,:),CTL_JJA->FSDSC(0,:,:) .LE. 0,False))

        CTL_Ann_ALB = (CTL_Ann->FSDSC(0,:,:) - CTL_Ann->FSNSC(0,:,:))/mask(CTL_Ann->FSDSC(0,:,:),CTL_Ann->FSDSC(0,:,:) .LE. 0,False)
        Diff_Ann_ALB =((DEF_Ann->FSDSC(0,:,:) - DEF_Ann->FSNSC(0,:,:))/mask(DEF_Ann->FSDSC(0,:,:),DEF_Ann->FSDSC(0,:,:) .LE. 0,False)) - ((CTL_Ann->FSDSC(0,:,:) - CTL_Ann->FSNSC(0,:,:))/mask(CTL_Ann->FSDSC(0,:,:),CTL_Ann->FSDSC(0,:,:) .LE. 0,False))

	print(dimsizes(CTL_DJF_ALB))
	CTL_DJF_ALB!0 = "lat"
	CTL_DJF_ALB!1 = "lon"

	CTL_DJF_ALB&lat = lats
	CTL_DJF_ALB&lon = lons

	CTL_DJF_ALB&lat@units="degrees_north"
	CTL_DJF_ALB&lon@units="degrees_east"

	copy_VarMeta(CTL_DJF_ALB,CTL_JJA_ALB)
	copy_VarMeta(CTL_DJF_ALB,CTL_Ann_ALB)
        copy_VarMeta(CTL_DJF_ALB,Diff_DJF_ALB)
        copy_VarMeta(CTL_DJF_ALB,Diff_JJA_ALB)
        copy_VarMeta(CTL_DJF_ALB,Diff_Ann_ALB)


	wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/DEF1-CTL_ALB")   ; open workstation

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

  	res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources

  	res@cnMinLevelValF  = 0.1                    ; set the minimum contour level
  	res@cnMaxLevelValF  = 0.5                     ; set the maximum contour level
  	res@cnLevelSpacingF = 0.05      ; contour spacing

  	res@gsnCenterString         = "Annual ALB from " + Experiments(0)
  	plot(0) = gsn_csm_contour_map_ce(wks,CTL_Ann_ALB,res) ;
        res@gsnCenterString         = "DJF ALB from " + Experiments(0)
        plot(2) = gsn_csm_contour_map_ce(wks,CTL_DJF_ALB,res) ;
        res@gsnCenterString         = "JJA ALB from " + Experiments(0)
        plot(4) = gsn_csm_contour_map_ce(wks,CTL_JJA_ALB,res) ;

       res@cnMinLevelValF  = -0.02                    ; set the minimum contour level
       res@cnMaxLevelValF  = 0.02                     ; set the maximum contour level
       res@cnLevelSpacingF = 0.004      ; contour spacing

        res@gsnCenterString         = "Annual ALB from " + Experiments(1) + " - " + Experiments(0)
        plot(1) = gsn_csm_contour_map_ce(wks,Diff_Ann_ALB,res) ;
        res@gsnCenterString         = "DJF ALB from " + Experiments(1) + " - " + Experiments(0)
        plot(3) = gsn_csm_contour_map_ce(wks,Diff_DJF_ALB,res) ;
        res@gsnCenterString         = "JJA ALB from " + Experiments(1) + " - " + Experiments(0)
        plot(5) = gsn_csm_contour_map_ce(wks,Diff_JJA_ALB,res) ;



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



