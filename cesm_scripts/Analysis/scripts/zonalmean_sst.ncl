load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_climZM_c061031.nc"

print("reading file in...")
  cdf_file = addfile(filename,"w")
print("file read in")

sst = cdf_file->SST_cpl
sst_pd = cdf_file->SST_cpl_prediddle
cice = cdf_file->ice_cov
cice_pd = cdf_file->ice_cov_prediddle

lmfilename = "/home/disk/eos4/rachel/CESM_outfiles/CESMtopof19/run1/atm/hist/landmask.nc"

lm_file = addfile(lmfilename,"r")

landmask = lm_file->landmask
sst_new = sst
sst_pd_new = sst_pd
cice_new = cice
cice_pd_new = cice_pd


dims1 = dimsizes(sst)
nmonths = dims1(0)
numlats = dims1(1)
numlons = dims1(2)
print(numlats)
print(numlons)

nmonth = 0
do while(nmonth .lt. 12)
nlat = 0
	do while(nlat .lt. numlats)
		nlon = 0
		count = 0
		sstsum = 0.0
		sstpdsum = 0.0
		cicesum = 0.0
		cicepdsum = 0.0
		do while (nlon .lt. numlons)
			if (landmask(nlat,nlon) .eq. 0) 
				count = count + 1
				sstsum = sstsum + sst(nmonth,nlat,nlon)
				sstpdsum = sstpdsum + sst_pd(nmonth,nlat,nlon)

				cicesum = cicesum + cice(nmonth,nlat,nlon)
				cicepdsum = cicepdsum + cice_pd(nmonth,nlat,nlon)
			end if
			nlon = nlon + 1
		end do
		if count .ne. 0
			sst_new(nmonth,nlat,:) = sstsum / count 
			sst_pd_new(nmonth,nlat,:) = sstpdsum / count
			cice_new(nmonth,nlat,:) = cicesum / count 
			cice_pd_new(nmonth,nlat,:) = cicepdsum / count
		else
			sst_new(nmonth,nlat,:) = avg(sst(nmonth,nlat,:)) 
			sst_pd_new(nmonth,nlat,:) = avg(sst_pd(nmonth,nlat,:)) 
			cice_new(nmonth,nlat,:) =  avg(cice(nmonth,nlat,:)) 
			cice_pd_new(nmonth,nlat,:) = avg(cice_pd(nmonth,nlat,:)) 
		end if
		
		nlat = nlat + 1
	end do

	nmonth = nmonth + 1
end do

cdf_file ->SST_cpl      = (/sst_new/)
cdf_file ->SST_cpl_prediddle     = (/sst_pd_new/)
cdf_file ->ice_cov      = (/cice_new/)
cdf_file ->ice_cov_prediddle     = (/cice_pd_new/)

end