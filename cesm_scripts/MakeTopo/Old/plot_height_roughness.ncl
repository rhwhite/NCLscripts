load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;begin

filenamein = "/home/disk/eos4/rachel/inputdata/topo/USGS-gtopo30_1.9x2.5_remap_c050602.nc"

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
nlats = dims1(0)
nlons = dims1(1)
print(nlats)
print(nlons)

HGTS = new((/nlats * nlons/),typeof(gpt))
SGH = new((/nlats * nlons/),typeof(gpt))
SGH30 = new((/nlats * nlons/),typeof(gpt))
count = 0

do ix = 0,nlats-1
	do iy = 0,nlons-1
		if(gpt(ix,iy) .GT. 0.0)
			HGTS(count) = gpt(ix,iy)

			SGH(count) = sgh(ix,iy)
			SGH30(count) = sgh30(ix,iy)
			count = count + 1
		end if
	end do
end do

  wks   = gsn_open_wks ("ps","scatter_HGT_SGH")            ; open workstation
  plots = new(2,graphic)
  res                   = True                     ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame

  res@gsnMaximize       = True                     ; maximize plot
  res@tiMainString      = "Scatter Plot"           ; add title
  res@xyMarkLineMode    = "Markers"                ; choose to use markers
  res@xyMarkers         =  16                      ; choose type of marker  
  res@xyMarkerColor     = "NavyBlue"               ; Marker color
  res@xyMarkerSizeF     = 0.005                     ; Marker size (default 0.01)

  res@gsnCenterString         = "height against standard deviation of 10min"

  plots(0)  = gsn_csm_xy (wks,HGTS(0:count-1),SGH(0:count-1),res)                    ; create plot
  res@gsnCenterString         = "height against standard deviation of 30s-10min"

  plots(1)  = gsn_csm_xy (wks,HGTS(0:count-1),SGH30(0:count-1),res)      

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plots,(/2,1/),resP)

  gsn_panel(wks,plots,(/2,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


