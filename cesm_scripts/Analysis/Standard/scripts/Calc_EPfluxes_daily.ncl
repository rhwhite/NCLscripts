load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"

; Calculate EP fluxes on a daily basis and then take the average.
; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates
; Plots the EP Flux vectors in a latitude-log(pressure) coordinate
; plot the divergence of EP-Flux

begin

; Get experiment names

logp = 0

print("Calc EP fluxes")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_nsecs")
h2startday = getenv("NCL_h2start")

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
dimslevint = dimsizes(lev_int)

function runEPdaily(Dir,cdf_file,filo:string,startidx:numeric,endidx:numeric,PHIS,pnew)
begin
    timesin = cdf_file->time(startidx:endidx)
    datesin = cdf_file->date(startidx:endidx)
    Uhy = cdf_file->U(startidx:endidx,:,:,:)
    Vhy = cdf_file->V(startidx:endidx,:,:,:)
    Thy = cdf_file->T(startidx:endidx,:,:,:)
    TBOT = cdf_file->TBOT(startidx:endidx,:,:)
    
    PS = cdf_file->PS(startidx:endidx,:,:)
    
    levs = cdf_file->lev
    nlevs = dimsizes(levs)
    
    hyam = cdf_file->hyam
    hybm = cdf_file->hybm
    
    p0 = tofloat(cdf_file->P0)
    P0mb = 0.01*cdf_file->P0
 
    p = pres_hybrid_ccm(PS,p0,hyam,hybm)
    
    dims1 = dimsizes(Uhy)
    dimslev = dimsizes(pnew)
    
    T = vinth2p_ecmwf(Thy,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
    U = vinth2p_ecmwf(Uhy,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
    V = vinth2p_ecmwf(Vhy,hyam,hybm,pnew,PS,1,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
    
    ; get pressure levels
    
    level = pnew
    level!0="lev_int"
    
    nlat = filevardimsizes(cdf_file,"lat")
    nlon = filevardimsizes(cdf_file,"lon")
    nlevels = dimsizes(pnew)
 
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
                        V(itime,ilevp,ilat,ilon) = V@_FillValue
                        T(itime,ilevp,ilat,ilon) = T@_FillValue
                    end if
                end do
            end do
        end do
    end do


    ; Calculate potential temperature
    THETA = T
    THETA = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)

    check = printEP(Dir,filo,U,V,THETA,level)
    return(check)

end

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir_in = (Direc + Experiment + "/atm/hist/raw/")
    print(Experiment)

    do iyear = startyr,endyr
        print(iyear)

        filename = Dir_in + Experiment + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-" + h2startday + "-00000.nc"
        ; open file with seasonal averages
        cdf_file_in = addfile(filename,"r")

        ;open file with topography
        filename_PHIS = Dir_in + Experiment + ".cam2.h0." + sprinti("%0.4i",startyr) + "-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS_in = cdf_file_PHIS->PHIS(0,:,:)
        filo_in = "EPfluxes_daily_" + sprinti("%0.4i",iyear) + "_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily(Dir_in,cdf_file_in,filo_in,0,364,PHIS_in,lev_int)


        ; For January:
        ;print("Jan")
        ;filo_in = "EPfluxes_daily_" + sprinti("%0.4i",iyear) + "-01_" + Experiment + ".cam2.h2.nc"
        ;test = runEPdaily(Dir_in,cdf_file_in,filo_in,0,30,PHIS_in,lev_int)
        
        ; For February
        ;print("Feb")
        ;filo_in = "EPfluxes_daily_" + sprinti("%0.4i",iyear) + "-02_" + Experiment + ".cam2.h2.nc"
        ;test = runEPdaily(Dir_in,cdf_file_in,filo_in,31,58,PHIS_in,lev_int)

        ; For December
        ;print("December")
        ;filo_in = "EPfluxes_daily_" + sprinti("%0.4i",iyear) + "-12_" + Experiment + ".cam2.h2.nc"
        ;test = runEPdaily(Dir_in,cdf_file_in,filo_in,334,364,PHIS_in,lev_int)

    end do
end do

end
