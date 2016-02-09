load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_VTmean_AZM")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

print(startyr*1)
print(endyr*1)

nyears = endyr-startyr+1

timespans= (/"DJF"/)
ntdims = dimsizes(timespans)
nts = ntdims(0)

do ts = 0,nts-1

	timespan = timespans(ts)

	do exps = 0,nexps-1

		Experiment = Experiments(exps)
		print(Experiment)
                Dir = (Direc + Experiment + "/atm/hist/")

		filein = "ZMA_bpf_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"

		cdf_file = addfile(Dir + filein,"r")

		VT_bpf = cdf_file->VdashTHdash_850bpf
		timebpf = cdf_file->time
		lat = cdf_file->lat
		lon = cdf_file->lon
	
		ndims = dimsizes(VT_bpf)
		ntimes = ndims(0)
	
		if (timespan .eq. "Annual") then
			VTbpf_mean = dim_avg_n(VT_bpf,0)
		else if (timespan .eq. "DJF") then
			count = 0
			VTbpf_temp = new(dimsizes(VT_bpf),typeof(VT_bpf))
	
			do nt = 0,ntimes-1
		        	year = floor(timebpf(nt)/10000.)
		        	month = floor((timebpf(nt) - 10000. * year)/100.)
		
		        	if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
		        		VTbpf_temp(count,:,:) = VT_bpf(nt,:,:)
		                        count = count + 1
		       		else if (month .gt. 12 .or. month .lt. 1)
					print("months not quite right!")
					exit
				end if
			        end if
			end do
		        VTbpf_mean = dim_avg_n(VTbpf_temp(0:count,:,:),0)
			delete(VTbpf_temp)
		else if (timespan .eq. "JJA") then
		        count = 0
		        VTbpf_temp = new(dimsizes(VT_bpf),typeof(VT_bpf))
		
		        do nt = 0,ntimes-1
		                year = floor(timebpf(nt)/10000.)
		                month = floor((timebpf(nt) - 10000. * year)/100.)
		
		                if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
		                        VTbpf_temp(count,:,:) = VT_bpf(nt,:,:)
		                        count = count + 1
				else if (month .gt. 12 .or. month .lt. 1)
					print("something wrong with months")
					exit
				end if				
		                end if
		        end do
		        VTbpf_mean = dim_avg_n(VTbpf_temp(0:count,:,:),0)
			delete(VTbpf_temp)
		end if
		end if
		end if
	
		ndims2 = dimsizes(VTbpf_mean)
		VTbpf_mean!0 = VT_bpf!1
		VTbpf_mean!1 = VT_bpf!2
		
;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
		filo = "VT_bpf_mean" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
		system("/bin/rm -f " + Dir + filo)
		fout = addfile(Dir + filo, "c")

		setfileoption(fout,"DefineMode",True)

; set attributes of output file
		fAtt = True
		fAtt@creation_date = systemfunc("date")
		fileattdef(fout,fAtt)

;set dimensions of output file
		dimNames = (/"time","lat","lon"/)
		dimSizes = (/1,ndims2(0),ndims2(1)/)
		dimUnlim = (/True,False,False/)
		filedimdef(fout,dimNames,dimSizes,dimUnlim)

		filevardef(fout,"lat",typeof(lat),getvardims(lat))
		filevardef(fout,"lon",typeof(lon),getvardims(lon))

		filevardef(fout,"VTbpf_mean",typeof(VTbpf_mean),getvardims(VTbpf_mean))

		fout ->lat    = (/lat/)
		fout ->lon    = (/lon/)
		fout ->VTbpf_mean = (/VTbpf_mean/)

		delete(VTbpf_mean)
		delete(VT_bpf)
		delete(timebpf)
		delete([/lat,lon/])
	end do

end do

end
