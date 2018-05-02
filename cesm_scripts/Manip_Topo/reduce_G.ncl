load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

percent=80.0

startlon = 260  ; 65 from T, 72.5 from M
endlon = 350  ; 120 from T, 150 from M
startlat = 60 ; 14 from T, 42 from M
endlat = 84 ; 38.5 from T, 55 from M

startlonR = 280.0  ; 
endlonR = 350.0  ; 
startlatR = 55.0 ; 
endlatR = 70.0 ;

old_gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

newfile = "Gland" + percent + "_USGS-gtopo30_1.9x2.5_remap_c050602.nc"

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

filenamein = "/home/disk/eos4/rachel/inputdata/topo/USGS-gtopo30_1.9x2.5_remap_c050602.nc"

print("reading file in...")
cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC

gpt_new = gpt
gpt_min = gpt * (percent) / 100.0   

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
; For Asia:
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

print(startnlat)
print(endnlat)
print(startnlon)
print(endnlon)

; make sure minimum values from multiplication are not less than old_gpt_min
do ny = 0,numlats-1
    do nx = 0,numlons-1
        gpt_min(ny,nx) = max((/gpt_min(ny,nx),old_gpt_min/))
    end do
end do

;sponge region - southern edge
gwgt = 5
do ny = startnlat-5,startnlat
	gwgt2 = 5
	print("first 5")
	do nx = startnlon-5,startnlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
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
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt2 = 0
	print("last 5")
	lastlon=min((/endnlon+5,numlons-1/))
    do nx = endnlon,lastlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)
		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt = gwgt - 1

end do

;sponge region - northern edge
gwgt = 0

lastlat = min((/endnlat+5,numlats-1/))
do ny = endnlat,lastlat
	gwgt2 = 5
	do nx = startnlon-5,startnlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 - 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
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
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do

	gwgt2 = 0
    lastlon=min((/endnlon+5,numlons-1/))
	do nx = endnlon,lastlon
		f2 = (/weights(gwgt),weights(gwgt2)/)
		gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
		sgh_new(ny,nx) = max(f2) * sgh(ny,nx)
		sgh30_new(ny,nx) = max(f2) * sgh30(ny,nx)

		gwgt2 = gwgt2 + 1
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)		
		end if
	end do
	gwgt = gwgt + 1
end do

;sponge region western region
gwgt = 5
do nx = startnlon-5,startnlon
	do ny = startnlat + 1,endnlat-1
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
	gwgt = gwgt - 1
end do

;sponge region eastern region
gwgt = 0
lastlon=min((/endnlon+5,numlons-1/))
do nx = endnlon,lastlon
	do ny = startnlat + 1,endnlat-1
		gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
		sgh_new(ny,nx) = weights(gwgt) * sgh(ny,nx)
		sgh30_new(ny,nx) = weights(gwgt) * sgh30(ny,nx)
		if (lm(ny,nx) .gt. 0)
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
	gwgt = gwgt + 1
end do

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
			f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
			gpt_new(ny,nx) = max(f) * lm(ny,nx)
			f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
			sgh_new(ny,nx) = max(f2) * lm(ny,nx)
			f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = max(f3) * lm(ny,nx)	
		end if
	end do
end do

; For the Rockies
; Find start and end lon and lats
do ilat = 0,numlats-2
    if lats(ilat) .LE. startlatR .AND. lats(ilat+1) .GT. startlatR then
        startnlat = ilat
    end if
    if lats(ilat) .LE. endlatR .AND. lats(ilat+1) .GT. endlatR then
        endnlat = ilat
    end if
end do

do ilon = 0,numlons-2
    if lons(ilon) .LE. startlonR .AND. lons(ilon+1) .GT. startlonR then
        startnlon = ilon
    end if
    if lons(ilon) .LE. endlonR .AND. lons(ilon+1) .GT. endlonR then
        endnlon = ilon
    end if
end do

print(startnlon*1.0)
print(endnlon * 1.0)
print(startnlat*1)
print(endnlat*1)

