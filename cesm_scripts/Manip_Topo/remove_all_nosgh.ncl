load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

gpt_min = 0 ;50m
sgh30_min = 10; roughness of flat russia/flat america

newfile = "Flat_noSGHred_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  "USGS-gtopo30_1.9x2.5_remap_c050602.nc " + diro + newfile)

filename = "/home/disk/eos4/rachel/inputdata/topo/" + newfile

print("reading file in...")
cdf_file = addfile(filename,"w")
print("file read in")

gpt = cdf_file->PHIS
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

do ny=0,numlats-1
	do nx = 0,numlons-1
			gpt(ny,nx) = gpt_min * lm(ny,nx)
			sgh30(ny,nx) = sgh30_min * lm(ny,nx)	
	end do
end do

cdf_file ->PHIS      = (/gpt/)
cdf_file ->SGH30     = (/sgh30/)

end
