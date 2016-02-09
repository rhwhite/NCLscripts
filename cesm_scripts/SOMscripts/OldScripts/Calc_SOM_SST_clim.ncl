load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =5

Experiments = (/"CESMSOM2topof19g16"/) 

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

nlats = dimsizes(lat)
nlons = dimsizes(lon)

print(nlats)
print(nlons)

ndims = dimsizes(SST)

ntimes = nyears

print(ntimes)
SSTs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))

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

	SST = cdf_file->SST

	SSTs(imonth-1,:,:,count) = SST(0,:,:)


	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM = dim_avg(SSTs)

ndims = dimsizes(SSTs_clim_SOM)
print(ndims)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
diro = "/home/disk/eos4/rachel/inputdata/ssts/"
filo = "SSTs_Clim_comp_" + Experiments + ".cam2.h0.nc"
system("/bin/rm -f " + diro + filo)
fout_std = addfile(diro + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"month","lat","lon"/)
dimSizes = (/ndims(0),ndims(1),ndims(2)/)
dimUnlim = (/False,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lats),getvardims(lats))
filevardef(fout_std,"lon",typeof(lons),getvardims(lons))

filevardef(fout_std,"SSTs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SSTs_clim_Had",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SSTs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

fout_std->lat = (/lats/)
fout_std->lon = (/lons/)



filename = ("/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc")

cdf_file = addfile(filename,"r")
print("file read in")
SSTs_clim_Had = cdf_file->SST_cpl + 273.15


SSTs_clim_Had!0="month"
SSTs_clim_Had!1="lat"
SSTs_clim_Had!2="lon"

SSTs_clim_SOM!0="month"
SSTs_clim_SOM!1="lat"
SSTs_clim_SOM!2="lon"

SSTs_clim_SOM&lat = lats
SSTs_clim_SOM&lon = lons

SSTs_clim_Had&lat = lats
SSTs_clim_Had&lon = lons


SSTs_clim_Had&lat@units="degree_north"
SSTs_clim_Had&lon@units="degree_east"

SSTs_clim_SOM&lat@units="degree_north"
SSTs_clim_SOM&lon@units="degree_east"

fout_std->SSTs_clim_SOM = (/SSTs_clim_SOM/)
fout_std->SSTs_clim_Had = (/SSTs_clim_Had/)

SSTs_clim_diff = SSTs_clim_SOM - SSTs_clim_Had

SSTs_clim_diff!0="month"
SSTs_clim_diff!1="lat"
SSTs_clim_diff!2="lon"

SSTs_clim_diff&lat = lats
SSTs_clim_diff&lon = lons


SSTs_clim_diff&lat@units="degree_north"
SSTs_clim_diff&lon@units="degree_east"

fout_std->SSTs_clim_diff = (/SSTs_clim_diff/)


SSTs_AM_SOM = dim_avg_n(SSTs_clim_SOM,0)
SSTs_AM_Had = dim_avg_n(SSTs_clim_Had,0)
SSTs_AM_diffs = SSTs_AM_SOM - SSTs_AM_Had


SSTs_AM_SOM!0="lat"
SSTs_AM_SOM!1="lon"

SSTs_AM_SOM&lat = lats
SSTs_AM_SOM&lon = lons

SSTs_AM_SOM&lat@units="degree_north"
SSTs_AM_SOM&lon@units="degree_east"


SSTs_AM_Had!0="lat"
SSTs_AM_Had!1="lon"

SSTs_AM_Had&lat = lats
SSTs_AM_Had&lon = lons

SSTs_AM_Had&lat@units="degree_north"
SSTs_AM_Had&lon@units="degree_east"


SSTs_AM_diffs!0="lat"
SSTs_AM_diffs!1="lon"

SSTs_AM_diffs&lat = lats
SSTs_AM_diffs&lon = lons

SSTs_AM_diffs&lat@units="degree_north"
SSTs_AM_diffs&lon@units="degree_east"

  wks   = gsn_open_wks ("eps","SSTs_SOM2_diffs")                  ; open workstation

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

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources

  res@cnMinLevelValF  = 272.0			; set the minimum contour level
  res@cnMaxLevelValF  = 302.0			; set the maximum contour level
  res@cnLevelSpacingF       = 2.0      ; contour spacing

  plot(0) = gsn_csm_contour_map_ce(wks,SSTs_AM_SOM,res) ;

  plot(1) = gsn_csm_contour_map_ce(wks,SSTs_AM_Had,res) ;


  res@cnMinLevelValF  = -2.0			; set the minimum contour level
  res@cnMaxLevelValF  = 2.0			; set the maximum contour level
  res@cnLevelSpacingF       = 0.25      ; contour spacing

  plot(2) = gsn_csm_contour_map_ce(wks,SSTs_AM_diffs,res) ;

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@txString         = "SSTs, K"              ; add common title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= (/"SOM_clim","Had_clim","Diffs"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

