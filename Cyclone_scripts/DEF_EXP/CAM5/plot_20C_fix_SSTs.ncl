load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears =25
startyear = 2

precipconst = 1000.0 * 86400.0

;Experiment = (/"b.e11.B20TRC5CN.f09_g16.001"/)
;Dir = "/glade/p/cesm/shared_outputdata/cases/cesm1/"

Experiment = "CAM5topo"
Dir = "/home/disk/rachel/CESM_outfiles/"

yearstring = ("0" + tostring(startyear))
imonth = 1
monthstring =  ("0" + tostring(imonth))


;landfile = "/glade/p/cesmdata/cseg/inputdata/lnd/clm2/griddata/fracdata_0.9x1.25_gx1v6_c090317.nc"
landfile = "/home/disk/eos4/rachel/inputdata/lnd/fracdata_1.9x2.5_gx1v6_c090206.nc"

cdf_lm = addfile(landfile,"r")
landmask = cdf_lm->LANDMASK
oceanmask = -1.0 * (landmask - 1.0)


filename = (Dir + Experiment + "/atm/hist/" + Experiment + ".cam2.h0.00" + yearstring + "-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon

TS = cdf_file->TS

nlats = dimsizes(lats)
nlons = dimsizes(lons)

print(nlats)
print(nlons)

ndims = dimsizes(TS)

ntimes = nyears

print(ntimes)
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(TS))
T2m = new((/12,ndims(1),ndims(2),ntimes/),typeof(TS))
U10 = new((/12,ndims(1),ndims(2),ntimes/),typeof(TS))
Precip = new((/12,ndims(1),ndims(2),ntimes/),typeof(TS))

count = 0

do iyear=startyear,(startyear+nyears-1)
        print(iyear*1)
        do imonth = 1,12
                if imonth .lt. 10
                        monthstring = ("0" + tostring(imonth))
                else
                        monthstring = tostring(imonth)
                end if

                if iyear .lt. 10
                        yearstring = ("0" + tostring(iyear))
                else
                        yearstring = tostring(iyear)
                end if

	filename = (Dir + Experiment + "/atm/hist/" + Experiment + ".cam2.h0.00" + yearstring + "-" + monthstring + ".nc")

        cdf_file = addfile(filename,"r")

        SSTs(imonth-1,:,:,count) = cdf_file->TS(0,:,:)
        T2m(imonth-1,:,:,count) = cdf_file->TREFHT(0,:,:)
        U10(imonth-1,:,:,count) = cdf_file->U10(0,:,:)
        Precip(imonth-1,:,:,count) = cdf_file->PRECT(0,:,:)

        end do
        count = count + 1
end do

;create mean

SSTs_clim = dim_avg(SSTs)
T2m_clim = dim_avg(T2m)
U10_clim = dim_avg(U10)
Precip_clim = dim_avg(Precip) * precipconst

ndims2 = dimsizes(SSTs_clim)

print(dimsizes(TS))
print(ndims2)

landmask!0 = "lat"
landmask!1 = "lon"

landmask&lat = lats
landmask&lon = lons

copy_VarMeta(landmask,oceanmask)

;Write variables to a new netcdf file
;-----------------------------------------------------------------------
diro = "$HOME/Yellowstone/"
filo = "Clims_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
system("/bin/rm -f " + diro + filo)
fout_std = addfile(diro + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"time","lat","lon"/)
dimSizes = (/ndims2(0),ndims2(1),ndims2(2)/)
dimUnlim = (/True,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lats),getvardims(lats))
filevardef(fout_std,"lon",typeof(lons),getvardims(lons))


filevardef(fout_std,"SSTs_clim",typeof(SSTs_clim),getvardims(TS))
filevardef(fout_std,"T2m_clim",typeof(T2m_clim),getvardims(TS))
filevardef(fout_std,"U10_clim",typeof(U10_clim),getvardims(TS))
filevardef(fout_std,"Precip_clim",typeof(Precip_clim),getvardims(TS))

filevardef(fout_std,"landmask",typeof(landmask),(/"lat","lon"/))
filevardef(fout_std,"oceanmask",typeof(oceanmask),(/"lat","lon"/))

delete([/SSTs,T2m,U10,Precip/])

fout_std->lat = lats
fout_std->lon = lons

fout_std->SSTs_clim = SSTs_clim
fout_std->T2m_clim = T2m_clim
fout_std->U10_clim = U10_clim
fout_std->Precip_clim = Precip_clim

fout_std->landmask    = landmask
fout_std->oceanmask   = oceanmask


print("printed lats etc")

ndims = dimsizes(SSTs_clim)
print(ndims)

