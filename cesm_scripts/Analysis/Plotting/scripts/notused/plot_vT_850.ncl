load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nyears = 40

secdays = 86400.0

Experiments = (/"CESMtopof19","CESMnoRTf19","CESMnoRf19","CESMnoTf19","CESMnoT2f19"/);,"CESMnotopof19"
print(Experiments)

nexps = dimsizes(Experiments)

diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(0) + "/atm/hist/"
filo = "EKE_EV_bpf_DJF_" + tostring(nyears) + "_" + Experiments(0) + ".cam2.h1.nc"
cdf_file = addfile(diro + filo, "r")

ndims = dimsizes(cdf_file->vth_850bpf)

VTH850 = new((/nexps,ndims(1),ndims(2)/),typeof(cdf_file->vth_850bpf))

VTH850(0,:,:) = dim_avg_n(cdf_file->vth_850bpf(:,:,:),0)

lats = cdf_file->lat
lons = cdf_file->lon

delete(cdf_file)

do iexp = 1,nexps-1

	diro = "/home/disk/eos4/rachel/CESM_outfiles/" + Experiments(iexp) + "/atm/hist/"
	filo = "EKE_EV_bpf_DJF_" + tostring(nyears) + "_" + Experiments(iexp) + ".cam2.h1.nc"

	cdf_file = addfile(diro + filo, "r")

	VTH850(iexp,:,:) = dim_avg_n(cdf_file->vth_850bpf(:,:,:),0)
	
	delete(cdf_file)

end do

toplot850 = new((/6,ndims(1),ndims(2)/),typeof(VTH850))
toplot850(0,:,:) = VTH850(0,:,:)
toplot850(1,:,:) =  VTH850(0,:,:) - VTH850(1,:,:)
toplot850(2,:,:) =  VTH850(0,:,:) - VTH850(2,:,:)
toplot850(3,:,:) =  VTH850(0,:,:) - VTH850(3,:,:)
toplot850(4,:,:) =  VTH850(0,:,:) - VTH850(4,:,:)
toplot850(5,:,:) =  toplot850(1,:,:) - toplot850(2,:,:) - toplot850(3,:,:)


titles = new((/6/),typeof(Experiments))
titles(0) = Experiments(0)
titles(1) =  "(topo - noRT)"
titles(2) =  "(topo - noR)" 
titles(3) =  "(topo - noT)" 
titles(4) =  "(topo - noT2)" 
titles(5) =  titles(1) + "-" + titles(2) + "-" + titles(3)

toplot850!1 = "lat"
toplot850!2 = "lon"

toplot850&lat = lats
toplot850&lon = lons

toplot850&lat@units="degree_north"
toplot850&lon@units="degree_east"


; plot
; plot one = 850mb

  wks   = gsn_open_wks ("eps","Figures/VTHbpf_850mb_40yrs_f19")                  ; open workstation

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
  res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(0)  

  res@lbOrientation   = "Vertical"                ; vertical label bar

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = 0.0			; set the minimum contour level
  res@cnMaxLevelValF  = 16.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,toplot850(0,:,:),res) ;
  res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(1)  


  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.4      ; contour spacing

  plot(1) = gsn_csm_contour_map_ce(wks,toplot850(1,:,:),res) ;

   res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(2)  

  plot(2) = gsn_csm_contour_map_ce(wks,toplot850(2,:,:),res) ;

   res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(3)  
  plot(3) = gsn_csm_contour_map_ce(wks,toplot850(3,:,:),res) ;

   res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(4)  
  plot(4) = gsn_csm_contour_map_ce(wks,toplot850(4,:,:),res) ;

    res@gsnCenterString         = "bpf VTH at 850mb,mKs:S:-1:N:, " + titles(5)  
  res@cnMinLevelValF  = -1.0			; set the minimum contour level
  res@cnMaxLevelValF  = 1.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.2      ; contour spacing

  plot(5) = gsn_csm_contour_map_ce(wks,toplot850(5,:,:),res) ;

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