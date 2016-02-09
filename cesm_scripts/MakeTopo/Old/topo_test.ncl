load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startnlon = 82
endnlon = 106
startnlat = 55
endnlat = 88


gpt_min = 98
sgh_min = 30
sgh30_min = 10
; read in landmask

lmin = "/home/disk/eos4/rachel/inputdata/topo/landmask_1.9x2.5.nc"

print("reading file in...")
  lm_file = addfile(lmin,"r")
print("file read in")

lm = lm_file->landmask

; create normal distrbution with 300 bins

nbins = 60

opt = True
opt@npts = nbins
nd = genNormalDist(1,1,opt)

nd = nd / sum(nd)

dims = dimsizes(nd)
print(dims)

ndcdf = new(dims,double)
ndcdf(0) = nd(0)

do nn = 1,dims-1
	ndcdf(nn) = ndcdf(nn-1) + nd(nn)
end do

;now take values at equal spacings:
spacing = (nbins/6)
weights = new(7,double)

weights(0) = ndcdf(spacing - 1)
weights(1) = ndcdf(2 * spacing - 1)
weights(2) = ndcdf(3 * spacing - 1)
weights(3) = ndcdf(4 * spacing - 1)
weights(4) = ndcdf(5 * spacing - 1)
weights(5) = 1.0

print(weights)

filenamein = "/home/disk/eos4/rachel/inputdata/topo/USGS-gtopo30_1.9x2.5_remap_c050602.nc"

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

gpt_new = gpt
sgh_new = sgh
sgh30_new = sgh30

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

do nx = 0,numlats-1
	do ny = 0,numlons-1
		if (lm(nx,ny) .lt. 1)
			lm(nx,ny) = -1
		end if
	end do
end do


gpt_new = gpt_new * lm
sgh_new = sgh_new * lm
sgh30_new = sgh30_new * lm
filenameout = "/home/disk/eos4/rachel/inputdata/topo/testUSGS-gtopo30_1.9x2.5_remap_c050602.nc"

print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
cdf_out ->SGH     = (/sgh_new/)
cdf_out ->SGH30     = (/sgh30_new/)

end