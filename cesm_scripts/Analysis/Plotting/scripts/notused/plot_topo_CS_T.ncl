load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMtopof19","CESMnoTf19","CESMnoT2f19","CESMnoT3f19"/)
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(0) + ".cam2.h0.nc"
cdf_file = addfile(diro + filo, "r")

ndims = dimsizes(cdf_file->PHIS)
nlats = ndims(1)
nlons = ndims(2)

print(nlats*1)
print(nlons*1)

startlat = (nlats/2)-1
endlat = nlats-1

temp = cdf_file->PHIS(0,startlat:endlat,:)

delete(ndims)
ndims = dimsizes(temp)
nlats = ndims(0)
nlons = ndims(1)

print(nlats*1)
print(nlons*1)

PHIS = new((/nexps,nlats,nlons/),typeof(cdf_file->PHIS))

PHIS(0,:,:) = cdf_file->PHIS(0,startlat:endlat,:)

lats = cdf_file->lat(startlat:endlat)
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "DJF" + tostring(nyears) + "_mean_" + Experiments(iexp) + ".cam2.h0.nc"
	cdf_file = addfile(diro + filo, "r")

	PHIS(iexp,:,:) = cdf_file->PHIS(0,startlat:endlat,:)
	
	delete(cdf_file)

end do

; find longitudes: between 90 and 110E

do nl = 0,nlons-2
	if lons(nl) .LE. 90.0 .AND. lons(nl+1) .GT. 90.0 then
		nlonstart = nl
	end if
	if lons(nl) .LE. 110.0 .AND. lons(nl+1) .GT. 110.0 then
		nlonend = nl+1
	end if
end do

print(nlonstart * 1)
print(nlonend * 1)

HGT_CS = dim_avg_n(PHIS(:,:,nlonstart:nlonend),2) / 9.8


toplot = new((/8,nlats/),typeof(HGT_CS))
toplot(0,:) =  HGT_CS(0,:)
toplot(1,:) =  HGT_CS(1,:)
toplot(2,:) =  HGT_CS(2,:)
toplot(3,:) =  HGT_CS(3,:)

titles = new((/8/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(noT1)" 
titles(2) =  "(noT2)" 
titles(3) =  "(noT3)" 


toplot!1 = "lat"

print(lats)
toplot&lat = tofloat(lats)


toplot&lat@units="degrees_north"

; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/HGTs_90-110E_CS_40yrs_TvsM")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(4,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@gsnCenterString         = "Surface Height Averaged over 90E to 110E " + titles(0)              ; add common title
  res@lbOrientation   = "Vertical"                ; vertical label bar
  res@trYMaxF            = 16000. 
  res@trXMaxF            = 90.
  res@trXMinF            = 0.


  plot(0) = gsn_csm_xy(wks,toplot&lat,toplot(0,:),res) ;

  res@gsnCenterString         = titles(1)
  plot(1) = gsn_csm_xy(wks,toplot&lat,toplot(1,:),res) ;

  res@gsnCenterString         = titles(2)
  plot(2) = gsn_csm_xy(wks,toplot&lat,toplot(2,:),res) ;

  res@gsnCenterString         =  titles(3)
  plot(3) = gsn_csm_xy(wks,toplot&lat,toplot(3,:),res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom

      resP@gsnDraw = False                           ; draw later, in maximize mode
      panelid1 = gsn_panel_return(wks,plot,(/4,1/),resP) 

  gsn_panel(wks,plot,(/4,1/),resP)               ; now draw as one plot

      mres = True
      maximize_output(wks,mres)



end