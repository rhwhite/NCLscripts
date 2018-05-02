load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;gpt_min = 0 ;50m
sgh_min = 30
;sgh30_min = 10; roughness of flat russia/flat america

newfile = "Topo_flatSGH_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  "USGS-gtopo30_1.9x2.5_remap_c050602.nc " + diro + newfile)

filename = "/home/disk/eos4/rachel/inputdata/topo/" + newfile

print("reading file in...")
cdf_file = addfile(filename,"w")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
lm = cdf_file->LANDFRAC

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

do ny=0,numlats-1
	do nx = 0,numlons-1
			sgh(ny,nx) = sgh_min * lm(ny,nx)	
	end do
end do

cdf_file ->SGH     = (/sgh/)

end
