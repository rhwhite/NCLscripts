load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

constn = 1.2
constp = 0.8

  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105.nc","r")

  qflx         = f->qdp              ; (time, z_t, nlat, nlon)

 delete(f)

  f         = addfile("$HOME/inputdata/som/pop_frc.gx1v6.100105_V3.nc","w")



dims = dimsizes(qflx)
print(dims)

f2 = addfile("/home/disk/eos4/rachel/inputdata/ssts/SFLXS_Clim_comp_CESMSOMtopof19g16_CESMtopof19.cam2.h0.nc","r")

qflx_corr = f2->HFs_clim_diffs

new_qflx = new(dimsizes(qflx),typeof(qflx))

; regrid qflx_corr onto pop grid.
qc_remap=PopLatLon(qflx_corr,"fv1.9x2.5","gx1v6","bilin","da","090206")      

print(dimsizes(qc_remap))
print(dimsizes(qflx))

do mm = 0,11
print(mm * 1)
	do ilat =0,dims(1)-1
		do ilon = 0,dims(2)-1

			x = ismissing(qc_remap(mm,ilat,ilon))
			if(x) then
				new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon)
			else 
				new_qflx(mm,ilat,ilon) = qflx(mm,ilat,ilon)
				y = qc_remap(mm,ilat,ilon)
				a = qflx(mm,ilat,ilon)
				if(y .LT. 0) then
					new_qflx(mm,ilat,ilon) = a + y*constn
				else
					new_qflx(mm,ilat,ilon) = a + y*constp
				end if
			end if
		end do
	end do
end do


f->qdp = (/new_qflx/)

