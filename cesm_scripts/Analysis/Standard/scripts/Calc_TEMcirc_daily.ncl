load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/Functions/TEMres_circ.ncl"

; Calculate TEM circulation (v*, w* and PSI) using function calcTEM, which
; follows Butchart (2014) and Seviour et al. 2011

begin

; Get experiment names

print("Calc TEM circulation")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

seas = getenv("NCL_seas")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1

lonstart = toint(getenv("NCL_ARG_lonstart"))
lonend = toint(getenv("NCL_ARG_lonend"))

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
P0 = 1000.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

; lev_int is used as an argument for runEPdaily
lev_int = 10^fspan(0,3,30)   ; interpolation targets
lev_int!0 = "lev_int"
nlevint = dimsizes(lev_int)

monthstart = [/0,31,59,90,120,151,181,212,243,273,304,334/]

function runTEMdaily(Dir,cdf_file_D,cdf_file_M,startidx:numeric,endidx:numeric,PHIS,pnew)
begin

    ; get Generic data
    hyam = cdf_file_M->hyam
    hybm = cdf_file_M->hybm 
    P0mb = 0.01*cdf_file_M->P0
    
    ; Get V,T,TBOT and PS from daily file to get daily V and T on pressure levels 
    Vhy_D = cdf_file_D->V(startidx:endidx,:,:,:)
    Thy_D = cdf_file_D->T(startidx:endidx,:,:,:)
    TBOT_D = cdf_file_D->TBOT(startidx:endidx,:,:)
    PS_D = cdf_file_D->PS(startidx:endidx,:,:)

    ; Get OMEGA, T, TBOT and PS from monthly file to get monthly w
    OMEGAhy = cdf_file_M->OMEGA(:,:,:,:)    ; Pa/s
    Thy_M = cdf_file_M->T(:,:,:,:)
    PS_M = cdf_file_M->PS(:,:,:)

    levs_M = cdf_file_M->lev
    nlevs = dimsizes(levs_M)
    if levs_M(0) .GT. levs_M(nlevs-1) then
        TBOT_M = Thy_M(:,0,:,:)
    else
        TBOT_M = Thy_M(:,nlevs-1,:,:)
    end if

    ; convert omega and T to pressure levels
    OMEGA_M = vinth2p_ecmwf(OMEGAhy,hyam,hybm,pnew,PS_M,1,P0mb,1,True,0,TBOT_M,conform(PS_M,PHIS,(/1,2/)))
    T_M = vinth2p_ecmwf(Thy_M,hyam,hybm,pnew,PS_M,1,P0mb,1,True,1,TBOT_M,conform(PS_M,PHIS,(/1,2/)))

    ; use inbuilt function to calculate w from OMEGA
    W_M = omega_to_w(OMEGA_M,conform(OMEGA_M,100.0*pnew,1),T_M)

    ; convert T and V to pressure levels
    T_D = vinth2p_ecmwf(Thy_D,hyam,hybm,pnew,PS_D,1,P0mb,1,True,1,TBOT_D,conform(PS_D,PHIS,(/1,2/)))
    V_D = vinth2p_ecmwf(Vhy_D,hyam,hybm,pnew,PS_D,1,P0mb,1,True,0,TBOT_D,conform(PS_D,PHIS,(/1,2/)))
    
    ; get pressure levels 
    level = pnew
    level!0="lev_int"
    
    nlat = filevardimsizes(cdf_file_M,"lat")
    nlon = filevardimsizes(cdf_file_M,"lon")
    nlevels = dimsizes(pnew)
 
    lat = tofloat(cdf_file_M->lat)
    lat!0="lat"
    lon = tofloat(cdf_file_M->lon)
    lon!0="lon"
   
    dsizes_D = dimsizes(T_D)
    dsizes_M = dimsizes(T_M)
 
    ntimes_D = dsizes_D(0)
    ntimes_M = dsizes_M(0)

    filo = "testTEM_hybrid2p.nc"
    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")
    ;print(Dir + filo)

    ;setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    ;fAtt = True
    ;fAtt@creation_date = systemfunc("date")
    ;fileattdef(fout_std,fAtt)

    fout_std->OMEGA_M = OMEGA_M
    fout_std->w_M = W_M
    fout_std->T_M = T_M

    ; mask out regions below ground
    ;print(level)
    do ilat = 0,nlat-1 
        do ilon = 0,nlon-1
            do ilevp = 0,nlevels-1
                do itime = 0,ntimes_D-1
                    if PS_D(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
                        V_D(itime,ilevp,ilat,ilon) = V_D@_FillValue
                        T_D(itime,ilevp,ilat,ilon) = T_D@_FillValue
                    end if
                end do
                do itime = 0,ntimes_M-1
                    if PS_M(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
                        W_M(itime,ilevp,ilat,ilon) = W_M@_FillValue
                    end if 
                end do
            end do
        end do
    end do


    ; Calculate potential temperature
    THETA_D = T_D
    THETA_D = T_D * (conform(T_D,level,1)/1000.0)^(-1.0 * kappa)

    result_list = calcTEM(Dir,"test.nc",W_M,V_D,THETA_D,PS_D,level)
    return(result_list)

end

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir_in = (Direc + Experiment + "/atm/hist/raw/")
    Dir_out = (Direc + Experiment + "/atm/hist/")
    print(Experiment)

    ; open file with topography
    filename_PHIS = Dir_in + Experiment + ".cam2.h0.0002-01.nc"
    cdf_file_PHIS = addfile(filename_PHIS,"r")
    PHIS_in = cdf_file_PHIS->PHIS(0,:,:)
    lats_in = cdf_file_PHIS->lat
    time_in = cdf_file_PHIS->time
    dimsPH = dimsizes(PHIS_in)
    nlats = dimsPH(0)

    if seas .eq. "Annual" then
        months = (/1,2,3,4,5,6,7,8,9,10,11,12/)
    else if seas .eq. "DJF" then
        months = (/1,2,12/)
    else if seas .eq. "JJA" then
        months = (/6,7,8/)
    end if
    end if
    end if

    nmonth = dimsizes(months) ; number of months to run for
    ntotal = nyears * nmonth

    times_out = new((ntotal),typeof(time_in))
    times_out!0 = "time"
    times_out@units = "days since 0001-01-01"

    vTEM_DJF = new((/ntotal,nlevint,nlats/),double)
    wTEM_DJF = new((/ntotal,nlevint,nlats/),double)
    PSI_DJF = new((/ntotal,nlevint,nlats/),double)
    PSI1_DJF = new((/ntotal,nlevint,nlats/),double)
    PSI2_DJF = new((/ntotal,nlevint,nlats/),double)

    ; Create file for output

    outfile = "TEMcir_" + Experiment + ".h2." + seas + "_" + sprinti("%0.2i",startyr) + "-" + sprinti("%0.2i",endyr) + ".nc"
    system("/bin/rm -f " + Dir_out + outfile)

    fout = addfile(Dir_out + outfile,"c")

    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout,fAtt)

    filedimdef(fout,"time",-1,True)

    nyear = 0
    do iyear = startyr,endyr
        print("year:")
        print(iyear*1)
        ; open file with daily means
        filename = Dir_in + Experiment + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-01-00000.nc"
        cdf_file_in = addfile(filename,"r")

        ;filo_in = "EPfluxes_daily_" + sprinti("%0.4i",iyear) + "_" + Experiment + ".cam2.h2.nc"
        ;test = runEPdaily(Dir_in,cdf_file_in,filo_in,0,364,PHIS_in,lev_int)

        do itermonth = 1,nmonth
            imonth = months(itermonth-1)
            print("month:")
            print(imonth*1)
            cdf_file_M = addfile(Dir_in + Experiment + ".cam2.h0." + sprinti("%0.4i",iyear) + "-" + sprinti("%0.2i",imonth) + ".nc","r")
            times_out(nyear*3) = cdf_file_M->time

            starti = monthstart[imonth-1]
            if imonth .EQ. 12
                endi = 364
            else
                endi = monthstart[imonth]-1
            end if

            result = runTEMdaily(Dir_in,cdf_file_in,cdf_file_M,starti,endi,PHIS_in,lev_int)

            PSI_DJF(nyear*nmonth + itermonth-1,:,:) = result[0]
            PSI1_DJF(nyear*nmonth + itermonth-1,:,:) = result[1]
            PSI2_DJF(nyear*nmonth + itermonth-1,:,:) = result[2]
            vTEM_DJF(nyear*nmonth + itermonth-1,:,:) = result[3]
            wTEM_DJF(nyear*nmonth + itermonth-1,:,:) = result[4]
         
        end do

        nyear = nyear + 1
    end do


    ; Add times to coordinate variable
    vTEM_DJF!0 = "time"
    vTEM_DJF!1 = "lev_p"
    vTEM_DJF!2 = "lat"

    vTEM_DJF@time = times_out
    vTEM_DJF@lev_p = lev_int
    vTEM_DJF@lat = lats_in

    ; Copy coordinate variables to all output files
    copy_VarCoords(vTEM_DJF,wTEM_DJF)
    copy_VarCoords(vTEM_DJF,PSI_DJF)
    copy_VarCoords(vTEM_DJF,PSI1_DJF)
    copy_VarCoords(vTEM_DJF,PSI2_DJF)

    ; Write out fields to file
    fout->PSI = PSI_DJF
    fout->PSI1 = PSI1_DJF
    fout->PSI2 = PSI2_DJF
    fout->vTEM = vTEM_DJF
    fout->wTEM = wTEM_DJF


end do

end
