;load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
    Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsecs")

nyears = endyr-startyr+1

;print(Experiments)

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

timespans= (/"DJF","MAM","JJA","SON"/)
ntdims = dimsizes(timespans)
nts = ntdims(0)


do ts = 0,nts-1

    timespan = timespans(ts)

    do exps = 0,nexps-1

        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")

        filein = "Z850_bpf_Annual" + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"

        cdf_file = addfile(Dir + filein,"r")

        Z850_bpf = cdf_file->Z850bpf
        timebpf = cdf_file->time
        lat = cdf_file->lat
        lon = cdf_file->lon

        ndims = dimsizes(Z850_bpf)
        ntimes = ndims(0)


        if (timespan .eq. "Annual") then
            Z850bpf_var = dim_variance_n(Z850_bpf,0)
        else if (timespan .eq. "DJF") then
            count = 0
            Z850bpf_temp = new(dimsizes(Z850_bpf),typeof(Z850_bpf))

            do nt = 0,ntimes-1
                year = floor(timebpf(nt)/10000.)
                month = floor((timebpf(nt) - 10000. * year)/100.)

                if (month .eq. 12 .or. month .eq. 1 .or. month .eq. 2)
                    Z850bpf_temp(count,:,:) = Z850_bpf(nt,:,:)
                    count = count + 1
                end if
            end do
            
            Z850bpf_var = dim_variance_n(Z850bpf_temp(0:count,:,:),0)
            delete(Z850bpf_temp)

        else if (timespan .eq. "MAM") then
            count = 0
            Z850bpf_temp = new(dimsizes(Z850_bpf),typeof(Z850_bpf))

            do nt = 0,ntimes-1
                year = floor(timebpf(nt)/10000.)
                month = floor((timebpf(nt) - 10000. * year)/100.)

                if (month .eq. 3 .or. month .eq. 4 .or. month .eq. 5)
                        Z850bpf_temp(count,:,:) = Z850_bpf(nt,:,:)
                        count = count + 1
                end if

            end do
            Z850bpf_var = dim_variance_n(Z850bpf_temp(0:count,:,:),0)
            delete(Z850bpf_temp)

        else if (timespan .eq. "JJA") then
            count = 0
            Z850bpf_temp = new(dimsizes(Z850_bpf),typeof(Z850_bpf))

            do nt = 0,ntimes-1
                year = floor(timebpf(nt)/10000.)
                month = floor((timebpf(nt) - 10000. * year)/100.)

                if (month .eq. 6 .or. month .eq. 7 .or. month .eq. 8)
                    Z850bpf_temp(count,:,:) = Z850_bpf(nt,:,:)
                    count = count + 1
                end if

            end do
            Z850bpf_var = dim_variance_n(Z850bpf_temp(0:count,:,:),0)
            delete(Z850bpf_temp)

        else if (timespan .eq. "SON") then
            count = 0
            Z850bpf_temp = new(dimsizes(Z850_bpf),typeof(Z850_bpf))

            do nt = 0,ntimes-1
                year = floor(timebpf(nt)/10000.)
                month = floor((timebpf(nt) - 10000. * year)/100.)

                if (month .eq. 9 .or. month .eq. 10 .or. month .eq. 11)
                    Z850bpf_temp(count,:,:) = Z850_bpf(nt,:,:)
                    count = count + 1 
                end if

            end do
            Z850bpf_var = dim_variance_n(Z850bpf_temp(0:count,:,:),0)
            delete(Z850bpf_temp) 
        end if
        end if
        end if
        end if
        end if

        ndims2 = dimsizes(Z850bpf_var)
        Z850bpf_var!0 = Z850_bpf!1
        Z850bpf_var!1 = Z850_bpf!2


    ;-----------------------------------------------------------------------
    ;Write variables to a new netcdf file, for stat fits in matlab
    ;-----------------------------------------------------------------------
        filo = "Z850bpf_var_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h1.nc"
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
        
        filevardef(fout,"Z850bpf_var",typeof(Z850bpf_var),getvardims(Z850bpf_var))

        fout ->lat    = (/lat/)
        fout ->lon    = (/lon/)
        fout ->Z850bpf_var = (/Z850bpf_var/)

        delete(lat)
        delete(lon)
    end do
end do

end
