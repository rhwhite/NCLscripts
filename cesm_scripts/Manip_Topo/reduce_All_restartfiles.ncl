load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

percent = 0.0
datein = "0001-01-12"

old_gpt_min = 0.0 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

fileins=(/"WACCM_f19_Flat.cam2.rh0." + datein + "-00000.nc","WACCM_f19_Flat.cam2.r." + datein + "-00000.nc"/)

nfiles = dimsizes(fileins)

print(nfiles)

diro = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_Flat_Spinup/"

; Read in land-mask
filenamein = diro + "WACCM_f19_Flat.cam2.rh0." + datein + "-00000.nc"

print("reading file in...")
cdf_file = addfile(filenamein,"r")
print("file read in")

print(max(cdf_file->LANDFRAC))
lm = cdf_file->LANDFRAC/max(cdf_file->LANDFRAC)   ; just because land fraction appears to be from

lons = cdf_file->lon
lats = cdf_file->lat
dims1 = dimsizes(lm)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)
  
do ifile=0,nfiles-1
    file1 = fileins(ifile)
    print(file1)

    system("cp " + diro + file1 + " " + diro + "Orig_" + file1)

    fileout1 = diro + file1

    filenamein = diro + file1

    print("reading file in...")
    cdf_file = addfile(filenamein,"r")
    print("file read in")

    gpt = cdf_file->PHIS

    gpt_new = gpt
    gpt_min = (gpt/100.0) * percent


    dims1 = dimsizes(gpt)
    numlats = dims1(0)
    numlons = dims1(1)


    do ny=0,numlats-1
        do nx = 0,numlons-1
            gpt_new(ny,nx) = gpt_min(ny,nx) * lm(ny,nx)
        end do
    end do


    ; Now write out this file
    print("reading file in...")
    
    cdf_out = addfile(fileout1,"w")
    print("file read in")

    cdf_out ->PHIS      = (/gpt_new/)

    delete(cdf_out)
end do
end
