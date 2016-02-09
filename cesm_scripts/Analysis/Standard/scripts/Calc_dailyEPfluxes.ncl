load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; Calculated EP fluxes from climatological (seasonal) mean
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates
; Plots the EP Flux vectors in a latitude-log(pressure) coordinate
; plot the divergence of EP-Flux

begin

; Get experiment names

print("Calc EP fluxes from daily")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_ARG_" + tostring(3+ne))
end do

startyr = toint(getenv("NCL_ARG_" + tostring(3+nexps)))
endyr = toint(getenv("NCL_ARG_" + tostring(4+nexps)))
secs = getenv("NCL_ARG_" + tostring(5+nexps))

nyears = endyr-startyr+1

lonstart = toint(getenv("NCL_ARG_lonstart"))
lonend = toint(getenv("NCL_ARG_lonend"))

timespan = "DJF"

a = 6.37122e06	; radius of Earth
print(a)
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
P0 = 1000.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment = Experiments(exps)
	Dir = (Direc + Experiment + "/atm/hist/")
	print(Experiment)

	filenameCLIM = Dir + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_Xpl_" + Experiment + ".cam2.h0.nc"
	; open file with seasonal averages
	fileCLIM = addfile(filenameCLIM,"r")

	levelCLIM = fileCLIM->lev_p
	nlevels2 = filevardimsizes(fileCLIM,"lev_p")

	nlat = filevardimsizes(fileCLIM,"lat")
	nlon = filevardimsizes(fileCLIM,"lon")

	lat = tofloat(fileCLIM->lat)
	lat!0="lat"
	lon = tofloat(fileCLIM->lon)
	lon!0="lon"

	; find lonstart and lonend
	print(lon)
	idxlonstart = 0
	idxlonend = nlon-1

	do ilon = 0,nlon-2
		print(lon(ilon))
		print(lonstart)
		if (lon(ilon) .LE. lonstart .AND. lon(ilon+1) .GT. lonstart) then
			idxlonstart = ilon
			break
		end if
	end do
	do ilon = 0,nlon-2
		if (lon(ilon) .LE. lonend .AND. lon(ilon+1) .GT. lonend) then
			idxlonend = ilon
			break
		end if
	end do

	print(lonstart)
	print(idxlonstart)
	print(lonend)
	print(idxlonend)

	T = fileCLIM->T(:,:,:,idxlonstart:idxlonend)

        ; Calculate potential temperature
        THETA = T
        THETA = T * (conform(T,levelCLIM,1)/1000.0)^(-1.0 * kappa)
        THETAzm = dim_avg_Wrap(THETA)
        ; Calculate d(THETA)/dp from vertical finite differences in log-pressure coordinates
        ; noting that dT/dp = (1/p) * dT/d(lnp)
        loglevel = log(levelCLIM)

        THETAp = center_finite_diff_n(THETAzm(time|:,lev_p|:,lat|:),loglevel,False,0,1) ; derivative in log coords doesn't care whether in Pa or in mb.
        ; named subscripting reorders the dimensions
        THETAp = THETAp / conform(THETAp,100.0 * levelCLIM,1) ; converts "level" to pascals from millibars while dividing by pressure.
        copy_VarMeta(THETAzm,THETAp)

        THETAp!2="lat"

        THETAptm = dim_avg_n_Wrap(THETAp(time|:,lev_p|:,lat|:),0)       ; time mean of THETAp

	ndims = dimsizes(THETAp)
	print(ndims)

	UVzmDJF = new((/90*nyears,ndims(1),ndims(2)/),typeof(THETAptm))
	VTHETAzmDJF = new((/90*nyears,ndims(1),ndims(2)/),typeof(THETAptm))

	countidx = 0


	do iyear = startyr,endyr
                if iyear .LT. 10
                        syear = "0" + tostring(iyear)
                else
                        syear = tostring(iyear)
                end if

		filename = Dir + "Daily_mean_yr" + syear + "_Xpl_" + Experiment + ".cam2.h2.nc"

		fileDAY = addfile(filename,"r")

		; get pressure levels

		date = fileDAY->date
		level = fileDAY->lev_p		; in hpa
		level!0="lev_p"
		levsizes = dimsizes(level)
		nlevels = filevardimsizes(fileDAY,"lev_p")
		
		ntimes = filevardimsizes(fileDAY,"date")

		if (nlevels .NE. nlevels2) then
			print(nlevels)
			print(nlevels2)
			exit
		end if

		do ilev=0,nlevels-1
			if (level(ilev) .NE. levelCLIM(ilev)) then
				print("levels not equal")
				print(level(ilev))
				print(levelCLIM(ilev))
				exit
			end if
		end do

		nlatDAY = filevardimsizes(fileDAY,"lat")
		nlonDAY = filevardimsizes(fileDAY,"lon")

		if (nlat .NE. nlatDAY) then
			print("lats not equal!")
		end if
		if (nlon .NE. nlonDAY) then
			print("lons not equal!")
		end if

		UV = fileDAY->UV(:,:,:,idxlonstart:idxlonend)
		VTHETA = fileDAY->VTHETA(:,:,:,idxlonstart:idxlonend)


        	UVzm = dim_avg_n_Wrap(UV(time|:,lev_p|:,lat|:,lon|:),3) ; averages over longitude dimension
                VTHETAzm = dim_avg_n_Wrap(VTHETA(time|:,lev_p|:,lat|:,lon|:),3)
 
		do itime = 0,ntimes-1
			datenow = date(itime)

			temp = datenow - (iyear * 10000)
			month = floor(temp/100.0)

			if (month .EQ. 1 .OR. month .EQ. 2 .OR. month .EQ. 12) then
				UVzmDJF(countidx,:,:) = UVzm(itime,:,:)
                                VTHETAzmDJF(countidx,:,:) = VTHETAzm(itime,:,:)
				countidx = countidx + 1
			end if
		end do

	end do

	print(countidx)
	if(countidx .NE. 90*nyears) then
		print(90*nyears)
		print(countidx)
		exit
	end if

	UVzmtm = dim_avg_n_Wrap(UVzmDJF(time|:,lev_p|:,lat|:),0)   ; average over time dimension
	VTHETAzmtm = dim_avg_n_Wrap(VTHETAzmDJF(time|:,lev_p|:,lat|:),0)   ; average over time dimension


        phi = lat*PI/180.0      ; Get latitude in radians
        cphi = cos(phi)
	sphi = sin(phi)
        acphi = a * cos(phi)
        asphi = a * sin(phi)
        f = 2*omega*sin(phi)

        Fphi = -UVzmtm*conform(UVzmtm,acphi,1)
        Fx = -UVzmtm
	Fphicphi = Fphi * conform(Fphi,cphi,1)
        Fp = conform(VTHETAzmtm,f*acphi,1) * VTHETAzmtm/THETAptm
	Fpxy = conform(VTHETAzmtm,f,1) * VTHETAzmtm/THETAptm

	
	print(level)
	print(P0)
	Fphi = (1.0 / P0) * conform(Fphi,level,0) * Fphi
	Fp = (1.0/P0) * conform(Fphi,level,0) * Fp

        copy_VarMeta(UVzmtm,Fphi)
        copy_VarMeta(VTHETAzmtm,Fp)

