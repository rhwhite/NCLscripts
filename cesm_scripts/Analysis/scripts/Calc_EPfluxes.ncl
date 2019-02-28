load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/Functions/EPflux.ncl"

; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; Calculated EP fluxes from climatological (seasonal) mean
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

version=getenv("NCL_CESMversion")
h2startday = getenv("NCL_h2start")

if version .EQ. "122" then
    camversion="cam"
else
    camversion="cam2"
end if

ERAlev = toint(getenv("NCL_ERAlev"))

if ERAlev .eq. 1 .or. ERAlev .eq. 0 then
    continue
else 
    print("setting ERAlev to default 0")
    ERAlev = 0
end if

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1

timespans = (/"ANN","DJF","JJA","MAM","SON"/)
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


        if ERAlev .eq. 1 then
            filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_ERAIpl_" + Experiment + "." + camversion + ".h0.nc"
        else
            filename = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + "." + camversion + ".h0.nc"
        end if

        ; open file with seasonal averages
        cdf_file = addfile(filename,"r")

        filenamePS = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment + "." + camversion + ".h0.nc"
        ; open file with seasonal averages
        filePS = addfile(filenamePS,"r")

        ; get pressure levels

        if ERAlev .eq. 1 then
            nlevels = filevardimsizes(cdf_file,"lev_p")
            level = cdf_file->lev_p
            level!0="lev_int"
        else
            nlevels = filevardimsizes(cdf_file,"lev_int")
            level = cdf_file->lev_int
            level!0="lev_int"
        end if

        nlat = filevardimsizes(cdf_file,"lat")
        nlon = filevardimsizes(cdf_file,"lon")

        lat = tofloat(cdf_file->lat)
        lat!0="lat"
        lon = tofloat(cdf_file->lon)
        lon!0="lon"

        if ERAlev .eq. 1 then
            U = cdf_file->U
            V = cdf_file->V
            T = cdf_file->T

            T!1="lev_int"
            U!1="lev_int"
            V!1="lev_int"

        else
            U = cdf_file->U_logp
            V = cdf_file->V_logp
            T = cdf_file->T_logp
        end if

        PS = filePS->PS(0,:,:)

        ; mask out regions below ground
        ;print(level)
        do ilat = 0,nlat-1
            do ilon = 0,nlon-1
                do ilevp = 0,nlevels-1
                    if PS(ilat,ilon) .LT. (level(ilevp)+20) *100.0
                    ;	print(tostring(ilevp) + ", " + tostring(ilat) + ", " + tostring(ilon))
                        U(:,ilevp,ilat,ilon) = U@_FillValue
                        V(:,ilevp,ilat,ilon) = V@_FillValue
                        T(:,ilevp,ilat,ilon) = T@_FillValue
                    end if
                end do
            end do
        end do


        ; Calculate potential temperature
        THETA = T ; set-up variables in THETA
        THETA = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)

        if ERAlev .eq. 1 then
            filo = "EPfluxes_stat_ERAIpl" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + "." + camversion + ".h0.nc"
        else
            filo = "EPfluxes_stat_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + Experiment + "." + camversion + ".h0.nc"
        end if

        check = printEP(Dir,filo,U,V,THETA,level)

    end do
end do

end
