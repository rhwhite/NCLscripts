load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

gpt_min = 0 ;0m
aps_min = 100000.0 ; based on point at i = 38, j = 17
oromea_min =0.0
aps_max = 101117


orosig_min = 0.0005
oropic_min = 130
oroval_min = 60

; reduce orography
max_red = 0.001

;filein = "T63GR15_jan_surf.nc"
filein = "rerun_ECHAM6_MR_MLO_NoTopo_SU_echam"

newfile = filein + "_orig"

diro = "/home/disk/eos4/rachel/MPIESM/ECHAM6.1/outfiles/ECHAM6_MR_MLO_NoTopo_SU/"

system("cp " + diro +  filein + " " + diro + newfile)

filenameout = diro + filein


; create normal distrbution with 300 bins

nbins = 60

opt = True
opt@npts = nbins
nd = genNormalDist(1,1,opt)

nd = nd / sum(nd)

dims = dimsizes(nd)
print(dims)

ndcdf_f = new(dims,float)
ndcdf_f(0) = nd(0)

do nn = 1,dims-1
	ndcdf_f(nn) = ndcdf_f(nn-1) + nd(nn)
end do

ndcdf_d = new(dims,double)
ndcdf_d(0) = nd(0)

do nn = 1,dims-1
        ndcdf_d(nn) = ndcdf_d(nn-1) + nd(nn)
end do

;now take values at equal spacings:
spacing = (nbins/6)
weights_f = new(7,float)

weights_f(0) = ndcdf_f(spacing - 1)
weights_f(1) = ndcdf_f(2 * spacing - 1)
weights_f(2) = ndcdf_f(3 * spacing - 1)
weights_f(3) = ndcdf_f(4 * spacing - 1)
weights_f(4) = ndcdf_f(5 * spacing - 1)
weights_f(5) = 1.0

print(weights_f)

weights_d = new(7,double)

weights_d(0) = ndcdf_d(spacing - 1)
weights_d(1) = ndcdf_d(2 * spacing - 1)
weights_d(2) = ndcdf_d(3 * spacing - 1)
weights_d(3) = ndcdf_d(4 * spacing - 1)
weights_d(4) = ndcdf_d(5 * spacing - 1)
weights_d(5) = 1.0

filenamein = diro + filein

print("reading file in...")
print(filenamein)
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->geosp

lm = cdf_file->slf
aps = cdf_file->aps
oromea = cdf_file->oromea

print(dimsizes(gpt))

gpt_new = gpt
aps_new = aps
oromea_new = oromea

dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)
lons = cdf_file->lon
lats = cdf_file->lat

; Find start and end lon and lats

startnlat = 0
endnlat = numlats

startnlon = 0
endnlon = numlons


do ny = startnlat,endnlat-1
    do nx = startnlon,endnlon - 1

        if (lm(ny,nx) .gt. 0)
            g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)*max_red/)
            gpt_new(ny,nx) = max(g1) * lm(ny,nx)

            g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)*max_red/)
            oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

        else

            gpt_new(ny,nx) = 0.0
            oromea_new(ny,nx) = 0.0
        end if
    end do
end do
	
print("reading file in...")
print(filenameout)
cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->geosp      = (/gpt_new/)
cdf_out ->oromea     = (/oromea_new/)


delete(cdf_out)



end