; take derivative with respect to latitude using 1/[a cos(phi)] d/dphi [cos(phi)*X] = d/d[asin(phi)] (cos(phi) * X)

        Fphicphi = Fphi * conform(Fphi,cphi,1)
        copy_VarMeta(Fphi,Fphicphi)

	EPdiv1 = center_finite_diff_n(Fphicphi(lev_p|:,lat|:),phi,False,0,1)/conform(Fphicphi,acphi,1)

; take derivate with respect to pressure
; Pressure in pascals
	EPdiv2 = center_finite_diff_n(Fp(lev_p|:,lat|:),level*100.0,False,0,0)  ; Convert to pa from hpa

; Add together derivative components
	EPdiv = EPdiv1 + EPdiv2

        Fp&lat = lat
        Fp&lev_p = level

        copy_VarMeta(Fp,EPdiv)

        copy_VarMeta(Fp,Fphi)


; Put onto equally space log-pressure levels

	level_int = 10^fspan(1,3,15)   ; interpolation targets
	level_int!0 = "lev_int"

	nlev_int = dimsizes(level_int)
	linlog=2                       ; Option to int2p that gives log-interpolation with no extrapolation
	Fp_int = int2p_n_Wrap(level,Fp(lev_p|:,lat|:),level_int,linlog,0)
	Fphi_int = int2p_n_Wrap(level,Fphi(lev_p|:,lat|:),level_int,linlog,0)
        EPdiv_int = int2p_n_Wrap(level,EPdiv(lev_p|:,lat|:),level_int,linlog,0)


	Fp_int!0 = "lev_int"
	Fp_int&lev_int = level_int
        Fphi_int!0 = "lev_int"
        Fphi_int&lev_int = level_int
        EPdiv_int!0 = "lev_int"
        EPdiv_int&lev_int = level_int


;-----------------------------------------------------------------------

	filo = "EPfluxes_Daily_" + timespan + tostring(startyr) + "_" + tostring(nyears) + "_" + tostring(lonstart) + "E-" + tostring(lonend) + "E_" + Experiment + ".cam2.h0.nc"
	system("/bin/rm -f " + Dir + filo)
	fout_std = addfile(Dir + filo, "c")

	setfileoption(fout_std,"DefineMode",True)

;set attributes of output file
	fAtt = True
	fAtt@creation_date = systemfunc("date")
	fileattdef(fout_std,fAtt)
	
;set dimensions of output file
	dimNames = (/"lat","lev_p","lev_int"/)
	dimSizes = (/nlat,nlevels,nlev_int/)
	dimUnlim = (/False,False,False/)
	filedimdef(fout_std,dimNames,dimSizes,dimUnlim)

	filevardef(fout_std,"lat",typeof(lat),getvardims(lat))
	filevardef(fout_std,"level",typeof(level),getvardims(level))
        filevardef(fout_std,"level_int",typeof(level_int),getvardims(level_int))

	
	filevardef(fout_std,"Fphi",typeof(Fphi),getvardims(Fphi))
        filevardef(fout_std,"Fp",typeof(Fp),getvardims(Fp))

        filevardef(fout_std,"EPdiv",typeof(EPdiv),getvardims(EPdiv))

        filevardef(fout_std,"Fphi_int",typeof(Fphi_int),getvardims(Fphi_int))
        filevardef(fout_std,"Fp_int",typeof(Fp_int),getvardims(Fp_int))
        filevardef(fout_std,"EPdiv_int",typeof(EPdiv_int),getvardims(EPdiv_int))

	fout_std->lat = (/lat/)
	fout_std->level = level
	fout_std->Fphi = Fphi
	fout_std->Fp = Fp
	fout_std->EPdiv = EPdiv
        
	fout_std->level_int = level_int
        fout_std->Fphi_int = Fphi_int
        fout_std->Fp_int = Fp_int
	fout_std->EPdiv_int = EPdiv_int

	print("printed it")

end do

end
