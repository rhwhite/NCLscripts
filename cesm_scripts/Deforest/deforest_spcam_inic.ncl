load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

filenamein = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/OrigInputs/inic/cam3.5sld_landspinup.clm2.i.0050-01-01-00000.nc"
filenameout = "/home/disk/eos4/rachel/SPCAM/DEF_SPCAM/DefInputs/DEFcam3.5sld_landspinup.clm2.i.0050-01-01-00000.nc"

system("cp " + filenamein + " " + filenameout)


nregions = 1
latstarts = (/-10.0/)
latends = (/-7.0/)
lonstarts = (/15.0/)
lonends = (/18.0/)

;nregions = 4
;latstarts = (/-24.0,-16.0,-16.0,-18.5/)
;latends = (/13.0, 10.0, 10.0, 21.0/)
;lonstarts = (/281.0, 0.0, 343.0, 90.0/)
;lonends = (/324.0, 36.0, 360.0, 183.0/)

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

pft = cdf_file->pfts1d_itypveg

lats = cdf_file->pfts1d_lat
lons = cdf_file->pfts1d_lon

dims1 = dimsizes(pft)
npfts = dims1(0)
print(tostring(npfts))

do ireg = 0,nregions-1
	do ipft = 0,npfts-1
		xlat = lats(ipft)
		xlon = lons(ipft)
		if (xlat .gt. latstarts(ireg) .and. xlat .lt. latends(ireg) .and. xlon .gt. lonstarts(ireg) .and. xlon .lt. lonends(ireg))
			print(ipft)
			print(pft(ipft))
;				if pft(ipft) .eq. 14
					
;                        	test = dim_sum_n(pft(:,ilat,ilon),0)
;				def4 = pft(4,ilat,ilon) ; broadleaf_evergreen_tropical_tree
;				def6 = pft(6,ilat,ilon) ; broadleaf_deciduous_tropical_tree
;				pft(4,ilat,ilon) = 0.0
;				pft(6,ilat,ilon) = 0.0
;				pft(14,ilat,ilon) = pft(14,ilat,ilon) + def4 + def6
;		
;                       	test2 = dim_sum_n(pft(:,ilat,ilon),0)
;	                     	if (test2 .NE. test)
;					print(test2 - test)
;				end if
		end if
	end do
end do

nl = integertochar(10) ; newline character

;cdf_out = addfile(filenameout,"w")

;globalAtt = True
;globalAtt@history = nl+\ 
;"copied from file " + filenamein + nl+\
;"deforested numbers 4 and 6 to 14 over regions:" +nl+\
;tostring(latstarts) +nl+\
;tostring(latends) +nl+\
;tostring(lonstarts) +nl+\
;tostring(lonends)

;fileattdef(cdf_out, globalAtt ) 

;cdf_out ->PCT_PFT      = (/pft/)


end


