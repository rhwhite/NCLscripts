load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/Obs/Clouds/CERES/"
inputfilename = "meanCERES_EBAF-TOA_Edition4.0_200003-201709.nc"

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)

inputfile = addfile(inputdir + "/" + inputfilename,"r")

inlats = inputfile->lat
inlons = inputfile->lon

infield = inputfile->toa_sw_all_mon(0,:,:)
printVarSummary(infield)

indimsize = dimsizes(infield)
nlon = indimsize(0)
nlat = indimsize(1) 
   
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
infield = inputfile->toa_sw_all_mon

ofield = ESMF_regrid(infield,Opt)
fout_std->toa_sw_all_mon = ofield

delete(infield)
delete(ofield)

infield = inputfile->cldarea_total_daynight_mon

ofield = ESMF_regrid(infield,Opt)
fout_std->cldarea_total_daynight_mon = ofield

delete(infield)
delete(ofield)

infield = inputfile->toa_sw_clr_mon

ofield = ESMF_regrid(infield,Opt)
fout_std->toa_sw_clr_mon = ofield

delete(infield)
delete(ofield)

infield = inputfile->toa_lw_clr_mon

ofield = ESMF_regrid(infield,Opt)
fout_std->toa_lw_clr_mon = ofield

delete(infield)
delete(ofield)

infield = inputfile->toa_lw_all_mon

ofield = ESMF_regrid(infield,Opt)
fout_std->toa_lw_all_mon = ofield

delete(infield)
delete(ofield)

end
