load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"


; Code to calculate Rossby stationary wave number, following Hoskins and Ambrizzi 1993. 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

print("Calc Rossby Refractive Index")

startyr=1980
endyr=2015
nyears = endyr-startyr+1

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/"

; Ignore leap years!
months = (/1,2,12/)
monthstarts = (/334,0,31/)
monthends = (/364,30,59/)
ndays = (/31,31,28/)
nmonths = dimsizes(months)

; loop over each year separately as this is how raw data is
do iyear = startyr,endyr
    print(tostring(iyear))
    filein = "daily_" + tostring(iyear) + ".nc"

    cdf_file = addfile(Dir + "ERAI_U_TH_Z_" + filein,"r")

    ; get pressure levels

    level = cdf_file->level		; in hpa, or mb
    level!0="level"
    nlevs = dimsizes(level)
    lat = tofloat(cdf_file->latitude)
    lat!0="latitude"
    lon = tofloat(cdf_file->longitude)
    lon!0="longitude"

    nlat = filevardimsizes(cdf_file,"latitude")
    nlon = filevardimsizes(cdf_file,"longitude")


    do imonth = 0,nmonths-1

        month = months(imonth)
        monthstart = monthstarts(imonth)
        monthend = monthends(imonth)
        
        if isleapyear(iyear) then
            if month .eq. 2 then
                monthend = monthend + 1 ; add 1 to end of Feb
            else if month .eq. 2 then
                monthstart = monthstart + 1     ; add 1 to beg of Dec
                monthend = monthend + 1         ; add 1 to end of Dec
            end if
            end if
        end if
    
        mid = toint(ndays(imonth)/2.0)

        timesin = cdf_file->time(monthstart:monthend)
        U = cdf_file->u(monthstart:monthend,:,:,:)
        T = cdf_file->t(monthstart:monthend,:,:,:)
        Zg = cdf_file->z(monthstart:monthend,:,:,:)
        Z = Zg/9.81

        ; set up new arrays with bi-monthly averages
        time_id = 0
        ntimes = dimsizes(timesin)
        Tnew1 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(T(0:mid-1,:,:,:),time_id),(/1,2,3/))
        Tnew2 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(T(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
        newT = array_append_record(Tnew1,Tnew2,0) ; last argument not used
        newT!0 = T!0
        newT!1 = T!1
        newT!2 = T!2
        newT!3 = T!3

        Unew1 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(U(0:mid-1,:,:,:),time_id),(/1,2,3/))
        Unew2 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(U(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
        newU = array_append_record(Unew1,Unew2,0)
        newU!0 = U!0
        newU!1 = U!1
        newU!2 = U!2
        newU!3 = U!3

        Znew1 =conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Z(0:mid-1,:,:,:),time_id),(/1,2,3/))
        Znew2 =conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Z(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
        newZ = array_append_record(Znew1,Znew2,0)
        
        newZ!0 = Zg!0
        newZ!1 = Zg!1
        newZ!2 = Zg!2
        newZ!3 = Zg!3



        ; Set up filename
        fileo = Dir + "/ERAI_ZMKs_bimonth_" + sprinti("%0.4i",iyear) + "-" + sprinti("%0.2i",month) + ".nc"
        system("/bin/rm -f " + fileo)

        ;Calc TH
        lev_id = 1
        lon_id = 3

        newTH = newT*((1000.0/conform(newT,level,lev_id))^0.286)
        copy_VarCoords(newT,newTH)

        ; Calc ZMs
        Uzm = dim_avg_n_Wrap(newU,lon_id) ; get zonal mean U
        Zzm = dim_avg_n_Wrap(newZ,lon_id) ; get zonal mean Z
        THzm = dim_avg_n_Wrap(newTH,lon_id) ; get zonal mean TH

        ; Add back in level and latitude dimension

        Uzm!2 = "latitude"
        THzm!2 = "latitude"
        Zzm!2 = "latitude"

        Uzm&latitude = lat
        THzm&latitude = lat
        Zzm&latitude = lat

        Uzm!1 = "level"
        THzm!1 = "level"
        Zzm!1 = "level"

        Uzm&level = level
        THzm&level = level
        Zzm&level = level



        ; call calcZMKs to calculate Ks
        returned = calcZMKs(Uzm,THzm,Zzm,level,lat,fileo)

        if returned .ne. 1 then
            print("error in calcZMKs")
            print(returned)
        end if
        delete([/newT,newU,newZ,Uzm,Zzm,THzm,Zg,timesin/])

        ; Now run monthly averages
        ; Set up filename
        fileo = Dir + "/ERAI_ZMKs_month_" + sprinti("%0.4i",iyear) + "-" + sprinti("%0.2i",month) + ".nc"
        system("/bin/rm -f " + fileo)

        time_id = 0
        Utm = dim_avg_n_Wrap(U,time_id) ; get time mean U
        Ztm = dim_avg_n_Wrap(Z,time_id) ; get time mean Z
        Ttm = dim_avg_n_Wrap(T,time_id) ; get time mean T

        ;Calc TH
        lev_id = 0
        lon_id = 2

        THtm = Ttm*((1000.0/conform(Ttm,level,lev_id))^0.286)
        copy_VarCoords(Ttm,THtm)

        ; Calc ZMs
        Uzm = dim_avg_n_Wrap(Utm,lon_id) ; get zonal mean U
        Zzm = dim_avg_n_Wrap(Ztm,lon_id) ; get zonal mean Z
        THzm = dim_avg_n_Wrap(THtm,lon_id) ; get zonal mean TH

        ; Add back in level and latitude dimension

        Uzm!1 = "latitude"
        THzm!1 = "latitude"
        Zzm!1 = "latitude"

        Uzm&latitude = lat
        THzm&latitude = lat
        Zzm&latitude = lat

        Uzm!0 = "level"
        THzm!0 = "level"
        Zzm!0 = "level"

        Uzm&level = level
        THzm&level = level
        Zzm&level = level



        ; call calcZMKs to calculate Ks
        returned = calcZMKs(Uzm,THzm,Zzm,level,lat,fileo)

        if returned .ne. 1 then
            print("error in calcZMKs")
            print(returned)
        end if
        delete([/Uzm,Zzm,THzm,Utm,Ttm,Ztm,THtm,U,Z,T/])

    end do
end do

end
