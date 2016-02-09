load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =40

Directory1 = "/home/disk/eos4/rachel/CESM_outfiles/"
;Directory1 = "/home/disk/rachel/CESM_outfiles/"
Experiments1 = (/"CESMSOM4topof19g16"/) 

;Directory2 = "/home/disk/eos4/rachel/CESM_outfiles/"
;Directory2 = "/home/disk/rachel/CESM_outfiles/"
;Experiments2 = (/"CESMSOM3topof19g16"/) 

Directory3 = "/home/disk/eos4/rachel/inputdata/ssts/"
Experiments3 = (/"sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"/) 


; Now read in all U,V and T/theta values before we subtract the mean values

iyear = 151
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = (Directory1 + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lat = cdf_file->lat
lon = cdf_file->lon
SST = cdf_file->SST

nlats = dimsizes(lat)
nlons = dimsizes(lon)

print(nlats)
print(nlons)

SST = mask(SST,SST.ne.0,True)

ntimes = nyears * 12

print(ntimes)
SSTs = new((/2,ntimes/),typeof(SST))
months = new(ntimes,integer)

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

	filename = (Directory1 + Experiments1 + "/atm/hist/" + Experiments1 + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SST = cdf_file->SST
	SST = mask(SST,SST.ne.0,True)

	SSTs(0,count) = dim_avg(dim_avg(SST(0,:,:)))

	months(count) = count + 1
	count = count + 1
	end do
end do

count = 0
do iyear=0,(nyears-1)
	print(iyear*1)

	filename = (Directory3 + Experiments3)

	cdf_file = addfile(filename,"r")

	do imonth = 0,11
	
        SST = cdf_file->SST_cpl(imonth,:,:)
        SST = mask(SST,SST.ne.0,True)

        SSTs(1,count) = dim_avg(dim_avg(SST(0,:,:))) + 273.15


	count = count + 1
	end do

end do


 wks   = gsn_open_wks ("eps","$HOME/Figures/SOMtest/SSTs_GM_ts_"+nyears+"yrs" + Experiments1)                  ; open workstation

 res                   = True                      ; plot mods desired
 res@tiMainString      = Experiments1 + "(blue), " + Experiments3 + "(red), :C:"        ; add title
res@tiMainFontHeightF  = 0.02  

 res@xyLineColors      = (/"blue","red"/)          ; change line color
 res@xyDashPatterns      = (/1,1/)          ; change line color

 plot  = gsn_csm_xy (wks,months,SSTs,res) ; create plot


