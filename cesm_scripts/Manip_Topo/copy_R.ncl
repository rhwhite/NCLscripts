load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlon = 210.0 ;
endlon = 270.0 ; 214 in index worls
startlat = 20.0 ;127
endlat = 69.0  ;171

newstartlon = 50

gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

newfile = "AsianRockies_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  "NoMT_USGS-gtopo30_1.9x2.5_remap_c050602.nc " + diro + newfile)

filenameout = "/home/disk/eos4/rachel/inputdata/topo/" + newfile


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

filenamein = "/home/disk/eos4/rachel/inputdata/topo/NoMT_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC

gpt_new = gpt

sgh_new = sgh
sgh30_new = sgh30

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

lons = cdf_file->lon
lats = cdf_file->lat

; Find start and end lon and lats
do ilat = 0,numlats-2
    if lats(ilat) .LE. startlat .AND. lats(ilat+1) .GT. startlat then
        startnlat = ilat
    end if
    if lats(ilat) .LE. endlat .AND. lats(ilat+1) .GT. endlat then
        endnlat = ilat
    end if
end do

do ilon = 0,numlons-2
    if lons(ilon) .LE. startlon .AND. lons(ilon+1) .GT. startlon then
        startnlon = ilon
    end if
    if lons(ilon) .LE. endlon .AND. lons(ilon+1) .GT. endlon then
        endnlon = ilon
    end if
end do


; Find start and end lon and lats for newstartlon
do ilon = 0,numlons-2
    if lons(ilon) .LE. newstartlon .AND. lons(ilon+1) .GT. newstartlon then
        newstartnlon = ilon
    end if
end do

nlons = endnlon - startnlon
newendnlon = newstartnlon + nlons


sponge=5
; western edge
do ilon = newstartnlon,newstartnlon+sponge
    gwgt = ilon - newstartnlon
    do ilat = startnlat,endnlat
        gpt_new(ilat,ilon) = (max((/gpt_min,gpt_new(ilat,ilon) + (weights(gwgt) * gpt(ilat,startnlon + gwgt))/)) * lm(ilat,ilon))
        sgh_new(ilat,ilon) = (max((/sgh_min,sgh_new(ilat,ilon) + (weights(gwgt) * sgh(ilat,startnlon + gwgt))/)) * lm(ilat,ilon))
        sgh30_new(ilat,ilon) = (max((/sgh30_min,sgh30_new(ilat,ilon) + (weights(gwgt) * sgh30(ilat,startnlon + gwgt))/)) * lm(ilat,ilon))
    end do
end do

; Copy orography from startlon to newstartlon

gpt_new(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1) = gpt_new(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1) + gpt(startnlat:endnlat,startnlon+sponge+1:endnlon-sponge-1) * (lm(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1))

sgh_new(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1) = sgh_new(startnlat:endnlat,newstartnlon+sponge + 1:newendnlon-sponge-1) + sgh(startnlat:endnlat,startnlon+sponge + 1:endnlon-sponge-1) * (lm(startnlat:endnlat,newstartnlon + sponge + 1:newendnlon-sponge-1))

sgh30_new(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1) = sgh30(startnlat:endnlat,newstartnlon+sponge+1:newendnlon-sponge-1) + sgh30_new(startnlat:endnlat,startnlon+sponge + 1:endnlon-sponge-1) * (lm(startnlat:endnlat,newstartnlon+sponge + 1:newendnlon-sponge-1))

; eastern edge
do ilon = newendnlon-sponge,newendnlon
    gwgt = -1 * (ilon - newendnlon)
    print(weights(gwgt)*1.0)
    print(1.0 *gwgt)
    do ilat = startnlat,endnlat
        gpt_new(ilat,ilon) = (max((/gpt_min,gpt_new(ilat,ilon) + (weights(gwgt) * gpt(ilat,endnlon - gwgt))/)) * lm(ilat,ilon))
        sgh_new(ilat,ilon) = (max((/sgh_min,sgh_new(ilat,ilon) + (weights(gwgt) * sgh(ilat,endnlon - gwgt))/)) * lm(ilat,ilon))
        sgh30_new(ilat,ilon) = (max((/sgh30_min,sgh30_new(ilat,ilon) + (weights(gwgt) * sgh30(ilat,endnlon - gwgt))/)) * lm(ilat,ilon))
    end do
end do


print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
cdf_out ->SGH     = (/sgh_new/)
cdf_out ->SGH30     = (/sgh30_new/)

end
