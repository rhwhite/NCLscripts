load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =10
startyear = 88

LMdir = "/home/disk/eos4/rachel/MPIESM/ECHAM4.6/echam_test1/echam4_ini/T42/"
lm_file = addfile(LMdir + "jan42m.nc","r")

Mask = lm_file->SLM(:,1:128) ;0 is sea, 1 is land

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
SST = cdf_file->tsurf(0,:,:)

nlats = dimsizes(lat)
nlons = dimsizes(lon)

print(nlats)
print(nlons)

ntimes = nyears * 12

print(ntimes)
SSTs = new((/3,ntimes/),typeof(SST))
months = new(ntimes,integer)

count = 0

print(dimsizes(Mask))
print(dimsizes(SST))
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
		if iyear .lt. 100
			yearstring = ("00" + tostring(iyear))
		else
			yearstring = "0" + tostring(iyear)
		end if

	filename = (Directory + Experiment + "_" + yearstring + ".nc")

	cdf_file = addfile(filename,"r")
	do imonth = 0,11

		SST = cdf_file->tsurf(imonth,:,:)
		SST = mask(SST,Mask.eq.0,True)
		SSTs(0,count) = dim_avg(dim_avg(SST(:,:)))
		count = count + 1
	end do

end do
print(count)

ExperimentObs2 = "year42m.nc"
filename = (LMdir + ExperimentObs2)
cdf_file = addfile(filename,"r")


count = 0
do iyear=0,(nyears-1)
        print(iyear*1)

        do imonth = 0,11

                SST2 =  cdf_file->sst(imonth,:,:)
                SST2=mask(SST2,Mask.eq.0,True)
                SSTs(1,count) = dble2flt(dim_avg(dim_avg(SST2(:,:))))

                count = count + 1
        end do

end do
print(count)




filename = (DirectoryObs + ExperimentsObs)
cdf_file = addfile(filename,"r")

latO = cdf_file->lat
lonO = cdf_file->lon

nlatsO = dimsizes(latO)
nlonsO = dimsizes(lonO)

count = 0
do iyear=0,(nyears-1)
	print(iyear*1)

	do imonth = 0,11
	
		SSTo =  cdf_file->SST_cpl(imonth,:,:)
		SSTo=mask(SSTo,SSTo.ne.0,True)
		SSTs(2,count) = dim_avg(dim_avg(SSTo(:,:))) +273.15

		count = count + 1
	end do

end do
print(count)

months = ispan(1,count,1)
print(dimsizes(months))
 wks   = gsn_open_wks ("eps","$HOME/Figures/DEF_ECHAM/SSTs_GM_ts_"+nyears+"yrs" + Experiment)  

 res                   = True                      ; plot mods desired
 res@tiMainString      = Experiment + "blue + " + ExperimentObs2 + " green + :C:" + ExperimentsObs + " red"        ; add title
res@tiMainFontHeightF  = 0.02
 ;res@pmLegendDisplayMode    = "Always"              ; turn on legend
 ;res@lgPerimOn              = False      ; No legend perimeter.
 ;res@pmLegendOrthogonalPosF = -0.005      ; Move closer to plot

; res@pmLegendHeightF        = 0.12                  ; height of legend.
; res@lgLabelFontHeightF     = .015                   ; change font height
; labels for the legend
; res@xyExplicitLegendLabels = (/"Eq Atl 44m MLD","Eq Pac 45m MLD","N Atl 260m MLD","N Atl 444m MLD","South Pac"/)

 res@xyLineColors      = (/"blue","green","red"/)          ; change line color

 plot  = gsn_csm_xy (wks,months,SSTs,res) ; create plot


