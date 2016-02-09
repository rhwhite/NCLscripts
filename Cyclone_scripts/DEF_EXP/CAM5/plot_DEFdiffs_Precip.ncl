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

variables = (/"PRECT","TS","TREFHT","U850","V850","U250","V250","ALDIR","ALDIF","ASDIR","ASDIF","LHFLX"/)
max1 = (/12.0, 300.,300., 15, 5.0, 50.0, 8.0 , 0.8, 0.8, 0.8,0.8,120/)
min1 = (/1.0, 240., 240., -15,-5.0,-10.0,-8.0, 0.3, 0.3, 0.3,0.3,20/)
max2 = (/0.75, 2.8, 2.5, 1.0, 0.75, 1.2, 1.0,0.015,0.015,0.015,0.015,10.0/)
min2 = (/-0.75,-2.8,-2.5,-1.0,-0.75,-1.2,-1.0,-0.015,-0.015,-0.015,-0.015,-10.0/)
step1 = (/ 1, 5, 5, 2, 1, 5, 2,0.05,0.05,0.05,0.05,10/)
step2 = (/0.15,0.4,0.4,0.2,0.15,0.2,0.2,0.003,0.003,0.003,0.003,2.0/)

seasons = (/"JJA","DJF","Ann"/)

nvars = dimsizes(variables)
nseasons = dimsizes(seasons)

do ivar = 0,nvars-1
	if (variables(ivar) .EQ. "PRECT")
		const = 86400. * 1000.
	else
		const = 1.0
	end if

	print(variables(ivar))
	CTL_DJF_var = const * CTL_DJF->$variables(ivar)$(0,:,:)
	Diff_DJF_var = const * (DEF_DJF->$variables(ivar)$(0,:,:)-CTL_DJF->$variables(ivar)$(0,:,:))

        CTL_JJA_var = const * CTL_JJA->$variables(ivar)$(0,:,:)
        Diff_JJA_var = const * (DEF_JJA->$variables(ivar)$(0,:,:)-CTL_JJA->$variables(ivar)$(0,:,:))

        CTL_Ann_var = const * CTL_Ann->$variables(ivar)$(0,:,:)
        Diff_Ann_var = const * (DEF_Ann->$variables(ivar)$(0,:,:)-CTL_Ann->$variables(ivar)$(0,:,:))

	print(dimsizes(CTL_DJF_var))
	CTL_DJF_var!0 = "lat"
	CTL_DJF_var!1 = "lon"

	CTL_DJF_var&lat = lats
	CTL_DJF_var&lon = lons

	CTL_DJF_var&lat@units="degrees_north"
	CTL_DJF_var&lon@units="degrees_east"

	copy_VarMeta(CTL_DJF_var,CTL_JJA_var)
	copy_VarMeta(CTL_DJF_var,CTL_Ann_var)
        copy_VarMeta(CTL_DJF_var,Diff_DJF_var)
        copy_VarMeta(CTL_DJF_var,Diff_JJA_var)
        copy_VarMeta(CTL_DJF_var,Diff_Ann_var)


	wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/DEF1-CTL_" + variables(ivar))   ; open workstation

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

  	res@cnMinLevelValF  = min1(ivar)                    ; set the minimum contour level
  	res@cnMaxLevelValF  = max1(ivar)                     ; set the maximum contour level
  	res@cnLevelSpacingF = step1(ivar)      ; contour spacing

  	res@gsnCenterString         = "Annual " + variables(ivar) + " from " + Experiments(0)
  	plot(0) = gsn_csm_contour_map_ce(wks,CTL_Ann_var,res) ;
        res@gsnCenterString         = "DJF " + variables(ivar) + " from " + Experiments(0)
        plot(2) = gsn_csm_contour_map_ce(wks,CTL_DJF_var,res) ;
        res@gsnCenterString         = "JJA " + variables(ivar) + " from " + Experiments(0)
        plot(4) = gsn_csm_contour_map_ce(wks,CTL_JJA_var,res) ;

       res@cnMinLevelValF  = min2(ivar)                    ; set the minimum contour level
       res@cnMaxLevelValF  = max2(ivar)                     ; set the maximum contour level
       res@cnLevelSpacingF = step2(ivar)      ; contour spacing

        res@gsnCenterString         = "Annual " + variables(ivar) + " from " + Experiments(1) + " - " + Experiments(0)
        plot(1) = gsn_csm_contour_map_ce(wks,Diff_Ann_var,res) ;
        res@gsnCenterString         = "DJF " + variables(ivar) + " from " + Experiments(1) + " - " + Experiments(0)
        plot(3) = gsn_csm_contour_map_ce(wks,Diff_DJF_var,res) ;
        res@gsnCenterString         = "JJA " + variables(ivar) + " from " + Experiments(1) + " - " + Experiments(0)
        plot(5) = gsn_csm_contour_map_ce(wks,Diff_JJA_var,res) ;



  	resP                  = True                   ; modify the panel plot
  	resP@gsnFrame         = False                  ; don't advance panel plot
  	resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  	resP@gsnPaperOrientation = "landscape"

      	resP@gsnDraw = False                           ; draw later, in maximize mode
      	panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP)
  	gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      	mres = True
      	maximize_output(wks,mres)

end do







end