toplotAnn = oceanmask * dim_avg_n(SSTs_clim,0)
toplotJJA = oceanmask *(SSTs_clim(5,:,:) + SSTs_clim(6,:,:) + SSTs_clim(7,:,:))/3.0
toplotDJF = oceanmask *(SSTs_clim(11,:,:) + SSTs_clim(0,:,:) + SSTs_clim(1,:,:))/3.0
 
toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats
toplotAnn&lon = lons

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)

wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/SSTs_K_" + startyear + "_" + nyears +"_" + Experiment)                  ; open workstation

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

  res@cnMinLevelValF  = 272.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 302.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual SST from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;

  res@gsnCenterString         = "JJA SST from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;

  res@gsnCenterString         = "DJF SST from " + Experiment
  plot(2)= gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "TS, K, " + Experiment ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

toplotAnn = oceanmask * (dim_avg_n(SSTs_clim,0) - 273.15)
toplotJJA = oceanmask *((SSTs_clim(5,:,:) + SSTs_clim(6,:,:) + SSTs_clim(7,:,:))/3.0) - 273.15
toplotDJF = oceanmask *((SSTs_clim(11,:,:) + SSTs_clim(0,:,:) + SSTs_clim(1,:,:))/3.0) - 273.15

toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats
toplotAnn&lon = lons

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)

wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/SSTs_C_" + startyear + "_" + nyears +"_" + Experiment)                  ; open workstation

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

  res@cnMinLevelValF  = 0.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 30.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 3.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual SST from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;

  res@gsnCenterString         = "JJA SST from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;

  res@gsnCenterString         = "DJF SST from " + Experiment
  plot(2)= gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "SST, C, " + Experiment ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot




toplotAnn = landmask * dim_avg_n(SSTs_clim,0)
toplotJJA = landmask *(SSTs_clim(5,:,:) + SSTs_clim(6,:,:) + SSTs_clim(7,:,:))/3.0
toplotDJF = landmask *(SSTs_clim(11,:,:) + SSTs_clim(0,:,:) + SSTs_clim(1,:,:))/3.0

toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats
toplotAnn&lon = lons

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)

wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/TS_" + startyear + "_" + nyears +"_" + Experiment)                  ; open workstation

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

  res@cnMinLevelValF  = 268.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 302.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual TS from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;

  res@gsnCenterString         = "JJA TS from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;

  res@gsnCenterString         = "DJF TS from " + Experiment
  plot(2)= gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "TS, K, " + Experiment ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot


toplotAnn = dim_avg_n(U10_clim,0)
toplotJJA = (U10_clim(5,:,:) + U10_clim(6,:,:) + U10_clim(7,:,:))/3.0
toplotDJF = (U10_clim(11,:,:) + U10_clim(0,:,:) + U10_clim(1,:,:))/3.0

toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats
toplotAnn&lon = lons

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)


wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/U10_" + startyear + "_" + nyears +"_" + Experiment)                  ; open workstation

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

  res@cnMinLevelValF  = 0.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 14.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual U10 speed from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;

  res@gsnCenterString         = "JJA U10 speed from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;

  res@gsnCenterString         = "DJF U10 speed from " + Experiment
  plot(2)= gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "U10, m/s, " + Experiment ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

toplotAnn = dim_avg_n(Precip_clim,0)
toplotJJA = (Precip_clim(5,:,:) + Precip_clim(6,:,:) + Precip_clim(7,:,:))/3.0
toplotDJF = (Precip_clim(11,:,:) + Precip_clim(0,:,:) + Precip_clim(1,:,:))/3.0

toplotAnn!0 = "lat"
toplotAnn!1 = "lon"

toplotAnn&lat = lats
toplotAnn&lon = lons

toplotAnn&lat@units="degrees_north"
toplotAnn&lon@units="degrees_east"

copy_VarCoords(toplotAnn,toplotJJA)
copy_VarCoords(toplotAnn,toplotDJF)


wks = gsn_open_wks ("eps","$HOME/Figures/DEF_PTESTS/Precip_" + startyear + "_" + nyears +"_" + Experiment)                  ; open workstation

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

  res@cnMinLevelValF  = 0.0                    ; set the minimum contour level
  res@cnMaxLevelValF  = 10.0                     ; set the maximum contour level
  res@cnLevelSpacingF       = 0.5      ; contour spacing

; Annual first
  res@gsnCenterString         = "Annual Precip from " + Experiment
  plot(0) = gsn_csm_contour_map_ce(wks,toplotAnn,res) ;

  res@gsnCenterString         = "JJA Precip from " + Experiment
  plot(1) = gsn_csm_contour_map_ce(wks,toplotJJA,res) ;

  res@gsnCenterString         = "DJF Precip from " + Experiment
  plot(2)= gsn_csm_contour_map_ce(wks,toplotDJF,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "Precip, mm/day, " + Experiment ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot




end



