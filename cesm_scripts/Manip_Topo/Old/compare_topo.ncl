load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

diro = "/home/disk/eos4/rachel/inputdata/topo/"
filename = diro + "USGS-gtopo30_0.9x1.25_remap_c051027.nc"

cdf_file = addfile(filename,"r")
print("file read in")

topo_f09 = cdf_file->PHIS / 9.81
lats_f09 = cdf_file->lat
lons_f09 = cdf_file->lon
ndims = dimsizes(topo_f09)
delete(cdf_file)
delete(filename)

filename = diro + "USGS-gtopo30_1.9x2.5_remap_c050602.nc"

cdf_file = addfile(filename,"r")
print("file read in")

topo_f19 = cdf_file->PHIS / 9.81
lats_f19 = cdf_file->lat
lons_f19 = cdf_file->lon

delete(cdf_file)
delete(filename)


; Regrid 2degree onto 1degree grid:
  
topo_f19_new = linint2(lons_f19,lats_f19,topo_f19,True,lons_f09,lats_f09,0)

copy_VarCoords_n(topo_f09,topo_f19_new,(/0,1/))


diffs = topo_f09 - topo_f19_new

topo_f09!0="lat"
topo_f09!1="lon"

topo_f19_new!0="lat"
topo_f19_new!1="lon"

diffs!0="lat"
diffs!1="lon"

topo_f09&lat = lats_f09
topo_f09&lon = lons_f09


topo_f19_new&lat = lats_f09
topo_f19_new&lon = lons_f09


diffs&lat = lats_f09
diffs&lon = lons_f09

topo_f09&lat@units="degree_north"
topo_f09&lon@units="degree_east"

topo_f19_new&lat@units="degree_north"
topo_f19_new&lon@units="degree_east"

diffs&lat@units="degree_north"
diffs&lon@units="degree_east"

;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("eps","topo_res_diffs")             ; open a ps file

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap

  res                      = True                 ; plot mods desired
  res@tiMainString      = "1 degree - 2degree, surface geopotential height, m"        ; add title

  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = -500.			; set the minimum contour level
  res@cnMaxLevelValF  = 1000.			; set the maximum contour level
  res@cnLevelSpacingF       = 100      ; contour spacing


  plot = gsn_csm_contour_map_ce(wks,diffs,res) ;


end