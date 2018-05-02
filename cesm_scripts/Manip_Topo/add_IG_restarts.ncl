load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlat = 44.0 ;
startlon = 74.0 ; IT5;74.0 IT3/4 ;74.0 IT2

Tibet_max = 2000.0 * 9.8 ; m
gpt_min = 490 ;50m
sgh_max = 400.0 ; half roughness of large Tibet
sgh30_max = 150.0; half roughness of large Tibet

file1 = "CESMSOM4topof19g16.cam2.h0.0169-12.nc"
file2 = "CESMSOM4topof19g16.cam2.r.0170-01-01-00000.nc"

diro = "/home/disk/eos4/rachel/inputdata/som/restart/IG44/"

system("cp " + diro + file1 + " " + diro + "Orig_" + file1)
system("cp " + diro + file2 + " " + diro + "Orig_" + file2)

fileout1 = diro + file1
fileout2 = diro + file2

filenamein = diro + file1

; create normal distrbution with 300 bins

nbins = 600

opt = True
opt@npts = nbins
nd = genNormalDist(1,1,opt)

nd = nd / sum(nd)

dims = dimsizes(nd)
print(dims)

ndcdf = new(dims,float)
ndcdf(0) = nd(0)

do nn = 1,dims-1
	ndcdf(nn) = ndcdf(nn-1) + nd(nn)
end do

;now take values at equal spacings:
spacing = (nbins/30)

weightslons = new(22,float)

weightslons(0) = 0.0
weightslons(1) = ndcdf(2 * spacing - 1)
weightslons(2) = ndcdf(4 * spacing - 1)
weightslons(3) = ndcdf(8 * spacing - 1)
weightslons(4) = ndcdf(12 * spacing - 1)
weightslons(5) = ndcdf(16 * spacing - 1)
weightslons(6) = ndcdf(20 * spacing - 1)
weightslons(7) = ndcdf(24 * spacing - 1)
weightslons(8) = ndcdf(28 * spacing - 1)
weightslons(9) = ndcdf(30 * spacing - 1)
weightslons(10) = ndcdf(30 * spacing - 1)
weightslons(11) = ndcdf(30 * spacing - 1)
weightslons(12) = ndcdf(30 * spacing - 1)
weightslons(13) = ndcdf(28 * spacing - 1)
weightslons(14) = ndcdf(24 * spacing - 1)
weightslons(15) = ndcdf(20 * spacing - 1)
weightslons(16) = ndcdf(16 * spacing - 1)
weightslons(17) = ndcdf(12 * spacing - 1)
weightslons(18) = ndcdf(8 * spacing - 1)
weightslons(19) = ndcdf(4 * spacing - 1)
weightslons(20) = ndcdf(2 * spacing - 1)
weightslons(21) = 0.0

print(weightslons)

weightslats = new(11,float)

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
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS(0,:,:)
lm = cdf_file->LANDFRAC(0,:,:)
lats = cdf_file->lat
lons = cdf_file->lon

filenamein2 = diro + file2

print("reading file in...")
  cdf_file = addfile(filenamein2,"r")
print("file read in")

sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

print(dimsizes(sgh))

gpt_new = gpt
sgh_new = sgh
sgh30_new = sgh30

printVarSummary(sgh)

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

printVarSummary(gpt_new)
printVarSummary(weightslons)
printVarSummary(weightslats)
printVarSummary(Tibet_max)

latweight = 0
do ny=starti,starti + dimsizes(weightslats)-1
	lonweight = 0
	do nx = startj,startj + dimsizes(weightslons)-1
			mult = (weightslons(lonweight) * weightslats(latweight))
		print(mult * 1)
			gpt_new(ny,nx) = gpt_new(ny,nx) * (1.0 - mult) + (Tibet_max * mult)
			sgh_new(ny,nx) = sgh_new(ny,nx) * (1.0 - mult) + (sgh_max * mult)
			sgh30_new(ny,nx) = sgh30_new(ny,nx) * (1.0 - mult) + (sgh30_max * mult)
	
		lonweight = lonweight + 1
	end do
	latweight = latweight + 1
end do

print("reading file in...")
  cdf_out = addfile(fileout1,"w")
print("file read in")

cdf_out ->PHIS(0,:,:)      = (/gpt_new/)
delete(cdf_out)

print("reading file in...")
  cdf_out = addfile(fileout2,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
cdf_out ->SGH     = (/sgh_new/)
cdf_out ->SGH30     = (/sgh30_new/)

delete(cdf_out)

end
