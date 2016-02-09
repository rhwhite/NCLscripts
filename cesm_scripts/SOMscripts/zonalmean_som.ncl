load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dir = "/home/disk/eos4/rachel/inputdata/som/"
filename = "pop_frc.gx1v6.100105.nc"

fileO = "zonalmean_pop_frc.gx1v6.100105.nc"

system("cp " + dir + filename + " " + dir + fileO)

filenameout = dir + fileO

print("reading file in...")
  cdf_file = addfile(filenameout,"w")
print("file read in")

V = cdf_file->V
U = cdf_file->U
T = cdf_file->T
S = cdf_file->S

dhdx = cdf_file->dhdx
dhdy = cdf_file->dhdy
hblt = cdf_file->hblt
qdp = cdf_file->qdp


V_new = V
U_new = U
T_new = T
S_new = S
dhdy_new = dhdy
dhdx_new = dhdx
hblt_new = hblt
qdp_new = qdp

landmask = cdf_file->mask

dims1 = dimsizes(qdp)
nmonths = dims1(0)
numlats = dims1(1)
numlons = dims1(2)
if nmonths .ne. 12 then
	print(nmonths)
	exit
end if
print(numlats)
print(numlons)

nmonth = 0
do while(nmonth .lt. 12)
nlat = 0
	do while(nlat .lt. numlats)
		nlon = 0
		count = 0
		Usum = 0.0
		Vsum = 0.0
		Tsum = 0.0
		Ssum = 0.0
		dhdxsum = 0.0
		dhdysum = 0.0
		hbltsum = 0.0
		qdpsum = 0.0

		do while (nlon .lt. numlons)
			if (landmask(nlat,nlon) .ne. 0) 
				count = count + 1
				Usum = Usum + U(nmonth,nlat,nlon)
                                Vsum = Vsum + V(nmonth,nlat,nlon)
                                Ssum = Ssum + S(nmonth,nlat,nlon)
                                Tsum = Tsum + T(nmonth,nlat,nlon)
				
                                dhdxsum = dhdxsum + dhdx(nmonth,nlat,nlon)
                                dhdysum = dhdysum + dhdy(nmonth,nlat,nlon)
                                hbltsum = hbltsum + hblt(nmonth,nlat,nlon)
                                qdpsum = qdpsum + qdp(nmonth,nlat,nlon)

			else
				
			end if
			nlon = nlon + 1
		end do
		nlon = 0
		do while (nlon .lt. numlons)
			if (landmask(nlat,nlon) .ne. 0)
		                if count .ne. 0

					U_new(nmonth,nlat,nlon) = Usum / count
					V_new(nmonth,nlat,nlon) = Vsum / count    
					S_new(nmonth,nlat,nlon) = Ssum / count
					T_new(nmonth,nlat,nlon) = Tsum / count

					dhdx_new(nmonth,nlat,nlon) = dhdxsum / count
					dhdy_new(nmonth,nlat,nlon) = dhdysum / count
					hblt_new(nmonth,nlat,nlon) = hbltsum / count
					qdp_new(nmonth,nlat,nlon) = qdpsum / count

				else
				
					U_new(nmonth,nlat,nlon) = Usum
					V_new(nmonth,nlat,nlon) = Vsum 
					S_new(nmonth,nlat,nlon) = Ssum 
					T_new(nmonth,nlat,nlon) = Tsum 

					dhdx_new(nmonth,nlat,nlon) = dhdxsum 
					dhdy_new(nmonth,nlat,nlon) = dhdysum 
					hblt_new(nmonth,nlat,nlon) = hbltsum 
					qdp_new(nmonth,nlat,nlon) = qdpsum 
				end if
			else 
; landmask
                                        U_new(nmonth,nlat,nlon) = U_new@_FillValue
                                        V_new(nmonth,nlat,nlon) = V_new@_FillValue
                                        S_new(nmonth,nlat,nlon) = S_new@_FillValue
                                        T_new(nmonth,nlat,nlon) = T_new@_FillValue

                                        dhdx_new(nmonth,nlat,nlon) = dhdx_new@_FillValue
                                        dhdy_new(nmonth,nlat,nlon) = dhdy_new@_FillValue
                                        hblt_new(nmonth,nlat,nlon) = hblt_new@_FillValue
                                        qdp_new(nmonth,nlat,nlon) = qdp_new@_FillValue
			end if
			nlon = nlon + 1
		end do		
		nlat = nlat + 1
	end do

	nmonth = nmonth + 1
end do

cdf_file ->U      = (/U_new/)
cdf_file ->V      = (/V_new/)
cdf_file ->S      = (/S_new/)
cdf_file ->T      = (/T_new/)

cdf_file ->dhdx      = (/dhdx_new/)
cdf_file ->dhdy      = (/dhdy_new/)
cdf_file ->hblt      = (/hblt_new/)
cdf_file ->qdp       = (/qdp_new/)

end
