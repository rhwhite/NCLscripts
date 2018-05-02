load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlat = 39.0 ;39.0 IT3/4 ;25.0 IT2
startlon = 95.0 ; IT5 ;74.0 IT3/4 ;74.0 IT2

Tibet_max = 5000.0 * 9.8 ; m
gpt_min = 490 ;50m
sgh_max = 800.0 ; roughness of??
sgh30_max = 300.0; roughness of??

newfile = "IdealT5_USGS-gtopo30_1.9x2.5_remap_c050602.nc"
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
spacing = (nbins/30)

weightslons = new(5,double)

weightslons(0) = 0.0
weightslons(1) = ndcdf(10 * spacing - 1)
weightslons(2) = ndcdf(30 * spacing - 1)
weightslons(3) = ndcdf(10 * spacing - 1)
weightslons(4) = 0.0

print(weightslons)

weightslats = new(11,double)

weightslats(0) = 0.0
weightslats(1) = ndcdf(5 * spacing - 1)
weightslats(2) = ndcdf(10 * spacing - 1)
weightslats(3) = ndcdf(20 * spacing - 1)
weightslats(4) = ndcdf(30 * spacing - 1)
weightslats(5) = ndcdf(30 * spacing - 1)
weightslats(6) = ndcdf(30 * spacing - 1)
weightslats(7) = ndcdf(20 * spacing - 1)
weightslats(8) = ndcdf(10 * spacing - 1)
weightslats(9) = ndcdf(5 * spacing - 1)
weightslats(10) = 0.0

print(weightslats)

;do nl = 0,8
;	lats(nl) = 25.0 + (1.9 * nl)
;end do

; wks   = gsn_open_wks ("eps","Tibet_shape_lon")                ; open workstation

; res                  = True                     ; plot mods desired
; res@tiMainString     = "Shape of Tibet along Longitude band"          ; add title

; plot  = gsn_csm_xy (wks,lats,weightslats(:)* Tibet_max,res) ; create plot

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
			gpt(ny,nx) = gpt(ny,nx) * (1.0 - mult) + (Tibet_max * mult)
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
