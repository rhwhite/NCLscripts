load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
    Experiments(ne) = getenv("NCL_Exp2_" + tostring(ne))
end do

print(Experiments)
startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

version=getenv("NCL_CESMversion")

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

pnew  = (/ 2, 5,10,30,50,100,200,250,500,850/)

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir = (Direc + Experiment + "/atm/hist/raw/")

    system("mkdir " + Dir + "Temp_pl")

    DirO = Dir + "/Temp_pl/"
    ;system("rm " + Dir + "Temp_pl/*")


    print(Experiment)
    filePHIS = (Dir + Experiment + "." + camversion + ".h0.0002-01.nc")

    do iyear = startyr,endyr
        print(tostring(iyear))
        if iyear .LT. 10
            syear = "0" + tostring(iyear)
        else
            syear = tostring(iyear)
        end if

        filename = (Dir + Experiment + "." + camversion + ".h2.00" + syear + "-01-01-00000.nc")
    
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
        TBOT = cdf_file->TBOT

        PHIS = cdf_file_PHIS->PHIS(0,:,:)
        PS = cdf_file->PS

        levs = cdf_file->lev
        nlevs = dimsizes(levs)

        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        
        p0 = tofloat(cdf_file->P0)
        ;p = pres_hybrid_ccm(PS,p0,hyam,hybm)

        dims1 = dimsizes(U)
        dimslev = dimsizes(pnew)

        ; Calculate PV
        ;gridtype = 1    ; normal grid
        ;PV = pot_vort_hybrid(p,U,V,T,lat,gridtype,0)
        ;copy_VarCoords(U,PV)


        Tpres = vinth2p_ecmwf(T,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
        Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
        Vpres = vinth2p_ecmwf(V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 
        ;PVpres = vinth2p_ecmwf(PV,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
        Z3pres = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,1,P0mb,1,True,-1,TBOT,conform(PS,PHIS,(/1,2/))) 
        ;Qpres = vinth2p_ecmwf(Q,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/))) 

;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
        filo = "U_V_T_Z3_pl" + Experiment + "_" + syear + "." + camversion + ".h2.nc"
        system("/bin/rm -f " + DirO + filo)
        fout = addfile(DirO + filo, "c")
    
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
        
    end do	

    system("ncrcat -O " + DirO + "/U_V_T_Z3_pl" + Experiment + "_??"  + "." + camversion + ".h2.nc " + Dir + "/U_V_T_Z3_pl" + Experiment + "." + camversion + ".h2." + sprinti("%0.4i",startyr) + "-00" + tostring(endyr) + ".nc")


end do

end
