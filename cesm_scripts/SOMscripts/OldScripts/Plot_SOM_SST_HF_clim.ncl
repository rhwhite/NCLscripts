load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =30

Experiments = (/"CESMSOMtopof19g16"/)
Experiments2 = (/"CESMtopof19"/) 

iyear = 150
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

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
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=150,(150+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)
	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)


	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM = dim_avg(SSTs)
SHFs_clim_SOM = dim_avg(SHFs)
LHFs_clim_SOM = dim_avg(LHFs)

delete([/SSTs,LHFs,SHFs/])

nyears =40

ntimes = nyears

SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 


count = 0
print(count)
  
do iyear=150,(150+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)
	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1

end do

;create mean

SSTs_clim_SOM_2 = dim_avg(SSTs)
SHFs_clim_SOM_2 = dim_avg(SHFs)
LHFs_clim_SOM_2 = dim_avg(LHFs)

delete([/SSTs,LHFs,SHFs/])

nyears = 10

ntimes = nyears

SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

count = 0
print(count)
  
do iyear=170,(170+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)
	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1

end do

;create mean

SSTs_clim_SOM_3 = dim_avg(SSTs)
SHFs_clim_SOM_3 = dim_avg(SHFs)
LHFs_clim_SOM_3 = dim_avg(LHFs)

delete([/SSTs,LHFs,SHFs/])

nyears = 10

ntimes = nyears

SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

count = 0
print(count)
  
do iyear=180,(180+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->SST(0,:,:)
	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)

	end do
	count = count + 1

end do

;create mean

SSTs_clim_SOM_4 = dim_avg(SSTs)
SHFs_clim_SOM_4 = dim_avg(SHFs)
LHFs_clim_SOM_4 = dim_avg(LHFs)

delete([/SSTs,LHFs,SHFs/])



ndims = dimsizes(SSTs_clim_SOM)
print(ndims)

;Get fluxes from fixed SST run

iy = 2
yearstring = tostring(iy)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.000" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->TS

ndims = dimsizes(SST)

nyears = 30
ntimes = nyears

print(ntimes)
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=iy,(iy+nyears-1)
	print(iyear*1)
		if iyear .lt. 10
			yearstring = ("0" + tostring(iyear))
		else
			yearstring = tostring(iyear)
		end if
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if


	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.00" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(imonth-1,:,:,count) = cdf_file->TS(0,:,:)
	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)

	end do

	count = count + 1

end do

;create mean

SSTs_clim_HAD = dim_avg(SSTs)
SHFs_clim_HAD = dim_avg(SHFs)
LHFs_clim_HAD = dim_avg(LHFs)

ndims = dimsizes(SSTs_clim_SOM)
print(ndims)

SHFs_clim_diff = SHFs_clim_SOM - SHFs_clim_HAD
LHFs_clim_diff = LHFs_clim_SOM - LHFs_clim_HAD
HFs_clim_diff_1 = SHFs_clim_diff + LHFs_clim_diff

SHFs_clim_diff = SHFs_clim_SOM_2 - SHFs_clim_HAD
LHFs_clim_diff = LHFs_clim_SOM_2 - LHFs_clim_HAD
HFs_clim_diff_2 = SHFs_clim_diff + LHFs_clim_diff

SHFs_clim_diff = SHFs_clim_SOM_3 - SHFs_clim_HAD
LHFs_clim_diff = LHFs_clim_SOM_3 - LHFs_clim_HAD
HFs_clim_diff_3 = SHFs_clim_diff + LHFs_clim_diff

SHFs_clim_diff = SHFs_clim_SOM_4 - SHFs_clim_HAD
LHFs_clim_diff = LHFs_clim_SOM_4 - LHFs_clim_HAD
HFs_clim_diff_4 = SHFs_clim_diff + LHFs_clim_diff




HFs_AM_diff_1 = dim_avg_n(HFs_clim_diff_1,0)
HFs_AM_diff_2 = dim_avg_n(HFs_clim_diff_2,0)
HFs_AM_diffs = HFs_AM_diff_1 - HFs_AM_diff_2
HFs_AM_diff_3 = dim_avg_n(HFs_clim_diff_3,0)
HFs_AM_diff_4 = dim_avg_n(HFs_clim_diff_4,0)

HFs_AM_diff_1!0="lat"
HFs_AM_diff_1!1="lon"

HFs_AM_diff_1&lat = lats
HFs_AM_diff_1&lon = lons

HFs_AM_diff_1&lat@units="degree_north"
HFs_AM_diff_1&lon@units="degree_east"

HFs_AM_diff_2!0="lat"
HFs_AM_diff_2!1="lon"

HFs_AM_diff_2&lat = lats
HFs_AM_diff_2&lon = lons

HFs_AM_diff_2&lat@units="degree_north"
HFs_AM_diff_2&lon@units="degree_east"

HFs_AM_diff_3!0="lat"
HFs_AM_diff_3!1="lon"

HFs_AM_diff_3&lat = lats
HFs_AM_diff_3&lon = lons

HFs_AM_diff_3&lat@units="degree_north"
HFs_AM_diff_3&lon@units="degree_east"


HFs_AM_diff_4!0="lat"
HFs_AM_diff_4!1="lon"

HFs_AM_diff_4&lat = lats
HFs_AM_diff_4&lon = lons

HFs_AM_diff_4&lat@units="degree_north"
HFs_AM_diff_4&lon@units="degree_east"


HFs_AM_diffs!0="lat"
HFs_AM_diffs!1="lon"

HFs_AM_diffs&lat = lats
HFs_AM_diffs&lon = lons

HFs_AM_diffs&lat@units="degree_north"
HFs_AM_diffs&lon@units="degree_east"


  wks   = gsn_open_wks ("eps","HFs_10yrs_SOM_diffs")                  ; open workstation

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(4,graphic)                          ; create a plot array

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

  res@cnMinLevelValF  = -40.0			; set the minimum contour level
  res@cnMaxLevelValF  = 40.0			; set the maximum contour level
  res@cnLevelSpacingF       = 10.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,HFs_AM_diff_1,res) ;

  plot(1) = gsn_csm_contour_map_ce(wks,HFs_AM_diff_2,res) ;
  res@cnMinLevelValF  = -4.0			; set the minimum contour level
  res@cnMaxLevelValF  = 4.0			; set the maximum contour level
  res@cnLevelSpacingF       = 1.0      ; contour spacing

  plot(2) = gsn_csm_contour_map_ce(wks,HFs_AM_diffs_3,res) ;

;  plot(3) = gsn_csm_contour_map_ce(wks,HFs_AM_diff_4,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "Air-sea heat flux, W/m2"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= (/"years 1-10","years 1-40","difference"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  gsn_panel(wks,plot,(/4,1/),resP)               ; now draw as one plot

