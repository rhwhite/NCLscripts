;================================================;
;  Popscal_3.ncl
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105.nc","r")

  mld         = f->hblt              ; (time, z_t, nlat, nlon)

  mld@lon2d   = f->xc             ; associate 2D arrays containing
  mld@lat2d   = f->yc              ; coordinates with variable
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("eps","pop_mld")             ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap

  res                      = True                 ; plot mods desired
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point

  plot = gsn_csm_contour_map_ce(wks,mld(0,:,:),res) ; time=0, z_t=0        
  end