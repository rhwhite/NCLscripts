load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
startlat = 47.0; 32.0 ;(IM3); 47.0 (IM2); 48 (IM)

startlon = 73.0

lonwidth = 57.5

jwidth = tointeger(ceil(lonwidth / 2.5))

Mong_max = 2000.0 * 9.8 ; m
gpt_min = 490 ;50m
sgh_max = 500.0 ; roughness of flat russia/flat america
sgh30_max = 150.0; roughness of flat russia/flat america

newfile = "IdealM2_USGS-gtopo30_1.9x2.5_remap_c050602.nc"
diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  "NoTopo_USGS-gtopo30_1.9x2.5_remap_c050602.nc " + diro + newfile)

filenameout = "/home/disk/eos4/rachel/inputdata/topo/" + newfile


; create normal distrbution with 300 bins

nbins = 600

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
spacing = (nbins/(jwidth))
weightslons = new(jwidth,double)
weightslons(0) = 0.0
weightslons(jwidth-1) = 0.0

jj2 = jwidth-2

edgeend = tointeger(ceil(jwidth/3))
do jj = 1,edgeend
	weightslons(jj) = ndcdf(jj*3 * spacing - 1)
	weightslons(jj2) = ndcdf(jj*3 * spacing - 1)

	jj2 = jj2 - 1
end do

do jj = edgeend+1,jwidth-edgeend-2
	weightslons(jj) = ndcdf(jwidth * spacing - 1)
end do

;print(weightslons)
delete(nd)
delete(ndcdf)
delete(dims)

nbins = 30

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

weightslats = new(3,double)

weightslats(0) = 1.0/3.0
weightslats(1) = 1.0
weightslats(2) = 1.0/3.0

print(weightslats)


print("reading file in...")
  cdf_file = addfile(filenameout,"w")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC
lats = cdf_file->lat
lons = cdf_file->lon

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

; find starti and startj

do ny = 0,numlats -2
	if (lats(ny) .LE. startlat .AND. lats(ny+1) .GT. startlat)
		starti = ny
	end if
end do

do ny = 0,numlons -2
	if (lons(ny) .LE. startlon .AND. lons(ny+1) .GT. startlon)
		startj = ny
	end if
end do

latweight = 0
do ny=starti,starti + dimsizes(weightslats)-1
	lonweight = 0
	do nx = startj,startj + dimsizes(weightslons)-1
			mult = (weightslons(lonweight) * weightslats(latweight))
		print(mult * 1)
			gpt(ny,nx) = gpt(ny,nx) * (1.0 - mult) + (Mong_max * mult)
			sgh(ny,nx) = sgh(ny,nx) * (1.0 - mult) + (sgh_max * mult)
			sgh30(ny,nx) = sgh30(ny,nx) * (1.0 - mult) + (sgh30_max * mult)
	
		lonweight = lonweight + 1
	end do
	latweight = latweight + 1
end do


cdf_file ->PHIS      = (/gpt/)
cdf_file ->SGH     = (/sgh/)
cdf_file ->SGH30     = (/sgh30/)

end