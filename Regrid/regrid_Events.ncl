load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

test = 0
Data = "CESM"

startday = "1"
endday = "5"

; Get experiment names
if (Data .EQ. "TRMM") then
        inputdir = "/home/disk/eos4/rachel/EventTracking/FiT_RW/TRMM_output/Standard/Precip/"
	if (test .EQ. 1) then
		inputfilename = "/weights/TRMM_1998_test.nc"
	else
		inputfilename = "DenDirSpd_Map_Sizes_" + startday + "-" + endday + "day_centre_TRMM_1998-2014_Standard_regrid_1lons_1lats.nc"
	end if

else if (Data .EQ. "ERAI") then
        inputdir = "/home/disk/eos4/rachel/EventTracking/FiT_RW_ERA/ERAI_output/Standard1980/Precip/"
	if (test .EQ. 1) then
		inputfilename = "/weights/ERAI_1980_test.nc"
	else
		inputfilename = "DenDirSpd_Map_Sizes_" + startday + "-" + endday + "day_centre_ERAI_1980-2014_Standard_regrid_1lons_1lats.nc"
	end if
else if (Data .EQ. "CESM") then
        inputdir = "/home/disk/eos4/rachel/EventTracking/FiT_RW_ERA/CESM_output/Standard1990-2014/Precip/"
        if (test .EQ. 1) then
                inputfilename = "/weights/CESM_1980_test.nc"
        else
                inputfilename = "DenDirSpd_Map_Sizes_" + startday + "-" + endday + "day_centre_CESM_1990-2014_Standard_regrid_1lons_1lats.nc"
        end if
end if
end if
end if

inputfile = addfile(inputdir + inputfilename,"r")

indimsize = getfiledimsizes(inputfile)
nyears = indimsize(0)
nseas = indimsize(1)
nlon = indimsize(2)
nlat = indimsize(3) 
 
inlats = inputfile->lat
inlons = inputfile->lon
infield = inputfile->TPrecipSeas(:,:,:,:)
inyears = inputfile->years
inseas = inputfile->seas

print(inlats)

print(nlat)
print(nlon)
print(nyears)
print(nseas)

outputgrid = addfile("/home/disk/eos4/rachel/Obs/OLR/Seas_olr.mon.mean.nc","r")

outlats = outputgrid->Latitude(::-1)
outlons = outputgrid->Longitude

print(dimsizes(outlats))
print(dimsizes(outlons))
nolat = dimsizes(outlats)
nolon = dimsizes(outlons)

Opt = True
Opt@SrcFileName = inputfilename
if (Data .EQ. "TRMM") then
	Opt@WgtFileName = "/weights/TRMM_2_OLR_wgts.nc"
else if (Data .EQ. "ERAI") then
	Opt@WgtFileName = "/weights/ERAI_2_OLR_wgts.nc"
else if (Data .EQ. "CESM") then
	Opt@WgtFileName = "/weights/CESM_2_OLR_wgts.nc"
end if
end if
end if

Opt@InterpMethod = "conserve"
Opt@SrcRegional = True
Opt@DstGridLat = outlats
Opt@DstGridLon = outlons
Opt@SrcGridLat = inlats
Opt@SrcGridLon = inlons
Opt@Overwrite = True

print(dimsizes(inlats))
;Since weights have already been calculated now...
;If weights have not already been calculated:
ofield = ESMF_regrid(infield,Opt)
delete(ofield)
print(typeof(infield))

;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------
outputname = inputdir + inputfilename + "_regrid_OLR.nc"

system("/bin/rm -f " + outputname)
setfileoption("nc","Format","NetCDF4")
;setfileoption("nc","Format","LargeFile")


