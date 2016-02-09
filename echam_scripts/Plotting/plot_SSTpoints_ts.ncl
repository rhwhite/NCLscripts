load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =10
startyear = 88

plotlats = (/15.7, 60.3, 62.5,-30.0/)
plotlons = (/315.0, 345.0, 341.0, 250.0/)

npoints = dimsizes(plotlats)

print(dimsizes(plotlats))

Experiment = ("test1")
Directory = "/home/disk/eos4/rachel/MPIESM/ECHAM4.6/echam_test1/output/" + Experiment + "/PProc/"

DirectoryObs = "/home/disk/eos4/rachel/inputdata/ssts/"
ExperimentsObs = (/"sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"/) 

; Now read in all U,V and T/theta values before we subtract the mean values

iyear = startyear
yearstring = "00" + tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = (Directory + Experiment + "_" + yearstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lat = cdf_file->lat
lon = cdf_file->lon
SST = cdf_file->tsurf(0:11,:,:)

nlats = dimsizes(lat)
nlons = dimsizes(lon)

print(nlats)
print(nlons)

; find plotlons and plotlats

plotlonidx = new((/npoints/),integer)
plotlatidx = new((/npoints/),integer)


do ilat=1,nlats-1
	print(ilat*1)
	if (lat(ilat-1) .GT. plotlats(0) .AND. lat(ilat) .LE. plotlats(0))
		plotlatidx(0) = ilat
	end if
	if (lat(ilat-1) .GT. plotlats(1) .AND. lat(ilat) .LE. plotlats(1))
		plotlatidx(1) = ilat
	end if
	if (lat(ilat-1) .GT. plotlats(2) .AND. lat(ilat) .LE. plotlats(2))
		plotlatidx(2) = ilat
	end if
	if (lat(ilat-1) .GT. plotlats(3) .AND. lat(ilat) .LE. plotlats(3))
		plotlatidx(3) = ilat
	end if
end do

do ilon=1,nlons-1
	if (lon(ilon-1) .LT. plotlons(0) .AND. lon(ilon) .GE. plotlons(0))
		plotlonidx(0) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(1) .AND. lon(ilon) .GE. plotlons(1))
		plotlonidx(1) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(2) .AND. lon(ilon) .GE. plotlons(2))
		plotlonidx(2) = ilon
	end if
	if (lon(ilon-1) .LT. plotlons(3) .AND. lon(ilon) .GE. plotlons(3))
		plotlonidx(3) = ilon
	end if
end do

print(plotlatidx)
print(plotlonidx)

ntimes = nyears * 12

print(ntimes)
SSTs = new((/npoints*2,ntimes/),typeof(SST))
months = new(ntimes,integer)

count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
		if iyear .lt. 100
			yearstring = ("00" + tostring(iyear))
		else
			yearstring = "0" + tostring(iyear)
		end if

	filename = (Directory + Experiment + "_" + yearstring + ".nc")

	cdf_file = addfile(filename,"r")

	SST = cdf_file->tsurf(0:11,:,:)
	do n=0,npoints-1
		SSTs(n,count:count+11) = SST(:,plotlatidx(n),plotlonidx(n))
	end do

	count = count + 12
end do
print(count)

filename = (DirectoryObs + ExperimentsObs)
cdf_file = addfile(filename,"r")

latO = cdf_file->lat
lonO = cdf_file->lon

nlatsO = dimsizes(latO)
nlonsO = dimsizes(lonO)

plotlonidxO = new((/npoints/),integer)
plotlatidxO = new((/npoints/),integer)


do ilat=1,nlatsO-1
        print(ilat*1)
        if (latO(ilat-1) .LT. plotlats(0) .AND. latO(ilat) .GE. plotlats(0))
                plotlatidxO(0) = ilat
        end if
        if (latO(ilat-1) .LT. plotlats(1) .AND. latO(ilat) .GE. plotlats(1))
                plotlatidxO(1) = ilat
        end if
        if (latO(ilat-1) .LT. plotlats(2) .AND. latO(ilat) .GE. plotlats(2))
                plotlatidxO(2) = ilat
        end if
        if (latO(ilat-1) .LT. plotlats(3) .AND. latO(ilat) .GE. plotlats(3))
                plotlatidxO(3) = ilat
        end if
end do

do ilon=1,nlonsO-1
        if (lonO(ilon-1) .LT. plotlons(0) .AND. lonO(ilon) .GE. plotlons(0))
                plotlonidxO(0) = ilon
        end if
        if (lonO(ilon-1) .LT. plotlons(1) .AND. lonO(ilon) .GE. plotlons(1))
                plotlonidxO(1) = ilon
        end if
        if (lonO(ilon-1) .LT. plotlons(2) .AND. lonO(ilon) .GE. plotlons(2))
                plotlonidxO(2) = ilon
        end if
        if (lonO(ilon-1) .LT. plotlons(3) .AND. lonO(ilon) .GE. plotlons(3))
                plotlonidxO(3) = ilon
        end if
end do

print(plotlatidxO)
print(plotlonidxO)



count = 0
do iyear=0,(nyears-1)
	print(iyear*1)

	filename = (DirectoryObs + ExperimentsObs)

	cdf_file = addfile(filename,"r")

	do imonth = 0,11
	
		do n=0,npoints-1
			temp =  cdf_file->SST_cpl(imonth,plotlatidxO(n),plotlonidxO(n))
			SSTs(n+(npoints),count) = temp+273.15
			delete(temp)

		end do
		count = count + 1
	end do

end do
print(count)

months = ispan(1,count,1)
print(dimsizes(months))
 wks   = gsn_open_wks ("eps","$HOME/Figures/DEF_ECHAM/SSTs_ts_"+nyears+"yrs" + Experiment)  

 res                   = True                      ; plot mods desired
 res@tiMainString      = Experiment + "(--), :C:" + ExperimentsObs + "(-)"        ; add title
res@tiMainFontHeightF  = 0.02
 ;res@pmLegendDisplayMode    = "Always"              ; turn on legend
 ;res@lgPerimOn              = False      ; No legend perimeter.
 ;res@pmLegendOrthogonalPosF = -0.005      ; Move closer to plot

; res@pmLegendHeightF        = 0.12                  ; height of legend.
; res@lgLabelFontHeightF     = .015                   ; change font height
; labels for the legend
; res@xyExplicitLegendLabels = (/"Eq Atl 44m MLD","Eq Pac 45m MLD","N Atl 260m MLD","N Atl 444m MLD","South Pac"/)

 res@xyLineColors      = (/"blue","red","green","purple","blue","red","green","purple"/)          ; change line color
 res@xyDashPatterns      = (/1,1,1,1,0,0,0,0/)          ; change line color

 plot  = gsn_csm_xy (wks,months,SSTs,res) ; create plot


