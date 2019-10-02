load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/Earth/rwhite/scripts/myNCL/NCLscripts/functions.ncl"


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

;Dir = "/home/Earth/rwhite/data/ERAI/daily_mean/"
;Dir = "/esarchive/scratch/rwhite/data/ERAI/daily_data/raw/"
;Dir = "/esarchive/scratch/rwhite/data/CCCma/daily_data/raw/"
Dir = "/esarchive/scratch/rwhite/data/NCEP-NCAR/daily_data/"

nfiles = 1
fileins = (/"ZM_U250_daily_NCEP_R2_19790101-20190707.nc"/)
;fileins = (/"ua250_day_CanESM5_historical_r1i1p1f1_gn_18500101-20141231.nc","ua250_day_CanESM5_historical_r2i1p1f1_gn_19800101-20141231.nc","ua250_day_CanESM5_historical_r3i1p1f1_gn_19800101-20141231.nc","ua250_day_CanESM5_historical_r4i1p1f1_gn_19800101-20141231.nc"/)

do ifile = 0,nfiles-1

    cdf_file = addfile(Dir + "/" + fileins(ifile),"r")

    ; Set up output filename
    fileo = Dir + "/ZMKs_" + fileins(ifile)
    print(fileo)
    system("/bin/rm -f " + fileo)

    ; If pressure levels are still there, need to use:
    ; need to change variable name for different input types
    ;U = cdf_file->uwnd(:,:,:,:)
    ZM_U = cdf_file->uwnd(:,:,:)

    ;U = cdf_file->u(:,:,:)

    ; If not already zonal mean:

    ;dimNames = getvardims(U)
    ;ndims =dimsizes(dimNames)

    ; loop through to find longitude
    ;do idim = 0,ndims-1
    ;    if dimNames(idim) .eq. "longitude" .or. dimNames(idim) .eq. "lon" then
    ;        lonid = idim
    ;    end if
    ;end do
   
    ;ZM_U = dim_avg_n_Wrap(U,lonid)

    lat = tofloat(cdf_file->latitude)
    ;lat = tofloat(cdf_file->lat)

    returned = calc_Btp_ZMKs(ZM_U,lat,fileo)

    print(returned)
end do
end
