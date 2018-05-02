load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"
load "/home/disk/eos4/rachel/git/NCL/Functions/TakNakflux_daily.ncl"

; Calculates TakNak fluxes on daily data from CTL, with seasonal means from No
; mountain experiments (i.e. the base state on which the effect of the mountains
; is acting

begin

monthstart = [/0,31,59,90,120,151,181,212,243,273,304,334/]

; Get experiment names

logp = 0

print("Calc TakNak fluxes")
Dirb = getenv("NCL_ARG_1")
Direc = getenv("NCL_Dirb")

print(Dirb)
print(Direc)
nexps = toint(getenv("NCL_ARG_2"))
Exps_base = new(nexps,"string")
Exps = new(nexps,"string")

do ne = 0,nexps-1
    Exps(ne) = getenv("NCL_Exp_" + tostring(ne))
    Exps_base(ne) = getenv("NCL_Exp2_" + tostring(ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

startyrC = toint(getenv("NCL_startyrC"))
nyearsC = toint(getenv("NCL_nyearsC"))

secs = getenv("NCL_ARG_" + tostring(5+nexps))
seas = getenv("NCL_seas")


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

dimsexps = dimsizes(Exps_base)
nexps = dimsexps(0)

; lev_int is used as an argument for runTakNakdaily
lev_int = 10^fspan(0,3,30)   ; interpolation targets
lev_int!0 = "lev_int"
dimslevint = dimsizes(lev_int)

function runTakNakdaily(Dir,clim_in,cdf_file,filo_out:string,startidx:numeric,endidx:numeric,PHIS,pnew)
begin
    ; Read in base state variables
    Ubase = clim_in->U(0,:,:,:)
    Vbase = clim_in->V(0,:,:,:)
    SFbase = clim_in->SF(0,:,:,:)
    THbase = clim_in->TH(0,:,:,:)
    Zbase = clim_in->Z3(0,:,:,:)

    ; Read in daily variables
    timesin = cdf_file->time(startidx:endidx)
    datesin = cdf_file->date(startidx:endidx)
    Uhy = cdf_file->U(startidx:endidx,:,:,:)
    Vhy = cdf_file->V(startidx:endidx,:,:,:)
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
    
    U = vinth2p_ecmwf(Uhy,hyam,hybm,pnew,PS,2,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
    V = vinth2p_ecmwf(Vhy,hyam,hybm,pnew,PS,2,P0mb,1,True,0,TBOT,conform(PS,PHIS,(/1,2/)))
   
    ; calculate streamfunction 
    temp = uv2sfvpF(U,V)
    SF = temp(0,:,:,:,:)

    SF@_FillValue = U@_FillValue

    ; get pressure levels
    
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
                    if PS(itime,ilat,ilon) .LT. (pnew(ilevp)+20) *100.0
                        SF(itime,ilevp,ilat,ilon) = SF@_FillValue
                    end if
                end do

            end do
        end do
    end do

    check = printTakNakdaily(Dir,filo_out,SF,SFbase,Ubase,Vbase,THbase,Zbase,pnew,lat,lon,timesin)
    return(check)

end



do exps = 0,nexps-1
    baseExp = Exps_base(exps)
    anomExp = Exps(exps)

    Dir_base = (Dirb + baseExp + "/atm/hist/")
    Dir_anom = (Direc + anomExp + "/atm/hist/")
    print(baseExp)

    if seas .eq. "Annual" then
        months = (/1,2,3,4,5,6,7,8,9,10,11,12/)
    else if seas .eq. "DJF" then
        months = (/1,2,12/)
    else if seas .eq. "JJA" then
        months = (/6,7,8/)
    end if
    end if
    end if

    climfile = Dir_base + "/" + seas + tostring(startyrC) + "_" + tostring(nyearsC) + "_mean_Xpl_" + baseExp + ".cam2.h0.nc"

    clim_in = addfile(climfile,"r") 
    pnew = clim_in->lev_p

    nmonth = dimsizes(months) ; number of months to run for
    ntotal = nyears * nmonth

    do iyear = startyr,endyr
        print(iyear)

        filename = Dir_anom + "/raw/" + anomExp + ".cam2.h2." + sprinti("%0.4i",iyear) + "-01-01-00000.nc"
        ; open file with seasonal averages
        cdf_file_in = addfile(filename,"r")

        ;open file with topography
        filename_PHIS = Dir_anom + "/raw/" + anomExp+ ".cam2.h0.0002-01.nc"
        cdf_file_PHIS = addfile(filename_PHIS,"r")

        PHIS_in = cdf_file_PHIS->PHIS(0,:,:)

        do itermonth = 0,nmonth-1
            imonth = months(itermonth)

            filo_out = "TakNakfluxes/TakNakfluxes_daily_" + sprinti("%0.4i",iyear) + "-" + sprinti("%0.2i",imonth) + "_" + anomExp + "_on_" + baseExp + ".cam2.h2.nc"

            starti = monthstart[imonth-1]
            if imonth .EQ. 12
                endi = 364
            else
                endi = monthstart[imonth]-1
            end if

            results = runTakNakdaily(Dir_base,clim_in,cdf_file_in,filo_out,starti,endi,PHIS_in,pnew)

        end do
    end do
end do

end
