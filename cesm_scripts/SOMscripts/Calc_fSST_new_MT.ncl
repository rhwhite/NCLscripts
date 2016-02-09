load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 


begin

; need to set setenv NCL_POP_REMAP /home/disk/eos4/rachel/inputdata/som/ prior to running!

dir = "$HOME/inputdata/ssts/"

Expn = "noT"
newfile = "sst_HadOIBl_SOM_" + Expn + "_bc_1.9x2.5_clim_c061031.nc"
oldfile = "sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"

 system("cp " + dir + oldfile + " " + dir + newfile)

  f         = addfile(dir + newfile,"w")

  ssts         = f->SST_cpl              ; (time, z_t, nlat, nlon)
  ssts2	       = f->SST_cpl_prediddle
  dims = dimsizes(ssts)
  nlats = dims(1)
  nlons = dims(2)


Months = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

do imonth=0,11
  f2         = addfile(dir + "SOMclims/" + Months(imonth) + "11_30_diffs_CAM4SOM4_" + Expn + ".nc","r")
  sst_temp = f2->SST(0,:,:)
  ;sst_add = f2fsh(sst_temp,(/nlats,nlons/))
  sst_add = sst_temp
  print(dimsizes(sst_add))
  print(dimsizes(ssts(imonth,:,:)))
  ssts(imonth,:,:) = ssts(imonth,:,:) + sst_add
  ssts2(imonth,:,:) = ssts2(imonth,:,:) + sst_add
  delete(f2)
end do

f->SST_cpl = (/ssts/)
f->SST_cpl_prediddle = (/ssts2/)


end
