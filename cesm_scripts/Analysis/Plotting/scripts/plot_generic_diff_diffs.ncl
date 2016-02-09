load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

index = 1
figtitle = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
nexps = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
dir = new(2,"string")
dir(0) = getenv("NCL_ARG2_" + tostring(index))
index = index + 1

Experiments = new((/2,nexps/),"string")
Titles = new((/2,nexps/),"string")
do ne = 0,nexps-1
        Experiments(0,ne) = getenv("NCL_ARG2_" + tostring(index))
	index = index + 1
end do
do ne = 0,nexps-1
        Titles(0,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do

dir(1) = getenv("NCL_ARG2_" + tostring(index))
index = index + 1

do ne = 0,nexps-1
        Experiments(1,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do
do ne = 0,nexps-1
        Titles(1,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do
startyr = new(2,"integer")
endyr = new(2,"integer")
nyears = new(2,"integer")
startyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
endyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
nyears(0) = endyr(0)-startyr(0)+1

startyr(1) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
endyr(1) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
nyears(1) = endyr(1)-startyr(1)+1
timespan = getenv("NCL_ARG2_" + tostring(index))


index = 1
variable = getenv("NCL_ARG_" + tostring(index))
index = index + 1
ilev = toint(getenv("NCL_ARG_" + tostring(index)))
index = index + 1

plotchar = new(6,"float")
do xx = 0,5
        plotchar(xx) = tofloat(getenv("NCL_ARG_" + tostring(index)))
        index = index + 1
end do
units = getenv("NCL_ARG_" + tostring(index))

print(plotchar)
print(units)
print(dir)

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

filo = Experiments(0,0) + "/atm/hist/" + timespan + tostring(startyr(0)) + "_" + tostring(nyears(0)) + "_mean_pl_" + Experiments(0,0) + ".cam2.h0.nc"
cdf_file = addfile(dir(0) + filo, "r")

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

vartest = cdf_file->U

if (ilev .NE. 0) then
; Find correct pressure level
	levs_mean = cdf_file->lev_p

	levsizes = dimsizes(levs_mean)
	nlevs = levsizes(0)

	plev = -1

	do nl = 0,nlevs-1
	        if levs_mean(nl) .EQ. ilev then
	                plev = nl
	        end if
	end do

	if (plev .LT. 0) then
	        print("didnt find a level")
	        exit
	end if
end if

ndims2 = dimsizes(vartest)
PHIS = new((/2,nexps,nlats,nlons/),typeof(vartest))
PS = new((/2,nexps,nlats,nlons/),typeof(vartest))

delete(cdf_file)

do iexp = 0,nexps-1
	do es = 0,1
		filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
		cdf_file = addfile(dir(es) + filo, "r")

		PS(es,iexp,:,:) = cdf_file->PS(0,:,:)
	        PHIS(es,iexp,:,:) = cdf_file->PHIS/9.8

                delete(cdf_file)
	end do
end do


if (variable .EQ. "U") then
        U = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

                        U(es,iexp,:,:) = cdf_file->U(0,plev,:,:)

                        delete(cdf_file)

                end do
        end do

        plotvar = U

else if (variable .EQ. "TH") then
        TH = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

                        TH(es,iexp,:,:) = cdf_file->T(0,plev,:,:) * ((1013.0/plev)^kappa)

                        delete(cdf_file)

                end do
        end do

        plotvar = TH

else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PRECT") then
        vartemp = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")
			
			if (variable .EQ. "THS") then
                        	vartemp(es,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(es,iexp,:,:))^kappa)
			else if (variable .EQ. "PRECT") then
	                        vartemp(es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			else if (variable .EQ. "TS") then
				vartemp(es,iexp,:,:) = cdf_file->TS(0,:,:)
			end if
			end if
			end if

                        delete(cdf_file)

                end do
        end do

        plotvar = vartemp

else if (variable .EQ. "EMGR") then
        EMGR = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/EMGR_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h0.nc"

                        cdf_file = addfile(dir(es) + filo, "r")

                        EMGR(es,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

                        delete(cdf_file)

                end do
        end do

        plotvar = EMGR

else if (variable .EQ. "Zvar") then
        Zvar = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

                        cdf_file = addfile(dir(es) + filo, "r")

                        Zvar(es,iexp,:,:) = cdf_file->Z850bpf_var(:,:)

                        delete(cdf_file)

                end do
        end do

        plotvar = Zvar

else if (variable .EQ. "dTHdy") then
        dTHdy = new((/2,nexps,nlats,nlons/),typeof(vartest))
	lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

        do iexp = 0,nexps-1

                do es = 0,1
                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan +tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

			TH = cdf_file->T(0,plev,:,:) * ((1013.0/plev)^kappa)
                        dTHdy(es,iexp,:,:) =center_finite_diff_n(TH,lat_dist, False, 0, 0)

                        delete(cdf_file)

                end do
        end do

        plotvar = dTHdy

else if (variable .EQ. "Tadv" .OR. variable .EQ. "UDdTHdx" .OR. variable .EQ. "VDdTHdy" .OR. variable .EQ. "DUdThdx" .OR. variable .EQ. "DVdTHdy" .OR. variable .EQ. "UV") then
	lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

	U = new((/2,nexps,nlats,nlons/),typeof(vartest))
	V = new((/2,nexps,nlats,nlons/),typeof(vartest))
	
	TH = new((/nlats,nlons/),typeof(vartest))

	dTHdy = new((/2,nexps,nlats,nlons/),typeof(vartest))
	dTHdx = new((/2,nexps,nlats,nlons/),typeof(vartest))

        do iexp = 0,nexps-1

		do es = 0,1
		        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
		        cdf_file = addfile(dir(es) + filo, "r")

       			levs_mean = cdf_file->lev_p

       		 	; Check levs
        		if levs_mean(plev) .NE. ilev then
        	        	print("should be " + tostring(ilev))
        	        	exit
        		end if

			U(es,iexp,:,:) = cdf_file->U(0,plev,:,:)
			V(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
	
			TH = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)
	
			dTHdy(es,iexp,:,:) = center_finite_diff_n(TH,lat_dist, False, 0, 0)

			do iy=0,nlats-1
				lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
				dTHdx(es,iexp,iy,:) = center_finite_diff_n(TH(iy:iy,:),lon_dist, False, 0, 1)
			end do
		
			delete(cdf_file)
			
		end do
	end do
	if (variable .EQ. "Tadv") then
		plotvar = -1.0 * ((U * dTHdx) + (V * dTHdy))
	else if (variable .EQ. "UDdTHdx") then
		plotvar = U(:,0,:,:) * dTHdx
	else if (variable .EQ. "VDdTHdy") then
		plotvar = V(:,0,:,:) * dTHdy
	else if (variable .EQ. "DUdTHdx") then
		plotvar = U * dTHdx(:,0,:,:)
	else if (variable .EQ. "DVdTHdy") then
		plotvar = V * dTHdy(:,0,:,:)
	else if (variable .EQ. "UV") then
		plotvar = U
		plotvar2 = V
	end if
	end if
	end if
	end if
	end if
	end if

end if
end if
end if
end if
end if
end if
end if

do es = 0,1
	do iexp = 0,nexps-1
		do iy = 0,nlons-1
			do ix = 0,nlats-1
				if (PS(es,iexp,ix,iy) .LT. ilev*100) then
					plotvar(es,iexp,ix,iy) = plotvar@_FillValue
       	      				if (variable .EQ. "UV") then
						plotvar2(es,iexp,ix,iy) = plotvar2@_FillValue
		  			end if
				end if
        		end do
		end do
	end do
end do
toplot = new((/3*(nexps+1),nlats,nlons/),typeof(plotvar))
toplot2 = new((/3*(nexps+1),nlats,nlons/),typeof(plotvar))
toplotPHIS = new((/3*(nexps+1),nlats,nlons/),typeof(PHIS))
toplottitle = new(3*(nexps+1),"string")

do iplot=0,1
	toplot(iplot,:,:) = plotvar(iplot,0,:,:)
	if (variable .EQ. "UV") then
		toplot2(iplot,:,:) = plotvar2(iplot,0,:,:)
	end if
	toplottitle(iplot) = Titles(iplot,0)
	toplotPHIS(iplot,:,:) = 0.0
end do

do ep = 1,nexps-1
	do iplot =0,1
        	toplot(ep*3+iplot,:,:) = plotvar(iplot,0,:,:) - plotvar(iplot,ep,:,:)
		if (variable .EQ. "UV") then
			toplot2(ep*3+iplot,:,:) = plotvar2(iplot,0,:,:) - plotvar2(iplot,ep,:,:)
		end if
		toplotPHIS(ep*3+iplot,:,:) =  PHIS(iplot,0,:,:) - PHIS(iplot,ep,:,:)
		toplottitle(ep*3+iplot) = Titles(iplot,0) + " - " + Titles(iplot,ep)
	end do
end do

do iplot=0,1
	toplot(nexps*3+iplot,:,:) = plotvar(iplot,0,:,:) - plotvar(iplot,1,:,:) - plotvar(iplot,2,:,:) + plotvar(iplot,3,:,:)
	if (variable .EQ. "UV") then
	        toplot2(nexps*3+iplot,:,:) = plotvar2(iplot,0,:,:) - plotvar2(iplot,1,:,:) - plotvar2(iplot,2,:,:) + plotvar2(iplot,3,:,:)
	end if
	toplotPHIS(nexps*3+iplot,:,:) = PHIS(iplot,0,:,:) - PHIS(iplot,1,:,:) - PHIS(iplot,2,:,:) + PHIS(iplot,3,:,:)
	toplottitle(nexps*3+iplot) = Titles(iplot,0) + " - " + Titles(iplot,1) + " - " + Titles(iplot,2) + " + " + Titles(iplot,3)

end do

do ep = 0,nexps
	toplot(ep*3+2,:,:) = toplot(ep*3,:,:) - toplot(ep*3+1,:,:)
	if (variable .EQ. "UV") then
	        toplot2(ep*3+2,:,:) = toplot2(ep*3,:,:) - toplot2(ep*3+1,:,:)
	end if
	toplottitle(ep*3+2) = toplottitle(ep*3) + " - " + toplottitle(ep*3+1)

	toplotPHIS(ep*3+2,:,:) = 0.0
end do


toplot!1 = "lat"
toplot!2 = "lon"

toplot&lat = lats
toplot&lon = lons

toplot&lat@units="degree_north"
toplot&lon@units="degree_east"

copy_VarCoords(toplot,toplotPHIS)
if (variable .EQ. "UV") then
	copy_VarCoords(toplot,toplot2)
end if

npanels = floattoint(ceil(nexps+1))

; plot
; plot one = 850mb

if (ilev .EQ. 0) then
  plotname = variable
  plottitle = variable
else
  plotname = variable + tostring(ilev)
  plottitle = variable + " at " + tostring(ilev) + "mb"
end if

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/" + plotname + "_" + timespan + "_" + figtitle + "_diff-diffs") 

  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(npanels*3,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
   res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@mpMinLonF = -30.0
  res@mpMaxLonF = 180.0
  res@mpMinLatF = 0.0
  res@mpMaxLatF = 90.0
  res@gsnLeftString = ""
  if (variable .EQ. "UV") then
	res@vcRefMagnitudeF         = 5.0              ; make vectors larger
	res@vcRefLengthF            = 0.050            ; ref vec length
	res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
	res@vcMinDistanceF          = 0.017            ; thin out vectors
  else
 	res@cnFillOn             = True                 ; turn on color fill
  	res@cnLinesOn            = False                ; turn off contour lines
  	res@gsnSpreadColors      = True                 ; use full colormap
  	res@gsnSpreadColorStart  = 10                   ; start at color 10
  	res@gsnSpreadColorEnd    = 96                   ; end at color 96
  	res@gsnAddCyclic         = True                 ; add cyclic point
	res@lbOrientation   = "Vertical"                ; vertical label bar
  end if

  resOv = True
  resOv@gsnDraw = False                        ; do not draw the plot
  resOv@gsnFrame = False                       ; do not advance the frame
  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  resOv@cnLevels = (/-100,100.0,2000.0,4000.0/)              ; set the contour levels
  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
  resOv@cnLineLabelsOn       = False
  resOv@cnConstFLabelOn = False
  resOv@cnInfoLabelOn       = False        ; no info label

if (variable .EQ. "UV") then
  res@gsnCenterString         = toplottitle(0)
  plot(0) = gsn_csm_vector_map(wks,toplot(0,:,:),toplot2(0,:,:),res) ;
  res@gsnCenterString         = toplottitle(1)
  plot(1) = gsn_csm_vector_map(wks,toplot(1,:,:),toplot2(1,:,:),res) ;

  do pp = 2,(nexps*2)+1
    res@gsnCenterString         = toplottitle(pp)
    plot(pp) = gsn_csm_vector_map_ce(wks,toplot(pp,:,:),toplot2(pp,:,:),res) ;
    plot_ov = gsn_csm_contour(wks,toplotPHIS(pp,:,:),resOv)
    overlay(plot(pp),plot_ov)
  end do

else
  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels 
  res@cnMinLevelValF  = plotchar(0)                   ; set the minimum contour level
  res@cnMaxLevelValF  = plotchar(1)                    ; set the maximum contour level
  res@cnLevelSpacingF       = plotchar(2)      ; contour spacing

  res@gsnCenterString         = toplottitle(0)
  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;
  res@gsnCenterString         = toplottitle(1)
  plot(1) = gsn_csm_contour_map_ce(wks,toplot(1,:,:),res) ;

  res@cnMinLevelValF  = plotchar(3)                    ; set the minimum contour level
  res@cnMaxLevelValF  = plotchar(4)                     ; set the maximum contour level
  res@cnLevelSpacingF       = plotchar(5)      ; contour spacing

  res@gsnCenterString         = toplottitle(2)
  plot(2) = gsn_csm_contour_map_ce(wks,toplot(2,:,:),res) ;


  do pp = 3,(nexps*3)+2
    res@gsnCenterString         = toplottitle(pp)
    plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
    plot_ov = gsn_csm_contour(wks,toplotPHIS(pp,:,:),resOv)
    overlay(plot(pp),plot_ov)
  end do
end if

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = plottitle + ", " + units

  resP@gsnDraw = False                           ; draw later, in maximize mode

  panelid1 = gsn_panel_return(wks,plot,(/npanels,3/),resP)

  gsn_panel(wks,plot,(/npanels,3/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
