load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


Dirin = "/home/disk/eos4/rachel/CESM_outfiles/CAM5_AMIP/"
Filein = "cam5.1_amip_1d_002.cam2.h1.U.19790101-20051231.nc"

pnew  = (/ 2, 5,10,30,50,100,200,250,300,500,700,850,975/)
nplevs = dimsizes(pnew)

DirO = Dirin
filename = (Dirin + Filein)

cdf_file = addfile(filename,"r")

PHIS_file = addfile("/home/disk/eos4/rachel//inputdata/topo/USGS-gtopo30_0.9x1.25_remap_c051027.nc","r")

timesin = cdf_file->time
datesin = cdf_file->date
lat = cdf_file->lat
lon = cdf_file->lon
P0mb = 0.01*cdf_file->P0
PHIS = PHIS_file->PHIS
levs = cdf_file->lev
nlevs = dimsizes(levs)

hyam = cdf_file->hyam
hybm = cdf_file->hybm

Utemp = cdf_file->U(0:10,:,:,:)
ndims = dimsizes(Utemp)

PStemp = cdf_file->PS

dims = dimsizes(PStemp)
ntimes = dims(0)

print(ntimes)
nchunks = 10
chunk = toint(ntimes/nchunks)

print(chunk*1)
print(ntimes*1)
print(nchunks*chunk)
;-----------------------------------------------------------------------
;Write variables to a new netcdf file, for stat fits in matlab
;-----------------------------------------------------------------------
filo = "U_pl_" + Filein
system("/bin/rm -f " + DirO + filo)
fout = addfile(DirO + filo, "c")

setfileoption(fout,"DefineMode",True)

; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)
dimNames = (/"time","lev_p","lat","lon"/)
dimSizes = (/ntimes,nplevs,ndims(2),ndims(3)/)
dimUnlim = (/True,False,False,False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)
filevardef(fout,"lev_p",typeof(pnew),(/"lev_p"/))

filevardef(fout,"U",typeof(Utemp),(/"time","lev_p","lat","lon"/))

fout->lat = lat
fout->lon = lon
fout->lev_p = pnew

print(ntimes*1)
startchunk = 0
do i = 0,nchunks-1
    endchunk = min((/startchunk + chunk,ntimes-1/))
    print(endchunk*1)
    U = cdf_file->U(startchunk:endchunk,:,:,:)

    PS = cdf_file->PS(startchunk:endchunk,:,:)

; Calculate PV
    Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,PS,conform(PS,PHIS,(/1,2/))) 

    fout ->U(startchunk:endchunk,:,:,:) = Upres

    startchunk = endchunk + 1
    delete(U)
    delete(PS)
    delete(Upres)
end do
end
