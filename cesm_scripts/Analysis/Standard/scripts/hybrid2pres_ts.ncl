load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Convert the files created by Create_Seas_ts.ncl onto pressure levels
; specified in this file

begin

Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

dirstr = getenv("NCL_dirstr")

timespans = (/"Annual","DJF","MAM","JJA","SON"/)
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

pnew  = (/1,2,3,4,5,6,8, 10, 15,20,25,30,40,50,70,100,150,200,250 \
	     , 300,400,500,600,700,750,775,850,925,1000 /)

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

do exps = 0,nexps-1

    do ts = 0,nts - 1

        timespan = timespans(ts)
        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/" + dirstr + "/raw/")

        print(Experiment)

        filename = (Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_" + Experiment + ".cam2.h0.nc")

        cdf_file = addfile(filename,"r")

        lat = cdf_file->lat
        lon = cdf_file->lon
        P0mb = 0.01*cdf_file->P0
        
        T = cdf_file->T
        PHIS = cdf_file->PHIS
        
        levs = cdf_file->lev
        nlevs = dimsizes(levs)
        print(nlevs)

        if levs(0) .GT. levs(nlevs-1) then
            TBOT = T(:,0,:,:)
        else
            TBOT = T(:,nlevs-1,:,:)
        end if

        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        PS = cdf_file->PS

        Tpres = vinth2p_ecmwf(T,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,PHIS)
        Upres = vinth2p_ecmwf(cdf_file->U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
        Vpres = vinth2p_ecmwf(cdf_file->V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 
        Z3pres = vinth2p_ecmwf(cdf_file->Z3,hyam,hybm,pnew,PS,1,P0mb,1,True,-1,TBOT,PHIS) 
        Qpres = vinth2p_ecmwf(cdf_file->Q,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,PHIS) 


        ; Calculate Potential temperature
        TH = Tpres * (conform(Tpres,pnew,1)/1000.0)^(-1.0 * kappa)
        copy_VarCoords(Tpres,TH)

    ;-----------------------------------------------------------------------
    ;Write variables to a new netcdf file, for stat fits in matlab
    ;-----------------------------------------------------------------------
        ; allow large files
        setfileoption("nc","Format","LargeFile")

        filo = timespan + tostring(startyr) + "_" + tostring(nyears) + "_ts_Xpl_" + Experiment + ".cam2.h0.nc"
        system("/bin/rm -f " + Dir + filo)
        fout = addfile(Dir + filo, "c")

        setfileoption(fout,"DefineMode",True)
        setfileoption(fout,"Format","LargeFile")

    ; set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fAtt@history = "created by hybrid2pres_ts.ncl" 
        fileattdef(fout,fAtt)

        fout ->U      = Upres
        fout ->V      = Vpres
        fout ->TH     = TH
        fout ->Z3     = Z3pres
        fout ->Q      = Qpres

        delete(Experiment)
        delete([/lat,lon,P0mb,T,hyam,hybm,PS/])
        delete(filename)
        delete([/Tpres,Upres,Vpres,Qpres,Z3pres/])
    end do
end do


end
