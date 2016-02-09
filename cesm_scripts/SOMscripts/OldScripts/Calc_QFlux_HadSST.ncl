load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin

nyears =40
Experiments = (/"CESMtopof19"/) 
startyear = 2

cp = 3996.0 ; (J/kg/K) shr_const_mod.F90
rho = 1026.0 ;(kg/m3)

ndays = (/31.0,28.0,31.0,30.0,31.0,30.0,31.0,31.0,30.0,31.0,30.0,31.0/)

  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105.nc","r")
  mld         = f->hblt              ; (time, z_t, nlat, nlon)
lats = f->yc
lons = f->xc

filename = "/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_clim_c061031.nc"
cdf_file = addfile(filename,"w")
print(filename)

SSTs_clim_ll = cdf_file->SST_cpl + 273.15

dims = dimsizes(lats)
nlats = dims(0)
nlons = dims(1)

print(nlats)
print(nlons)

ndims = dimsizes(SSTs_clim_ll)

ntimes = nyears

print(ntimes)
LHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SSTs_clim_ll))
SHFs = new((/12,ndims(1),ndims(2),ntimes/),typeof(SSTs_clim_ll)) 
LWNs =  new((/12,ndims(1),ndims(2),ntimes/),typeof(SSTs_clim_ll)) 
SWNs =  new((/12,ndims(1),ndims(2),ntimes/),typeof(SSTs_clim_ll)) 


print(dimsizes(SSTs_clim_ll))
count = 0

print(count)
  
do iyear=startyear,(startyear+nyears-1)
	print(iyear*1)
	do imonth = 1,12
		if iyear .lt. 10
			yearstring = ("000" + tostring(iyear))
		else
			yearstring = tostring("00" + iyear)
		end if
		if imonth .lt. 10
			monthstring = ("0" + tostring(imonth))
		else
			monthstring = tostring(imonth)
		end if

	filename = ("/home/disk/eos4/rachel/CESM_outfiles/" + Experiments + "/atm/hist/" + Experiments + ".cam2.h0." + yearstring +"-" + monthstring + ".nc")

	cdf_file = addfile(filename,"r")

	LHFs(imonth-1,:,:,count) = cdf_file->LHFLX(0,:,:) ; positive upwards
	SHFs(imonth-1,:,:,count) = cdf_file->SHFLX(0,:,:) ; positive upwards (assumed!)
	LWNs(imonth-1,:,:,count) = cdf_file->FLNS(0,:,:) ; positive upwards (assumed!)
	SWNs(imonth-1,:,:,count) = cdf_file->FSNS(0,:,:) ; positive upwards (assumed!)


	end do
	count = count + 1
end do

;create mean

SHFs_clim_ll = dim_avg(SHFs)
LHFs_clim_ll = dim_avg(LHFs)
SFRs_clim_ll = dim_avg(LWNs)+dim_avg(SWNs)

; Put onto pop grid
SHFs_clim = PopLatLon(SHFs_clim_ll,"fv1.9x2.5","gx1v6","bilin","da","090206")      
LHFs_clim = PopLatLon(LHFs_clim_ll,"fv1.9x2.5","gx1v6","bilin","da","090206")      
SFRs_clim = PopLatLon(SFRs_clim_ll,"fv1.9x2.5","gx1v6","bilin","da","090206")      

SSTs_clim = PopLatLon(SSTs_clim_ll,"fv1.9x2.5","gx1v6","bilin","da","090206")      

AHFs_clim = SFRs_clim - LHFs_clim - SHFs_clim


delete([/"LHFs","SHFs","SRFRADs","SHFs_clim_ll","LHFs_clim_ll","SFRs_clim_ll","AHFs_clim_ll"/])

ndims = dimsizes(SSTs_clim)
print(ndims)
print(dimsizes(AHFs_clim))

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
diro = "/home/disk/eos4/rachel/inputdata/som/"
filo = "OQFLX_from_" + Experiments  + ".cam2.h0.nc"
system("/bin/rm -f " + diro + filo)
fout_std = addfile(diro + filo, "c")

setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout_std,fAtt)

;set dimensions of output file
dimNames = (/"month","lat","lon"/)
dimSizes = (/ndims(0),ndims(1),ndims(2)/)
dimUnlim = (/True,False,False/)
filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

filevardef(fout_std,"lat",typeof(lats),(/"lat","lon"/))
filevardef(fout_std,"lon",typeof(lons),(/"lat","lon"/))

filevardef(fout_std,"SSTs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))

filevardef(fout_std,"SHFs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))
filevardef(fout_std,"LHFs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))
filevardef(fout_std,"SFRs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))

filevardef(fout_std,"AHFs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))

filevardef(fout_std,"OHFs_clim",typeof(SHFs_clim),(/"month","lat","lon"/))

filevardef(fout_std,"DTterm_clim",typeof(SHFs_clim),(/"month","lat","lon"/))
filevardef(fout_std,"DT_clim",typeof(SHFs_clim),(/"month","lat","lon"/))

fout_std->lat = (/lats/)
fout_std->lon = (/lons/)

fout_std->SSTs_clim = (/SSTs_clim/)
fout_std->SHFs_clim = (/SHFs_clim/)
fout_std->LHFs_clim = (/LHFs_clim/)
fout_std->SFRs_clim = (/SFRs_clim/)
fout_std->AHFs_clim = (/AHFs_clim/)


OHFs_clim = new(dimsizes(AHFs_clim),typeof(AHFs_clim))
DTterm_clim = new(dimsizes(AHFs_clim),typeof(AHFs_clim))
DT_clim = new(dimsizes(AHFs_clim),typeof(AHFs_clim))

;Calculate Ocean heat flux

print(nlats)
print(nlons)

do imonth = 0,11
	do ilat=0,nlats-1
		do ilon=0,nlons-1
			imonth2 = imonth + 1
			if (imonth2 .GT. 11) then
				imonth2 = 1
			end if

			DeltaT = SSTs_clim(imonth2,ilat,ilon) - SSTs_clim(imonth,ilat,ilon)

			Tchange = (DeltaT * cp * rho * mld(imonth,ilat,ilon))/(ndays(imonth) * 24.0 * 60.0 * 60.0)
			OHFs_clim(imonth,ilat,ilon) = Tchange - AHFs_clim(imonth,ilat,ilon)
			DTterm_clim(imonth,ilat,ilon) = Tchange
			DT_clim(imonth,ilat,ilon) = DeltaT
		end do
	end do
end do		

fout_std->OHFs_clim = (/OHFs_clim/)
fout_std->DT_clim = (/DT_clim/)
fout_std->DTterm_clim = (/DTterm_clim/)

end

