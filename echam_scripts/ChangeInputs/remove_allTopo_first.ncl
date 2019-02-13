load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlon = 0.0
endlon = 360
startlat = -90.0
endlat = 90.0

gpt_min = 490 ;50m
az0_min = 0.25 ; based on point at i = 38, j = 17
orostd_min = 15
orosig_min = 0.0005
oropic_min = 130
oroval_min = 60

max_red = 0.95 ; 0.95 for first one!
max_red2 = 0.0

filein = "T63GR15_jan_surf.nc"
filein2 = "jsbach_T63GR15_11tiles_1850.nc"
newfile = "NoTopo_" + sprintf("%2.0f", max_red*100) + "_" + filein
newfile2 = "NoTopo_" + sprintf("%2.0f", max_red*100) + "_" + filein2

diro = "/home/disk/eos4/rachel/inputdata/ECHAM/LR/echam6/T63/"
diro2 = "/home/disk/eos4/rachel/inputdata/ECHAM/LR/jsbach/T63/"

system("cp " + diro +  filein + " " + diro + newfile)
system("cp " + diro2 +  filein2 + " " + diro2 + newfile2)

filenameout = diro + newfile
filenameout2 = diro2 + newfile2


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
  cdf_file = addfile(filenamein,"r")

print("file read in")

gpt = cdf_file->GEOSP
lm = todouble(cdf_file->SLM)
az0 = cdf_file->AZ0
orostd = cdf_file->OROSTD
orosig = cdf_file->OROSIG
oropic = cdf_file->OROPIC
oroval = cdf_file->OROVAL

print(dimsizes(gpt))

gpt_new = gpt
az0_new = az0
orostd_new = orostd
orosig_new = orosig
oropic_new = oropic
oroval_new = oroval

dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)
lons = cdf_file->lon
lats = cdf_file->lat

startnlat = 0
endnlat = numlats

startnlon = 0
endnlon = numlons

do ny = startnlat,endnlat-1
	do nx = startnlon,endnlon - 1
		if (lm(ny,nx) .gt. 0.0)
            if gpt(ny,nx) .lt. 0.0 ; effect of near the edge of very steep orography
                gpt_new(ny,nx) = gpt_min
            else
                g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)*max_red/)
			    gpt_new(ny,nx) = max(g1) * todouble(lm(ny,nx))
            end if
            g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)*max_red2/)
            az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))

            g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)*max_red2/)
            orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

            g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)*max_red2/)
            orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

            g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)*max_red2/)
            oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

            g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)*max_red2/)
            oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
		else

			gpt_new(ny,nx) = 0.0
			az0_new(ny,nx) = 0.001
			orostd_new(ny,nx) = 0.0
			orosig_new(ny,nx) = 0.0
			oropic_new(ny,nx) = 0.0
            oroval_new(ny,nx) = 0.0
		end if
	end do
end do

print("reading file in...")
  cdf_out = addfile(filenameout,"w")
  cdf_out2 = addfile(filenameout2,"w")

print("file read in")

cdf_out ->GEOSP      = (/gpt_new/)
cdf_out ->AZ0     = (/az0_new/)
cdf_out ->OROSTD     = (/orostd_new/)
cdf_out ->OROSIG     = (/orosig_new/)
cdf_out ->OROPIC     = (/oropic_new/)
cdf_out ->OROVAL     = (/oroval_new/)

cdf_out2->roughness_length = (/az0_new/)
cdf_out2->roughness_length_oro = (/az0_new/)

delete(cdf_out)



end
