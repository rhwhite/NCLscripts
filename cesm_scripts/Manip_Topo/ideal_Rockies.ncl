load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

midlat = 40.0 ; 37.5 is mid-Rockies
midlon = 260.0 ; 250.0 is mid-Rockies for now

rotation = 0.0 ; 0.0 is test

length = 4500 ; km 
width = 2250 ; km 


Rearth = 6371 ; in km

pi = 4.*atan(1.0)
print(pi)

rotrads = (rotation/180.0) * pi
pi2 = 0.5 * pi

print(rotrads)

Topo_max = 2000.0 * 9.8 ; m
gpt_min = 490 ;50m
sgh_max = 400.0 ; half roughness of large Tibet
sgh30_max = 150.0; half roughness of large Tibet

newfile = "IdealGauss_Rockies_" + tostring_with_format(midlat,"%3.1f") + "_" + tostring_with_format(rotation,"%3.1f") + "deg_USGS-gtopo30_1.9x2.5_remap_c050602.nc"
diro = "/home/disk/eos4/rachel/inputdata/topo/"

origfile = "NoNAmMount_USGS-gtopo30_1.9x2.5_remap_c050602.nc"


system("cp " + diro + origfile + " " + diro + newfile)

filenameout = "/home/disk/eos4/rachel/inputdata/topo/" + newfile


nl = integertochar(10)  ; newline character

print("reading file in...")
  cdf_file = addfile(filenameout,"w")
print("file read in")

gpt = cdf_file->PHIS
sgh = cdf_file->SGH
sgh30 = cdf_file->SGH30
lm = cdf_file->LANDFRAC
lats = cdf_file->lat
lons = cdf_file->lon

print(dimsizes(gpt))
dims1 = dimsizes(gpt)
numlats = dims1(0)
numlons = dims1(1)
print(numlats)
print(numlons)

globalAtt             = True

  globalAtt@history     = nl+\
      systemfunc("date") + ": ncl ideal_rockies.ncl."+nl+\
	"Original file: " + origfile +nl+\
	"Mid-point i: " + midlon + " degrees E " +nl+\
	"Mid-point j: " + midlat + " degrees N " +nl+\  
	"Rotation: " + rotation + " degrees" +nl+\
	"Width: " + width + " degrees " +nl+\
	"Length: " + length + " degrees "

  fileattdef(cdf_file, globalAtt )

; find midi and midj

do ny = 0,numlats -2
        if (lats(ny) .LE. midlat .AND. lats(ny+1) .GT. midlat)
                midj = ny
        end if
end do

do nx = 0,numlons -2
        if (lons(nx) .LE. midlon .AND. lons(nx+1) .GT. midlon)
                midi = nx
        end if
end do

; find lat and lon width

latsize = abs(lats(midj) - lats(midj+1)) * Rearth * pi / 180.0
lonsize = abs(lons(midi) - lons(midi+1)) * Rearth * pi * cos(lats(midj) * pi/180.0) / 180.0

print(abs(lats(midj) - lats(midj+1)))
print(latsize)
print(lonsize)

igrids = round(length/lonsize,3)
if ((igrids % 2) .ne. 0) then
	igrids = igrids + 1
end if
jgrids = round(width/latsize,3)
if ((jgrids % 2) .ne. 0) then
	jgrids = jgrids + 1
end if

; find starti and startj

starti = midi - round(igrids/2.0,3)
startj = midj - round(jgrids/2.0,3)

rotdiffi = min((/jgrids * cos(rotrads + pi2), igrids * cos(rotrads) + jgrids * cos(rotrads + pi2), jgrids * cos(rotrads),0/))
rotdiff2i = max((/jgrids * cos(rotrads + pi2), igrids * cos(rotrads) + jgrids * cos(rotrads + pi2), jgrids * cos(rotrads),0/))

rotstarti = toint(starti + floor(rotdiffi))
rotendi = toint(starti + ceil(rotdiff2i))

rotdiffj = min((/jgrids * sin(rotrads + pi2), igrids * sin(rotrads) + jgrids * sin(rotrads + pi2), jgrids * sin(rotrads),0/))

