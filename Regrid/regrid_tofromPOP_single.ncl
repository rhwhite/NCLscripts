load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names

inputdir = "/home/disk/eos4/rachel/inputdata/Hosing/"
filein = "CAM4POP_NoMT-CTL_TOThosing.nc"

in = addfile(inputdir + filein,"r")
outputfile = inputdir + "regrid_" + filein

PRECT = in->HOSING(:,:,:)
printVarSummary(PRECT)
print(max(PRECT))

;remapPRECT = PopLatLon(PRECT,"fv1.9x2.5","gx1v6","bilin","da","090206")
remapPRECT = PopLatLon(PRECT,"gx1v6","fv1.9x2.5","bilin","da","090206")

print(max(remapPRECT))
printVarSummary(remapPRECT)

system("rm " + outputfile) 
fout_std = addfile(outputfile, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

setfileoption(fout_std,"DefineMode",False)

fout_std->HOSING = remapPRECT
print("printed it")

end
