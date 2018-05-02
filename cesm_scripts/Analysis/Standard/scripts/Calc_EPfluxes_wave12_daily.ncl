load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

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


pnew  = (/1000,925,850,775,750,700,600,500,400,300,250,200,150,100, \
            70,50,40,30,25,20,15,10,8,6,5,4,3,2,1 /)

function runEPdaily(Dir,cdf_file,filo:string,startidx:numeric,endidx:numeric,PHIS)
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
    level!0="lev_p"
    
    nlat = filevardimsizes(cdf_file,"lat")
    nlon = filevardimsizes(cdf_file,"lon")
    nlevels = dimsizes(pnew)
 
    lat = tofloat(cdf_file->lat)
    lat!0="lat"
    lon = tofloat(cdf_file->lon)
    lon!0="lon"
    
    ntimes = dimsizes(timesin)


    ; Calculate potential temperature
    TH = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)
    copy_VarMeta(T,TH)


    ; Calculate amplitude of each harmonic
    FFT_T = ezfftf_n(T,3)    ; computes fourier transform on right-most
                        ; dimension, i.e. longitude

    FFT_U = ezfftf_n(U,3)    ; computes fourier transform on right-most
                        ; dimension, i.e. longitude

    FFT_V = ezfftf_n(V,3)    ; computes fourier transform on right-most
                        ; dimension, i.e. longitude

    FFT_TH = ezfftf_n(TH,3)    ; computes fourier transform on right-most
                        ; dimension, i.e. longitude

    ; set wavenumber 3 and higher to 0
    FFT_T(:,:,:,:,2:) = 0.0
    FFT_U(:,:,:,:,2:) = 0.0
    FFT_V(:,:,:,:,2:) = 0.0
    FFT_TH(:,:,:,:,2:) = 0.0


    ; reconstruct over 5th dimension (index 4)
    ; 1st is real and imaginary components
    ; 2nd is time
    ; 3rd is level
    ; 4th is latitude

    ZM_T = dim_avg_n(T,3)
    ZM_U = dim_avg_n(U,3)
    ZM_V = dim_avg_n(V,3)
    ZM_TH = dim_avg_n(TH,3)


    T_wave12 = conform(T,ZM_T,(/0,1,2/)) + ezfftb_n(FFT_T,0,4)
    U_wave12 = conform(U,ZM_U,(/0,1,2/)) + ezfftb_n(FFT_U,0,4)
    V_wave12 = conform(V,ZM_V,(/0,1,2/)) + ezfftb_n(FFT_V,0,4)
    TH_wave12 = conform(TH,ZM_TH,(/0,1,2/)) + ezfftb_n(FFT_TH,0,4)

    copy_VarCoords(T,T_wave12)
    copy_VarCoords(U,U_wave12)
    copy_VarCoords(V,V_wave12)
    copy_VarCoords(TH,TH_wave12)

    TH_wave12zm = dim_avg_Wrap(TH_wave12)


    ; mask out regions below ground
    ;print(level)
    do ilat = 0,nlat-1
        do ilon = 0,nlon-1
            do ilevp = 0,nlevels-1
                do itime = 0,ntimes-1
                    if PS(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
                        U_wave12(itime,ilevp,ilat,ilon) = U_wave12@_FillValue
                        V_wave12(itime,ilevp,ilat,ilon) = V_wave12@_FillValue
                        T(itime,ilevp,ilat,ilon) = T@_FillValue
                    end if
                end do
            end do
        end do
    end do

    ; Calculate d(THETA)/dp from vertical finite differences in
    ; log-pressure coordinates
    ; noting that dT/dp = (1/p) * dT/d(lnp)
    loglevel = log(level)

    THETAp = center_finite_diff_n(TH_wave12zm(time|:,lev_p|:,lat|:),loglevel,False,0,1) 
                    ;derivative in log coords doesn't care whether in Pa or in mb.
    ; named subscripting reorders the dimensions
    ;        THETAp = THETAp / conform(THETAp,100.0 * level,1) 
    ; converts "level" to pascals from millibars while dividing by pressure.
    THETAp = center_finite_diff_n(TH_wave12zm(time|:,lev_p|:,lat|:),level*100.0,False,0,1) ;

    copy_VarMeta(TH_wave12zm,THETAp)
    ; za stands for zonal anomaly
    THETAp!2="lat"
    ; zm stands for zonal mean

    Uzm = dim_avg_n_Wrap(U_wave12(time|:,lev_p|:,lat|:,lon|:),3)

    Uza = dim_rmvmean_Wrap(U_wave12(time|:,lev_p|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    Vza = dim_rmvmean_Wrap(V_wave12(time|:,lev_p|:,lat|:,lon|:))   
                                        ; removes mean of rightmost dimension
    THETAza = dim_rmvmean_Wrap(TH_wave12(time|:,lev_p|:,lat|:,lon|:))

    UV = Uza * Vza
    copy_VarMeta(Uza,UV)
    UVzm = dim_avg_n_Wrap(UV(time|:,lev_p|:,lat|:,lon|:),3) 
                                            ; averages over longitude dimension
;    UVzmtm = dim_avg_n_Wrap(UVzm(time|:,lev_p|:,lat|:),0)   
;                                            ; average over time dimension

    VTHETA = Vza * THETAza
    copy_VarCoords(Vza,VTHETA)
    VTHETAzm = dim_avg_n_Wrap(VTHETA(time|:,lev_p|:,lat|:,lon|:),3) 
                                         ;average over longitude dimension
;    VTHETAzmtm = dim_avg_n_Wrap(VTHETAzm(time|:,lev_p|:,lat|:),0)   
;                                        ; average over time dimension

;    THETAptm = dim_avg_n_Wrap(THETAp(time|:,lev_p|:,lat|:),0)          
;                                        ; time mean of THETAp
    phi = lat*PI/180.0      ; Get latitude in radians
    cphi = cos(phi)
    sphi = sin(phi)
    acphi = a * cos(phi)
    asphi = a * sin(phi)
    f = 2*omega*sin(phi)

    Fphi = -UVzm*conform(UVzm,acphi,2)
    Fx = -UVzm
    Fphicphi = Fphi * conform(Fphi,cphi,2)
    Fp = conform(VTHETAzm,f*acphi,2) * VTHETAzm/THETAp
    Fpxy = conform(VTHETAzm,f,2) * VTHETAzm/THETAp

    FphiBEH = (1.0 / P0) * conform(Fphi,level,1) * Fphi
    FpBEH = (1.0/P0) * conform(Fp,level,1) * Fp

    copy_VarMeta(UVzm,Fphi)
    copy_VarMeta(UVzm,FphiBEH)
    copy_VarMeta(UVzm,Fx)
    copy_VarMeta(VTHETAzm,Fp)
    copy_VarMeta(VTHETAzm,FpBEH)
    copy_VarMeta(VTHETAzm,Fpxy)
    
    ; take derivative with respect to latitude using 1/[a cos(phi)] d/dphi
    ; [cos(phi)*X] = d/d[asin(phi)] (cos(phi) * X)

    Fphicphi = Fphi * conform(Fphi,cphi,2)
    FphiBEHcphi = FphiBEH * conform(FphiBEH,cphi,2)
    copy_VarMeta(Fphi,Fphicphi)
    copy_VarMeta(Fphi,FphiBEHcphi)

    EPdiv1 = center_finite_diff_n(Fphicphi(time|:,lev_p|:,lat|:),phi,False,0,2)/conform(Fphicphi,acphi,2)

    EPdivBEH1 = center_finite_diff_n(FphiBEHcphi(time|:,lev_p|:,lat|:),phi,False,0,2)/conform(Fphicphi,acphi,2)

    latdist = gc_latlon(lat(40),0,lat(41),0,1,3) ; in m

    EPdiv1xy = center_finite_diff_n(Fx(time|:,lev_p|:,lat|:),latdist,False,0,2)

    ; take derivate with respect to pressure
    ; Pressure in pascals
    EPdiv2 = center_finite_diff_n(Fp(time|:,lev_p|:,lat|:),level*100.0,False,0,1)
    ; Convert to pa from hpa
    EPdivBEH2 = center_finite_diff_n(FpBEH(time|:,lev_p|:,lat|:),level*100.0,False,0,1)  

    EPdiv2xy = center_finite_diff_n(Fpxy(time|:,lev_p|:,lat|:),level*100.0,False,0,1)

    ; Add together derivative components
    EPdiv = EPdiv1 + EPdiv2
    EPdivxy = EPdiv1xy + EPdiv2xy
    EPdivBEH = EPdivBEH1 + EPdivBEH2

    Fp&time=timesin
    Fp&lat = lat
    Fp&lev_p = level

    copy_VarMeta(Fp,EPdiv)
    copy_VarMeta(Fp,EPdiv1)
    copy_VarMeta(Fp,EPdiv2)
    copy_VarMeta(Fp,EPdivxy)
    copy_VarMeta(Fp,EPdivBEH)
    copy_VarMeta(Fp,Fphi)

    
    ; Compute acceleration from divF

    dudt = 86400.0 * EPdiv/conform(EPdiv,acphi,2);
    dudt@long_name = "acceleration from EP flux divergence"
    dudt@units = "m/s2"
    copy_VarCoords(EPdiv,dudt)

    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout_std,fAtt)

    fout_std->EPdiv = EPdiv
    fout_std->dudt = dudt
    fout_std->Fp = Fp
    fout_std->Fphi = Fphi


    fout_std->EPdiv_tm = dim_avg_n_Wrap(EPdiv(time|:,lev_p|:,lat|:),0)
    fout_std->dudt_tm = dim_avg_n_Wrap(dudt(time|:,lev_p|:,lat|:),0)
    fout_std->Fp_tm = dim_avg_n_Wrap(Fp(time|:,lev_p|:,lat|:),0)
    fout_std->Fphi_tm = dim_avg_n_Wrap(Fphi(time|:,lev_p|:,lat|:),0)


    return(1)

end

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir_in = (Direc + Experiment + "/atm/hist/")
    print(Experiment)

    do iyear = startyr,endyr
        print(iyear)
        filename = Dir_in + Experiment + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-01-00000.nc"
        ; open file with seasonal averages
        cdf_file_in = addfile(filename,"r")

        ;open file with topography
        filename_PHIS = Dir_in + Experiment + ".cam2.h0.0002-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS_in = cdf_file_PHIS->PHIS(0,:,:)

        ; For January:
        print("Jan")
        filo_in = "EPfluxes_daily_wave12_" + sprinti("%0.4i",iyear) + "-01_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily(Dir_in,cdf_file_in,filo_in,0,30,PHIS_in)
        
        ; For February
        print("Feb")
        filo_in = "EPfluxes_daily_wave12_" + sprinti("%0.4i",iyear) + "-02_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily(Dir_in,cdf_file_in,filo_in,31,58,PHIS_in)

        ; For December
        print("December")
        filo_in = "EPfluxes_daily_wave12_" + sprinti("%0.4i",iyear) + "-12_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily(Dir_in,cdf_file_in,filo_in,334,364,PHIS_in)

    end do
end do

end
