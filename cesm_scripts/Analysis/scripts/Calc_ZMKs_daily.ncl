load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"

; Code to calculate Rossby stationary wave number, following Hoskins and
; Ambrizzi 1993.
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a

begin

; Get experiment names

logp = 0

print("Calc Ks on daily data")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

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

; p levels
lev_p = 10^fspan(0,3,30)   ; interpolation targets
lev_p!0 = "lev_p"
dimslevint = dimsizes(lev_p)
    
do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir_in = (Direc + Experiment + "/atm/hist/")
    print(Experiment)

    do iyear = startyr,endyr
        print(iyear*1)
        
        filename = Dir_in + Experiment + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-01-00000.nc"
        cdf_file = addfile(filename,"r")

        ;open file with topography
        filename_PHIS = Dir_in + Experiment + ".cam2.h0.0001-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS = cdf_file_PHIS->PHIS(0,:,:)

        timesin = cdf_file->time
        datesin = cdf_file->date
        Uhy = cdf_file->U
        Thy = cdf_file->T
        Zhy = cdf_file->Z3
        TBOT = cdf_file->TBOT
        
        PS = cdf_file->PS
        
        levs = cdf_file->lev
        nlevs = dimsizes(levs)
        
        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        
        p0 = tofloat(cdf_file->P0)
        P0mb = 0.01*cdf_file->P0
     
        p = pres_hybrid_ccm(PS,p0,hyam,hybm)
        
        dims1 = dimsizes(Uhy)
        dimslev = dimsizes(lev_p)
        
        T = vinth2p_ecmwf(Thy,hyam,hybm,lev_p,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
        U = vinth2p_ecmwf(Uhy,hyam,hybm,lev_p,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
        Z = vinth2p_ecmwf(Zhy,hyam,hybm,lev_p,PS,1,P0mb,1,True,-1,TBOT,conform(PS,PHIS,(/1,2/)))
        
        ; get pressure levels
        
        level = lev_p
        level!0="lev_p"
        
        nlat = filevardimsizes(cdf_file,"lat")
        nlon = filevardimsizes(cdf_file,"lon")
        nlevels = dimsizes(lev_p)
     
        lat = tofloat(cdf_file->lat)
        lat!0="lat"
        lon = tofloat(cdf_file->lon)
        lon!0="lon"
        
        ntimes = dimsizes(timesin)

        ; mask out regions below ground
        ;print(level)
        do ilat = 0,nlat-1 
            do ilon = 0,nlon-1
                do ilevp = 0,nlevels-1
                    do itime = 0,ntimes-1
                        if PS(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
                            U(itime,ilevp,ilat,ilon) = U@_FillValue 
                            Z(itime,ilevp,ilat,ilon) = Z@_FillValue
                            T(itime,ilevp,ilat,ilon) = T@_FillValue
                        end if
                    end do
                end do
            end do
        end do




        ; Calculate potential temperature
        lev_id = 1

        TH = T*((1000.0/conform(T,level,lev_id))^0.286)
        copy_VarCoords(T,TH)

        lon_id = 3

        ; Calculate zonal means
        Uzm = dim_avg_n_Wrap(U,lon_id)
        THzm = dim_avg_n_Wrap(TH,lon_id)
        Zzm = dim_avg_n_Wrap(Z,lon_id)

        fileo = Dir_in + "ZMKs_daily_" + sprinti("%0.4i",iyear) + "_" + Experiment + ".cam2.h2.nc"

        returned = calcZMKs(Uzm,THzm,Zzm,level,lat,fileo)
        print(returned*1)
    end do
end do

end

