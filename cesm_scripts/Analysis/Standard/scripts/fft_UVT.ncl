load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Performs fast fourier transform on climatological data to obtain wavenumber
; harmonics
; See, for example https://www.ncl.ucar.edu/Applications/Scripts/fanal_1.ncl
; https://www.ncl.ucar.edu/Document/Functions/Built-in/fourier_info.shtml

; Written by R H White May 2017, rachel.white@cantab.net

begin

; Get experiment names

logp = 0

print("Calc Fourier harmonics")
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

timespans = (/"Annual","DJF","JJA","MAM","SON"/)
;timespan = getenv("NCL_season")
dimtimes = dimsizes(timespans)
nts = dimtimes(0)

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

do ts = 0,nts - 1

    timespan = timespans(ts)
    dimsexps = dimsizes(Experiments)
    nexps = dimsexps(0)
    do exps = 0,nexps-1
        Experiment = Experiments(exps)
        Dir = (Direc + Experiment + "/atm/hist/")
        print(Experiment)


        filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
        ; open file with seasonal averages
        cdf_file = addfile(filename,"r")

        filenamePS = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + ".cam2.h0.nc"
        ; open file with seasonal averages
        filePS = addfile(filenamePS,"r")

        ; get pressure levels

        nlevelstemp = filevardimsizes(cdf_file,"lev_p")
        nlevels = nlevelstemp-1	
        level = cdf_file->lev_p(0:nlevels-1)
        level!0="lev_p"

        nlat = filevardimsizes(cdf_file,"lat")
        nlon = filevardimsizes(cdf_file,"lon")

        lat = tofloat(cdf_file->lat)
        lat!0="lat"
        lon = tofloat(cdf_file->lon)
        lon!0="lon"

        ; find lonstart and lonend
        idxlonstart = 0
        idxlonend = nlon-1

        do ilon = 0,nlon-2
            if (lon(ilon) .LE. lonstart .AND. lon(ilon+1) .GT. lonstart) then
                idxlonstart = ilon
                break
            end if
        end do
        do ilon = 0,nlon-2
            if (lon(ilon) .LE. lonend .AND. lon(ilon+1) .GT. lonend) then
                idxlonend = ilon
                break
            end if
        end do



        U = cdf_file->U(:,0:nlevels-1,:,:)
        V = cdf_file->V(:,0:nlevels-1,:,:)
        T = cdf_file->T(:,0:nlevels-1,:,:)
        Z = cdf_file->Z3(:,0:nlevels-1,:,:)

        PS = filePS->PS(0,:,:)

        ; Calculate potential temperature
        TH = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)
        copy_VarMeta(T,TH)

        ; Calculate information on each Fourier component

        ; Specify first 10 harmonics
        nhar = 10

        finfo_T = fourier_info(T,nhar,1)
        finfo_U = fourier_info(U,nhar,1)
        finfo_V = fourier_info(V,nhar,1)
        finfo_TH = fourier_info(TH,nhar,1)
        finfo_Z= fourier_info(Z,nhar,1)
        

        finfo_T!0 = "ampl_phase_var"
        finfo_T!1 = "time"
        finfo_T!2 = "level"
        finfo_T!3 = "lat"
        finfo_T!4 = "wavenumber"

        finfo_T&level = level
        finfo_T&lat = lat
        finfo_T&wavenumber = ispan(1,nhar,1)

        copy_VarMeta(finfo_T,finfo_U)
        copy_VarMeta(finfo_T,finfo_V)
        copy_VarMeta(finfo_T,finfo_TH)
        copy_VarMeta(finfo_T,finfo_Z)


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

        ; mask out regions below ground
        ;print(level)
        do ilat = 0,nlat-1
            do ilon = 0,nlon-1
                do ilevp = 0,nlevels-1
                    if PS(ilat,ilon) .LT. (level(ilevp)+20) *100.0
                    ;   print(tostring(ilevp) + ", " + tostring(ilat) + ", " + tostring(ilon))
;                        U_wave12(:,ilevp,ilat,ilon) = U@_FillValue
;                        V_wave12(:,ilevp,ilat,ilon) = V@_FillValue
;                        T_wave12(:,ilevp,ilat,ilon) = T@_FillValue
;                        TH_wave12(:,ilevp,ilat,ilon) = TH@_FillValue

                    end if
                end do
            end do
        end do


        copy_VarMeta(T,T_wave12)
        copy_VarMeta(U,U_wave12)
        copy_VarMeta(V,V_wave12)
        copy_VarMeta(TH,TH_wave12)

        filo = "FFT_wave12_UVTTH_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + ".cam2.h0.nc"

        system("/bin/rm -f " + Dir + filo)
        fout_std = addfile(Dir + filo, "c")

        setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)
        
    ;set dimensions of output file
;        dimNames = (/"times","lat","lon","lev_p"/)
;        dimSizes = (/ntimes,nlat,nlon,nlevels/)
;        dimUnlim = (/True,False,False,False/)
;        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

        fout_std->T_wave12 = T_wave12
        fout_std->U_wave12 = U_wave12
        fout_std->V_wave12 = V_wave12
        fout_std->TH_wave12 = TH_wave12

        fout_std->finfo_T = finfo_T
        fout_std->finfo_U = finfo_U 
        fout_std->finfo_V = finfo_V 
        fout_std->finfo_TH = finfo_TH 
        fout_std->finfo_Z = finfo_Z




    end do
end do

end
