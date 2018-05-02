load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

percent=0.0

startnlon = 29
endnlon = 61
startnlat = 71
endnlat = 76

old_gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

fileins=(/"WACCM_f19_NoM.cam2.rh0.0001-01-16-00000.nc","WACCM_f19_NoM.cam2.r.0001-01-16-00000.nc"/)

nfiles = dimsizes(fileins)

print(nfiles)

diro = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_NoM_Spinup/"

; Read in land-mask
filenamein = diro + "WACCM_f19_NoM.cam2.rh0.0001-01-06-00000.nc"

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

lm = cdf_file->LANDFRAC/241.0   ; just because land fraction appears to be from
  

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


do ifile=0,nfiles-1
    file1 = fileins(ifile)
    print(file1)

    system("cp " + diro + file1 + " " + diro + "Orig_" + file1)

    fileout1 = diro + file1

    filenamein = diro + file1

    print("reading file in...")
      cdf_file = addfile(filenamein,"r")
    print("file read in")

    gpt = cdf_file->PHIS

    gpt_new = gpt
    gpt_min = (gpt/100.0) * percent


    print(gpt)


    print(dimsizes(gpt))
    dims1 = dimsizes(gpt)
    numlats = dims1(0)
    numlons = dims1(1)
    print(numlats)
    print(numlons)

    ; make sure minimum values from multiplication are not less than old_gpt_min
    do ny = 0,numlats-1
        do nx = 0,numlons-1
            gpt_min(ny,nx) = max((/gpt_min(ny,nx),old_gpt_min/))
        end do
    end do


    print("gpt_min")
    print(gpt_min)

    ;sponge region - southern edge
    gwgt = 5
    do ny = startnlat-5,startnlat
        gwgt2 = 5
        print("first 5")
        do nx = startnlon-5,startnlon
            f2 = (/weights(gwgt),weights(gwgt2)/)
            print(max(f2))
            gpt_new(ny,nx) = max(f2) * gpt(ny,nx)

            gwgt2 = gwgt2 - 1
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if

        end do
        print("then")
        do nx = startnlon + 1,endnlon-1
            print(weights(gwgt)*1)
            gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if
        end do

        gwgt2 = 0
        print("last 5")
        do nx = endnlon,endnlon + 5
            f2 = (/weights(gwgt),weights(gwgt2)/)
            print(max(f2))
            gpt_new(ny,nx) = max(f2) * gpt(ny,nx)
            gwgt2 = gwgt2 + 1
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
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

            gwgt2 = gwgt2 - 1
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if
        end do

        do nx = startnlon + 1,endnlon-1
            gpt_new(ny,nx) = weights(gwgt) * gpt(ny,nx)
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if
        end do

        gwgt2 = 0
        do nx = endnlon,endnlon+5
            f2 = (/weights(gwgt),weights(gwgt2)/)
            gpt_new(ny,nx) = max(f2) * gpt(ny,nx)

            gwgt2 = gwgt2 + 1
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
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
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
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
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if
        end do
        gwgt = gwgt + 1
    end do

    print(gwgt)


    do ny = startnlat+1,endnlat-1
        do nx = startnlon + 1,endnlon - 1
            if (lm(ny,nx) .gt. 0)
                gpt_new(ny,nx) = 9.8
            else
                gpt_new(ny,nx) = 0
            end if
            if (lm(ny,nx) .gt. 0)
                f = (/min((/gpt_min(ny,nx),gpt(ny,nx)/)),gpt_new(ny,nx)/)
                gpt_new(ny,nx) = max(f) * lm(ny,nx)
            end if
        end do
    end do

    ; Now write out this file
    print("reading file in...")
      cdf_out = addfile(fileout1,"w")
    print("file read in")

    cdf_out ->PHIS      = (/gpt_new/)

    delete(cdf_out)
end do
end
