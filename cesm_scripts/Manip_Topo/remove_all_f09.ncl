load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

gpt_min = 490 ;50m
sgh_min = 30 ; roughness of flat russia/flat america
sgh30_min = 10; roughness of flat russia/flat america

filein = "USGS-gtopo30_0.9x1.25_remap_c051027.nc"

newfile = "NoTopo_" + filein

diro = "/home/disk/eos4/rachel/inputdata/topo/"

system("cp " + diro +  filein + " " + diro + newfile)

filenameout = diro + newfile

filenamein = diro + filein

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC

lats = cdf_file->lat
lons = cdf_file->lon

gpt_new = gpt
sgh_new = sgh
sgh30_new = sgh30

dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)


; main region
do ny = 0,numlats-1
	do nx = 0,numlons - 1
		if (lm(ny,nx) .gt. 0)
			f = (/gpt_min,gpt_new(ny,nx)/)
			gpt_new(ny,nx) = min(f) * lm(ny,nx)
			f2 = (/sgh_min,sgh_new(ny,nx)/)
			sgh_new(ny,nx) = min(f2) * lm(ny,nx)
			f3 = (/sgh30_min,sgh30_new(ny,nx)/)
			sgh30_new(ny,nx) = min(f3) * lm(ny,nx)		
		else
            gpt_new(ny,nx) = 0
            sgh_new(ny,nx) = 0
            sgh30_new(ny,nx) = 0
		end if
	end do
end do

print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")
print(filenameout)

cdf_out->PHIS      = (/gpt_new/)
cdf_out->SGH     = (/sgh_new/)
cdf_out->SGH30     = (/sgh30_new/)

print("written")
delete(cdf_out)

end


