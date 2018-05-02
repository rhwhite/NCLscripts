load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Calculate transformed Eulerian mean residual circulation, following Butchart
; (2014) and Seviour et al. 2011
; Calculate TEM circulation on a daily basis and then take the average

undef("calcTEM")
function calcTEM(Dir,filo:string,W,V,THETA,PS,level)
begin

    a = 6.37122e06  ; radius of Earth
    PI = 3.14159265358979
    omega =  7.2921e-5
    g = 9.80616
    P0 = 1000.0
    H = 6800 ; m, from Seviour et al. 2011

    ; Calculate zonal mean time mean PS
    PStm = dim_avg_n_Wrap(PS(time|:,lat|:,lon|:),0)
    PSzmtm = dim_avg_n_Wrap(PStm(lat|:,lon|:),1)

    ; Calculate zonal mean TH
    THETAzm = dim_avg_Wrap(THETA)
    lat = THETAzm&lat

    ; Calculate d(THETA)/dz from vertical finite differences in
    ; height coordinates
    loglevel = log(level)
    height = H * log(P0/level)

    THzmtm = dim_avg_n_Wrap(THETAzm(time|:,lev_int|:,lat|:),0)

    THETAz = center_finite_diff_n(THzmtm(lev_int|:,lat|:),height,False,0,0) 

    ; za stands for zonal anomaly
    ; zm stands for zonal mean

    Wzm = dim_avg_n_Wrap(W(time|:,lev_int|:,lat|:,lon|:),3)
    Vzm = dim_avg_n_Wrap(V(time|:,lev_int|:,lat|:,lon|:),3)


    Vza = dim_rmvmean_Wrap(V(time|:,lev_int|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    THETAza = dim_rmvmean_Wrap(THETA(time|:,lev_int|:,lat|:,lon|:))

    ; Calculate nonlinear products
    VTHETA = Vza * THETAza
    copy_VarCoords(Vza,VTHETA)
    VTHzm = dim_avg_n_Wrap(VTHETA(time|:,lev_int|:,lat|:,lon|:),3) 
                                         ;average over longitude dimension

    ;calculate time means
    Wzmtm = dim_avg_n_Wrap(Wzm(time|:,lev_int|:,lat|:),0)
    Vzmtm = dim_avg_n_Wrap(Vzm(time|:,lev_int|:,lat|:),0)
    VTHzmtm = dim_avg_n_Wrap(VTHzm(time|:,lev_int|:,lat|:),0)
    
    ; calculate rho0 = exp(-Z/H) using Z = Hln(P0/P)
    rho0 = conform(Vzmtm,level,0)/conform(Vzmtm,P0,1)

    ; get some constants
    phi = (conform(rho0,lat*PI/180.0,1))      ; Get latitude in radians
    cphi = cos(phi)
    acphi = a * cphi

    ; set up new arrays
    wTEM = new(dimsizes(Wzmtm),double,Wzmtm@_FillValue)
    vTEM = new(dimsizes(Wzmtm),double,Wzmtm@_FillValue)

    ; calculate wTEM = w + 1/(acosphi) d/d(phi) (cosphi v'TH'/THz)

    ; in case of 0 values
    THETAz = where(THETAz .NE. 0,THETAz,THETAz@_FillValue)

    wTEM_temp =  cphi * VTHzmtm / THETAz
    copy_VarCoords(VTHzmtm,wTEM_temp)

    wTEM_tempdphi = center_finite_diff_n(wTEM_temp(lev_int|:,lat|:),phi,False,0,1)

    wTEM1 = todouble(Wzmtm)
    wTEM2 = (1/acphi) * todouble(wTEM_tempdphi)

    wTEM = wTEM1 + wTEM2

    ; calculate vTEM = v - 1/rho0 d/dz(rho0 v'Th'/THz)

    vTEM_temp = rho0 * VTHzmtm / THETAz
    copy_VarCoords(VTHzmtm,vTEM_temp)
    ; Tues Dec 5 2017 fixed bug: vTEM_tempdz = center_finite_diff_n(wTEM_temp...)
    vTEM_tempdz = center_finite_diff_n(vTEM_temp(lev_int|:,lat|:),height,False,0,0)

    vTEM1 = todouble(Vzmtm)
    vTEM2 = (1/rho0) * todouble(vTEM_tempdz)

    vTEM = vTEM1 - vTEM2

    ; Integrate w to get PSI
    PSIw1 = new(dimsizes(Wzmtm),double,Wzmtm@_FillValue) 
    PSIw2 = new(dimsizes(Wzmtm),double,Wzmtm@_FillValue)
    PSIw = new(dimsizes(Wzmtm),double,Wzmtm@_FillValue)

    nlats = dimsizes(lat)
    PSIlats = new(nlats,float)

    ; integrate from -90 to 90:
    PSIw1(:,0) = 0

    do ilat = 1,nlats-1
        dlat = phi(:,ilat) - phi(:,ilat-1)
        PSIw1(:,ilat) =  PSIw1(:,ilat-1) + (dlat * rho0(:,ilat) * acphi(:,ilat) * wTEM(:,ilat) )

    end do

    PSIw2(:,nlats-1) = 0
    do jlat = 1,nlats-1
        ilat = nlats - 1 - jlat
        dlat = phi(:,ilat) - phi(:,ilat+1)
        PSIw2(:,ilat) = PSIw2(:,ilat+1) + (dlat * rho0(:,ilat) * acphi(:,ilat) * wTEM(:,ilat))

    end do

    copy_VarCoords(Vzmtm,PSIw1)
    copy_VarCoords(Vzmtm,PSIw2)

    ; take average of two integrals to get PSI:
    PSIw = 0.5 * (PSIw1 + PSIw2)
   
    copy_VarCoords(Vzmtm,PSIw)
    copy_VarCoords(Vzmtm,vTEM)
    copy_VarCoords(Vzmtm,wTEM)



    ;-----------------------------------------------------------------------

    filo = "testTEM_midway.nc"
    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")
    ;print(Dir + filo)

    ;setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    ;fAtt = True
    ;fAtt@creation_date = systemfunc("date")
    ;fileattdef(fout_std,fAtt)

    fout_std->phi = phi
    fout_std->cphi = cphi
    fout_std->acphi = acphi
    fout_std->PSzmtm = PSzmtm
    fout_std->rho0 = rho0

    fout_std->PSIw = PSIw
    fout_std->PSIw1 = PSIw1
    fout_std->PSIw2 = PSIw2
    
    fout_std->VTHzmtm = VTHzmtm
    fout_std->vTEM = vTEM
    fout_std->vTEM1 = vTEM1
    fout_std->vTEM2 = vTEM2

    fout_std->vTEM_temp = vTEM_temp
    fout_std->vTEM_tempdz = vTEM_tempdz

    fout_std->wTEM1 = wTEM1
    fout_std->wTEM2 = wTEM2

    fout_std->wTEM = wTEM
    fout_std->wTEM_temp = wTEM_temp
    fout_std->wTEM_tempdphi = wTEM_tempdphi
    fout_std->w = W
    fout_std->v = dim_avg_n_Wrap(V(time|:,lev_int|:,lat|:,lon|:),0)

    fout_std->w_zm = Wzmtm
    fout_std->v_zm = Vzmtm
    fout_std->TH_zm = THzmtm
    fout_std->THETAz = THETAz

    return([/PSIw,PSIw1,PSIw2,vTEM,wTEM/])

end
