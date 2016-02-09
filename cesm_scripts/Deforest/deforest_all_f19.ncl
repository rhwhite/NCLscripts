load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filenamein = "/home/disk/eos4/rachel/inputdata/lnd/surfdata_1.9x2.5_simyr2000_c091005.nc"
filenameout = "/home/disk/eos4/rachel/inputdata/lnd/DEFsurfdata_1.9x2.5_simyr2000_c091005.nc"

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

pft = cdf_file->PCT_PFT

dims1 = dimsizes(pft)
nlats = dims1(1)
nlons = dims1(2)
print(nlats)
print(nlons)

;Amazon
startnlon = 110
endnlon = 131
startnlat = 37
endnlat = 55

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
startnlon = 137
endnlon = 13
startnlat = 41
endnlat = 54

do ilat = startnlat,endnlat
        do ilon = 0,endnlon
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

print(nlons)
do ilat = startnlat,endnlat
        do ilon = startnlon,nlons-1
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

startnlon = 27
endnlon = 70
startnlat = 39
endnlat = 61


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


