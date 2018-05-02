load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlon = 72.0
endlon = 152.5
startlat = 44.0
endlat = 54.0

gpt_min = 490 ;50m
aps_min = 100000.0 ; based on point at i = 38, j = 17
oromea_min = 50.0
aps_max = 101117


orosig_min = 0.0005
oropic_min = 130
oroval_min = 60

max_red = 0.6
max_red2 = 0.95

;filein = "T63GR15_jan_surf.nc"
filein = "rerun_ECHAM6_LR_MLO_NoMSU_echam"

newfile = filein + "_original40"

diro = "/home/disk/eos4/rachel/MPIESM/ECHAM6.1/outfiles/ECHAM6_LR_MLO_NoMSU/"

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
aps = cdf_file->aps

lm = cdf_file->slm
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
do ilat = 0,numlats-2
	if lats(ilat) .GE. startlat .AND. lats(ilat+1) .LT. startlat then
		endnlat = ilat
	end if
	if lats(ilat) .GE. endlat .AND. lats(ilat+1) .LT. endlat then
		startnlat = ilat
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

print(startnlat)
print(endnlat)

;sponge region - southern edge
gwgt = 5
do ny = startnlat-5,startnlat
	gwgt2 = 5
	print("first 5")
	do nx = startnlon-5,startnlon
		f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
                f2_d2 = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)

		gpt_new(ny,nx) = max(f2_d) * gpt(ny,nx)
		aps_new(ny,nx) = aps(ny,nx) / max(f2_d2)  
                oromea_new(ny,nx) = max(f2_d) * oromea(ny,nx)


		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(g1) * lm(ny,nx)
			g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
			aps_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
			g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
			oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
		end if

	end do
	print("then")
	do nx = startnlon + 1,endnlon-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                aps_new(ny,nx) = min((/1.0/weights_d(gwgt),1.0/max_red2/)) * aps(ny,nx)
                oromea_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * oromea(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		end if
	end do

	gwgt2 = 0
	print("last 5")
	do nx = endnlon,endnlon + 5
		f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
                f2_d2 = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)

                gpt_new(ny,nx) = max(f2_d) * gpt(ny,nx)
                aps_new(ny,nx) = aps(ny,nx) / max(f2_d2)
                oromea_new(ny,nx) = max(f2_d) * oromea(ny,nx)
		
		gwgt2 = gwgt2 + 1
		
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
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
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)

                gpt_new(ny,nx) = max(f2_d) * gpt(ny,nx)
                aps_new(ny,nx) = aps(ny,nx) / max(f2_d2)
                oromea_new(ny,nx) = max(f2_d) * oromea(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
		end if
	end do

	do nx = startnlon + 1,endnlon-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                aps_new(ny,nx) = max((/1.0 /weights_d(gwgt),1.0 / max_red2/)) * aps(ny,nx)
                oromea_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * oromea(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		end if
	end do

	gwgt2 = 0
	do nx = endnlon,endnlon+5
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)

                gpt_new(ny,nx) = max(f2_d) * gpt(ny,nx)
                aps_new(ny,nx) = aps(ny,nx) / max(f2_d2)
                oromea_new(ny,nx) = max(f2_d) * oromea(ny,nx)

		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
		end if
	end do
	gwgt = gwgt + 1
end do

print(gwgt)
;sponge region western region
gwgt = 5
do nx = startnlon-5,startnlon
	do ny = startnlat + 1,endnlat-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                aps_new(ny,nx) = max((/1.0 / weights_d(gwgt),1.0 / max_red2/)) * aps(ny,nx)
                oromea_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * oromea(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		end if
	end do
	gwgt = gwgt - 1
end do

print(gwgt)

;sponge region eastern region
gwgt = 0
do nx = endnlon,endnlon+5
	do ny = startnlat + 1,endnlat-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                aps_new(ny,nx) = max((/1.0 / weights_d(gwgt),1.0 / max_red2/)) * aps(ny,nx)
                oromea_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * oromea(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		end if
	end do
	gwgt = gwgt + 1
end do

print(gwgt)


do ny = startnlat+1,endnlat-1
	do nx = startnlon + 1,endnlon - 1
		
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)*max_red/)
			gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/max((/aps_min,aps(ny,nx)/)),aps_new(ny,nx)/max_red2/)
                        aps_new(ny,nx) = min(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/oromea_min,oromea(ny,nx)/)),oromea_new(ny,nx)*max_red/)
                        oromea_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		else

			gpt_new(ny,nx) = gpt(ny,nx)
			aps_new(ny,nx) = aps(ny,nx)
			oromea_new(ny,nx) = oromea(ny,nx)
		end if
	end do
end do

print("reading file in...")
print(filenameout)
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->geosp      = (/gpt_new/)
cdf_out ->oromea     = (/oromea_new/)
cdf_out ->aps	     = (/aps_new/)


delete(cdf_out)



end