;sponge region - southern edge
gwgt = 5
do ny = startnlat-5,startnlat
    gwgt2 = 5
    print("first 5")
    do nx = startnlon-5,startnlon
        f2 = (/weights(gwgt),weights(gwgt2)/)
        gpt_new(ny,nx) = max(f2) * gpt_new(ny,nx)
        sgh_new(ny,nx) = max(f2) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = max(f2) * sgh30_new(ny,nx)

        gwgt2 = gwgt2 - 1
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)
        end if

    end do
    do nx = startnlon + 1,endnlon-1
        gpt_new(ny,nx) = weights(gwgt) * gpt_new(ny,nx)
        sgh_new(ny,nx) = weights(gwgt) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = weights(gwgt) * sgh30_new(ny,nx)
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)
        end if
    end do

    gwgt2 = 0
    print("last 5")
    lastlon=min((/endnlon+5,numlons-1/))
    do nx = endnlon,lastlon
        f2 = (/weights(gwgt),weights(gwgt2)/)
        gpt_new(ny,nx) = max(f2) * gpt_new(ny,nx)
        sgh_new(ny,nx) = max(f2) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = max(f2) * sgh30_new(ny,nx)
        gwgt2 = gwgt2 + 1
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)
        end if
    end do

    gwgt = gwgt - 1

end do

;sponge region - northern edge
gwgt = 0
lastlat = min((/endnlat+5,numlats-1/))
do ny = endnlat,lastlat
    gwgt2 = 5
    do nx = startnlon-5,startnlon
        f2 = (/weights(gwgt),weights(gwgt2)/)
        gpt_new(ny,nx) = max(f2) * gpt_new(ny,nx)
        sgh_new(ny,nx) = max(f2) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = max(f2) * sgh30_new(ny,nx)
        
        gwgt2 = gwgt2 - 1
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)  
        end if
    end do
    
    do nx = startnlon + 1,endnlon-1
        gpt_new(ny,nx) = weights(gwgt) * gpt_new(ny,nx)
        sgh_new(ny,nx) = weights(gwgt) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = weights(gwgt) * sgh30_new(ny,nx)
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)  
        end if
    end do
    
    gwgt2 = 0
    lastlon=min((/endnlon+5,numlons-1/))
    do nx = endnlon,lastlon
        f2 = (/weights(gwgt),weights(gwgt2)/)
        gpt_new(ny,nx) = max(f2) * gpt_new(ny,nx)
        sgh_new(ny,nx) = max(f2) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = max(f2) * sgh30_new(ny,nx)
        
        gwgt2 = gwgt2 + 1
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)      
        end if
    end do
    gwgt = gwgt + 1
end do

;sponge region western region
gwgt = 5
do nx = startnlon-5,startnlon
    do ny = startnlat + 1,endnlat-1
        gpt_new(ny,nx) = weights(gwgt) * gpt_new(ny,nx)
        sgh_new(ny,nx) = weights(gwgt) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = weights(gwgt) * sgh30_new(ny,nx)
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)
        end if
    end do
    gwgt = gwgt - 1
end do


;sponge region eastern region
gwgt = 0
lastlon=min((/endnlon+5,numlons-1/))
do nx = endnlon,lastlon
    do ny = startnlat + 1,endnlat-1
        gpt_new(ny,nx) = weights(gwgt) * gpt_new(ny,nx)
        sgh_new(ny,nx) = weights(gwgt) * sgh_new(ny,nx)
        sgh30_new(ny,nx) = weights(gwgt) * sgh30_new(ny,nx)
        if (lm(ny,nx) .gt. 0)
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
            gpt_new(ny,nx) = max(f) * lm(ny,nx)
            f2 = (/min((/sgh_min,sgh(ny,nx)/)),sgh_new(ny,nx)/)
            sgh_new(ny,nx) = max(f2) * lm(ny,nx)
            f3 = (/min((/sgh30_min,sgh30(ny,nx)/)),sgh30_new(ny,nx)/)
            sgh30_new(ny,nx) = max(f3) * lm(ny,nx)
        end if
    end do
    gwgt = gwgt + 1
end do

do ny = startnlat+1,endnlat-1
    do nx = startnlon + 1,endnlon - 1
        print(ny*1)
        print(nx*1)
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
            f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
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
