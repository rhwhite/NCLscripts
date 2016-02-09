load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filename = "/home/disk/eos4/rachel/inputdata/topo/NoTopo_USGS-gtopo30_0.9x1.25_remap_c051027.nc"

print("reading file in...")
  cdf_file = addfile(filename,"w")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

gpt(:,:) = 0.0
sgh(:,:) = 0.0
sgh30(:,:) = 0.0


cdf_file ->PHIS      = (/gpt/)
cdf_file ->SGH     = (/sgh/)
cdf_file ->SGH30     = (/sgh30/)

end