load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names

seasname = (/"DJF","MAM","JJA","SON"/)

dirin = getenv("NCL_dir")
print(dirin)
filein = getenv("NCL_file")

in = addfile(dirin + "ANN" + filein,"r")
outputfile = dirin + "regrid_" + filein

HMXL = in->HMXL
TEMP = in->TEMP
SALT = in->SALT
RHO = in->RHO 
MOC = in->MOC

remapHMXL = PopLatLon(HMXL,"gx1v6","1x1d","bilin","da","100716")
remapTEMP = PopLatLon(TEMP,"gx1v6","1x1d","bilin","da","100716")
remapSALT = PopLatLon(SALT,"gx1v6","1x1d","bilin","da","100716")
remapRHO = PopLatLon(RHO,"gx1v6","1x1d","bilin","da","100716")

system("rm " + outputfile) 
fout_std = addfile(outputfile, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

setfileoption(fout_std,"DefineMode",False)

fout_std->HMXL = remapHMXL
fout_std->TEMP = remapTEMP
fout_std->SALT = remapSALT
fout_std->RHO = remapRHO
fout_std->MOC = MOC
print("printed it")

delete([/MOC,HMXL,TEMP,SALT,RHO/])

; Now repeat for seasons

do iseas=0,3
    print(iseas)
    in = addfile(dirin + seasname(iseas) + filein,"r")

    outputfile = dirin + "regrid_" + seasname(iseas) + filein

    HMXL = in->HMXL(0,:,:)
    TEMP = in->TEMP(0,:,:,:)
    SALT = in->SALT(0,:,:,:)
    RHO = in->RHO(0,:,:,:)
    MOC = in->MOC(0,:,:,:)

    remapHMXL = PopLatLon(HMXL,"gx1v6","1x1d","bilin","da","100716")
    remapTEMP = PopLatLon(TEMP,"gx1v6","1x1d","bilin","da","100716")
    remapSALT = PopLatLon(SALT,"gx1v6","1x1d","bilin","da","100716")
    remapRHO = PopLatLon(RHO,"gx1v6","1x1d","bilin","da","100716")

    system("rm " + outputfile)
    fout_std = addfile(outputfile, "c")

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout_std,fAtt)

    setfileoption(fout_std,"DefineMode",False)

    fout_std->HMXL = remapHMXL
    fout_std->TEMP = remapTEMP
    fout_std->SALT = remapSALT
    fout_std->RHO = remapRHO
    fout_std->MOC = MOC
    print("printed it")
    delete([/MOC,HMXL,TEMP,SALT,RHO/])

end do
end
