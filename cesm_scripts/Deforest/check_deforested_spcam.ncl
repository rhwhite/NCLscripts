load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;filenamein = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/DefInputs/DEFsurfdata_064x128_061205.nc"
filenamein = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/DefInputs/DEFsurfdata_064x128_061205_test.nc"
filenameout = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/DefInputs/DEFsurfdata_064x128_061205_test2.nc"

system("cp " + filenamein + " " + filenameout)

nregions = 4
latstarts = (/-24.0,-16.0,-16.0,-18.5/)
latends = (/13.0, 10.0, 10.0, 21.0/)
lonstarts = (/281.0, 0.0, 343.0, 90.0/)
lonends = (/324.0, 36.0, 360.0, 183.0/)

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

pft = cdf_file->PCT_PFT
landfrac = cdf_file->LANDFRAC_PFT
monthly_lai = cdf_file->MONTHLY_LAI
monthly_sai = cdf_file->MONTHLY_SAI
mon_ht = cdf_file->MONTHLY_HEIGHT_TOP
mon_hb = cdf_file->MONTHLY_HEIGHT_TOP
lats = cdf_file->LATIXY
lons = cdf_file->LONGXY

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

do ireg = 0,nregions-1
	do ilat = 0,nlats-1
		do ilon = 0,nlons-1
			xlat = lats(ilat,ilon)
			xlon = lons(ilat,ilon)
			if (xlat .gt. latstarts(ireg) .and. xlat .lt. latends(ireg) .and. xlon .gt. lonstarts(ireg) .and. xlon .lt. lonends(ireg))

				if pft(14,ilat,ilon) .gt. 0.0
					if all(monthly_lai(:,14,ilat,ilon) .eq. 0.0)
						if all(monthly_lai(:,13,ilat,ilon) .eq. 0.0)
							if any(monthly_lai(:,14,ilat,ilon+1) .ne. 0.0)
								print("replacing with nearby monthly_lai")
								monthly_lai(:,14,ilat,ilon) = monthly_lai(:,14,ilat,ilon+1)
                                                                monthly_sai(:,14,ilat,ilon) = monthly_sai(:,14,ilat,ilon+1)
							else if any(monthly_lai(:,14,ilat,ilon-1) .ne. 0.0)
                                                                print("replacing with nearby monthly_lai")                                                        
							        monthly_lai(:,14,ilat,ilon) = monthly_lai(:,14,ilat,ilon-1)
                                                                monthly_sai(:,14,ilat,ilon) = monthly_sai(:,14,ilat,ilon-1)
							else if any(monthly_lai(:,14,ilat+1,ilon) .ne. 0.0)
                                                                print("replacing with nearby monthly_lai")
                                                                monthly_lai(:,14,ilat,ilon) = monthly_lai(:,14,ilat+1,ilon)
                                                                monthly_sai(:,14,ilat,ilon) = monthly_sai(:,14,ilat+1,ilon)
                                                        else if any(monthly_lai(:,14,ilat-1,ilon) .ne. 0.0)
                                                                print("replacing with nearby monthly_lai")
                                                                monthly_lai(:,14,ilat,ilon) = monthly_lai(:,14,ilat-1,ilon)
                                                                monthly_sai(:,14,ilat,ilon) = monthly_sai(:,14,ilat-1,ilon)
							else if any(monthly_lai(:,13,ilat,ilon+1) .ne. 0.0)
                                                                print("replacing with artic grass AND nearby monthly_lai")
                                                        	pft(13,ilat,ilon) = pft(14,ilat,ilon)
                                                        	pft(14,ilat,ilon) = 0.0
                                                                monthly_lai(:,13,ilat,ilon) = monthly_lai(:,13,ilat,ilon+1)
                                                                monthly_sai(:,13,ilat,ilon) = monthly_sai(:,13,ilat,ilon+1)
	                                                else if any(monthly_lai(:,13,ilat,ilon-1) .ne. 0.0)
                                                                print("replacing with artic grass AND nearby monthly_lai")
                                                                pft(13,ilat,ilon) = pft(14,ilat,ilon)
                                                                pft(14,ilat,ilon) = 0.0
                                                                monthly_lai(:,13,ilat,ilon) = monthly_lai(:,13,ilat,ilon-1)
                                                                monthly_sai(:,13,ilat,ilon) = monthly_sai(:,13,ilat,ilon-1)        
                                                        else if any(monthly_lai(:,13,ilat+1,ilon) .ne. 0.0)
                                                                print("replacing with artic grass AND nearby monthly_lai")
                                                                pft(13,ilat,ilon) = pft(14,ilat,ilon)
                                                                pft(14,ilat,ilon) = 0.0
                                                                monthly_lai(:,13,ilat,ilon) = monthly_lai(:,13,ilat+1,ilon)
                                                                monthly_sai(:,13,ilat,ilon) = monthly_sai(:,13,ilat+1,ilon)
                                                        else if any(monthly_lai(:,13,ilat-1,ilon) .ne. 0.0)
                                                                print("replacing with artic grass AND nearby monthly_lai")
                                                                pft(13,ilat,ilon) = pft(14,ilat,ilon)
                                                                pft(14,ilat,ilon) = 0.0
                                                                monthly_lai(:,13,ilat,ilon) = monthly_lai(:,13,ilat-1,ilon)
                                                                monthly_sai(:,13,ilat,ilon) = monthly_sai(:,13,ilat-1,ilon)
							else
								print(tostring(ilon) + ", " + tostring(ilat))
	                                                        print(tostring(landfrac(ilat,ilon)))
							end if
							end if
							end if
							end if
							end if
							end if
							end if
							end if
						else
							pft(13,ilat,ilon) = pft(14,ilat,ilon)
							pft(14,ilat,ilon) = 0.0
						end if
					end if
				end if
			end if
		end do
	end do
end do

do ireg = 0,nregions-1
        do ilat = 0,nlats-1
                do ilon = 0,nlons-1
                        xlat = lats(ilat,ilon)
                        xlon = lons(ilat,ilon)
                        if (xlat .gt. latstarts(ireg) .and. xlat .lt. latends(ireg) .and. xlon .gt. lonstarts(ireg) .and. xlon .lt. lonends(ireg))

				if pft(14,ilat,ilon) .gt. 0.0
                                        if all(monthly_lai(:,14,ilat,ilon) .eq. 0.0)
                                                print("lai")
						print(tostring(landfrac(ilat,ilon)))
                                                print(tostring(ilon) + ", " + tostring(ilat))
                                        end if
				end if
                                if pft(13,ilat,ilon) .gt. 0.0
                                        if all(monthly_lai(:,13,ilat,ilon) .eq. 0.0)
                                                print("lai for 13")
						print(tostring(landfrac(ilat,ilon)))
                                                print(tostring(ilon) + ", " + tostring(ilat))
                                        end if
                                end if
			end if
		end do
	end do
end do


cdf_out = addfile(filenameout,"w")

nl = integertochar(10) ; newline character

globalAtt = True
globalAtt@checkhistory = nl+\
"checked, and some c4 grass converted to c3_non-artic-grass (13)"
fileattdef(cdf_out, globalAtt )

cdf_out ->PCT_PFT      = (/pft/)
cdf_out ->MONTHLY_LAI = (/monthly_lai/)
cdf_out ->MONTHLY_SAI = (/monthly_sai/)


end


