load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

print("hybrid to pressure levels on daily data")

Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
    Experiments(ne) = getenv("NCL_Exp2_" + tostring(ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
version=getenv("NCL_CESMversion")
h2startday = getenv("NCL_h2start")

; history name of files with daily data (h1, h2 etc?)
dailyfile = getenv("NCL_dailyfile")

if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

nsecs = getenv("NCL_nsecs")

nyears = endyr-startyr+1

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

pnew  = (/ 2, 5,10,30,50,100,200,250,300,500,700,850,975/)

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir = (Direc + Experiment + "/atm/hist/raw/")
    DirFinal = (Direc + Experiment + "/atm/hist/")

    system("mkdir " + Dir + "Temp_pl")

    DirO = Dir + "/Temp_pl/"
    ;system("rm " + Dir + "Temp_pl/*")

    print(Experiment)
    sstartyr = sprinti("%0.4i",startyr)
    filePHIS = (Dir + Experiment + "." + camversion + ".h0." + sstartyr + "-06.nc")

    do iyear = startyr,endyr
        print(tostring(iyear))
	    syear = sprinti("%0.4i",iyear)

        filename = (Dir + Experiment + "." + camversion + "." + dailyfile + "." + syear + "-01-" + h2startday + "-00000.nc")
    
        cdf_file = addfile(filename,"r")
        cdf_file_PHIS = addfile(filePHIS,"r")


        timesin = cdf_file->time
        datesin = cdf_file->date
        lat = cdf_file->lat
        lon = cdf_file->lon
        P0mb = 0.01*cdf_file->P0
        U = cdf_file->U
        V = cdf_file->V
        T = cdf_file->T
        Z3 = cdf_file->Z3

        dohumidity=0
        if (isfilevar(cdf_file, "Q")) then
            Q = cdf_file->Q
            dohumidity = 1
        end if

        doomega=0
        if (isfilevar(cdf_file, "OMEGA")) then
            OMEGA = cdf_file->OMEGA
            doomega = 1
        end if

        PHIS = cdf_file_PHIS->PHIS(0,:,:)
        PS = cdf_file->PS

        levs = cdf_file->lev
        nlevs = dimsizes(levs)

        ; check that levels go from top down in order to get TBOT
        if levs(0) .lt. levs(nlevs-1) then
            TBOT = T(:,nlevs-1,:,:)
        else if levs(0) .gt. levs(nlevs-1) then
            TBOT = T(:,0,:,:)
        else
            print("something very wrong with levels when trying to find TBOT")
            exit()
        end if
        end if

        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        
        p0 = tofloat(cdf_file->P0)
        p = pres_hybrid_ccm(PS,p0,hyam,hybm)

        dims1 = dimsizes(U)
        dimslev = dimsizes(pnew)

        ; Calculate PV - now we do this on isobaric levels - pot_vort_hybrid
        ; can give division by zero errors which are reportedly fixed in 
        ; pot_vort_isobaric
        ;gridtype = 1    ; normal grid
        ;PV = pot_vort_hybrid(p,U,V,T,lat,gridtype,0)
        ;copy_VarCoords(U,PV)


        Tpres = vinth2p_ecmwf(T,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
        Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
        Vpres = vinth2p_ecmwf(V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
        ;PVpres = vinth2p_ecmwf(PV,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
        Z3pres = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True,-1,TBOT,conform(PS,PHIS,(/1,2/))) 
        if dohumidity .eq. 1 then
            Qpres = vinth2p_ecmwf(Q,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
        end if
        if doomega .eq. 1 then
            OMEGApres = vinth2p_ecmwf(OMEGA,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
        end if

        ; Calculate PV on pressure levels
        gridtype = 1    ; normal grid
        PVpres = pot_vort_isobaric(pnew,Upres,Vpres,Tpres,lat,gridtype,0)
        copy_VarCoords(Upres,PVpres)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
        filoUV = "U_V_pl_daily_" + Experiment + "_" + syear + "." + camversion + ".nc"
        system("/bin/rm -f " + DirO + filo)
        foutUV = addfile(DirO + filoUV, "c")
    
        setfileoption(fout,"DefineMode",True)

    
; set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout,fAtt)
        filedimdef(fout,"time",-1,True)   
 
        fout ->U = Upres
        fout ->V = Vpres
        fout->Z3 = Z3pres
        fout ->T = Tpres
        if dohumidity .eq. 1 then
            fout ->Q = Qpres
        end if
        fout ->PV = PVpres
        if doomega .eq. 1 then
            fout ->OMEGA = OMEGApres
        end if
    end do	

    system("ncrcat -O -v U,V " + DirO + "/U_V_T_Z3_pl_daily_" + Experiment + "_*"  + "." + camversion + ".nc " + DirFinal + "/U_V_pldaily_" + Experiment + "." + camversion + "." + sprinti("%0.4i",startyr) + "-" + sprinti("%0.4i",endyr) + ".nc")

    system("ncrcat -O -v T " + DirO + "/U_V_T_Z3_pl_daily_" + Experiment + "_*"  + "." + camversion + ".nc " + DirFinal + "/T_pldaily_" + Experiment + "." + camversion + "." + sprinti("%0.4i",startyr) + "-" + sprinti("%0.4i",endyr) + ".nc")

    system("ncrcat -O -v Z,PV " + DirO + "/U_V_T_Z3_pl_daily_" + Experiment + "_*"  + "." + camversion + ".nc " + DirFinal + "/Z3_PV_pldaily_" + Experiment + "." + camversion + "." + sprinti("%0.4i",startyr) + "-" + sprinti("%0.4i",endyr) + ".nc")

    if dohumidity .eq. 1 then
        system("ncrcat -O -v Q " + DirO + "/U_V_T_Z3_pl_daily_" + Experiment + "_*"  + "." + camversion + ".nc " + DirFinal + "/Q_pldaily_" + Experiment + "." + camversion + "." + sprinti("%0.4i",startyr) + "-" + sprinti("%0.4i",endyr) + ".nc")
    end if

    if doomega .eq. 1 then
        system("ncrcat -O -v OMEGA " + DirO + "/U_V_T_Z3_pl_daily_" + Experiment + "_*"  + "." + camversion + ".nc " + DirFinal + "/OMEGA_pldaily_" + Experiment + "." + camversion + "." + sprinti("%0.4i",startyr) + "-" + sprinti("%0.4i",endyr) + ".nc")
    end if



end do

end
