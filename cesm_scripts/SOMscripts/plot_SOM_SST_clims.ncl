load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =35
startyear = 1
Experiment = (/"CAM4SOM4topo"/)

iyear = startyear
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else
                        yearstring = ("0" + tostring(iyear))
                end if
                end if

imonth = 1
monthstring =  ("0" + tostring(imonth))


filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiment + "/atm/hist/" + Experiment + ".cam2.h0." + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(SST)

ntimes = nyears

print(ntimes)
SSTs_SOM = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))

count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else
                        yearstring = ("0" + tostring(iyear))
                end if
                end if

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiment + "/atm/hist/" + Experiment + ".cam2.h0." + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs_SOM(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM1 = dim_avg(SSTs_SOM(:,:,:,0:count-1))
SST_ann_SOM1 = dim_avg_n(SSTs_clim_SOM1,0)
SST_DJF_SOM1 = (SSTs_clim_SOM1(11,:,:) + SSTs_clim_SOM1(0,:,:) + SSTs_clim_SOM1(1,:,:))/3.0
SST_JJA_SOM1 = dim_avg_n(SSTs_clim_SOM1(5:7,:,:),0)

Experiments3 = (/"CESMSOMtopof19g16"/)

startyear2 = 150
iyear = startyear2
                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else
                        yearstring = ("0" + tostring(iyear))
                end if
                end if
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments3 + "/atm/hist/" + Experiments3 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(SST)

ntimes = nyears

print(ntimes)
SSTs_SOMo = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))

count = 0

print(count)
  
