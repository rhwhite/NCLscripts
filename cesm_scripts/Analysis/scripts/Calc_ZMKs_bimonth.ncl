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

print("Calc Ks on fortnightly averages from daily data")
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
;lev_p = (/1000.0, 925.0, 850.0, 750.0, 500.0, 400.0, 300.0, 250.0, 200.0, 150.0, 100.0, 50.0, 25.0, 10.0, 8.0, 7.0, 6.0, 5.0, 4.5, 4.0, 3.5, 3.0, 2.75, 2.5, 2.25, 2.0, 1.75, 1.5, 1.25, 1.0/)

lev_p = 10^fspan(0,3,30)   ; interpolation targets
lev_p!0 = "lev_p"
dimslevint = dimsizes(lev_p)


months = (/1,2,12/)
monthstarts = (/334,0,31/)
monthends = (/364,30,59/)
ndays = (/31,31,28/)
nmonths = dimsizes(months)

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
        hyam = cdf_file->hyam
        hybm = cdf_file->hybm

        p0 = tofloat(cdf_file->P0)
        P0mb = 0.01*cdf_file->P0

        do imonth = 0,nmonths
            month = months(imonth)
            monthstart = monthstarts(imonth)
            monthend = monthends(imonth)
            mid = toint(ndays(imonth)/2.0)

            timesin = cdf_file->time(monthstart:monthend)
            datesin = cdf_file->date(monthstart:monthend)
            Uhy = cdf_file->U(monthstart:monthend,:,:,:)
            Thy = cdf_file->T(monthstart:monthend,:,:,:)
            Zhy = cdf_file->Z3(monthstart:monthend,:,:,:)
            TBOT = cdf_file->TBOT(monthstart:monthend,:,:)
            
            PS = cdf_file->PS(monthstart:monthend,:,:)
            
            levs = cdf_file->lev
            nlevs = dimsizes(levs)
            
            dims1 = dimsizes(Uhy)
            dimslev = dimsizes(lev_p)
           
            nlat = filevardimsizes(cdf_file,"lat")
            nlon = filevardimsizes(cdf_file,"lon")

            lat = tofloat(cdf_file->lat)
            lat!0="lat"
            lon = tofloat(cdf_file->lon)
            lon!0="lon"
 
            time_id = 0
            ntimes = dimsizes(timesin)
            Tnew1 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Thy(0:mid-1,:,:,:),time_id),(/1,2,3/))
            Tnew2 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Thy(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
            newT = array_append_record(Tnew1,Tnew2,0) ; last argument not used
            newT!0 = Thy!0
            newT!1 = Thy!1
            newT!2 = Thy!2
            newT!3 = Thy!3

            TBOTnew1 = conform_dims((/1,nlat,nlon/),dim_avg_n_Wrap(TBOT(0:mid-1,:,:),time_id),(/1,2/))
            TBOTnew2 = conform_dims((/1,nlat,nlon/),dim_avg_n_Wrap(TBOT(mid:ntimes-1,:,:),time_id),(/1,2/))
            newTBOT = array_append_record(TBOTnew1,TBOTnew2,0)

            Unew1 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Uhy(0:mid-1,:,:,:),time_id),(/1,2,3/))
            Unew2 = conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Uhy(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
            newU = array_append_record(Unew1,Unew2,0)
            newU!0 = Uhy!0
            newU!1 = Uhy!1
            newU!2 = Uhy!2
            newU!3 = Uhy!3

            Znew1 =conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Zhy(0:mid-1,:,:,:),time_id),(/1,2,3/))
            Znew2 =conform_dims((/1,nlevs,nlat,nlon/),dim_avg_n_Wrap(Zhy(mid:ntimes-1,:,:,:),time_id),(/1,2,3/))
            newZ = array_append_record(Znew1,Znew2,0)
            newZ!0 = Zhy!0
            newZ!1 = Zhy!1
            newZ!2 = Zhy!2
            newZ!3 = Zhy!3


            PSnew1 = conform_dims((/1,nlat,nlon/),dim_avg_n_Wrap(PS(0:mid-1,:,:),time_id),(/1,2/))
            PSnew2 = conform_dims((/1,nlat,nlon/),dim_avg_n_Wrap(PS(mid:ntimes-1,:,:),time_id),(/1,2/))
            newPS = array_append_record(PSnew1,PSnew2,0)

            T =vinth2p_ecmwf(newT,hyam,hybm,lev_p,newPS,1,P0mb,1,True,1,newTBOT,conform(newPS,PHIS,(/1,2/)))
            U =vinth2p_ecmwf(newU,hyam,hybm,lev_p,newPS,1,P0mb,1,True,0,newTBOT,conform(newPS,PHIS,(/1,2/)))
            Z =vinth2p_ecmwf(newZ,hyam,hybm,lev_p,newPS,1,P0mb,1,True,-1,newTBOT,conform(newPS,PHIS,(/1,2/)))
            
            dims = dimsizes(T)
            ntimes = dims(0)
            level = lev_p
            level!0="lev_p"
            nlevels = dimsizes(lev_p)


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


            Tcoords = T
            Uzm!2 = "lat"
            THzm!2 = "lat"
            Zzm!2 = "lat"

            Uzm&lat = lat
            THzm&lat = lat
            Zzm&lat = lat

            fileo = Dir_in + "ZMKs_bimonth_int_" + sprinti("%0.4i",iyear) + "-" + sprinti("%0.2i",month) + "_" + Experiment + ".cam2.h2.nc"
            system("/bin/rm -f " + fileo)
            returned = calcZMKs(Uzm,THzm,Zzm,level,lat,fileo)
            
            if (returned .ne. 1) then
                print(returned)
                exit
            end if

            delete([/timesin,datesin,newT,newZ,newU,newTBOT,newPS,Uhy,Thy,Zhy,TBOT,PS/])
        end do
    end do
end do

end

