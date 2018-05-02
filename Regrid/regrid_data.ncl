load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

test = 0

if test .EQ. 1 then
	chunksize = 5
else
	chunksize = 2000
end if

; Get experiment names
inputdir = "/home/disk/eos4/rachel/Obs/TRMM/3hrly/"

if (test .EQ. 1) then
	inputfilename = "TRMM_1998_test.nc"
else
	inputfilename = "TRMM_1998-2014_3B42_3hrly_nonan.nc"
end if
inputfile = addfile(inputdir + inputfilename,"r")

indimsize = getfiledimsizes(inputfile)
ntimes = indimsize(0)
nlon = indimsize(1)
nlat = indimsize(2) 
 
inlats = inputfile->latitude
inlons = inputfile->longitude
infield = inputfile->pcp(0:chunksize-1,:,:)

print(nlat)
print(nlon)
print(ntimes)

outputgrid = addfile("/home/disk/eos4/rachel/Obs/ERAI/Precip_3hrly/ERAI_Totalprecip_1980-2015_grid.nc","r") 
outlats = outputgrid->latitude(::-1)
outlons = outputgrid->longitude


nolat = dimsizes(outlats)
nolon = dimsizes(outlons)

numchunks = ceil(ntimes / chunksize)
print(numchunks)

Opt = True
Opt@SrcFileName = inputfilename
Opt@WgtFileName = "/weights/TRMM_2_ERAI_wgts.nc"
Opt@InterpMethod = "conserve"
Opt@SrcRegional = True
Opt@DstGridLat = outlats
Opt@DstGridLon = outlons
Opt@SrcGridLat = inlats
Opt@SrcGridLon = inlons
Opt@Overwrite = True

;Since weights have already been calculated now...
;ofield = ESMF_regrid_with_weights(infield,"/weights/TRMM_2_ERAI_wgts.nc",False)
;If weights have not already been calculated:
;ofield = ESMF_regrid(infield,Opt)
;ofield = area_conserve_remap_Wrap(inlons,inlats,infield(0,:,:),outlons,outlats,False)
print(typeof(infield))

;----------------------------------------------------------------------
; Write out results to a new netcdf file
;-----------------------------------------------------------------------

delete(infield)

do ichunk = 0,numchunks
        print(ichunk*1)
        tarray = (/(ichunk+1)*chunksize - 1,ntimes-1/)

	infield = inputfile->pcp(ichunk*chunksize:min(tarray),:,:)

	ofield = ESMF_regrid_with_weights(infield,"/weights/TRMM_2_ERAI_wgts.nc",False)

	if ichunk .LT. 10 then
		stringchunk = "0" + tostring(ichunk)
	else
		stringchunk = tostring(ichunk)
	end if 

	dims = dimsizes(ofield)
	ntimeschunk = dims(0)
	outputname = inputdir + "regrid2ERAI_" + stringchunk + "_" + inputfilename
	
	system("/bin/rm -f " + outputname)
	setfileoption("nc","Format","LargeFile")

	fout_std = addfile(outputname, "c")

	setfileoption(fout_std,"DefineMode",True)

	;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)

	;set dimensions of output file
	dimNames = (/"time","latitude","longitude"/)
	dimSizes = (/ntimeschunk,nolat,nolon/)
	dimUnlim = (/True,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
	;
	filevardef(fout_std,"lat",typeof(outlats),getvardims(outlats))
	filevardef(fout_std,"pcp",typeof(ofield),(/"time","latitude","longitude"/))
	filevardef(fout_std,"lon",typeof(outlons),getvardims(outlons))

	setfileoption(fout_std,"DefineMode",False)

	print(dimsizes(ofield))
;	print(dimsizes(fout_std->pcp(:,:,:)))
	fout_std->pcp = ofield
	fout_std->lat = outlats
	fout_std->lon = outlons
	
	delete(ofield)
	delete(infield)
end do

print("printed it")



end