do iyear=startyear2,(startyear2+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

                if iyear .lt. 10
                        yearstring = ("000" + tostring(iyear))
                else if iyear .lt. 100
                        yearstring = ("00" + tostring(iyear))
                else
                        yearstring = ("0" + tostring(iyear))
                end if
                end if

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments3 + "/atm/hist/" + Experiments3 + ".cam2.h0." + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs_SOMo(imonth-1,:,:,count) = cdf_file->SST(0,:,:)

	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOMo = dim_avg(SSTs_SOMo(:,:,:,0:count-1))
SST_ann_SOMo = dim_avg_n(SSTs_clim_SOMo,0)
SST_DJF_SOMo = (SSTs_clim_SOMo(11,:,:) + SSTs_clim_SOMo(0,:,:) + SSTs_clim_SOMo(1,:,:))/3.0
SST_JJA_SOMo = dim_avg_n(SSTs_clim_SOMo(5:7,:,:),0)



filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"
cdf_file = addfile(filename,"w")
print(filename)

SSTs_HAD = cdf_file->SST_cpl + 273.15


;create mean

SST_ann_HAD = dim_avg_n(SSTs_HAD,0)
SST_DJF_HAD = (SSTs_HAD(11,:,:) + SSTs_HAD(0,:,:) + SSTs_HAD(1,:,:))/3.0
SST_JJA_HAD = dim_avg_n(SSTs_HAD(5:7,:,:),0)



SST_diffs_ann1 = SST_ann_SOM1 - SST_ann_HAD
SST_diffs_ann2 = SST_ann_SOMo - SST_ann_HAD

SST_diffs_DJF1 = SST_DJF_SOM1 - SST_DJF_HAD
SST_diffs_DJF2 = SST_DJF_SOMo - SST_DJF_HAD

SST_diffs_JJA1 = SST_JJA_SOM1 - SST_JJA_HAD
SST_diffs_JJA2 = SST_JJA_SOMo - SST_JJA_HAD


SST_ann_HAD!0="lat"
SST_ann_HAD!1="lon"

SST_ann_HAD&lat = lats
SST_ann_HAD&lon = lons

SST_ann_HAD&lat@units="degree_north"
SST_ann_HAD&lon@units="degree_east"


copy_VarCoords(SST_ann_HAD,SST_ann_SOM1)
copy_VarCoords(SST_ann_HAD,SST_ann_SOMo)
copy_VarCoords(SST_ann_HAD,SST_DJF_HAD)
copy_VarCoords(SST_ann_HAD,SST_JJA_HAD)
copy_VarCoords(SST_ann_HAD,SST_DJF_SOM1)
copy_VarCoords(SST_ann_HAD,SST_JJA_SOM1)
copy_VarCoords(SST_ann_HAD,SST_DJF_SOMo)
copy_VarCoords(SST_ann_HAD,SST_JJA_SOMo)

copy_VarCoords(SST_ann_HAD,SST_diffs_ann1)
copy_VarCoords(SST_ann_HAD,SST_diffs_DJF1)
copy_VarCoords(SST_ann_HAD,SST_diffs_JJA1)
copy_VarCoords(SST_ann_HAD,SST_diffs_ann2)
copy_VarCoords(SST_ann_HAD,SST_diffs_DJF2)
copy_VarCoords(SST_ann_HAD,SST_diffs_JJA2)



  wks   = gsn_open_wks ("eps","$HOME/Figures/SOMvsfSST/SSTs_Ann_DJF_JJA__" + Experiment + "_" + nyears + "yrs")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(9,graphic)                          ; create a plot array

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

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 273.0			; set the minimum contour level
  res@cnMaxLevelValF  = 300.0			; set the maximum contour level
  res@cnLevelSpacingF       = 3.0      ; contour spacing

  res@gsnCenterString         = "Ann HAD SST"
  plot(0) = gsn_csm_contour_map_ce(wks,SST_ann_HAD,res) ;
  res@gsnCenterString         = "Ann " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,SST_ann_SOM1,res) ;
  res@gsnCenterString         = "Ann " + Experiments3
  plot(2) = gsn_csm_contour_map_ce(wks,SST_ann_SOMo,res) ;

  res@gsnCenterString         = "DJF HAD SST"
  plot(3) = gsn_csm_contour_map_ce(wks,SST_DJF_HAD,res) ;
  res@gsnCenterString         = "DJF " + Experiment
  plot(4) = gsn_csm_contour_map_ce(wks,SST_DJF_SOM1,res) ;
  res@gsnCenterString         = "DJF " + Experiments3
  plot(5) = gsn_csm_contour_map_ce(wks,SST_DJF_SOMo,res) ;

  res@gsnCenterString         = "JJA HAD SST"
  plot(6) = gsn_csm_contour_map_ce(wks,SST_JJA_HAD,res) ;
  res@gsnCenterString         = "JJA " + Experiment
  plot(7) = gsn_csm_contour_map_ce(wks,SST_JJA_SOM1,res) ;
  res@gsnCenterString         = "JJA " + Experiments3
  plot(8) = gsn_csm_contour_map_ce(wks,SST_JJA_SOMo,res) ;


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "SSTs"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,3/),resP) 

  gsn_panel(wks,plot,(/3,3/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)
  wks   = gsn_open_wks ("eps","$HOME/Figures/SOMvsfSST/SST-diffs_Ann_DJF_JJA__" + Experiment + "_" + nyears + "yrs")                  ; open workstation

  delete(plot)
  delete(panelid1)


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

  res@cnMinLevelValF  = -2.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.4      ; contour spacing


  res@gsnCenterString         = "Ann diffs " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,SST_diffs_ann1,res) ;
  res@gsnCenterString         = "Ann diffs " + Experiments3
  plot(1) = gsn_csm_contour_map_ce(wks,SST_diffs_ann2,res) ;
  res@gsnCenterString         = "DJF diffs " + Experiment
  plot(2) = gsn_csm_contour_map_ce(wks,SST_diffs_DJF1,res) ;
  res@gsnCenterString         = "DJF diffs " + Experiments3
  plot(3) = gsn_csm_contour_map_ce(wks,SST_diffs_DJF2,res) ;
  res@gsnCenterString         = "JJA diffs " + Experiment
  plot(4) = gsn_csm_contour_map_ce(wks,SST_diffs_JJA1,res) ;
  res@gsnCenterString         = "JJA diffs " + Experiments3
  plot(5) = gsn_csm_contour_map_ce(wks,SST_diffs_JJA2,res) ;


  res@cnMinLevelValF  = -2.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 2.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.4      ; contour spacing


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "SSTs"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/3,2/),resP)

  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)

