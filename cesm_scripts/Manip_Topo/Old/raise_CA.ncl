load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

startnlon = 103
endnlon = 113
startnlat = 51
endnlat = 57

endnlat2 = 54
endnlon2 = 113


gpt_fac = 5.0 
sgh_fac = 5.0 
sgh30_fac = 5.0

newfile1 = "bothalb.cam2.r.0150-01-01-00000.nc"
newfile2 = "bothalb.cam2.h0.0149-12.nc"
diro = "/home/disk/eos4/rachel/inputdata/som/restart/newtopo/"

filenameout = diro + newfile1
filenameout2 = diro + newfile2


filenamein = filenameout

print("reading file in...")
  cdf_file = addfile(filenamein,"r")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30

gpt_new = gpt
sgh_new = sgh
sgh30_new = sgh30

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

do ny = startnlat,endnlat
	do nx = startnlon,endnlon

		if ny .LT. endnlat2 .AND. nx .LT. endnlon2 then
			gpt_new(ny,nx) = gpt_fac * gpt(ny,nx) * 3.0
		else
			gpt_new(ny,nx) = gpt_fac * gpt(ny,nx)
		end if


		if (gpt_new(ny,nx) .GT. 15000.0) then
			gpt_new(ny,nx) = 15000.0
		end if
	end do

end do

print("reading file in...")
  cdf_out = addfile(filenameout,"w")
print("file read in")

cdf_out ->PHIS      = (/gpt_new/)
delete(cdf_out)

cdf_out = addfile(filenameout2,"w")
print("file read in")

PHISnew = cdf_out ->PHIS

ndims = dimsizes(PHISnew)
ntimes = ndims(0)

do nt = 0,ntimes-1
	PHISnew = tofloat(gpt_new)
end do

cdf_out ->PHIS      = (/PHISnew/)

end