fout_std = addfile(outputname, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"years","seasons","lat","lon"/)
dimSizes = (/nyears,nseas,nolat,nolon/)
dimUnlim = (/False,False,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
;
filevardef(fout_std,"lat",typeof(outlats),(/"lat"/))
filevardef(fout_std,"TPrecipSeas",typeof(infield),(/"years","seasons","lat","lon"/))
filevardef(fout_std,"TPrecipAnn",typeof(infield),(/"years","lat","lon"/))
filevardef(fout_std,"TDensitySeas",typeof(infield),(/"years","seasons","lat","lon"/))
filevardef(fout_std,"TDensityAnn",typeof(infield),(/"years","lat","lon"/))
filevardef(fout_std,"lon",typeof(outlons),(/"lon"/))
filevardef(fout_std,"years",typeof(inyears),(/"years"/))
filevardef(fout_std,"seasons",typeof(inseas(0)),(/"seasons"/))
setfileoption(fout_std,"DefineMode",False)

fout_std->lat = (/outlats/)
fout_std->lon = (/outlons/)

delete(infield)

;infield  = inputfile->TPrecipSeas
;ofield = ESMF_regrid_with_weights(infield,"/weights/TRMM_2_OLR_wgts.nc",False)
;fout_std->TPrecipSeas = ofield
;delete(ofield)

;infieldA  = inputfile->TPrecipAnn
;ofieldA = ESMF_regrid_with_weights(infieldA,"/weights/TRMM_2_OLR_wgts.nc",False)
;fout_std->TPrecipAnn = ofieldA

print("now writing")
do iyear = 0,nyears-1
	print(iyear*1)
	infieldA  = inputfile->TPrecipAnn(iyear,:,:)
	infieldAD = inputfile->TDensityAnn(iyear,:,:)
	if (Data .EQ. "TRMM") then
		ofieldA = ESMF_regrid_with_weights(infieldA,"/weights/TRMM_2_OLR_wgts.nc",False)
                ofieldAD = ESMF_regrid_with_weights(infieldAD,"/weights/TRMM_2_OLR_wgts.nc",False)

	else if (Data .EQ. "ERAI") then
                ofieldA = ESMF_regrid_with_weights(infieldA,"/weights/ERAI_2_OLR_wgts.nc",False)
                ofieldAD = ESMF_regrid_with_weights(infieldAD,"/weights/ERAI_2_OLR_wgts.nc",False)
	else if (Data .EQ. "CESM") then
                ofieldA = ESMF_regrid_with_weights(infieldA,"/weights/CESM_2_OLR_wgts.nc",False)
                ofieldAD = ESMF_regrid_with_weights(infieldAD,"/weights/CESM_2_OLR_wgts.nc",False)
	end if
	end if
	end if
        print(dim_sum(dim_sum(infieldA)))
        ofieldA@_FillValue = -9999
	print(dim_sum(dim_sum(ofieldA)))

        print(dim_sum(dim_sum(infieldAD)))
	ofieldAD@_FillValue = -9999
        print(dim_sum(dim_sum(ofieldAD)))

	fout_std->TPrecipAnn(iyear,:,:) = ofieldA
        fout_std->TDensityAnn(iyear,:,:) = ofieldAD
	fout_std->years(iyear) = inyears(iyear)
	do iseas = 0,nseas-1
		infield = inputfile->TPrecipSeas(iyear,iseas,:,:)
                infieldD = inputfile->TDensitySeas(iyear,iseas,:,:)

		if (Data .EQ. "TRMM") then
			ofield = ESMF_regrid_with_weights(infield,"/weights/TRMM_2_OLR_wgts.nc",False)
                        ofieldD = ESMF_regrid_with_weights(infieldD,"/weights/TRMM_2_OLR_wgts.nc",False)

		else if (Data .EQ. "ERAI") then
                        ofield = ESMF_regrid_with_weights(infield,"/weights/ERAI_2_OLR_wgts.nc",False)
                        ofieldD = ESMF_regrid_with_weights(infieldD,"/weights/ERAI_2_OLR_wgts.nc",False)
		else if (Data .EQ. "CESM") then
                        ofield = ESMF_regrid_with_weights(infield,"/weights/CESM_2_OLR_wgts.nc",False)
                        ofieldD = ESMF_regrid_with_weights(infieldD,"/weights/CESM_2_OLR_wgts.nc",False)
		end if
		end if
		end if
		fout_std->TPrecipSeas(iyear,iseas,:,:) = ofield
                fout_std->TDensitySeas(iyear,iseas,:,:) = ofieldD

		delete(infield)
	end do
end do


do iseas =0, nseas-1
        print(inseas(iseas))
        print(fout_std->seasons(iseas))
        fout_std->seasons(iseas) = tostring(inseas(iseas))
end do
delete(ofield)


print("printed it")



end
