load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 1
startyear = 1

secdays = 60*60*24
mfactor = 1000. * secdays

Experiment = "CESM13_B11_CAM5CLM45SP_DOM_CTL_f02g16"

diro = "/home/disk/eos4/rachel/Yellowstone/" + Experiment + "/"
filo = Experiment + ".cam.h0.ANN.nc"
fout_std2 = addfile(diro + filo,"r")

lats2 = fout_std2->lat
lons2 = fout_std2->lon

TS_ANN = fout_std2->TS 
Precip_ANN = fout_std2->PRECC(0,:,:) + fout_std2->PRECL(0,:,:) 
LH_ANN = fout_std2->LHFLX

delete(fout_std2)

filo = Experiment + ".cam.h0.DJF.nc"
fout_std2 = addfile(diro + filo,"r")

TS_DJF = fout_std2->TS        
Precip_DJF = fout_std2->PRECC(0,:,:) + fout_std2->PRECL(0,:,:)
LH_DJF = fout_std2->LHFLX
delete(fout_std2)

filo = Experiment + ".cam.h0.JJA.nc"
fout_std2 = addfile(diro + filo,"r")

TS_JJA = fout_std2->TS 
Precip_JJA = fout_std2->PRECC(0,:,:) + fout_std2->PRECL(0,:,:)
LH_JJA = fout_std2->LHFLX
delete(fout_std2)

vars = (/"Precip","TS","LH"/)
nvars = dimsizes(vars)

do ivar = 0,nvars-1

	var = vars(ivar)
	print(var)

	if (var .EQ. "Precip") then
		toplotAnn = Precip_ANN * mfactor
		toplotJJA = Precip_JJA * mfactor
		toplotDJF = Precip_DJF * mfactor
		mins = 0.0
		maxs = 12.0
		diffs = 1.0	
		units = "mm/day"
	else if (var .EQ. "TS") then
	        toplotAnn = TS_ANN
	        toplotJJA = TS_JJA 
	        toplotDJF = TS_DJF
		mins = 255.0
		maxs = 305.0
		diffs = 5.0
		units = "K"
	else if (var .EQ. "LH") then
	        toplotAnn = LH_ANN 
	        toplotJJA = LH_JJA 
	        toplotDJF = LH_DJF
		mins = 10
		maxs = 160
		diffs = 15
		units = "W/m2"
	else
		print("wrong variable!")
		print(var)
		exit
	end if
	end if
	end if

	

	toplotAnn!0 = "lat"
	toplotAnn!1 = "lon"
	
	toplotAnn&lat = lats2
	toplotAnn&lon = lons2

	toplotAnn&lat@units="degrees_north"
	toplotAnn&lon@units="degrees_east"

	copy_VarMeta(toplotAnn,toplotJJA)
	copy_VarMeta(toplotAnn,toplotDJF)


wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/" + var + "_" + Experiment + "_" + startyear + "_" + nyears)                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(3,graphic)                          ; create a plot array

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

  res@cnMinLevelValF  = mins                    ; set the minimum contour level
  res@cnMaxLevelValF  = maxs                     ; set the maximum contour level
  res@cnLevelSpacingF = diffs      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual " + var + " " + units + " from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;
  res@gsnCenterString         = "JJA" + var + " " + units +  " from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;
  res@gsnCenterString         = "DJF" + var + " " + units + " from " + Experiment
  plot(2) = gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,1/),resP)

  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

end do

end



