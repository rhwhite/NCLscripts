load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/inputdata/LGM/MARGO/"
inputfilename = "sst.nc"

inputfile = addfile(inputdir + "/" + inputfilename,"r")

inlats = inputfile->latitude
inlons = inputfile->longitude

infield = inputfile->SST(:,:)
printVarSummary(infield)

inputmask = infield(:,:)
inputmask = where(infield.gt.0.0, 1.0, 0.0)
inputmask = where(ismissing(inputmask),0.0,1.0)

indimsize = dimsizes(infield)
nlon = indimsize(0)
nlat = indimsize(1) 
   
outputgrid = addfile("/home/disk/eos4/rachel/inputdata/LGM/domain.camocn.1.9x2.5_gx1v6_LGM.nc","r") 

outputmask = outputgrid->mask(:,:)
outputmask = (outputmask * -1) + 1

outlatcorn = outputgrid->yv
outloncorn = outputgrid->xv

output = addfile("/home/disk/eos4/rachel/inputdata/LGM/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc","r")
outlats = output->lat
outlons = output->lon

nolon = dimsizes(outlons)
nolat = dimsizes(outlats)
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
;Opt@DstGridMask = outputmask
;Opt@SrcGridCornerLat = inlatcorn
;Opt@SrcGridCornerLon = inloncorn
;Opt@DstGridCornerLat = outlatcorn
;Opt@DstGridCornerLon = outloncorn


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

print("SST")
infield = inputfile->SST

ofield = ESMF_regrid(infield,Opt)
fout_std->SST = ofield

delete(infield)
delete(ofield)

end
