load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startlon = 72.0
endlon = 152.5
startlat = 44.0
endlat = 54.0

gpt_min = 490 ;50m
aps_min = 100000.0 ; based on point at i = 38, j = 17
oromea_min = 50.0
aps_max = 101117


orosig_min = 0.0005
oropic_min = 130
oroval_min = 60

max_red = 0.1
max_red2 = 0.95

filein = "T63GR15_jan_surf.nc"
;filein = "b40.1850.track1.1deg.006.cam2.r.0863-01-01-00000.nc"

diro = "/home/disk/eos4/rachel/inputdata/ECHAM/LR/echam6/T63/"

fraction = 1.0

filein = "NoMongolia_T63GR15_jan_surf.nc"
fileout = "rerun_ECHAM6_LR_MLO_NoMSU_echam"
fileoutS = "rerun_ECHAM6_LR_MLO_NoMSU_surf"

diri = "/home/disk/eos4/rachel/inputdata/ECHAM/LR/echam6/T63/" 
diro = "/home/disk/eos4/rachel/MPIESM/ECHAM6.1/outfiles/ECHAM6_LR_MLO_NoMSU/"

system("cp " + diro +  fileout + " " + diro + fileout + "_origbackup")
system("cp " + diro +  fileoutS + " " + diro + fileoutS + "_origbackup")


filenameout = diro + fileout
filenameoutS = diro + fileoutS

filenamein = diri + filein

print("reading file in...")
print(filenamein)
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt_new = cdf_file->GEOSP
oromea_new = cdf_file->GEOSP / 9.81
az0_new = cdf_file->AZ0
lm = cdf_file->SLM

az0l_new = az0_new
az0l_new = where(lm .EQ. 0,0.0,az0_new)

print("reading file in...")
print(filenameout)
  cdf_out = addfile(filenameout,"w")
  cdf_outS = addfile(filenameoutS,"w")

print("file read in")

cdf_out ->geosp      = fraction * gpt_new + ((1.0 - fraction) * cdf_out->geosp)
cdf_out ->oromea     = fraction * oromea_new + ((1.0 - fraction) * cdf_out->oromea)
cdf_out ->az0	     = fraction * az0_new + ((1.0-fraction) * cdf_out->az0)
cdf_out ->az0l       = fraction * az0l_new + ((1.0-fraction) * cdf_out->az0l)

cdf_outS ->az0        = fraction * az0_new + ((1.0-fraction) * cdf_out->az0)
cdf_outS ->az0lm       = fraction * az0l_new + ((1.0-fraction) * cdf_out->az0l)


delete(cdf_out)



end
