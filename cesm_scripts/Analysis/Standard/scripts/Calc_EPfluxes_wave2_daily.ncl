load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/cesm_scripts/Functions/EPflux_daily.ncl"

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

; p_int is used as an argument for runEPdaily
p_int = 10^fspan(0.1,3,25)   ; interpolation targets
p_int!0 = "lev_p"
dimslevint = dimsizes(p_int)

function runEPdaily_FFT(Dir,cdf_file,filo:string,startidx:numeric,endidx:numeric,PHIS,pnew)
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

    ; set wavenumber 1 to 0
    FFT_T(:,:,:,:,0) = 0.0
    FFT_U(:,:,:,:,0) = 0.0
    FFT_V(:,:,:,:,0) = 0.0
    FFT_TH(:,:,:,:,0) = 0.0

    ; reconstruct over 5th dimension (index 4)
    ; 1st is real and imaginary components
    ; 2nd is time
    ; 3rd is level
    ; 4th is latitude

    ZM_T = dim_avg_n(T,3)
    ZM_U = dim_avg_n(U,3)
    ZM_V = dim_avg_n(V,3)
    ZM_TH = dim_avg_n(TH,3)


    T_wave = conform(T,ZM_T,(/0,1,2/)) + ezfftb_n(FFT_T,0,4)
    U_wave = conform(U,ZM_U,(/0,1,2/)) + ezfftb_n(FFT_U,0,4)
    V_wave = conform(V,ZM_V,(/0,1,2/)) + ezfftb_n(FFT_V,0,4)
    TH_wave = conform(TH,ZM_TH,(/0,1,2/)) + ezfftb_n(FFT_TH,0,4)

    copy_VarCoords(T,T_wave)
    copy_VarCoords(U,U_wave)
    copy_VarCoords(V,V_wave)
    copy_VarCoords(TH,TH_wave)

    TH_wavezm = dim_avg_Wrap(TH_wave)

    ; mask out regions below ground
    ;print(level)
    do ilat = 0,nlat-1
        do ilon = 0,nlon-1
            do ilevp = 0,nlevels-1
                do itime = 0,ntimes-1
                    if PS(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
                        U_wave(itime,ilevp,ilat,ilon) = U_wave@_FillValue
                        V_wave(itime,ilevp,ilat,ilon) = V_wave@_FillValue
                        TH_wave(itime,ilevp,ilat,ilon) = TH_wave@_FillValue
                    end if
                end do
            end do
        end do
    end do

    check = printEPdaily(Dir,filo,U_wave,V_wave,TH_wave,level)
    return(check)

end

do exps = 0,nexps-1
    Experiment = Experiments(exps)
    Dir_in = (Direc + Experiment + "/atm/hist/")
    print(Experiment)

    do iyear = startyr,endyr
        print(iyear*1)
        filename = Dir_in + Experiment + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-01-00000.nc"
        ; open file with seasonal averages
        cdf_file_in = addfile(filename,"r")

        ;open file with topography
        filename_PHIS = Dir_in + Experiment + ".cam2.h0.0001-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS_in = cdf_file_PHIS->PHIS(0,:,:)

        ; For January:
        filo_in = "EPfluxes_daily_wave2_" + sprinti("%0.4i",iyear) + "-01_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily_FFT(Dir_in,cdf_file_in,filo_in,0,30,PHIS_in,p_int)
        print(test)        

        ; For February
        filo_in = "EPfluxes_daily_wave2_" + sprinti("%0.4i",iyear) + "-02_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily_FFT(Dir_in,cdf_file_in,filo_in,31,58,PHIS_in,p_int)
        print(test)

        ; For December
        filo_in = "EPfluxes_daily_wave2_" + sprinti("%0.4i",iyear) + "-12_" + Experiment + ".cam2.h2.nc"
        test = runEPdaily_FFT(Dir_in,cdf_file_in,filo_in,334,364,PHIS_in,p_int)
        print(test)

    end do
end do

end
