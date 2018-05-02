load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlon = 72.0
endlon = 152.5
startlat = 44.0
endlat = 54.0

gpt_min = 490 ;50m
az0_min = 0.25 ; based on point at i = 38, j = 17
orostd_min = 15
orosig_min = 0.0005
oropic_min = 130
oroval_min = 60

max_red = 0.85
max_red2 = 0.0

filein = "T63GR15_jan_surf.nc"
filein2 = "jsbach_T63GR15_11tiles_1850.nc"
newfile = "NoMong_t95_" + filein
newfile2 = "NoMong_" + filein2

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
lm = cdf_file->SLM
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
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)
		f2_dgpt = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
		gpt_new(ny,nx) = max(f2_dgpt) * gpt(ny,nx)
		az0_new(ny,nx) = max(f2_d) * az0(ny,nx)
                orostd_new(ny,nx) = max(f2_d) * orostd(ny,nx)
                orosig_new(ny,nx) = max(f2_d) * orosig(ny,nx)
                oropic_new(ny,nx) = max(f2_d) * oropic(ny,nx)
                oroval_new(ny,nx) = max(f2_d) * oroval(ny,nx)


		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(g1) * lm(ny,nx)
			g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
			az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
			g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
			orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
			g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

		end if

	end do
	print("then")
	do nx = startnlon + 1,endnlon-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                az0_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * az0(ny,nx)
                orostd_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orostd(ny,nx)
                orosig_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orosig(ny,nx)
                oropic_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oropic(ny,nx)
                oroval_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oroval(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))		
		end if
	end do

	gwgt2 = 0
	print("last 5")
	do nx = endnlon,endnlon + 5
		f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)
                f2_dgpt = (/weights_d(gwgt),weights_d(gwgt2),max_red/)

                gpt_new(ny,nx) = max(f2_dgpt) * gpt(ny,nx)
                az0_new(ny,nx) = max(f2_d) * az0(ny,nx)
                orostd_new(ny,nx) = max(f2_d) * orostd(ny,nx)
                orosig_new(ny,nx) = max(f2_d) * orosig(ny,nx)
                oropic_new(ny,nx) = max(f2_d) * oropic(ny,nx)
                oroval_new(ny,nx) = max(f2_d) * oroval(ny,nx)
		
		gwgt2 = gwgt2 + 1
		
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx)) 

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
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)
                f2_dgpt = (/weights_d(gwgt),weights_d(gwgt2),max_red/)
                gpt_new(ny,nx) = max(f2_dgpt) * gpt(ny,nx)
                az0_new(ny,nx) = max(f2_d) * az0(ny,nx)
                orostd_new(ny,nx) = max(f2_d) * orostd(ny,nx)
                orosig_new(ny,nx) = max(f2_d) * orosig(ny,nx)
                oropic_new(ny,nx) = max(f2_d) * oropic(ny,nx)
                oroval_new(ny,nx) = max(f2_d) * oroval(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)
                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx)) 

		end if
	end do

	do nx = startnlon + 1,endnlon-1
                gpt_new(ny,nx) = max((/weights_d(gwgt),max_red/)) * gpt(ny,nx)
                az0_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * az0(ny,nx)
                orostd_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orostd(ny,nx)
                orosig_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orosig(ny,nx)
                oropic_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oropic(ny,nx)
                oroval_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oroval(ny,nx)		

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
		        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
		end if
	end do

	gwgt2 = 0
	do nx = endnlon,endnlon+5
                f2_d = (/weights_d(gwgt),weights_d(gwgt2),max_red2/)
                f2_dgpt = (/weights_d(gwgt),weights_d(gwgt2),max_red/)

                gpt_new(ny,nx) = max(f2_dgpt) * gpt(ny,nx)
                az0_new(ny,nx) = max(f2_d) * az0(ny,nx)
                orostd_new(ny,nx) = max(f2_d) * orostd(ny,nx)
                orosig_new(ny,nx) = max(f2_d) * orosig(ny,nx)
                oropic_new(ny,nx) = max(f2_d) * oropic(ny,nx)
                oroval_new(ny,nx) = max(f2_d) * oroval(ny,nx)

		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
                        
                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
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
                az0_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * az0(ny,nx)
                orostd_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orostd(ny,nx)
                orosig_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orosig(ny,nx)
                oropic_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oropic(ny,nx)
                oroval_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oroval(ny,nx)

		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))
	

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
                az0_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * az0(ny,nx)
                orostd_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orostd(ny,nx)
                orosig_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * orosig(ny,nx)
                oropic_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oropic(ny,nx)
                oroval_new(ny,nx) = max((/weights_d(gwgt),max_red2/)) * oroval(ny,nx)


		if (lm(ny,nx) .gt. 0)
                        g1 = (/min((/gpt_min,gpt(ny,nx)/)),gpt_new(ny,nx)/)
                        gpt_new(ny,nx) = max(g1) * lm(ny,nx)

                        g2 = (/min((/az0_min,az0(ny,nx)/)),az0_new(ny,nx)/)
                        az0_new(ny,nx) = max(g2) * todouble(lm(ny,nx))

                        g3 = (/min((/orostd_min,orostd(ny,nx)/)),orostd_new(ny,nx)/)
                        orostd_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/orosig_min,orosig(ny,nx)/)),orosig_new(ny,nx)/)
                        orosig_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oropic_min,oropic(ny,nx)/)),oropic_new(ny,nx)/)
                        oropic_new(ny,nx) = max(g3) * todouble(lm(ny,nx))

                        g3 = (/min((/oroval_min,oroval(ny,nx)/)),oroval_new(ny,nx)/)
                        oroval_new(ny,nx) = max(g3) * todouble(lm(ny,nx))



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
