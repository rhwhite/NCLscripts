load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

file1 = "CESMSOM4topof19g16.cam2.h0.0169-12.nc"
file2 = "CESMSOM4topof19g16.cam2.r.0170-01-01-00000.nc"

diro = "/home/disk/eos4/rachel/inputdata/som/restart/notopo/"

system("cp " + diro + file1 + " " + diro + "Orig_" + file1)
system("cp " + diro + file2 + " " + diro + "Orig_" + file2)

fileout1 = diro + file1
fileout2 = diro + file2

filenamein = diro + file1

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS(0,:,:)
lm = cdf_file->LANDFRAC(0,:,:)

filenamein2 = diro + file2

print("reading file in...")
  cdf_file = addfile(filenamein2,"r")
print("file read in")

sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

print(dimsizes(sgh))

gpt_new = gpt
sgh_new = sgh
sgh30_new = sgh30

printVarSummary(sgh)

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

do ny=0,numlats-1
	do nx = 0,numlons-1
			gpt_new(ny,nx) = gpt_min * lm(ny,nx)
			sgh_new(ny,nx) = sgh_min * lm(ny,nx)
			sgh30_new(ny,nx) = sgh30_min * lm(ny,nx)	
	end do
end do


print("reading file in...")
  cdf_out = addfile(fileout1,"w")
print("file read in")

cdf_out ->PHIS(0,:,:)      = (/gpt_new/)
delete(cdf_out)

print("reading file in...")
  cdf_out = addfile(fileout2,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
cdf_out ->SGH     = (/sgh_new/)
cdf_out ->SGH30     = (/sgh30_new/)

delete(cdf_out)

end
