load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMnotopof19","CESM_onlyIM2","CESM_onlyITSh","CESM_onlyIT","CESM_onlyIT2","CESM_onlyITVVS","CESM_onlyIT4"/)

print(Experiments)

nexps = dimsizes(Experiments)

titles = new((/nexps/),typeof(Experiments))
titles(0) =  "NoTopo"
titles(1) =  "Thin Altai - NoTopo"
titles(2) =  "Thick Altai - NoTopo"
titles(3) =  "Tibet - NoTopo"
titles(4) =  "Thick high Altai - NoTopo"
titles(5) =  "Thick short Altai - NoTopo"
titles(6) =  "Thick narrow Altai - NoTopo"

diro = "/home/disk/rachel/CESM_outfiles/"
filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs_mean = cdf_file->lev_p

; Find 925 and 250hpa levels
levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

nlev_925 = -1
nlev_250 = -1

do nl = 0,nlevs-1
	if levs_mean(nl) .EQ. 925 then
		nlev_925 = nl
	end if
	if levs_mean(nl) .EQ. 250 then
		nlev_250 = nl
	end if
end do

if (nlev_925 .LT. 0 .OR. nlev_250 .LT. 0) then
	print("didnt find a level")
	exit
end if

ndims = dimsizes(cdf_file->U)
nlons = ndims(3)
nlats = ndims(2)

print(nlons)
print(nlats)

U250 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
U925 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))
V250 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->V))
V925 = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->V))
PHIS = new((/nexps,ndims(2),ndims(3)/),typeof(cdf_file->U))

U250(0,:,:) = cdf_file->U(0,nlev_250,:,:)
U925(0,:,:) = cdf_file->U(0,nlev_925,:,:)
V250(0,:,:) = cdf_file->V(0,nlev_250,:,:)
V925(0,:,:) = cdf_file->V(0,nlev_925,:,:)

filo = Experiments(0) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

levs = cdf_file->lev
nlev = dimsizes(levs)
if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
end if

PS = cdf_file->PS
PHIS(0,:,:) = cdf_file->PHIS(0,:,:) / 9.8

lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)


do iy = 0,nlons-1
	do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 25000) then
			U250(0,ix,iy) = U250@_FillValue
			V250(0,ix,iy) = V250@_FillValue
		end if
		if (PS(0,ix,iy) .LT. 92500) then
			U925(0,ix,iy) = U925@_FillValue
			V925(0,ix,iy) = V925@_FillValue
		end if


	end do
end do

delete(PS)


do iexp = 1,nexps-1

	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_pl_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs_mean = cdf_file->lev_p

; Check levs
	if levs_mean(nlev_925) .NE. 925 then
		print(levs_mean(nlev_925))
		print("should be 925!")
		exit
	end if
	if levs_mean(nlev_250) .NE. 250 then
		print(levs_mean(nlev_250))
		print("should be 250!")
		exit
	end if


	U250(iexp,:,:) = cdf_file->U(0,nlev_250,:,:)
	U925(iexp,:,:) = cdf_file->U(0,nlev_925,:,:)
	V250(iexp,:,:) = cdf_file->V(0,nlev_250,:,:)
	V925(iexp,:,:) = cdf_file->V(0,nlev_925,:,:)
	


	filo = Experiments(iexp) + "/atm/hist/DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	levs = cdf_file->lev
	nlev = dimsizes(levs)
	if (levs(nlev-1) .LT. levs(0)) then
		nlev = 1
	end if

	print(levs(nlev-1) * 1.0)

	PHIS(iexp,:,:) = cdf_file->PHIS(0,:,:) / 9.8
	PS = cdf_file->PS


	do iy = 0,nlons-1
	   do ix = 0,nlats-1
		if (PS(0,ix,iy) .LT. 25000) then
		   U250(iexp,ix,iy) = U250@_FillValue
		   V250(iexp,ix,iy) = V250@_FillValue
		end if
		if (PS(0,ix,iy) .LT. 92500) then
		   U925(iexp,ix,iy) = U925@_FillValue
		   V925(iexp,ix,iy) = V925@_FillValue
		end if
	   end do
	end do
	
	delete(PS)
	delete(cdf_file)

end do

toplotU = new((/nexps,ndims(2),ndims(3)/),typeof(U250))
toplotU2 = new((/nexps,ndims(2),ndims(3)/),typeof(U250))

toplotV = new((/nexps,ndims(2),ndims(3)/),typeof(U250))
toplotV2 = new((/nexps,ndims(2),ndims(3)/),typeof(U250))

toplotU(0,:,:) = U250(0,:,:)
toplotV(0,:,:) = V250(0,:,:)
toplotU2(0,:,:) =  U925(0,:,:)
toplotV2(0,:,:) =  V925(0,:,:)

do ep=1,nexps-1
	toplotU(ep,:,:) = U250(ep,:,:) - U250(0,:,:)
        toplotV(ep,:,:) = V250(ep,:,:) - V250(0,:,:)
        toplotU2(ep,:,:) = U925(ep,:,:) - U925(0,:,:)
        toplotV2(ep,:,:) = V925(ep,:,:) - V925(0,:,:)

end do


toplot3 = new((/nexps,ndims(2),ndims(3)/),typeof(PHIS))
toplot3(0,:,:) =  0.0
do ep = 1,nexps-1
	toplot3(ep,:,:) =  PHIS(ep,:,:) - PHIS(0,:,:)
end do

toplotU!1 = "lat"
toplotU!2 = "lon"

toplotU&lat = lats
toplotU&lon = lons

toplotU&lat@units="degree_north"
toplotU&lon@units="degree_east"

copy_VarCoords(toplotU,toplot3)
copy_VarCoords(toplotU,toplotV)
copy_VarCoords(toplotU,toplotU2)
copy_VarCoords(toplotU,toplotV2)


; plot
; plot one = 250mb

npanels = floattoint(ceil(nexps/2.0))
print(npanels)

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/IdealTvM/UV_250_40yrs_ITvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(nexps,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
;  res@gsnSpreadColors      = True                 ; use full colormap
;  res@gsnSpreadColorStart  = 10                   ; start at color 10
;  res@gsnSpreadColorEnd    = 96                   ; end at color 96
  res@gsnAddCyclic         = True                 ; add cyclic point
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0

;  res@lbOrientation   = "Vertical"                ; vertical label bar
  res@vcRefMagnitudeF         = 5.0              ; make vectors larger
  res@vcRefLengthF            = 0.01            ; ref vec length
  res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  res@vcMinDistanceF          = 0.017            ; thin out vectors

  resOv                  = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/200.0,2000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label



  res@gsnCenterString         = titles(0)              ; add common title
  plot(0) = gsn_csm_vector_map(wks,toplotU(0,:,:),toplotV(0,:,:),res) ;

  res@vcRefLengthF            = 0.05            ; ref vec length

do pp = 1,nexps-1
  res@gsnCenterString         = titles(pp)              ; add common title
  plot(pp) = gsn_csm_vector_map(wks,toplotU(pp,:,:),toplotV(pp,:,:),res) ;
  plot_ov = gsn_csm_contour(wks,toplot3(pp,:,:),resOv)
  overlay(plot(pp),plot_ov)
end do
  
  resP                  = True                   ; modify the panel plot
  resP@txString   = "mean U and V at 250mb, "
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP) 

  gsn_panel(wks,plot,(/npanels,2/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)


end
