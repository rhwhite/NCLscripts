load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

nstartlat = -40.0;-40.0
nendlat = 45.0;45.0

newfile = "pop_frc.gx1v6.100105_V2.1.nc"

  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105.nc","r")

  qflx         = f->qdp              ; (time, z_t, nlat, nlon)
  sst	       = f->T
  lats         = f->yc
  lons	       = f->xc

 delete(f)

 system("cp $HOME/inputdata/som/pop_frc.gx1v6.100105.nc $HOME/inputdata/som/" + newfile)

  f         = addfile("$HOME/inputdata/som/" + newfile,"w")


; create normal distrbution with 300 bins
begin

nbins = 300

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
spacing = (nbins/49) ; 25 gridboxes is around 10 degrees at this resolution.
weights = new(50,float)

weights(0) = ndcdf(spacing - 1)
do nw = 1,48
weights(nw) = ndcdf((nw+1) * spacing - 1)
end do
weights(49) = 1.0

print(weights)

delete(dims)
dims = dimsizes(qflx)
print(dims)

f2 = addfile("/home/disk/eos4/rachel/inputdata/som/OQFLX_from_CESMtopof19.cam2.h0.nc","r")


qc_corr = -1.0 * f2->OHFs_clim
sst_corr = f2->SSTs_clim - 273.15

ndims = dimsizes(lats)
nlats = ndims(0)
nlons = ndims(1)

print(nlons)
print(nlats)

startlats = new(nlons,integer)
endlats = new(nlons,integer)
do ilon = 0,nlons - 1
	do ilat = 1,nlats-1
		if (lats(ilat-1,ilon) .LE. nstartlat .AND. lats(ilat,ilon) .GT. nstartlat) then
			startlats(ilon) = ilat-1
		end if
		if (lats(ilat-1,ilon) .LE. nendlat .AND. lats(ilat,ilon) .GT. nendlat) then
			endlats(ilon) = ilat
		end if
	end do
end do

new_qflx = qflx
new_sst = sst

do mm = 0,11
print(mm * 1)

; southern bit - nothing up to 50S

	do ilon = 0,dims(2)-1
		counts = 0
		do ilat = startlats(ilon)-49,startlats(ilon)-1
			new_qflx(mm,ilat,ilon) = (qflx(mm,ilat,ilon) * (1.0 - weights(counts))) + (qc_corr(mm,ilat,ilon) * weights(counts))
			new_sst(mm,ilat,ilon) = (sst(mm,ilat,ilon) * (1.0 - weights(counts))) + (sst_corr(mm,ilat,ilon) * weights(counts))

			counts = counts + 1
		end do

		do ilat =startlats(ilon),endlats(ilon)
			new_qflx(mm,ilat,ilon) = qc_corr(mm,ilat,ilon)
			new_sst(mm,ilat,ilon) = sst_corr(mm,ilat,ilon)
		end do

		counts = 49
		do ilat = endlats(ilon)+1,endlats(ilon)+48
			new_qflx(mm,ilat,ilon) = (qflx(mm,ilat,ilon)* (1.0 - weights(counts))) + (qc_corr(mm,ilat,ilon) * weights(counts))
			new_sst(mm,ilat,ilon) = (sst(mm,ilat,ilon)* (1.0 - weights(counts))) + (sst_corr(mm,ilat,ilon) * weights(counts))
			counts = counts - 1
		end do
	end do

end do

copy_VarCoords(qflx,new_qflx)
copy_VarCoords(sst,new_sst)


f->qdp = (/new_qflx/)
f->T = (/new_sst/)

end