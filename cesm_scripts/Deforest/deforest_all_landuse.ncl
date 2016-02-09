load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filenamein = "/home/disk/eos4/rachel/inputdata/lnd/rawdata/mksrf_landuse_rc2000_c090630.nc"
filenameout = "/home/disk/eos4/rachel/inputdata/lnd/rawdata/mksrf_DEFlanduse_rc2000_c090630.nc" 

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

pft = cdf_file->PCT_PFT

dims1 = dimsizes(pft)
print(dims1)
nlats = dims1(1)
nlons = dims1(2)
print(nlats)
print(nlons)

if (nlats .NE. 360 .OR. nlons .NE. 720) then
	print("wrong resolution")
	exit
end if

;Amazon
startnlon = 196
endnlon = 290
startnlat = 135
endnlat = 207

do ilat = startnlat,endnlat
	do ilon = startnlon,endnlon
		if (pft(4,ilat,ilon) .GT. 0.0)
                        test = dim_sum_n(pft(:,ilat,ilon),0)
			def = pft(4,ilat,ilon)
			pft(4,ilat,ilon) = 0.0
			pft(14,ilat,ilon) = pft(14,ilat,ilon) + def
		
                        test2 = dim_sum_n(pft(:,ilat,ilon),0)
			if (test2 .NE. test)
				print(test2 - test)
			end if
		end if
	end do
end do


; Congo
startnlon = 330
endnlon = 435
startnlat = 148
endnlat = 196

do ilat = startnlat,endnlat
        do ilon = startnlon,endnlon
                if (pft(4,ilat,ilon) .GT. 0.0)
                        test = dim_sum_n(pft(:,ilat,ilon),0)
		        def = pft(4,ilat,ilon)
                        pft(4,ilat,ilon) = 0.0
                        pft(14,ilat,ilon) = pft(14,ilat,ilon) + def
                        test2 = dim_sum_n(pft(:,ilat,ilon),0)
                        if (test2 .NE. test)
				print(test2-test)
			end if
		end if
        end do
end do

;Asia

startnlon = 540
endnlon = 702
startnlat = 124
endnlat = 220


do ilat = startnlat,endnlat
        do ilon = startnlon,endnlon
                if (pft(4,ilat,ilon) .GT. 0.0)
               		test = dim_sum_n(pft(:,ilat,ilon),0)
		        def = pft(4,ilat,ilon)
                        pft(4,ilat,ilon) = 0.0
                        pft(14,ilat,ilon) = pft(14,ilat,ilon) + def
			test2 = dim_sum_n(pft(:,ilat,ilon),0)
			if (test2 .NE. test)
                                print(test2-test)
                        end if
         	end if
        end do
end do



print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->PCT_PFT      = (/pft/)


end


