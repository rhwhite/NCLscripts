load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_climZM_NCI_c061031.nc"

print("reading file in...")
  cdf_file = addfile(filename,"w")
print("file read in")

cice = cdf_file->ice_cov
cice_pd = cdf_file->ice_cov_prediddle

cice_new = cice
cice_new(:,:,:) = 0.0

cice_pd_new = cice_pd
cice_pd_new(:,:,:) = 0.0

cdf_file ->ice_cov      = (/cice_new/)
cdf_file ->ice_cov_prediddle     = (/cice_pd_new/)

end