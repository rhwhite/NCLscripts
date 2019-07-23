load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("Calc_Eady")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsec")

nyears = endyr-startyr+1

timespans = (/"ANN","DJF","JJA"/)
nts = dimsizes(timespans)


cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
pi = 3.14159

Ps = 1013.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/atm/")
	print(Experiment)

    do its = 0,nts-1
        timespan = timespans(its)
        filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam.h0.nc"

        cdf_file = addfile(filename,"r")

        levs_mean = cdf_file->lev_p

    ; Find 250 and 850hpa levels
        levsizes = dimsizes(levs_mean)
        nlevs = levsizes(0)

        nlev_250 = -1
        nlev_600 = -1
        nlev_775 = -1
        nlev_850 = -1
        nlev_925 = -1

        do nl = 0,nlevs-1
            if levs_mean(nl) .eq. 250 then
                nlev_250 = nl
            end if
            if levs_mean(nl) .eq. 600 then
                nlev_600 = nl
            end if
            if levs_mean(nl) .eq. 775 then
                nlev_775 = nl
            end if
            if levs_mean(nl) .eq. 850 then
                nlev_850 = nl
            end if
            if levs_mean(nl) .eq. 925 then
                nlev_925 = nl
            end if
        end do

        if (nlev_250 .lt. 0 .or. nlev_600 .lt. 0 .or. nlev_775 .lt. 0 .or. nlev_850 .lt. 0 .or. nlev_925 .lt. 0) then
            print("didnt find a level")
            exit
        end if

        lat = cdf_file->lat
        lon = cdf_file->lon

        U925 = cdf_file->U(0,nlev_925,:,:)
        V925 = cdf_file->V(0,nlev_925,:,:)
        Z925 = cdf_file->Z3(0,nlev_925,:,:)
        T925 = cdf_file->T(0,nlev_925,:,:)
        TH925 = T925 * (Ps/925.0)^(kappa)
        
        U775 = cdf_file->U(0,nlev_775,:,:)
        V775 = cdf_file->V(0,nlev_775,:,:)
        Z775 = cdf_file->Z3(0,nlev_775,:,:)
        T775 = cdf_file->T(0,nlev_775,:,:)
        TH775 = T775 * (Ps/775.0)^(kappa)
        
        U250 = cdf_file->U(0,nlev_250,:,:)
        V250 = cdf_file->V(0,nlev_250,:,:)
        Z250 = cdf_file->Z3(0,nlev_250,:,:)
        T250 = cdf_file->T(0,nlev_250,:,:)
        TH250 = T250 * (Ps/250.0)^(kappa)

        T850 =  cdf_file->T(0,nlev_850,:,:)
        TH850 = T850 * (Ps/850.0)^(kappa)

        T600 =  cdf_file->T(0,nlev_600,:,:)
        TH600 = T600 * (Ps/600.0)^(kappa)

        delete([/T925,T850,T775,T600,T250/])
        
        ndims = dimsizes(U925)

    ; Calculate f at all latitudes
        fc = new(dimsizes(U925),typeof(U925))

        do nlat = 0,ndims(0)-1
            fc(nlat,:) = tofloat(2 * omega * sin(lat(nlat)*pi/180.0))
        end do

    ;Calculate N for 850 (925 - 775) and 600 (925-250)

        Nworking = (TH925 - TH775)/(Z925 - Z775)
        Nworking = Nworking * g / TH850
        
        N850 = sqrt(Nworking)

        delete(Nworking)

        Nworking = (TH925 - TH250)/(Z925 - Z250)
        Nworking = Nworking * g / TH600

        N600 = sqrt(Nworking)

        delete(Nworking)

    ; Calculate |dU/dZ|

        dudz850 = (U925 - U775) / (Z925 - Z775)
        dudz850_2 = dudz850 * dudz850

        dvdz850 = (V925 - V775) / (Z925 - Z775)
        dvdz850_2 = dvdz850 * dvdz850

        mod_dUdz850 = sqrt(dudz850_2 + dvdz850_2)

        delete([/dudz850,dudz850_2,dvdz850,dvdz850_2/])
        delete([/U775,V775/])

        dudz600 = (U925 - U250) / (Z925 - Z250)
        dudz600_2 = dudz600 * dudz600

        dvdz600 = (V925 - V250) / (Z925 - Z250)
        dvdz600_2 = dvdz600 * dvdz600

        mod_dUdz600 = sqrt(dudz600_2 + dvdz600_2)

        delete([/dudz600,dudz600_2,dvdz600,dvdz600_2/])
        delete([/U250,V925,V250/])
        delete([/Z925,Z775,Z250/])

    ;Calculate Eady maximum growth rate = 0.31 f/N * mod(dU/dz)

        EMGR850 = 0.31 * (fc/N850) * mod_dUdz850
        EMGR850!0 = U925!0
        EMGR850!1 = U925!1

        EMGR600 = 0.31 * (fc/N600) * mod_dUdz600
        EMGR600!0 = U925!0
        EMGR600!1 = U925!1


        delete(U925)

    ;-----------------------------------------------------------------------
    ;Write variables to a new netcdf file
    ;-----------------------------------------------------------------------
        filo = "EGR_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam.h0.nc"
        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)
        
    ;set dimensions of output file
        dimNames = (/"lat","lon"/)
        dimSizes = (/ndims(0),ndims(1)/)
        dimUnlim = (/False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

        filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
        filevardef(fout_std,"lon",typeof(lon),getvardims(lon))
        
        filevardef(fout_std,"EMGR850",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"EMGR600",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"N850",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"N600",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"mod_dUdz850",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"mod_dUdz600",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"TH925",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"TH775",typeof(EMGR850),getvardims(EMGR850))
        filevardef(fout_std,"TH250",typeof(EMGR850),getvardims(EMGR850))
        
        filevardef(fout_std,"fc",typeof(EMGR850),getvardims(EMGR850))

        fout_std->lat = lat
        fout_std->lon = lon
        fout_std->fc = fc

        fout_std->EMGR850 = (/EMGR850/)
        fout_std->EMGR600 = (/EMGR600/)

        fout_std->N850 = (/N850/)
        fout_std->N600 = (/N600/)
        fout_std->mod_dUdz850 = (/mod_dUdz850/)
        fout_std->mod_dUdz600 = (/mod_dUdz600/)
        fout_std->TH925 = (/TH925/)
        fout_std->TH775 = (/TH775/)
        fout_std->TH250 = (/TH250/)
        

        delete(EMGR850)
        delete(EMGR600)
        delete([/lat,lon,fc/])
        print("printed it")

        delete([/TH925,TH850,TH775,TH600,TH250/])
        delete([/N850,N600,mod_dUdz850,mod_dUdz600/])
    end do
end do

end
