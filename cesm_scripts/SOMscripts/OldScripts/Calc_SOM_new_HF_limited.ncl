load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

const = - 0.75

nstartlat = -35;-40.0
nendlat = 45.0;45.0

newfile = "pop_frc.gx1v6.100105_V16.nc"

  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105.nc","r")

  qflx         = f->qdp              ; (time, z_t, nlat, nlon)
  lats         = f->yc
  lons	       = f->xc

 delete(f)

 system("cp $HOME/inputdata/som/pop_frc.gx1v6.100105.nc $HOME/inputdata/som/" + newfile)

  f         = addfile("$HOME/inputdata/som/" + newfile,"w")


; create normal distrbution with 300 bins
begin

nbins = 100

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
spacing = (nbins/24) ; 25 gridboxes is around 10 degrees at this resolution.
weights = new(25,float)

weights(0) = ndcdf(spacing - 1)
do nw = 1,23
weights(nw) = ndcdf((nw+1) * spacing - 1)
end do
weights(24) = 1.0

print(weights)

delete(dims)
dims = dimsizes(qflx)
print(dims)

f2 = addfile("/home/disk/eos4/rachel/inputdata/ssts/SFLXS_AM_CESMSOMtopof19g16_CESMtopof19.cam2.h0.nc","r")


qflx_corr = f2->SFCFLXs_AM_diffs*const

new_qflx = new(dimsizes(qflx),typeof(qflx))

; regrid qflx_corr onto pop grid.
qc_remap=PopLatLon(qflx_corr,"fv1.9x2.5","gx1v6","bilin","da","090206")      


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

do mm = 0,11
print(mm * 1)

; southern bit - nothing up to 50S





do ilon = 0,dims(2)-1		
counts = 0
	do ilat = startlats(ilon)-24,startlats(ilon)-1
	
		x = ismissing(qc_remap(ilat,ilon))
		if(x) then
			new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon)
		else 
			new_qflx(mm,ilat,ilon) = (qflx(mm,ilat,ilon) + (qc_remap(ilat,ilon) * weights(counts)))
		end if			
		counts = counts + 1
	end do
end do

do ilon = 0,dims(2)-1
	do ilat =startlats(ilon),endlats(ilon)
		x = ismissing(qc_remap(ilat,ilon))
		if(x) then
			new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon)
		else 
			new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon) + qc_remap(ilat,ilon)
		end if
	end do
end do



do ilon = 0,dims(2)-1		
counts = 23
	do ilat = endlats(ilon)+1,endlats(ilon)+24
		x = ismissing(qc_remap(ilat,ilon))
		if(x) then
			new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon)
		else 
			new_qflx(mm,ilat,ilon) = (qflx(mm,ilat,ilon) + (qc_remap(ilat,ilon) * weights(counts)))
		end if
	counts = counts - 1
	end do
end do

end do

f->qdp = (/new_qflx/)

end
