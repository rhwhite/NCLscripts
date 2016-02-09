load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

factor = 0.9999
otherfactor = 1.0 - factor

filenamein = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/OrigInputs/lnd/surfdata/surfdata_064x128_061205.nc"
filenameout = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/DefInputs/DEF2surfdata_064x128_061205.nc"

system("cp " + filenamein + " " + filenameout)

nregions = 4
latstarts = (/-24.0,-16.0,-16.0,-18.5/)
latends = (/13.0, 10.0, 10.0, 21.0/)
lonstarts = (/281.0, 0.0, 343.0, 90.0/)
lonends = (/324.0, 36.0, 360.0, 183.0/)

;AMAZON
;latis: 23 - 36 (inclusive)
;lonis = 100 - 115
;from 281E to 324E
;from -24N to 13N

;CONGO
;latis: 26 - 35 
;lonis:122 - 13
;from: -16 to 10
;from: 343E - 36E

;MARITIME
;latis: 25 - 39
;lonis: 32 - 65
;from: -18.5N to 21N
;from: 90.0E to 183E


print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

pft = cdf_file->PCT_PFT

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
				if (pft(4,ilat,ilon) .ne. 0.0 .or. pft(6,ilat,ilon) .ne. 0.0) 	
					test = dim_sum_n(pft(:,ilat,ilon),0)
					def4 = pft(4,ilat,ilon) ; broadleaf_evergreen_tropical_tree
					def6 = pft(6,ilat,ilon) ; broadleaf_deciduous_tropical_tree
					if pft(14,ilat,ilon) .gt. pft(13,ilat,ilon)
						pft(14,ilat,ilon) = pft(14,ilat,ilon) + (def4*factor) + (def6*factor)
			                        pft(4,ilat,ilon) = def4*otherfactor
                        	                pft(6,ilat,ilon) = def6*otherfactor
					else if pft(13,ilat,ilon) .ne. 0.0
						pft(13,ilat,ilon) = pft(13,ilat,ilon) + (def4*factor) + (def6*factor)
                                        	pft(4,ilat,ilon) = def4*otherfactor
                                        	pft(6,ilat,ilon) = def6*otherfactor		
					else if pft(10,ilat,ilon) .ne. 0.0
                                                pft(10,ilat,ilon) = pft(10,ilat,ilon) + (def4*factor) + (def6*factor)
                                                pft(4,ilat,ilon) = def4*otherfactor
                                                pft(6,ilat,ilon) = def6*otherfactor
					else
						print(pft(:,ilat,ilon))
					end if
					end if
					end if

					test2 = dim_sum_n(pft(:,ilat,ilon),0)
					if (abs(test2 - test) .gt. 0.0001)
						print(test2 - test)
					end if
				end if
			end if
		end do
	end do
end do

nl = integertochar(10) ; newline character

cdf_out = addfile(filenameout,"w")

globalAtt = True
globalAtt@history = nl+\ 
"copied from file " + filenamein + nl+\
"deforested numbers 4 and 6, preferentially to 14 or 15 (whichever is most prevalent), or to 10 if neither 14 or 15 exist, over regions:" +nl+\
tostring(latstarts) +nl+\
tostring(latends) +nl+\
tostring(lonstarts) +nl+\
tostring(lonends)

fileattdef(cdf_out, globalAtt ) 

cdf_out ->PCT_PFT      = (/pft/)


end


