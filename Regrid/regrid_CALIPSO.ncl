load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/Obs/Clouds/GOCCP/"
inputfilename = "climMapLowMidHigh330m_200606-201612_avg_CFMIP2_sat_3.1.2.nc"

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)

inputfile = addfile(inputdir + "/" + inputfilename,"r")

inlats = inputfile->latitude
inlons = inputfile->longitude

infield = inputfile->cltcalipso

indimsize = dimsizes(infield)
ntime = indimsize(0)
nlon = indimsize(1)
nlat = indimsize(2) 
   
print(ntime)
 
outputgrid = addfile("/home/disk/eos4/rachel/Obs/Clouds/ctl_coarse_1000-1300avg_atmos.nc","r") 
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
dimNames = (/"time","lat","lon"/)
dimSizes = (/ntime,nolat,nolon/)
dimUnlim = (/True,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
;
filevardef(fout_std,"lat",typeof(outlats),getvardims(outlats))
filevardef(fout_std,"lon",typeof(outlons),getvardims(outlons))

setfileoption(fout_std,"DefineMode",False)

fout_std->lat = outlats
fout_std->lon = outlons

fout_std->time = (/months/)

;-------------------------
; regrid variables
; and write to file
;------------------------

print("cltcalipso")
infield = inputfile->cltcalipso

ofield = ESMF_regrid(infield,Opt)
fout_std->cltcalipso = ofield

delete(infield)
delete(ofield)
print("cllcalipso")
infield = inputfile->cllcalipso

ofield = ESMF_regrid(infield,Opt)
fout_std->cllcalipso = ofield

end
