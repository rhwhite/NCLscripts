load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startnlon = 26
endnlon = 48
startnlat = 55
endnlat = 68

gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

newfile = "NoT_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  "USGS-gtopo30_1.9x2.5_remap_c050602.nc " + diro + newfile)

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

filenamein = "/home/disk/eos4/rachel/inputdata/topo/USGS-gtopo30_1.9x2.5_remap_c050602.nc"

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

;sponge region - southern edge
gwgt = 5
do ny = startnlat-5,startnlat
	gwgt2 = 5
	print("first 5")
	do nx = startnlon-5,startnlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		print(max(f2))
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if

	end do
	print("then")
	do nx = startnlon + 1,endnlon-1
		print(weights(gwgt)*1)
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt2 = 0
	print("last 5")
	do nx = endnlon,endnlon + 5
		f2 = (/weights(gwgt),weights(gwgt2)/)
		print(max(f2))
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)
		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt = gwgt - 1

end do
;print(gwgt)

;sponge region - northern edge
gwgt = 0
do ny = endnlat,endnlat+5
	gwgt2 = 5
	do nx = startnlon-5,startnlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	do nx = startnlon + 1,endnlon-1
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt2 = 0
	do nx = endnlon,endnlon+5
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)		
		end if
	end do
	gwgt = gwgt + 1
end do

print(gwgt)
;sponge region western region
gwgt = 5
do nx = startnlon-5,startnlon
	do ny = startnlat + 1,endnlat-1
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
	gwgt = gwgt - 1
end do

print(gwgt)

;sponge region eastern region
gwgt = 0
do nx = endnlon,endnlon+5
	do ny = startnlat + 1,endnlat-1
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
	gwgt = gwgt + 1
end do

print(gwgt)


do ny = startnlat+1,endnlat-1
	do nx = startnlon + 1,endnlon - 1
		if (lm(ny,nx) .gt. 0)
			gpt_new(ny,nx) = 9.8
			sgh_new(ny,nx) = 9.8
			sgh30_new(ny,nx) = 9.8
		else
			gpt_new(ny,nx) = 0
			sgh_new(ny,nx) = 0
			sgh30_new(ny,nx) = 0
		end if
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
end do


print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
cdf_out ->SGH     = (/sgh_new/)
cdf_out ->SGH30     = (/sgh30_new/)

end
