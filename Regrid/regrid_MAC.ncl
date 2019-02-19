load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/Obs/Clouds/MAC/"
inputfilename = "mean_maclwp_cloudlwpave_1988-2016.nc"

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)

inputfile = addfile(inputdir + "/" + inputfilename,"r")

inlats = inputfile->lat
inlons = inputfile->lon

infield = inputfile->cloudlwp(0,:,:)
printVarSummary(infield)

inputmask = infield(:,:)
inputmask = where(infield.gt.0.0, 1.0, 0.0)
inputmask = where(ismissing(inputmask),0.0,1.0)

indimsize = dimsizes(infield)
nlon = indimsize(0)
nlat = indimsize(1) 
   
outputgrid = addfile("/home/disk/eos4/rachel/Obs/Clouds/ctl_coarse_1000-1300avg_atmos.nc","r") 

outputmask = outputgrid->land_mask(:,:)

outputmask = where(outputmask.eq.1,0,1) 
outputmask = where(ismissing(outputmask),0,1)

outlats = outputgrid->lat
outlons = outputgrid->lon

nolat = dimsizes(outlats)
nolon = dimsizes(outlons)

Opt = True
;Opt@SrcFileName = inputfilename
Opt@InterpMethod = "bilinear"

Opt@SrcRegional = False
Opt@DstGridLat = outlats
Opt@DstGridLon = outlons
Opt@SrcGridLat = inlats
Opt@SrcGridLon = inlons
Opt@ForceOverwrite = True
Opt@SrcGridMask = inputmask
Opt@DstGridMask = outputmask

;----------------------------------------------------------------------
; Create output file
;-----------------------------------------------------------------------

outputname = inputdir + "regrid_" + inputfilename

system("/bin/rm -f " + outputname)
setfileoption("nc","Format","LargeFile")

fout_std = addfile(outputname, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"lat","lon"/)
dimSizes = (/nolat,nolon/)
dimUnlim = (/False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
;
filevardef(fout_std,"lat",typeof(outlats),getvardims(outlats))
filevardef(fout_std,"lon",typeof(outlons),getvardims(outlons))

setfileoption(fout_std,"DefineMode",False)

fout_std->lat = outlats
fout_std->lon = outlons

;-------------------------
; regrid variables
; and write to file
;------------------------

print("lwp")
infield = inputfile->cloudlwp

ofield = ESMF_regrid(infield,Opt)
fout_std->cloudlwp = ofield

delete(infield)
delete(ofield)
print("lmp_error")
infield = inputfile->cloudlwp_error

ofield = ESMF_regrid(infield,Opt)
fout_std->cloudlwp_error = ofield

fout_std->inmask = inputmask(:,:)

end