rotdiff2j = max((/jgrids * sin(rotrads + pi2), igrids * sin(rotrads) + jgrids * sin(rotrads + pi2), jgrids * sin(rotrads),0/))

rotstartj = toint(startj + floor(rotdiffj))
rotendj = toint(startj + ceil(rotdiff2j))

ihalf = toint((rotstarti + rotendi)*0.5)
jhalf = toint((rotstartj + rotendj)*0.5)


; create normal distrbution with 300 bins

nbins = 600

opt = True
opt@npts = nbins
nd = genNormalDist(1,1,opt)

nd = nd / sum(nd)

dims = dimsizes(nd)
print(dims)

ndcdf = new(dims,double)
ndcdf(0) = nd(0)

do nn = 1,dims-1
        ndcdf(nn) = ndcdf(nn-1) + nd(nn)
end do

;now take values at equal spacings:

spacinglength = (nbins/toint(igrids/2))
spacingwidth = (nbins/toint(jgrids/2))

weightslons = new(igrids,double)
weightslats = new(jgrids,double)

do ii = 0,toint(igrids/2)-1
        weightslons(ii) = ndcdf(ii * spacinglength)
        weightslons(igrids-1-ii) = ndcdf(ii * spacinglength)
end do

do ii = 0,toint(jgrids/2)-1
        weightslats(ii) = ndcdf(ii * spacingwidth)
        weightslats(jgrids-1-ii) = ndcdf(ii * spacingwidth)
end do

mult = new((/igrids,jgrids/),double)

do ii = 0,igrids-1
        do jj = 0,jgrids-1
                mult(ii,jj) = (weightslons(ii) * weightslats(jj))
        end do
end do

;print(mult)



do nx=rotstarti,rotendi+1
       print(nx)
	 do ny = rotstartj,rotendj+1
		a = nx - starti
		b = ny - startj
		if (a .eq. 0) then
			xx = sqrt(a^2 + b^2) * cos (tofloat(pi2) - tofloat(rotrads))
			yy = sqrt(a^2 + b^2) * sin (tofloat(pi2) - tofloat(rotrads))	
		else if (b .eq. 0) then
                        xx = sqrt(a^2 + b^2) * cos (tofloat(pi) - tofloat(rotrads))
                        yy = sqrt(a^2 + b^2) * sin (tofloat(pi) - tofloat(rotrads))
		else		
			angle = (atan(tofloat(b)/tofloat(a)))	
			if (angle .lt. 0) then
				xx = sqrt(a^2 + b^2) * cos (pi + atan(tofloat(b)/tofloat(a)) - rotrads)
				yy = sqrt(a^2 + b^2) * sin (pi + atan(tofloat(b)/tofloat(a)) - rotrads) 
			else
                                xx = sqrt(a^2 + b^2) * cos (atan(tofloat(b)/tofloat(a)) - rotrads)
                                yy = sqrt(a^2 + b^2) * sin (atan(tofloat(b)/tofloat(a)) - rotrads)
			end if
		end if			
		end if
	
		x1 = (floor(xx))
		x2 = x1 + 1
		y1 = (floor(yy))
		y2 = y1 + 1

		if (x1 .ge. 0 .and. x2 .lt. igrids .and. y1 .ge. 0 .and. y2 .lt. jgrids) then
			R1 = (x2-xx) * (y2-yy) * mult(toint(x1),toint(y1))
			R2 = (xx-x1) * (y2-yy) * mult(toint(x2),toint(y1))
			R3 = (x2-xx) * (yy-y1) * mult(toint(x1),toint(y2))
			R4 = (xx-x1) * (yy-y1) * mult(toint(x2),toint(y2))			

			R = R1 + R2 + R3 + R4

			gpt(ny,nx) = gpt(ny,nx) * (1.0 - R) + (Topo_max * R)
			sgh(ny,nx) = sgh(ny,nx) * (1.0 - R) + (sgh_max * R)
			sgh30(ny,nx) = sgh30(ny,nx) * (1.0 - R) + (sgh30_max * R)
		end if
        end do
end do


cdf_file ->PHIS      = (/gpt/)
cdf_file ->SGH     = (/sgh/)
cdf_file ->SGH30     = (/sgh30/)

end
