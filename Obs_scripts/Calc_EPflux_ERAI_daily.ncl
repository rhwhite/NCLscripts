load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"

; Calculate EP fluxes on a daily basis and then take the average.
; Based on NOAA NCL script at
; http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also:
; http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of
; http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates

begin

print("Calc Rossby Refractive Index")

startyr=1980
endyr=2015
nyears = endyr-startyr+1

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/"

filein = "daily_" + tostring(startyr) + "-" + tostring(endyr) + ".nc"
;filein = "daily_" + tostring(startyr) + ".nc"

cdf_file = addfile(Dir + "ERAI_U_TH_Z_" + filein,"r")
cdf_fileV = addfile(Dir + "ERAI_V_" + filein,"r")


; get pressure levels

level = cdf_file->level		; in hpa, or mb
level!0="level"
lat = tofloat(cdf_file->latitude)
lat!0="latitude"
lon = tofloat(cdf_file->longitude)
lon!0="longitude"

ndims = dimsizes(cdf_file->u)
ntimes = ndims(0)

print(ntimes)
tstart = 0
tchunk = 1000
nchunks = ceil(ntimes/tchunk)
startchunk = 0

do ichunk=startchunk,nchunks 
    tmin = ichunk * tchunk
    tmax = min((/(ichunk+1)*tchunk,ntimes/))

    U = cdf_file->u(tmin:tmax-1,:,:,:)
    V = cdf_fileV->v(tmin:tmax-1,:,:,:)
    T = cdf_file->t(tmin:tmax-1,:,:,:)

    ; Set up filename
    fileo = "/ERAI_EPfluxes_" + tostring(ichunk) + "_" + filein
    system("/bin/rm -f " + fileo)

    lev_id = 1
    lon_id = 3

    ; Calculate TH from T
    TH = T*((1000.0/conform(T,level,lev_id))^0.286)

    ; Change coordinate to those matching CESM
    U!0 = "time"
    U!1 = "lev_int"
    U!2 = "lat"
    U!3 = "lon"
    copy_VarCoords(U,TH)
    copy_VarCoords(U,V)

    ; Calculate EP fluxes
    check = printEP(Dir,fileo,U,V,TH,level)

    print(check)

    delete([/U,T,TH,V/])
end do
end
