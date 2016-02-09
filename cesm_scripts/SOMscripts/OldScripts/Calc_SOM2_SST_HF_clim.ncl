load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =30

Experiments = (/"CESMSOMtopof19g16"/)
Experiments2 = (/"CESMtopof19"/) 

iyear = 151
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
SRFRADs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=151,151+nyears-1
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
	SRFRADs(imonth-1,:,:,count) = cdf_file->SRFRAD(0,:,:)


	end do
	count = count + 1
end do

;create mean

SSTs_clim_SOM = dim_avg(SSTs(:,:,:,0:count-1))
SHFs_clim_SOM = dim_avg(SHFs(:,:,:,0:count-1))
LHFs_clim_SOM = dim_avg(LHFs(:,:,:,0:count-1))
SFRs_clim_SOM = dim_avg(SRFRADs)
LSHFs_clim_SOM = LHFs_clim_SOM + SHFs_clim_SOM

delete([/"SSTs","LHFs","SHFs","SRFRADs"/])


ndims = dimsizes(SSTs_clim_SOM)
print(ndims)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
diro = "/home/disk/eos4/rachel/inputdata/ssts/"
filo = "SFLXS_Clim_comp_" + Experiments + "_" + Experiments2 + ".cam2.h0.nc"
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
dimUnlim = (/True,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lats),getvardims(lats))
filevardef(fout_std,"lon",typeof(lons),getvardims(lons))

filevardef(fout_std,"SSTs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SSTs_clim_HAD",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SSTs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

filevardef(fout_std,"SHFs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SHFs_clim_HAD",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SHFs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

filevardef(fout_std,"LHFs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"LHFs_clim_HAD",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"LHFs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

filevardef(fout_std,"LSHFs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"LSHFs_clim_HAD",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"LSHFs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

filevardef(fout_std,"SFRs_clim_SOM",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SFRs_clim_HAD",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"SFRs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))

filevardef(fout_std,"HFs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))
filevardef(fout_std,"AllHFs_clim_diffs",typeof(SSTs_clim_SOM),(/"month","lat","lon"/))


fout_std->lat = (/lats/)
fout_std->lon = (/lons/)

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

ntimes = nyears

print(ntimes)
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 
SRFRADs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SST)) 

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

	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:)
	SRFRADs(imonth-1,:,:,count) = cdf_file->SRFRAD(0,:,:)

	end do
	count = count + 1
end do

; Get SSTs

filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"
cdf_file = addfile(filename,"w")
print(filename)

SSTs_clim_HAD = cdf_file->SST_cpl + 273.15


;create mean

SHFs_clim_HAD = dim_avg(SHFs)
LHFs_clim_HAD = dim_avg(LHFs)
SFRs_clim_HAD = dim_avg(SRFRADs)

LSHFs_clim_HAD = LHFs_clim_HAD + SHFs_clim_HAD

ndims = dimsizes(SSTs_clim_SOM)
print(ndims)

SSTs_clim_HAD!0="month"
SSTs_clim_HAD!1="lat"
SSTs_clim_HAD!2="lon"

SSTs_clim_SOM!0="month"
SSTs_clim_SOM!1="lat"
SSTs_clim_SOM!2="lon"

SSTs_clim_SOM&lat = lats
SSTs_clim_SOM&lon = lons

SSTs_clim_HAD&lat = lats
SSTs_clim_HAD&lon = lons


SSTs_clim_HAD&lat@units="degree_north"
SSTs_clim_HAD&lon@units="degree_east"

SSTs_clim_SOM&lat@units="degree_north"
SSTs_clim_SOM&lon@units="degree_east"

fout_std->SSTs_clim_SOM = (/SSTs_clim_SOM/)
fout_std->SSTs_clim_HAD = (/SSTs_clim_HAD/)
fout_std->SHFs_clim_SOM = (/SHFs_clim_SOM/)
fout_std->SHFs_clim_HAD = (/SHFs_clim_HAD/)
fout_std->LHFs_clim_SOM = (/LHFs_clim_SOM/)
fout_std->LHFs_clim_HAD = (/LHFs_clim_HAD/)
fout_std->LSHFs_clim_SOM = (/LSHFs_clim_SOM/)
fout_std->LSHFs_clim_HAD = (/LSHFs_clim_HAD/)
fout_std->SFRs_clim_SOM = (/SFRs_clim_SOM/)
fout_std->SFRs_clim_HAD = (/SFRs_clim_HAD/)

SSTs_clim_diff = new(dimsizes(SSTs_clim_HAD),typeof(SSTs_clim_HAD))

do imonth = 0,11
	do ilat=0,nlats-1
		do ilon=0,nlons-1
			if(SSTs_clim_SOM(imonth,ilat,ilon) .NE. 0.0) then
				SSTs_clim_diff(imonth,ilat,ilon) = SSTs_clim_SOM(imonth,ilat,ilon) - SSTs_clim_HAD(imonth,ilat,ilon) 
			else
				SSTs_clim_diff(imonth,ilat,ilon) = 0.0
			end if
		end do
	end do
end do
		
SHFs_clim_diff = SHFs_clim_SOM - SHFs_clim_HAD
LHFs_clim_diff = LHFs_clim_SOM - LHFs_clim_HAD
HFs_clim_diff = SHFs_clim_diff + LHFs_clim_diff
LSHFs_clim_diff = LSHFs_clim_SOM - LSHFs_clim_HAD
SFRs_clim_diff = SFRs_clim_SOM - SFRs_clim_HAD
AllHFs_clim_diff = SHFs_clim_diff + LHFs_clim_diff + SFRs_clim_diff


SSTs_clim_diff!0="month"
SSTs_clim_diff!1="lat"
SSTs_clim_diff!2="lon"

SSTs_clim_diff&lat = lats
SSTs_clim_diff&lon = lons

SSTs_clim_diff&lat@units="degree_north"
SSTs_clim_diff&lon@units="degree_east"

SHFs_clim_diff!0="month"
SHFs_clim_diff!1="lat"
SHFs_clim_diff!2="lon"

SHFs_clim_diff&lat = lats
SHFs_clim_diff&lon = lons

SHFs_clim_diff&lat@units="degree_north"
SHFs_clim_diff&lon@units="degree_east"

LHFs_clim_diff!0="month"
LHFs_clim_diff!1="lat"
LHFs_clim_diff!2="lon"

LHFs_clim_diff&lat = lats
LHFs_clim_diff&lon = lons

LHFs_clim_diff&lat@units="degree_north"
LHFs_clim_diff&lon@units="degree_east"


HFs_clim_diff!0="month"
HFs_clim_diff!1="lat"
HFs_clim_diff!2="lon"

HFs_clim_diff&lat = lats
HFs_clim_diff&lon = lons

HFs_clim_diff&lat@units="degree_north"
HFs_clim_diff&lon@units="degree_east"


fout_std->SSTs_clim_diffs = (/SSTs_clim_diff/)
fout_std->SHFs_clim_diffs = (/SHFs_clim_diff/)
fout_std->LHFs_clim_diffs = (/LHFs_clim_diff/)
fout_std->HFs_clim_diffs = (/HFs_clim_diff/)
fout_std->LSHFs_clim_diffs = (/LSHFs_clim_diff/)
fout_std->SFRs_clim_diffs = (/SFRs_clim_diff/)
fout_std->AllHFs_clim_diffs = (/AllHFs_clim_diff/)
