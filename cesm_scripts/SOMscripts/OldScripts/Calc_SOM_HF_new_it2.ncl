load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

nyears =20

Experiments = (/"CESMSOM4topof19g16"/)
Experiments2 = (/"CESMtopof19"/) 

iyear = 160
yearstring = tostring(iyear)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

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

ntimes = nyears*12

print(ntimes)
SSTs = new((/ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/ndims(1),ndims(2),ntimes/),typeof(SST)) 
SRFRADs = new((/ndims(1),ndims(2),ntimes/),typeof(SST)) 
SFCFLXs = new((/ndims(1),ndims(2),ntimes/),typeof(SST)) 

print(dimsizes(SSTs))
count = 0

print(count)
  
do iyear=160,(160+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

		yearstring = tostring(iyear)

	filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0.0" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(:,:,count) = cdf_file->SST(0,:,:)
	LHFs(:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(:,:,count) = cdf_file->SHFLX(0,:,:)
	SFCFLXs(:,:,count) = cdf_file->FSNS(0,:,:)-cdf_file->FLNS(0,:,:)-cdf_file->SHFLX(0,:,:)-cdf_file->LHFLX(0,:,:)

	count = count + 1
	end do

end do

print(count)
;create mean

SSTs_AM_SOM = dim_avg(SSTs)
SHFs_AM_SOM = dim_avg(SHFs)
LHFs_AM_SOM = dim_avg(LHFs)
SFCFLXs_AM_SOM = dim_avg(SFCFLXs) 

delete([/"SSTs","LHFs","SHFs","SFCFLXs"/])

ndims = dimsizes(SSTs_AM_SOM)
print(ndims)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
diro = "/home/disk/eos4/rachel/inputdata/ssts/"
filo = "SFLXS_AM_" + Experiments + "_" + Experiments2 + ".cam2.h0.nc"
system("/bin/rm -f " + diro + filo)
fout_std = addfile(diro + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"lat","lon"/)
dimSizes = (/ndims(1),ndims(2)/)
dimUnlim = (/False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lats),getvardims(lats))
filevardef(fout_std,"lon",typeof(lons),getvardims(lons))

filevardef(fout_std,"SSTs_AM_SOM",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SSTs_AM_HAD",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SSTs_AM_diffs",typeof(SSTs_AM_SOM),(/"lat","lon"/))

filevardef(fout_std,"SHFs_AM_SOM",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SHFs_AM_HAD",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SHFs_AM_diffs",typeof(SSTs_AM_SOM),(/"lat","lon"/))

filevardef(fout_std,"LHFs_AM_SOM",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"LHFs_AM_HAD",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"LHFs_AM_diffs",typeof(SSTs_AM_SOM),(/"lat","lon"/))

filevardef(fout_std,"SFCFLXs_AM_SOM",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SFCFLXs_AM_HAD",typeof(SSTs_AM_SOM),(/"lat","lon"/))
filevardef(fout_std,"SFCFLXs_AM_diffs",typeof(SSTs_AM_SOM),(/"lat","lon"/))

fout_std->lat = (/lats/)
fout_std->lon = (/lons/)

;Get fluxes from fixed SST run

iy = 2
yearstring = tostring(iy)
imonth = 1
monthstring =  ("0" + tostring(imonth))

filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.000" + yearstring +"-" + monthstring + ".nc")

cdf_file = addfile(filename,"r")
print("file read in")

lats = cdf_file->lat
lons = cdf_file->lon
SST = cdf_file->TS

ndims = dimsizes(SST)

ntimes = nyears*12

print(ntimes)
SSTs = new((/ndims(1),ndims(2),ntimes/),typeof(SST))
LHFs = new((/ndims(1),ndims(2),ntimes/),typeof(SST))
SHFs = new((/ndims(1),ndims(2),ntimes/),typeof(SST)) 
SFCFLXs = new((/ndims(1),ndims(2),ntimes/),typeof(SST)) 

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


	filename = ("/home/disk/rachel/CESM_outfiles/" + Experiments2 + "/atm/hist/" + Experiments2 + ".cam2.h0.00" + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	SSTs(:,:,count) = cdf_file->TS(0,:,:)
	LHFs(:,:,count) = cdf_file->LHFLX(0,:,:)
	SHFs(:,:,count) = cdf_file->SHFLX(0,:,:)
	SFCFLXs(:,:,count) =  cdf_file->FSNS(0,:,:)-cdf_file->FLNS(0,:,:)-cdf_file->LHFLX(0,:,:)-cdf_file->SHFLX(0,:,:)
	count = count + 1

	end do
end do

print(count)
;create mean

SSTs_AM_HAD = dim_avg(SSTs)
SHFs_AM_HAD = dim_avg(SHFs)
LHFs_AM_HAD = dim_avg(LHFs)
SFCFLXs_AM_HAD = dim_avg(SFCFLXs) 

delete(ndims)
ndims = dimsizes(SSTs_AM_SOM)
print(ndims)

SSTs_AM_HAD!0="lat"
SSTs_AM_HAD!1="lon"

SSTs_AM_HAD&lat = lats
SSTs_AM_HAD&lon = lons

SSTs_AM_HAD&lat@units="degree_north"
SSTs_AM_HAD&lon@units="degree_east"

copy_VarCoords(SSTs_AM_HAD,SSTs_AM_SOM)


fout_std->SSTs_AM_SOM = (/SSTs_AM_SOM/)
fout_std->SSTs_AM_HAD = (/SSTs_AM_HAD/)
fout_std->SHFs_AM_SOM = (/SHFs_AM_SOM/)
fout_std->SHFs_AM_HAD = (/SHFs_AM_HAD/)
fout_std->LHFs_AM_SOM = (/LHFs_AM_SOM/)
fout_std->LHFs_AM_HAD = (/LHFs_AM_HAD/)
fout_std->SFCFLXs_AM_HAD = (/SFCFLXs_AM_HAD/)
fout_std->SFCFLXs_AM_SOM = (/SFCFLXs_AM_SOM/)

SSTs_AM_diff = SSTs_AM_SOM - SSTs_AM_HAD
SHFs_AM_diff = SHFs_AM_SOM - SHFs_AM_HAD
LHFs_AM_diff = LHFs_AM_SOM - LHFs_AM_HAD
SFCFLXs_AM_diff = SFCFLXs_AM_SOM - SFCFLXs_AM_HAD 

copy_VarCoords(SSTs_AM_HAD,SSTs_AM_diff)
copy_VarCoords(SSTs_AM_HAD,SHFs_AM_diff)
copy_VarCoords(SSTs_AM_HAD,LHFs_AM_diff)
copy_VarCoords(SSTs_AM_HAD,SFCFLXs_AM_diff)


fout_std->SSTs_AM_diffs = (/SSTs_AM_diff/)
fout_std->SHFs_AM_diffs = (/SHFs_AM_diff/)
fout_std->LHFs_AM_diffs = (/LHFs_AM_diff/)

fout_std->SFCFLXs_AM_diffs = (/SFCFLXs_AM_diff/)
