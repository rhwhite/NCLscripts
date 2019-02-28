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

print("Calc wavenumber 1 and 2 amplitudes")
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


pnew  = (/850,500,250,100,50,10,1 /)

function runFFT(Dir,cdf_file,filo:string,startidx:numeric,endidx:numeric,PHIS)
begin
    timesin = cdf_file->time(startidx:endidx)
    datesin = cdf_file->date(startidx:endidx)
    Zhy = cdf_file->Z3(startidx:endidx,:,:,:)
    TBOT = cdf_file->TBOT(startidx:endidx,:,:)
    
    PS = cdf_file->PS(startidx:endidx,:,:)
    
    levs = cdf_file->lev
    nlevs = dimsizes(levs)
    
    hyam = cdf_file->hyam
    hybm = cdf_file->hybm
    
    p0 = tofloat(cdf_file->P0)
    P0mb = 0.01*cdf_file->P0
 
    p = pres_hybrid_ccm(PS,p0,hyam,hybm)
    
    dims1 = dimsizes(Zhy)
    dimslev = dimsizes(pnew)
    
    Z = vinth2p_ecmwf(Zhy,hyam,hybm,pnew,PS,1,P0mb,1,True,1,TBOT,conform(PS,PHIS,(/1,2/)))
    
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

    ; Calculate amplitude of each harmonic
    FFT_Z_all = ezfftf_n(Z,3)    ; computes fourier transform on right-most
                        ; dimension, i.e. longitude

    ; Select wavenumbers 1, 2, 3 and 4+
    FFT_Z = FFT_Z_all(:,:,:,:,0:3)
    FFT_Z(:,:,:,:,3) = dim_sum_n(FFT_Z_all(:,:,:,:,3:),4)

    ; set wavenumber 3 and higher to 0
    ;FFT_T(:,:,:,:,2:) = 0.0


    FFT_Z!0 = "RealImag"
    FFT_Z!1 = "time"
    FFT_Z!2 = "lev_p"
    FFT_Z!3 = "lat"
    FFT_Z!4 = "wavenumber"

    FFT_Z&lat = cdf_file->lat
    FFT_Z&lev_p = pnew
    FFT_Z&time = cdf_file->time(startidx:endidx)

    ; reconstruct over 5th dimension (index 4)
    ; 1st is real and imaginary components
    ; 2nd is time
    ; 3rd is level
    ; 4th is latitude
    ; 5th is wavenumber

    Wave1 = FFT_Z_all
    Wave1(:,:,:,:,1:) = 0.0

    Wave2 = FFT_Z_all
    Wave2(:,:,:,:,2:) = 0.0
    Wave2(:,:,:,:,0) = 0.0

    Z_wave1 = ezfftb_n(Wave1,0,4)
    Z_wave2 = ezfftb_n(Wave2,0,4)

    copy_VarCoords(Z,Z_wave1)
    copy_VarCoords(Z,Z_wave2)

    ; mask out regions below ground
    ;print(level)
    ;do ilat = 0,nlat-1
    ;    do ilon = 0,nlon-1
    ;        do ilevp = 0,nlevels-1
    ;            do itime = 0,ntimes-1
    ;                if PS(itime,ilat,ilon) .LT. (level(ilevp)+20) *100.0
    ;                    U_wave12(itime,ilevp,ilat,ilon) = U_wave12@_FillValue
    ;                    V_wave12(itime,ilevp,ilat,ilon) = V_wave12@_FillValue
    ;                    T(itime,ilevp,ilat,ilon) = T@_FillValue
    ;                end if
    ;            end do
    ;        end do
    ;    end do
    ;end do

    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    fout_std = addfile(Dir + filo, "c")

    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout_std,fAtt)

    fout_std->FFT1_Z = FFT_Z
    fout_std->Z = Z
    ;fout_std->Z_wave1 = Z_wave1
    ;fout_std->Z_wave2 = Z_wave2


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
        filename_PHIS = Dir_in + Experiment + ".cam2.h0.0001-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS_in = cdf_file_PHIS->PHIS(0,:,:)

        ; For January:
        print("Jan")
        filo_in = "Z_FFT_" + sprinti("%0.4i",iyear) + "-01_" + Experiment + ".cam2.h2.nc"
        test = runFFT(Dir_in,cdf_file_in,filo_in,0,30,PHIS_in)
        
        ; For February
        print("Feb")
        filo_in = "Z_FFT_" + sprinti("%0.4i",iyear) + "-02_" + Experiment + ".cam2.h2.nc"
        test = runFFT(Dir_in,cdf_file_in,filo_in,31,58,PHIS_in)

        ; For March
        print("Mar")
        filo_in = "Z_FFT_" + sprinti("%0.4i",iyear) + "-03_" + Experiment + ".cam2.h2.nc"
        test = runFFT(Dir_in,cdf_file_in,filo_in,59,89,PHIS_in)

        ;  For November
        print("Nov")
        filo_in = "Z_FFT_" + sprinti("%0.4i",iyear-1) + "-11_" + Experiment + ".cam2.h2.nc"
        test = runFFT(Dir_in,cdf_file_in,filo_in,304,333,PHIS_in)


        ;  For December
        print("December")
        filo_in = "Z_FFT_" + sprinti("%0.4i",iyear-1) + "-12_" + Experiment + ".cam2.h2.nc"
        test = runFFT(Dir_in,cdf_file_in,filo_in,334,364,PHIS_in)

    end do
end do

end
