load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"


begin

print("Calc Rossby Refractive Index")

startyr=1980
endyr=2015
nyears = endyr-startyr+1
chunksize = 200

Dir = "/home/disk/eos4/rachel/Obs/ERAI/Daily/"

filein = "daily_1980-2015.nc"

cdf_file = addfile(Dir + "ERAI_U_TH_Z_" + filein,"r")

; get pressure levels

level = cdf_file->level		; in hpa, or mb
level!0="level"
lat = tofloat(cdf_file->latitude)
lat!0="latitude"
lon = tofloat(cdf_file->longitude)
lon!0="longitude"
times = cdf_file->time

; loop over chunks so we don't run out of memory
ndims =dimsizes(times)
ntimes = ndims(0)
print(ntimes)
 
nchunks = ntimes/chunksize
do ichunk = 1,nchunks+1
    starti = (ichunk-1)*chunksize
    endi = min((/starti + chunksize,ntimes-1/))
    ; Set up filename
    fileo = Dir + "/CH" + tostring(ichunk) + "_ERAI_FullKs_" + filein
    system("/bin/rm -f " + fileo)

    print(starti*1)
    print(endi*1)
    U = cdf_file->u(starti:endi,:,:,:)
    T = cdf_file->t(starti:endi,:,:,:)
    Z = cdf_file->z(starti:endi,:,:,:)/9.81

    ; Call CalcFullKs
    ;Calc TH

    lev_id = 1
    lon_id = 3

    TH = T*((1000.0/conform(T,level,lev_id))^0.286)
    copy_VarCoords(T,TH)

    returned = calcFullKs(U(:,:,:,:),TH(:,:,:,:),Z(:,:,:,:),level,lat,fileo)
    print(returned)

    delete([/U,T,Z,TH/])

end do
end
