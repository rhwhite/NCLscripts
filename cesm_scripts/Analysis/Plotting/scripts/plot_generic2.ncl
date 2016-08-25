load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; set some defaults
diffdiffs = "false" ;;!!!!!! diffdiffs=.true. no longer an option!
linear = "false"
nonlinplot = 1.0 ; factor for colorbar for non-linear plot
varswitch = 0
papertitles = getenv("NCLplottitles")
LineColors = (/"blue","red","green","cyan","black","yellow"/)
overplot = 1
justblue = getenv("NCLallblue")
print(justblue)
vmagnitude = 5
vmax = 2
vspacing = 0.2
minmag = 1.0


Rair = 287.0
pi = 3.14159

rho = 1.000e3	; from CAM shr model, density in kg/m3 
LHev = 2.501e6 	; from CAM shr model, in J/kg

index = 1
numvars = toint(getenv("NCLnumvars"))
difexps = toint(getenv("NCLdifexps"))
expdif = toint(getenv("NCLexpdif"))
figtitle = getenv("NCLfigtit")
nexps = toint(getenv("NCLnumexps"))
dir = getenv("NCLdir1")

if nexps .EQ. 1 .AND. numvars .GT. 1 then
	varswitch = 1
else if difexps .EQ. 1 then
	varswitch = 1
end if
end if

; find number of columns:
if (difexps .EQ. 0) then
	numcols = numvars
	numrows = nexps
else if (difexps .EQ. 1) then
	if (numvars .EQ. 1) then
		numcols = 2
		numrows = nexps
	else
		numcols = numvars
		numrows = 1
		nexps = 1	; shift back to printing one experiment per variable
	end if
else
	print("difexps should be 0 or 1")
	exit
end if
end if

; Allow difexps to plto one column, but with different experiments for different variables - specifically for figure 4 for Mongolia paper

nrows = nexps

Experiments = new((/numcols,nrows/),"string")
Titles = new((/numcols,nrows/),"string")
ExpCTLs = new((/numcols,nrows/),"integer")
startyrs = new((/numcols,nrows/),"integer")
nyears = new((/numcols,nrows/),"integer")
timespans = new((/numcols,nrows/),"string")
reverses = new((/numcols,nrows/),"string")
plotERA = new((/numcols/),"integer")


index = 1
plotERA(0) = toint(getenv("NCLplotERA1"))
do ne = 0,nexps-1
	Experiments(0,ne) = getenv("NCLexps1_" + tostring(index))
	Titles(0,ne) = getenv("NCLtitles1_" + tostring(index))
	ExpCTLs(0,ne) = toint(getenv("NCLCTLs1_" + tostring(index)))
	startyrs(0,ne) = toint(getenv("NCLstarts1_" + tostring(index)))
	nyears(0,ne) = toint(getenv("NCLnyears1_" + tostring(index)))
        timespans(0,ne) = (getenv("NCLtimespans1_" + tostring(index)))
	reverses(0,ne) = (getenv("NCLreverses1_" + tostring(index)))

	index = index+ 1
end do
print(Titles)
if (numcols .GT. 1) then
	if (difexps .EQ. 0) then
		do ncol = 1,numcols-1
			plotERA(ncol) = plotERA(0)
			Experiments(ncol,:) = Experiments(0,:)
			Titles(ncol,:) = Titles(0,:)
			ExpCTLs(ncol,:) = ExpCTLs(0,:)
			startyrs(ncol,:) = startyrs(0,:)
			nyears(ncol,:) = nyears(0,:)
			timespans(ncol,:) = timespans(0,:)
			reverses(ncol,:) = reverses(0,:)
		end do
	else
		index = 1
		do ne = 0,numvars-1

                        plotERA(ne) = plotERA(0)
			Experiments(ne,:) = getenv("NCLexps1_" + tostring(index))
			Titles(ne,:) = getenv("NCLtitles1_" + tostring(index))
			ExpCTLs(ne,:) = toint(getenv("NCLCTLs1_" + tostring(index)))
			startyrs(ne,:) = toint(getenv("NCLstarts1_" + tostring(index)))
			nyears(ne,:) = toint(getenv("NCLnyears1_" + tostring(index)))
			timespans(ne,:) = (getenv("NCLtimespans1_" + tostring(index)))
			reverses(ne,:) = (getenv("NCLreverses1_" + tostring(index)))

			index = index+ 1
		end do 

	end if
end if

print(Titles)
linear = getenv("NCLlinear")
clon = toint(getenv("NCLclon"))
slon = toint(getenv("NCLslon"))
elon = toint(getenv("NCLelon"))
slat = toint(getenv("NCLslat"))
elat = toint(getenv("NCLelat"))
plottype = getenv("NCLplottype")
plotctl = toint(getenv("NCLplotctl"))
titleprefix = getenv("NCLtitleprefix")

latratio = (tofloat(elon)-tofloat(slon))/(tofloat(elat)-tofloat(slat))


if (slat .GT. 1000) then
	polar = "true"
else
	polar = "false"
end if

vars = new((/numrows,numcols/),"string")
ilevs = new((/numrows,numcols/),"integer")
vartitles = new((/numrows,numcols/),"string")
plotmins = new((/numrows,numcols,2/),"float")
plotmaxs = new((/numrows,numcols,2/),"float")
plotdifs = new((/numrows,numcols,2/),"float")
units = new((/numrows,numcols/),"string")

do ii = 0,numvars-1
	vars(:,ii) = getenv("NCLplotvar_" + tostring(ii+1))
	ilevs(:,ii) = toint(getenv("NCLilev_" + tostring(ii+1)))
	vartitles(:,ii) = getenv("NCLvartitle_" + tostring(ii+1))
	do xx = 0,1
		plotmins(:,ii,xx) = tofloat(getenv("NCLmin" + tostring(xx+1) + "_" + tostring(ii+1)))
		plotmaxs(:,ii,xx) = tofloat(getenv("NCLmax" + tostring(xx+1) + "_" + tostring(ii+1)))
		plotdifs(:,ii,xx) = tofloat(getenv("NCLdiffs" + tostring(xx+1) + "_" + tostring(ii+1)))
	end do

	units(:,ii) = getenv("NCLunits_" + tostring(ii+1))
end do

;if (numvars .EQ. 1 .AND. numcols .NE. 1) then
;        print("variable the same on each side of plot")
;
;	do ii = 1,numcols-1
;		vars(ii) = vars(0)
;		ilevs(ii) = ilevs(0)
;		vartitles(ii) = vartitles(0)
;		do xx = 0,1
;			plotmins(ii,xx) = plotmins(0,xx) 
;			plotmaxs(ii,xx) = plotmaxs(0,xx)
;			plotdifs(ii,xx) = plotdifs(0,xx)
;		end do
;		units(ii) = units(0)
;	end do
;else
;        print("variables different or only one column")
;        print("variables: " + vars)
;end if

blankcount = 0

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

plotfactor = new((/numrows,numcols/),"float")
plotfactor(:,:) = 1.0
do jj=0,numrows-1
	do ii=0,numcols-1
		if (vars(jj,ii) .EQ. "SFZA" .OR. vars(jj,ii) .EQ. "SF") then
			plotfactor(jj,ii) = 1.0e6
		else if (vars(jj,ii) .EQ. "PV") then
			plotfactor(jj,ii) = 1.0e-6
		else if (vars(jj,ii) .EQ. "dPVdy") then
			plotfactor(jj,ii) = 1.0e-12
		end if
		end if
		end if
	end do
end do

if (max(plotERA) .GT. 0) then
	Eplevs = new((/numcols/),integer)
	Eplevs(:) = -1
	
	do ic = 0,numcols-1

		if (plotERA(ic) .EQ. 1 .OR. plotERA(ic) .EQ. 2) then
			ilevsE = ilevs(0,:)

			; Read in ERA-I

			if (plotERA(ic) .EQ. 1) then
				fileObs = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_climfrommonthly_DJF_1979-2015.nc"
			else
				fileObs = "/home/disk/eos4/rachel/Obs/NCEP-NCAR/DJF_NCAR.nc"
			end if
			
			cdf_Obs = addfile(fileObs, "r")

			latsE = cdf_Obs->latitude
			lonsE = cdf_Obs->longitude
			
			nlatsE = dimsizes(latsE)
			nlonsE = dimsizes(lonsE)

			fliplat = 0
			if (latsE(0) .GT. latsE(nlatsE-1)) then
				fliplat = 1
				latsE = latsE(::-1) ; flip latitudes
			end if

			print(fliplat)

			levelsE = cdf_Obs->level
			; Find level
			nlevsE = dimsizes(levelsE)

			Etemp = cdf_Obs->u

			if (ilevsE(ic) .NE. 0) then
			; Find correct pressure level

				do nl = 0,nlevsE-1
					if levelsE(nl) .EQ. ilevsE(ic) then
						Eplevs(ic) = nl
					end if
				end do

				if (Eplevs(ic) .LT. 0)
					print("didnt find a level")
					print(ilevE(ic))
					exit
				end if
			end if
		end if
	end do
        E_plotvar = new((/numcols,nlatsE,nlonsE/),typeof(Etemp))

	do ic = 0,numcols-1
                if (plotERA(ic) .EQ. 1 .OR. plotERA(ic) .EQ. 2) then

			variable = vars(0,ic)
			print(variable)
			ilev = ilevsE(ic)

			if (variable .EQ. "U") then
				print("reading ERA U")
				E_plotvar(ic,:,:) = tofloat(cdf_Obs->u(0,Eplevs(ic),:,:))
				if (fliplat .EQ. 1) then 
					E_plotvar(ic,:,:) = E_plotvar(ic,::-1,:)
				end if
			else if (variable .EQ. "V") then
				E_plotvar(ic,:,:) = tofloat(cdf_Obs->v(0,Eplevs(ic),:,:))
				if (fliplat .EQ. 1) then 
					E_plotvar(ic,:,:) = E_plotvar(ic,::-1,:)
				end if
			else if (variable .EQ. "SFZA" .OR. variable .EQ. "SF") then

				SFtempE = new((/nlatsE,nlonsE/), typeof(Etemp))
				tempE = new((/nlatsE,nlonsE/),typeof(Etemp))
				E_U = tofloat(cdf_Obs->u(0,Eplevs(ic),:,:))
				E_V = tofloat(cdf_Obs->v(0,Eplevs(ic),:,:))
			
				if (fliplat .EQ. 1) then
					E_U(:,:) = E_U(::-1,:)
					E_V(:,:) = E_V(::-1,:)
				end if

				uv2sfvpf(E_U,E_V,SFtempE,tempE)

				if (variable .EQ. "SF") then
					E_plotvar(ic,:,:) = SFtempE
				else
					SFZM = dim_avg_n(SFtempE,1)
					do ix = 0,nlonsE-1
						E_plotvar(ic,:,ix) = SFtempE(:,ix) - SFZM
					end do
				delete(SFZM)

				end if
				delete(SFtempE)
				delete(tempE)
			else if (variable .EQ. "TH") then
				if (plotERA(ic) .EQ. 1) then
					E_plotvar(ic,:,:) = cdf_Obs->t(0,Eplevs(ic),:,:) * (1013.0/tofloat(levelsE(Eplevs(ic))))^(kappa)
				else
					E_plotvar(ic,:,:) = cdf_Obs->th(0,Eplevs(ic),:,:)
				end if
				if (fliplat .EQ. 1) then
					E_plotvar(ic,:,:) = E_plotvar(ic,::-1,:)
				end if


			else if (variable .EQ. "Zvar850") then
				if (plotERA(ic) .EQ. 1) then
					fileObs2 = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_Z850bpf_DJF_6hrly_1979_37.nc"
					cdf_Obs2 = addfile(fileObs2, "r")
					Zbpfvar = cdf_Obs2->Z850bpf_var
					if (fliplat .EQ. 1) then
						Zbpfvar(:,:) = Zbpfvar(::-1,:)
					end if
		
					E_plotvar(ic,:,:) = Zbpfvar
					delete(Zbpfvar)
				end if
			else if (variable .EQ. "Zvar250") then
	                        if (plotERA(ic) .EQ. 1) then
                                        fileObs2 = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_Z250bpf_DJF_6hrly_1979_37.nc"
                                        cdf_Obs2 = addfile(fileObs2, "r")
                                        Zbpfvar = cdf_Obs2->Z250bpf_var
                                        if (fliplat .EQ. 1) then
                                                Zbpfvar(:,:) = Zbpfvar(::-1,:)
                                        end if

                                        E_plotvar(ic,:,:) = Zbpfvar
                                        delete(Zbpfvar)
                                end if
			else if (variable .EQ. "PREC") then
				if (plotERA(ic) .EQ. 1) then
					fileObs2 = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_DJFclim_PRECIP_1979-2015.nc"
					cdf_Obs2 = addfile(fileObs2, "r")
					Precip = cdf_Obs2->tp(0,:,:)
					if (fliplat .EQ. 1) then
						Precip(:,:) = Precip(::-1,:)
					end if
					; Change units: read in in m/12-hrs
					; want to change to mm/day

					Precip = Precip * (2.0) * 1000.0 
					E_plotvar(ic,:,:) = Precip
					delete(Precip)
					delete(cdf_Obs2)
					delete(fileObs2)
				end if
			else if (variable .EQ. "PV") then
	       
				if (plotERA(ic) .EQ. 1) then
					PV = cdf_Obs->pv(0,Eplevs(ic),:,:)

					if (fliplat .EQ. 1) then
						PV(:,:) = PV(::-1,:)
					end if

				       E_plotvar(ic,:,:) = PV
					delete(PV)
				end if
			else if variable .EQ. "dPVdy" then
                                if (plotERA(ic) .EQ. 1) then
                                        PV = cdf_Obs->pv(0,Eplevs(ic),:,:)

                                        if (fliplat .EQ. 1) then
                                                PV(:,:) = PV(::-1,:)
                                        end if
	                                Elat_dist = tofloat(gc_latlon(latsE(0),lonsE(0),latsE(1),lonsE(0),2,3))
                                        E_plotvar(ic,:,:) = center_finite_diff_n(PV(:,:),Elat_dist, False, 0, 0)
                                        delete(PV)
                                end if
			else if (variable .EQ. "TdiaSRF") then
				E_plotvar(ic,:,:) = 0.0
			else if (variable .EQ. "Z") then
				E_plotvar(ic,:,:) = 0.0
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if	
			E_plotvar(ic,:,:) = E_plotvar(ic,:,:)/plotfactor(0,ic)
		end if
	end do
		
	E_plotvar!1 = "lat"
	E_plotvar!2 = "lon"

	E_plotvar&lat = latsE
	E_plotvar&lon = lonsE

	E_plotvar&lat@units="degree_north"
	E_plotvar&lon@units="degree_east"

end if

; Now go get experiment data
print(Experiments)
filo = Experiments(0,0) + "/atm/hist/" + timespans(0,0) + tostring(startyrs(0,0)) + "_" + tostring(nyears(0,0)) + "_mean_Xpl_" + Experiments(0,0) + ".cam2.h0.nc"
cdf_file = addfile(dir + filo, "r")

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

vartest = cdf_file->U

levs_mean = cdf_file->lev_p

levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

ndims2 = dimsizes(vartest)
PHIS = new((/numcols,nexps,nlats,nlons/),typeof(vartest))
PS = new((/numcols,nexps,nlats,nlons/),typeof(vartest))

if (plottype .EQ. "ZMline" .OR. plottype .EQ. "CSZ" .OR. plottype .EQ. "CSM") then
	; find correct lons
	do nl = 0,nlons-2
		if lons(nl) .LE. slon .AND. lons(nl+1) .GT. slon then
			nlonstart = nl
			print(nlonstart)
		end if
		if lons(nl) .LE. elon .AND. lons(nl+1) .GT. elon then
			nlonend = nl+1
			print(nlonend)
		end if
	end do
        do nl = 0,nlats-2
                if lats(nl) .LE. slat .AND. lats(nl+1) .GT. slat then
                        nlatstart = nl
                        print(nlatstart)
                end if
                if lats(nl) .LE. elat .AND. lats(nl+1) .GT. elat then
                        nlatend = nl+1
                        print(nlatend)
                end if
        end do
	if slat .EQ. -90.0
		nlatstart = 0
		slat = toint(lats(nlatstart))
	end if
	if elat .EQ. 90.0
		nlatend = nlats-1
		elat = toint(lats(nlatend))
	end if
end if

delete(cdf_file)

do iexp = 0,numrows-1
	do ic = 0,numcols-1
		print(iexp)
		print(ic)
		if (Experiments(ic,iexp) .EQ. "0") then
			PS(ic,iexp,:,:) = 10000.0
			PHIS(ic,iexp,:,:) = 10000.0
		else
			filo = Experiments(ic,iexp) + "/atm/hist/" + timespans(ic,iexp) + tostring(startyrs(ic,iexp)) + "_" + tostring(nyears(ic,iexp)) + "_mean_" + Experiments(ic,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir + filo, "r")

			PS(ic,iexp,:,:) = cdf_file->PS(0,:,:)
			PHIS(ic,iexp,:,:) = cdf_file->PHIS/9.8

			delete(cdf_file)
		end if
	end do
end do

; Find which variable is to be plotted


if (plottype .EQ. "CSM") then
	plotvar = new((/numcols,nexps,nlevs,nlats/),typeof(vartest))
else if (plottype .EQ. "CSZ") then
        plotvar = new((/numcols,nexps,nlevs,nlons/),typeof(vartest))
else
	plotvar = new((/numcols,nexps,nlats,nlons/),typeof(vartest))
	plotvar2 = new((/numcols,nexps,nlats,nlons/),typeof(vartest))
        plotvar3 = new((/numcols,nexps,nlats,nlons/),typeof(vartest))

end if
end if

do es = 0,numcols-1
	; set up some things that need to be defined for all rows
	; for these, assume all rows have the variable of the top row
	variable = vars(0,es)
	ilev = ilevs(0,es)
        var = new((/nexps,nlats,nlons/),typeof(vartest))

	if (variable .EQ. "vort" .OR. variable .EQ. "-DuDdTHdx" .OR. variable .EQ. "-dTHdy" .OR. variable .EQ. "-dTHdx" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-Tadv") then
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		U = new((/nexps,nlats,nlons/),typeof(vartest))
		V = new((/nexps,nlats,nlons/),typeof(vartest))

		dTHdy = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdx = new((/nexps,nlats,nlons/),typeof(vartest))

		vort = new((/nexps,nlats,nlons/),typeof(vartest))
	end if	



        do iexp = 0,numrows-1


		variable = vars(iexp,es)
		ilev = ilevs(iexp,es)

		if (plottype .EQ. "CSZ" .OR. plottype .EQ. "CSM") then
			print("cross-section")

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir + filo, "r")
                        filo2 = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file2 = addfile(dir + filo2, "r")

			levs_mean = cdf_file->lev_p
			PVlevs = levs_mean * 100.0
			PVlevs@units = "Pa"

			PVlats = cdf_file->lat
			
			T = cdf_file->T(0,:,:,:)
			TH = cdf_file->TH(0,:,:,:)

			U = cdf_file->U(0,:,:,:)
			V = cdf_file->V(0,:,:,:)
			OMEGA = cdf_file->OMEGA(0,:,:,:)

			PHIS(es,iexp,:,:) = cdf_file2->PHIS(0,:,:)
			PS(es,iexp,:,:) = cdf_file2->PS(0,:,:) / 100.0

			delete(cdf_file)
			delete(cdf_file2)

			gridtype = 1 ; regular grid
			opt = 0 ; just potential vorticity for now
			PV = pot_vort_isobaric(PVlevs,U,V,T,PVlats, gridtype, opt)


			do iy = 0,nlons-1
				do ix = 0,nlats-1
					do il = 0,nlevs -1
						if (PS(es,iexp,ix,iy) .LT. levs_mean(il)) then
							U(il,ix,iy) = U@_FillValue
                                                        V(il,ix,iy) = V@_FillValue
                                                        TH(il,ix,iy) = TH@_FillValue
                                                        OMEGA(il,ix,iy) = OMEGA@_FillValue
							PV(il,ix,iy) = PV@_FillValue
						end if
					end do
				end do
			end do


			if (plottype .EQ. "CSM") then
				if (variable .EQ. "U") then
					plotvar(es,iexp,:,:) = dim_avg_n(U(:,:,nlonstart:nlonend),2)
				else if (variable .EQ. "V") then
					plotvar(es,iexp,:,:) = dim_avg_n(V(:,:,nlonstart:nlonend),2)
				else if (variable .EQ. "OMEGA") then
					plotvar(es,iexp,:,:) = dim_avg_n(OMEGA(:,:,nlonstart:nlonend),2)
				else if (variable .EQ. "TH") then
					
					plotvar(es,iexp,:,:) = tofloat(dim_avg_n(TH(:,:,nlonstart:nlonend),2))
			
				else if (variable .EQ. "PV") then

					plotvar(es,iexp,:,:) = dim_avg_n(PV(:,:,nlonstart:nlonend),2)

				end if
				end if
				end if
				end if
				end if 
			else if (plottype .EQ. "CSZ") then
                                if (variable .EQ. "U") then
                                        plotvar(es,iexp,:,:) = dim_avg_n(U(:,nlatstart:nlatend,:),1)
                                else if (variable .EQ. "V") then
                                        plotvar(es,iexp,:,:) = dim_avg_n(V(:,nlatstart:nlatend,:),1)
                                else if (variable .EQ. "OMEGA") then
                                        plotvar(es,iexp,:,:) = dim_avg_n(OMEGA(:,nlatstart:nlatend,:),1)
                                else if (variable .EQ. "TH") then
                                        plotvar(es,iexp,:,:) = tofloat(dim_avg_n(TH(:,nlatstart:nlatend,:),1))
                                else if (variable .EQ. "PV") then

                                        plotvar(es,iexp,:,:) = dim_avg_n(PV(:,nlatstart:nlatend,:),1)

                                end if
                                end if
                                end if
                                end if
                                end if
			end if
			end if
		else

			if (variable .EQ. "U" .OR. variable .EQ. "V" .OR. variable .EQ. "OMEGA" .OR. variable .EQ. "dudz" .OR. variable .EQ. "SF" .OR. variable .EQ. "SFZA" .OR. variable .EQ. "UV" .OR. variable .EQ. "Z" .OR. variable .EQ. "WindShear") then
				if (Experiments(es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
					blankcount = blankcount + 1
				else

					filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
					cdf_file = addfile(dir + filo, "r")

					levs_mean2 = cdf_file->lev_p
					nlevs = dimsizes(levs_mean2)
					; Find correct pressure level
					plev = -1
					do nl = 0,nlevs-1
						if levs_mean2(nl) .EQ. ilev then
							plev = nl
						end if
					end do
					if (plev .LT. 0) then
						print("didnt find a level")
						exit
					end if


					; for SFZA at 250, also get TakNak fluxes for overplotting
					if variable .EQ. "SFZA" .AND. ilev .EQ. 250 then
						if iexp .EQ. 0 then
							plotvar2(es,iexp,:,:) = 0.0
							plotvar3(es,iexp,:,:) = 0.0
						else
							if reverses(es,iexp) .EQ. "false" then
	
								filein2 = Experiments(es,0) + "/atm/hist/TakNak01_fluxes_" + timespans(es,iexp) + "_" + Experiments(es,0) + "-" + Experiments(es,iexp) + ".nc"
								
								cdf_file2 = addfile(dir + filein2,"r")
							else
                                                                filein2 = Experiments(es,iexp) + "/atm/hist/TakNak01_fluxes_" + Experiments(es,iexp) + "-" + Experiments(es,0) + ".nc"
                                                                
                                                                cdf_file2 = addfile(dir + filein2,"r")
							end if

							TNlevels = cdf_file2->level
							TNnlevs = dimsizes(TNlevels)
							;get pressure level - don't assume it's the same as others!
							plevTN = -1
							do nl = 0,TNnlevs-1
								if TNlevels(nl) .EQ. ilev then
									plevTN = nl
								end if
							end do
							if (plevTN .LT. 0) then
								print("didnt find a level")
								exit
							end if
							print(cdf_file2->level(plevTN))

							plotvar2(es,iexp,:,:) = tofloat(cdf_file2->Fx(0,plevTN,:,:))
							plotvar3(es,iexp,:,:) =tofloat( cdf_file2->Fy(0,plevTN,:,:))
						end if
					end if
					if (variable .EQ. "SF" .OR. variable .EQ. "SFZA") then
						SFtemp = new((/nlats,nlons/), typeof(vartest))
						temp = new((/nlats,nlons/),typeof(vartest))
						uv2sfvpf(cdf_file->U(0,plev,:,:),cdf_file->V(0,plev,:,:),SFtemp,temp)

						if (variable .EQ. "SF") then
							plotvar(es,iexp,:,:) = SFtemp
						else
							SFZM = dim_avg_n(SFtemp,1)
							do ix = 0,nlons-1
								plotvar(es,iexp,:,ix) = SFtemp(:,ix) - SFZM
							end do

						end if

					else if (variable .EQ. "U") then
						plotvar(es,iexp,:,:) = cdf_file->U(0,plev,:,:)
					else if (variable .EQ. "V") then
						plotvar(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
					else if (variable .EQ. "dudz") then
						dudz = center_finite_diff_n(cdf_file->U(0,:,:,:),levs_mean,False,0,0)
						plotvar(es,iexp,:,:) = dudz(plev,:,:)
					else if (variable .EQ. "UV") then
						plotvar(es,iexp,:,:) = cdf_file->U(0,plev,:,:)
						plotvar2(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
					else if (variable .EQ. "OMEGA") then
						plotvar(es,iexp,:,:) = cdf_file->OMEGA(0,plev,:,:)
					else if (variable .EQ. "Z") then
						plotvar(es,iexp,:,:) = cdf_file->Z3(0,plev,:,:)
					else if (variable .EQ. "WindShear") then
                                                plev850 = -1
                                                plev250 = -1
                                                do nl = 0,nlevs-1
                                                        if levs_mean(nl) .EQ. 250 then
                                                                plev250 = nl
                                                        end if
                                                        if levs_mean(nl) .EQ. 850 then
                                                                plev850 = nl
                                                        end if
                                                end do
                                                if (plev250 .LT. 0 .OR. plev850 .LT. 0) then
                                                        print("didnt find a level")
                                                        exit
                                                end if
						plotvar(es,iexp,:,:) = cdf_file->U(0,plev250,:,:) - cdf_file->U(0,plev850,:,:)
					end if
					end if
					end if
					end if
					end if
					end if
					end if
					end if
					delete(cdf_file)
					delete(levs_mean2)
				end if

			else if (variable .EQ. "Tdia" .OR. variable .EQ. "DTCOND" .OR. variable .EQ. "DTV" .OR. variable .EQ. "QRL" .OR. variable .EQ. "QRS") then
				filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir + filo, "r")
				levs_mean = cdf_file->lev_p

				; Check levs
				if levs_mean(plev) .NE. ilev then
					print("should be " + tostring(ilev))
					exit
				end if

				if (variable .EQ. "Tdia") then
					plotvar(es,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) + cdf_file->DTV(0,plev,:,:) + cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)
				else if (variable .EQ. "DTCOND") then
					plotvar(es,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:)
				else if (variable .EQ. "QRL") then
					plotvar(es,iexp,:,:) = cdf_file->QRL(0,plev,:,:)
				else if (variable .EQ. "QRS") then
					plotvar(es,iexp,:,:) = cdf_file->QRS(0,plev,:,:)
				else if (variable .EQ. "DTV") then
					plotvar(es,iexp,:,:) = cdf_file->DTV(0,plev,:,:)
				end if
				end if
				end if
				end if
				end if

				delete(cdf_file)

			else if (variable .EQ. "TH") then

				filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir + filo, "r")

				levs_mean2 = cdf_file->lev_p
				nlevs = dimsizes(levs_mean2)
				; Find correct pressure level
				plev = -1
				do nl = 0,nlevs-1
					if levs_mean2(nl) .EQ. ilev then
						plev = nl
					end if
				end do
				if (plev .LT. 0) then
					print("didnt find a level")
					exit
				end if

				plotvar(es,iexp,:,:) = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

				delete(cdf_file)
				delete(levs_mean2)

			else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PREC" .OR. variable .EQ. "PmE" .OR. variable .EQ. "Topo" .OR. variable .EQ. "TdiaSRF" .OR. variable .EQ. "TradSRF" .OR. variable .EQ. "SHFLX" .OR. variable .EQ. "LHFLX" .OR. variable .EQ. "U10" .OR. variable .EQ. "EVAP" .OR. variable .EQ. "WScurl") then
			
				filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir + filo, "r")
				
				if (variable .EQ. "THS") then
					plotvar(es,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(es,iexp,:,:))^kappa)
				else if (variable .EQ. "PREC") then
					; change from m/sec to mm/day
					plotvar(es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
				else if (variable .EQ. "PmE") then
					EVAP = cdf_file->QFLX(0,:,:) / rho	; convert to m/s
					plotvar(es,iexp,:,:) = (cdf_file->PRECT(0,:,:) - EVAP) * secdays * 1000.0   ; convert to mm/day
				else if (variable .EQ. "EVAP") then
					plotvar(es,iexp,:,:) = cdf_file->QFLX(0,:,:) *secdays * 1000.0 / rho 	; convert to mm/day

				else if (variable .EQ. "TS") then
					plotvar(es,iexp,:,:) = cdf_file->TS(0,:,:)
				else if (variable .EQ. "TdiaSRF") then
					plotvar(es,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:) - cdf_file->SHFLX(0,:,:) - cdf_file->LHFLX(0,:,:)
				else if (variable .EQ. "TradSRF") then
					plotvar(es,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:)    
				else if (variable .EQ. "SHFLX") then
					plotvar(es,iexp,:,:) = -1.0 * cdf_file->SHFLX(0,:,:)
				else if (variable .EQ. "LHFLX") then
					plotvar(es,iexp,:,:) = -1.0 * cdf_file->LHFLX(0,:,:)
				else if (variable .EQ. "U10") then
					plotvar(es,iexp,:,:) = cdf_file->U10(0,:,:)
				else if (variable .EQ. "Topo") then
					plotvar(es,iexp,:,:) = cdf_file->PHIS/9.8
				else if (variable .EQ. "WScurl") then
                                        ; Add conversion of -1 to match observations: taux is stress on atmosphere, not stress on ocean
					taux = cdf_file->TAUX(0,:,:) * -1.0
					tauy = cdf_file->TAUY(0,:,:) * -1.0
					plotvar(es,iexp,:,:) = uv2vr_cfd(taux,tauy,cdf_file->lat,cdf_file->lon,3)
				end if
				end if
				end if
				end if
				end if
				end if
				end if
				end if
				end if
				end if
				end if
				end if

				delete(cdf_file)

			else if (variable .EQ. "EMGR") then

				filo = Experiments(es,iexp) + "/atm/hist/EMGR_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h0.nc"

				cdf_file = addfile(dir + filo, "r")
				plotvar(es,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

				delete(cdf_file)

                        else if (variable .EQ. "Ks") then

                                filo = Experiments(es,iexp) + "/atm/hist/Ks_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h0.nc"

                                cdf_file = addfile(dir + filo, "r")
                                levs_Ks = cdf_file->lev_p
                                nlevs = dimsizes(levs_Ks)
				; Find correct pressure level
				plev = -1
				do nl = 0,nlevs-1
					if levs_Ks(nl) .EQ. ilev then
						plev = nl
					end if
				end do
				if (plev .LT. 0) then
					print("didnt find a level")
					exit
				end if
				Ks = cdf_file->Ks(0,plev,:,:)
                                plotvar(es,iexp,:,:) = tofloat(Ks)
                                do ilat = 0,nlats-1
					do ilon = 0,nlons-1
				
						if (isnan_ieee(Ks(ilat,ilon))) then
							plotvar(es,iexp,ilat,ilon) = plotvar@_FillValue
						end if
					end do
				end do
				delete(cdf_file)


			else if (variable .EQ. "Zvar") then

				if (Experiments(es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
				else
					if ilev .EQ. 850 then
						filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
						cdf_file = addfile(dir + filo, "r")
						plotvar(es,iexp,:,:) = cdf_file->Z850bpf_var(:,:)
					else if ilev .EQ. 250 then
                                                filo = Experiments(es,iexp) + "/atm/hist/Z250bpf_var_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
                                                cdf_file = addfile(dir + filo, "r")
                                                plotvar(es,iexp,:,:) = cdf_file->Z250bpf_var(:,:)
					end if
					end if
					delete(cdf_file)
					
				end if

			else if (variable .EQ. "dTHdy" .OR. variable .EQ. "dTHdz" .OR. variable .EQ. "dTHdzdTHdy" .OR. variable .EQ. "TWcalc" .OR. variable .EQ. "dTHdyAVG") then
	
        	                dTHdy = new((/nlevs,nlats,nlons/),typeof(vartest))
				nullarr = new((/nlevs,nlats,nlons/),typeof(vartest))
	
                                if (Experiments(es,iexp) .EQ. "0") then
                                        plotvar(es,iexp,:,:) = 0.0
                                        blankcount = blankcount + 1
                                else

                                        filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                                        cdf_file = addfile(dir + filo, "r")

                                        levs_mean = cdf_file->lev_p
					lats = cdf_file->lat
					f = tofloat(2 * 7.292e-5 * sin(lats * pi / 180.0))

					dp = center_finite_diff_n(levs_mean,1,False,1,0)
					print(dp)					

				        do nl = 0,nlevs-1
                                        	if levs_mean(nl) .EQ. ilev then
                                                	plev = nl
                                        	end if
                                	end do
                                	if (plev .LT. 0) then
                                	        print("didnt find a level")
                                	        exit
                                	end if                                        

					; Check lats are from south to north
					if lats(0) .GT. lats(nlats-1) then
						print("lats the wrong way round!")
						exit
					end if

                                        TH = tofloat(cdf_file->TH(0,:,:,:))
					Z3 = tofloat(cdf_file->Z3(0,:,:,:))

					dTHdz = center_finite_diff_n(TH,Z3,False,0,0)

					gradsf (TH(:,:,:), nullarr, dTHdy)

					if (variable .EQ. "dTHdy") then
						plotvar(es,iexp,:,:) = dTHdy(plev,:,:)
					else if (variable .EQ. "dTHdz") then
						plotvar(es,iexp,:,:) = dTHdz(plev,:,:)
					else if (variable .EQ. "dTHdzdTHdy") then
						plotvar(es,iexp,:,:) = dTHdz(plev,:,:)/dTHdy(plev,:,:)
					else if (variable .EQ. "TWcalc") then
						;get levs for 850 and 250
                                                plev850 = -1
						plev250 = -1
                                                do nl = 0,nlevs-1
                                                        if levs_mean(nl) .EQ. 250 then
                                                                plev250 = nl
                                                        end if
                                                        if levs_mean(nl) .EQ. 850 then
                                                                plev850 = nl
                                                        end if
                                                end do
                                                if (plev250 .LT. 0 .OR. plev850 .LT. 0) then
                                                        print("didnt find a level")
                                                        exit
                                                end if
						averagedTHdy = dim_avg_wgt_n_Wrap(dTHdy(plev850:plev250,:,:),dp(plev850:plev250),1,0)
						plotvar(es,iexp,:,:) = - Rair * averagedTHdy * log(850.0/250.0) / conform(averagedTHdy,f,0)
					else if variable .EQ. "dTHdyAVG" then
                                                ;get levs for 850 and 250
                                                plev850 = -1
                                                plev250 = -1
                                                do nl = 0,nlevs-1
                                                        if levs_mean(nl) .EQ. 250 then
                                                                plev250 = nl
                                                        end if
                                                        if levs_mean(nl) .EQ. 850 then
                                                                plev850 = nl
                                                        end if
                                                end do
                                                if (plev250 .LT. 0 .OR. plev850 .LT. 0) then
                                                        print("didnt find a level")
                                                        exit
                                                end if
                                                averagedTHdy = dim_avg_wgt_n_Wrap(dTHdy(plev850:plev250,:,:),dp(plev850:plev250),1,0)
						plotvar(es,iexp,:,:) = averagedTHdy
					end if
					end if
					end if
					end if
					end if
					delete(dTHdz)
					delete(TH)
					delete(Z3)
				end if


			else if (variable .EQ. "uP" .OR. variable .EQ. "uH") then
				filo = Experiments(es,iexp) + "/atm/hist/EV_bpf_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

				cdf_file = addfile(dir + filo, "r")
			
				if (variable .EQ. "uH") then
					plotvar(es,iexp,:,:) = cdf_file->u_H_bpf250(:,:)
				else if (variable .EQ. "uP") then
					print("***warning*** factor of -1.0 that we don't understand yet!!!")
					plotvar(es,iexp,:,:) = -1.0 * cdf_file->u_P_bpf850(:,:)
				end if
				end if
			
				delete(cdf_file)

			else if (variable .EQ. "PV" .OR. variable .EQ. "dPVdy") then
				lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))
				filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"

				;filo = Experiments(es,iexp) + "/atm/hist/PV_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_ts_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir + filo, "r")

				levs_PV = cdf_file->lev_p
				nPVlevs = dimsizes(levs_PV)
				; Find levs
		                if (ilev .NE. 0) then
				; Find correct pressure level
					plev = -1

					do nl = 0,nPVlevs-1
						if levs_PV(nl) .EQ. ilev then
							plev = nl
						end if
					end do

					if (plev .LT. 0) then
						print("didnt find a level")
						exit
					end if
				end if

				PVall = cdf_file->PV(:,plev,:,:)
				PVtm = dim_avg_n(PVall,0)
				dPVdy = PVtm(:,:)
				dPVdx = PVtm(:,:)
	; fine for no topography or hybrid levels:			gradsf(PVtm(:,:),dPVdx,dPVdy)
				dPVdy = center_finite_diff_n(PVtm(:,:),lat_dist, False, 0, 0)
				
				if variable .EQ. "PV" then
					plotvar(es,iexp,:,:) = PVtm(:,:)
				else if variable .EQ. "dPVdy" then
					plotvar(es,iexp,:,:) = dPVdy
				end if
				end if

				delete(cdf_file)
		
			else if (variable .EQ. "vort" .OR. variable .EQ. "-DuDdTHdx" .OR. variable .EQ. "-dTHdy" .OR. variable .EQ. "-dTHdx" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-Tadv") then
				if (Experiments(es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
					blankcount = blankcount + 1
				else

					filo = Experiments(es,iexp) + "/atm/hist/" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_mean_Xpl_" + Experiments(es,iexp) + ".cam2.h0.nc"
					cdf_file = addfile(dir + filo, "r")

					levs_mean = cdf_file->lev_p
					
	                                ; Find correct pressure level
                                        plev = -1

                                        do nl = 0,nPVlevs-1
                                                if levs_PV(nl) .EQ. ilev then
                                                        plev = nl
                                                end if
                                        end do

                                        if (plev .LT. 0) then
                                                print("didnt find a level")
                                                exit
                                        end if

					U(iexp,:,:) = cdf_file->U(0,plev,:,:)
					V(iexp,:,:) = cdf_file->V(0,plev,:,:)
			
					TH = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

					dTHdy(iexp,:,:) = center_finite_diff_n(TH,lat_dist, False, 0, 0)
					
					vort(iexp,:,:) = uv2vr_cfd(cdf_file->U(0,plev,:,:),cdf_file->V(0,plev,:,:),lats,lons,0)

					do iy=0,nlats-1
						lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
						dTHdx(iexp,iy,:) = center_finite_diff_n(TH(iy:iy,:),lon_dist, False, 0, 1)
					end do
							
					if (variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY") then
						U(iexp,:,:) = U(0,:,:)
						V(iexp,:,:) = V(0,:,:)
					else if (variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY") then
						dTHdx(iexp,:,:) = dTHdx(0,:,:)
						dTHdy(iexp,:,:) = dTHdy(0,:,:)
					else if (variable .EQ. "-DuDdTHdx") then
						if (iexp .NE. 0) then
							U(iexp,:,:) = U(0,:,:) - U(iexp,:,:)
							V(iexp,:,:) = V(0,:,:) - V(iexp,:,:)
							dTHdx(iexp,:,:) = dTHdx(0,:,:) - dTHdx(iexp,:,:)
							dTHdy(iexp,:,:) = dTHdy(0,:,:) - dTHdy(iexp,:,:)
						end if	
					end if
					end if 
					end if
				end if	
		
			else if (variable .EQ. "EKEbpf" .OR. variable .EQ. "divVbpfTbpf") then
				vartemp = new((/nlats,nlons/),typeof(vartest))
				lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

				filo = Experiments(es,iexp) + "/atm/hist/EKE_mean_bpf_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

				cdf_file = addfile(dir + filo, "r")

				if (ilev .EQ. "850") then
					if (variable .EQ. "EKEbpf") then	
						plotvar(es,iexp,:,:) = cdf_file->EKE_bpf850(:,:)
					else if (variable .EQ. "divVbpfTbpf") then		
						vartemp(:,:) = cdf_file->VprTpr_bpf850(:,:)	
						plotvar(es,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)

					end if
					end if
				else if (ilev .EQ. "250") then
					if (variable .EQ. "EKEbpf") then
						plotvar(es,iexp,:,:) = cdf_file->EKE_bpf250(:,:)
					else if (variable .EQ. "divVbpfTbpf") then	
						vartemp(:,:) = cdf_file->VprTpr_bpf250(:,:)                               
						plotvar(es,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)	
					end if
					end if
				else
					print("invalid EKE level, only 250 and 850 accepted")
					exit
				end if
				end if

			else if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
				filo = Experiments(es,iexp) + "/atm/hist/Z850_bpf_Events_" + tostring(ilev) + "_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".nc"

				cdf_file = addfile(dir + filo, "r")

				if (variable .EQ. "Zmax") then
					plotvar(es,iexp,:,:) = cdf_file->max_values(:,:)
				else if (variable .EQ. "Zlen") then
					plotvar(es,iexp,:,:) = cdf_file->lengths(:,:)
				else if (variable .EQ. "Znum") then
					plotvar(es,iexp,:,:) = tofloat(cdf_file->counter(:,:))
				else if (variable .EQ. "Zmag") then
					plotvar(es,iexp,:,:) = tofloat(cdf_file->mean_values(:,:))
				end if
				end if
				end if
				end if

			else if (variable .EQ. "-DivVprTpr") then
				VprTpr = new((/nlats,nlons/),typeof(vartest))
				lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

				filo = Experiments(es,iexp) + "/atm/hist/VprTpr_" + timespans(es,iexp) + tostring(startyrs(es,iexp)) + "_" + tostring(nyears(es,iexp)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
				cdf_file = addfile(dir + filo, "r")
				
				if (ilev .EQ. "850") then
					VprTpr = cdf_file->meanVprTHpr850
				else if (ilev .EQ. "250") then
					VprTpr = cdf_file->meanVprTHpr250
				end if
				end if

				plotvar(es,iexp,:,:) = -1.0 * center_finite_diff_n(VprTpr,lat_dist, False, 0, 0)

			else
				print("variable not allowed")
				print(variable)
				exit
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
			end if
		end if
	end do


	; some things need to be done after looping through all experiments!
	if (variable .EQ. "-Tadv" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DuDdTHdx") then
		plotvar(es,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy)) 
	else if (variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-DUdTHdX") then
		plotvar(es,:,:,:) = -1.0 * U * dTHdx 
	else if (variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-DVdTHdY") then
		plotvar(es,:,:,:) = -1.0 * V * dTHdy 
	else if (variable .EQ. "-dTHdy") then
		plotvar(es,:,:,:) = -1.0 * dTHdy 
	else if (variable .EQ. "-dTHdx") then
		plotvar(es,:,:,:) = -1.0 * dTHdx 
	else if (variable .EQ. "vort") then
		plotvar(es,:,:,:) = vort
	end if
	end if
	end if
	end if
	end if
	end if

end do

if (max(plotERA) .GT. 0) then
	E_plotvar_RG = area_conserve_remap_Wrap(lonsE,latsE,E_plotvar,lons,lats,False)

	E_plotvar_RG!1 = "lat"
	E_plotvar_RG!2 = "lon"

	E_plotvar_RG&lat = lats
	E_plotvar_RG&lon = lons

	E_plotvar_RG&lat@units="degree_north"
	E_plotvar_RG&lon@units="degree_east"
end if

do es = 0,numcols-1
	do iexp = 0,numrows-1
		variable = vars(iexp,es)
		ilev = ilevs(iexp,es)

		if (plottype .NE. "CSZ" .AND. plottype .NE. "CSM") then
			if (ilev .NE. 0) then
				do iy = 0,nlons-1
					do ix = 0,nlats-1
						if (max(plotERA) .GT. 0) then
							if (PS(es,0,ix,iy) .LT. (ilev*100 + 2000)) then
								E_plotvar_RG(es,ix,iy) = E_plotvar_RG@_FillValue
							end if
						end if
						do iexp = 0,nexps-1
							if (PS(es,iexp,ix,iy) .LT. (ilev*100 + 2000)) then
								plotvar(es,iexp,ix,iy) = plotvar@_FillValue
							end if
							if (variable .EQ. "UV") then
								plotvar2(es,iexp,ix,iy) = plotvar2@_FillValue
							end if
						end do
					end do
				end do
			end if


			if (variable .EQ. "TS") then
				do iexp = 0,nexps-1
					do iy = 0,nlons-1
						do ix = 0,nlats-1
							if (ExpCTLs(es,iexp) .GE. 0 .AND. ExpCTLs(es,iexp) .LT. 50) then
								if (PHIS(es,iexp,ix,iy) .LT. (PHIS(es,ExpCTLs(es,iexp),ix,iy) -1) .OR. PHIS(es,iexp,ix,iy) .GT. (PHIS(es,ExpCTLs(es,iexp),ix,iy) +1)) then
									plotvar(es,iexp,ix,iy) = plotvar@_FillValue
									if (variable .EQ. "UV") then
										plotvar2(es,iexp,ix,iy) = plotvar2@_FillValue
									end if
								end if
							end if
						end do
					end do
				end do
			end if
		end if
	end do
end do




countplots = new(numcols,"integer")
countplots(:) = 0

singlesize = nexps

do ic = 0,numcols-1
	do ne = 0,numrows-1
		if (ExpCTLs(ic,ne) .GE. 0) then
			countplots(ic) = countplots(ic) + 1
		end if
	end do
	if plotERA(ic) .GE. 1 then
		countplots(ic) = countplots(ic) + 1
		singlesize = nexps + 1
	end if
end do

panelsize = numcols * max(countplots)
if (linear .EQ. "true") then
	panelsize = panelsize + numcols
	singlesize= singlesize + 1
end if

;print(panelsize)
;print(singlesize)

if (plottype .EQ. "map") then
        toplot = new((/numcols,singlesize,nlats,nlons/),typeof(plotvar))
        toplot@_FillValue = 9.96921e+36
	toplot2 = new((/numcols,singlesize,nlats,nlons/),typeof(plotvar))
        toplot3 = new((/numcols,singlesize,nlats,nlons/),typeof(plotvar))

	toplottitle = new((/numcols,singlesize/),"string")
	toplotPHIS = new((/numcols,singlesize,nlats,nlons/),typeof(PHIS))
	
	toplotCI = new((/numcols,singlesize/),typeof("integer"))

	do ic = 0,numcols-1
		plotcounter = 0
	
		do ep = 0,nexps-1
			if (reverses(ic,ep) .EQ. "true") then
				factor = -1.0
			else
				factor = 1.0
			end if

			if (ExpCTLs(ic,ep) .GE. 0) then
				if (ExpCTLs(ic,ep) .EQ. 100) then
					toplot(ic,plotcounter,:,:) = plotvar(ic,ep,:,:)
					if variable .EQ. "UV" then					
						toplot2(ic,plotcounter,:,:) = plotvar2(ic,ep,:,:)
					else
						toplot2(ic,plotcounter,:,:) = 0.0
						toplot3(ic,plotcounter,:,:) = 0.0
					end if

					toplotPHIS(ic,plotcounter,:,:) = PHIS(ic,ep,:,:)
					toplottitle(ic,plotcounter) = Titles(ic,ep)
		
					toplotCI(ic,plotcounter) = 0					

				else

					if (variable .EQ. "-DuDdTHdx") then
						print("doesn't work with DuDdTHdx now")
						exit
					else
						toplot(ic,plotcounter,:,:) = factor * (plotvar(ic,ExpCTLs(ic,ep),:,:) - plotvar(ic,ep,:,:))

						if (variable .EQ. "UV") then
							toplot2(ic,plotcounter,:,:) = factor * (plotvar2(ic,ExpCTLs(ic,ep),:,:) - plotvar2(ic,ep,:,:))
						else
                                                        toplot2(ic,plotcounter,:,:) = plotvar2(ic,ep,:,:)
                                                        toplot3(ic,plotcounter,:,:) = plotvar3(ic,ep,:,:)

						end if
					end if
					
					toplotPHIS(ic,plotcounter,:,:) =  factor * (PHIS(ic,ExpCTLs(ic,ep),:,:) - PHIS(ic,ep,:,:))

					if (reverses(ic,ep) .EQ. "true") then
						toplottitle(ic,plotcounter) = Titles(ic,ep) + " - " + Titles(ic,ExpCTLs(ic,ep))
					else
						toplottitle(ic,plotcounter) = Titles(ic,ExpCTLs(ic,ep)) + " - " + Titles(ic,ep)
					end if

					toplotCI(ic,plotcounter) = 1

				end if

				if (expdif .EQ. 1) then
					toplot(1,plotcounter,:,:) = toplot(1,plotcounter,:,:) - toplot(0,plotcounter,:,:)

					toplottitle(1,plotcounter) = "(" + toplottitle(1,plotcounter) + " - " + toplottitle(0,plotcounter) + ")"
				end if
			end if			
			plotcounter = plotcounter + 1 
		end do

	end do


	if (linear .EQ. "true") then
		print("plotting linearness")
		if (nexps .NE. 4) then
			print("linear only compatible with 4 experiments")
			exit
		end if

		do iplot=0,1
                        toplot(iplot,plotcounter,:,:) = factor * -1.0 * ( (plotvar(iplot,0,:,:) - plotvar(iplot,1,:,:)) - (plotvar(iplot,0,:,:) - plotvar(iplot,2,:,:)) - (plotvar(iplot,0,:,:) - plotvar(iplot,3,:,:)))/plotfactor(0,iplot)

			if (variable .EQ. "UV") then
				toplot2(iplot,nexps,:,:) = plotvar2(iplot,0,:,:) - plotvar2(iplot,1,:,:) - plotvar2(iplot,2,:,:) + plotvar2(iplot,3,:,:)
			
			else
				toplot2(iplot,nexps,:,:) = 0.0
				toplot3(iplot,nexps,:,:) = 0.0
			end if
			toplotPHIS(iplot,plotcounter,:,:) = PHIS(iplot,0,:,:) - PHIS(iplot,1,:,:) - PHIS(iplot,2,:,:) + PHIS(iplot,3,:,:)
			toplottitle(iplot,plotcounter) = Titles(iplot,0) + " - " + Titles(iplot,1) + " - " + Titles(iplot,2) + " + " + Titles(iplot,3)
		end do
	end if


	do ic = 0,numcols-1
		do iexp = 0,numrows-1
			toplot(ic,iexp,:,:) = toplot(ic,iexp,:,:)/ plotfactor(iexp,ic)
		end do
	end do

	toplot!2 = "lat"
	toplot!3 = "lon"

	toplot&lat = lats
	toplot&lon = lons

	toplot&lat@units="degree_north"
	toplot&lon@units="degree_east"

	copy_VarCoords(toplot,toplotPHIS)
	copy_VarCoords(toplot,toplot2)
        copy_VarCoords(toplot,toplot3)


else if (plottype .EQ. "ZMline")
        toplot = new((/numcols,nexps+1,nlats/),typeof(plotvar))
	toplottitle = new((/numcols,nexps+1/),"string")
	
	toplot(0,0,:) = dim_avg_n(plotvar(0,0,:,nlonstart:nlonend),1)
	toplottitle(0,0) = Titles(0,0)
	
	if (expdif .EQ. 1) then
		toplot(1,0,:) = dim_avg_n(plotvar(1,0,:,nlonstart:nlonend),1) - dim_avg_n(plotvar(0,0,:,nlonstart:nlonend),1)
		toplottitle(1,0) = Titles(1,0) + " - " + Titles(0,0)
	else
		toplot(1,0,:) = dim_avg_n(plotvar(1,0,:,nlonstart:nlonend),1)
		toplottitle(1,0) = Titles(1,0)
	end if

	do ep = 1,nexps-1
		do ic = 0,numcols-1
			if (variable .EQ. "-DuDdTHdx") then
				toplot(ic,ep,:,:) = factor * dim_avg_n(plotvar(ic,ep,:,nlonstart:nlonend),1)
			else
				toplot(ic,ep,:) = factor * (dim_avg_n(plotvar(ic,0,:,nlonstart:nlonend),1) - dim_avg_n(plotvar(ic,ep,:,nlonstart:nlonend),1))	
			end if
			if (reverses(ic,ep) .EQ. "true") then
				toplottitle(ic,ep) = Titles(ic,ep) + " - " + Titles(ic,0)
			else
				toplottitle(ic,ep) = Titles(ic,0) + " - " + Titles(ic,ep)
			end if
		end do

		if (expdif .EQ. 1) then
			toplot(1,ep,:,:) = toplot(1,ep,:,:) - toplot(0,ep,:,:)
			
			if (reverses(ep) .EQ. "true") then
				toplottitle(ic,ep) = "(" + Titles(1,ep) + " - " + Titles(1,0) + ")" + " - " + "(" + Titles(0,ep) + " - " + Titles(0,0) + ")"
			else
				toplottitle(ic,ep) = "(" + Titles(1,0) + " - " + Titles(1,ep) + ")" + " - " + "(" + Titles(0,0) + " - " + Titles(0,ep) + ")"
			end if
		end if
	end do
	

	toplot!2 = "lat"
	toplot&lat = lats
	toplot&lat@units="degree_north"

else if (plottype .EQ. "CSM") then
	print("cross-section")
	
        toplot = new((/numcols,singlesize,nlevs,nlats/),typeof(plotvar))
        toplot2 = new((/numcols,singlesize,nlevs,nlats/),typeof(plotvar))
        toplottitle = new((/numcols,singlesize/),"string")
        toplotCI = new((/numcols,singlesize/),typeof("integer"))

        toplot(0,0,:,:) = plotvar(0,0,:,:)
        toplot(1,0,:,:) = plotvar(1,0,:,:)

	toplottitle(0,0) = Titles(0,0)
        toplottitle(1,0) = Titles(1,0)


	toplotCI(0,0) = 0
        toplotCI(1,0) = 0

        do ep = 1,nexps-1
                do ic = 0,numcols-1
			if (reverses(ic,ep) .EQ. "true") then
				factor = -1.0
			else
				factor = 1.0
			end if

                	toplot(ic,ep,:,:) = factor *(plotvar(ic,0,:,:) - plotvar(ic,ep,:,:))
		        toplotCI(ic,ep) = 1

                        if (reverses(ic,ep) .EQ. "true") then
                                toplottitle(ic,ep) = Titles(ic,ep) + " - " + Titles(ic,0)
                        else
                                toplottitle(ic,ep) = Titles(ic,0) + " - " + Titles(ic,ep)
                        end if
       		end do
	end do 

	do ic = 0,numcols-1
        	toplot(ic,:,:,:) = toplot(ic,:,:,:)/plotfactor(ic)
	end do

	toplot!2 = "lev"
	toplot!3 = "lat"

	toplot&lev = levs_mean
	toplot&lat = lats

	toplot&lat@units="degrees_north"
	toplot&lev@units="mb"

else if (plottype .EQ. "CSZ") then
        toplot = new((/numcols,singlesize,nlevs,nlons/),typeof(plotvar))
        toplot2 = new((/numcols,singlesize,nlevs,nlons/),typeof(plotvar))
        toplottitle = new((/numcols,singlesize/),"string")
        toplotCI = new((/numcols,singlesize/),typeof("integer"))

        toplot(0,0,:,:) = plotvar(0,0,:,:)
        toplot(1,0,:,:) = plotvar(1,0,:,:)

        toplottitle(0,0) = Titles(0,0)

        toplotCI(0,0) = 0
        toplotCI(1,0) = 0

        do ep = 1,nexps-1
		do ic = 0,numcols-1
			if (reverses(ic,ep) .EQ. "true") then
				factor = -1.0
			else
				factor = 1.0
			end if
                        toplot(ic,ep,:,:) = factor *(plotvar(ic,0,:,:) - plotvar(ic,ep,:,:))
                        toplotCI(ic,ep) = 1

                        if (reverses(ic,ep) .EQ. "true") then
                                toplottitle(ic,ep) = Titles(ic,ep) + " - " + Titles(ic,0)
                        else
                                toplottitle(ic,ep) = Titles(ic,0) + " - " + Titles(ic,ep)
                        end if
                end do
        end do

	do ic = 0,numcols-1
        	toplot(ic,:,:,:) = toplot(ic,:,:,:)/plotfactor(ic)
	end do

        toplot!2 = "lev"
        toplot!3 = "lon"

        toplot&lev = levs_mean
        toplot&lon = lons

        toplot&lon@units="degrees_east"
        toplot&lev@units="mb"

end if
end if
end if
end if

; plot

if (ilevs(0,0) .EQ. 0)
	all_vars = vars(0,0) + "_SFC_"
else if (ilevs(0,0) .EQ. -1)     ; vertical cross-section
	all_vars = vars(0,0) + "_"
else
	all_vars = vars(0,0) + tostring(ilevs(0,0)) + "_"
end if
end if

;print(numrows)
;print(numcols)
do ir = 0,numrows-1
	do ic = 1,numcols-1
		if (ilevs(ir,ic) .EQ. 0) 
			all_vars = all_vars + vars(ir,ic) + "_SFC_"
		else if (ilevs(ir,ic) .EQ. -1)
			all_vars = all_vars + vars(ir,ic) + "_"
		else
			all_vars = all_vars + vars(ir,ic) + tostring(ilevs(ir,ic)) + "_"
		end if
		end if
	end do
end do


if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
	plotname = variable + tostring(ilev) + "_" + plottype + "_" + slon + "-" + elon
else
	if (ilev .EQ. 0) then
	  plotname =  all_vars + plottype + "_" + slon + "-" + elon + "_" + slat + "_" + elat
	else
	  plotname = all_vars + plottype + "_" + slon + "-" + elon
	end if
end if

if (diffdiffs .EQ. "true")
  plotname = plotname + "_dds"
end if

timespantitle = timespans(0,0)

do ic = 0,numcols-1
	do iexp = 0,nexps-1
		if (timespans(ic,iexp) .NE. timespans(0,0)) then
			timespantitle = timespantitle + "_" + timespans(0,iexp)
		end if
	end do
end do

wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/" + titleprefix + plotname + "_" + timespantitle) 


colorshere = (/"navy","blue3","mediumblue","dodgerblue","deepskyblue","white","white","lightgoldenrod","gold","darkorange","red","red4"/)

;gsn_define_colormap(wks,colorshere)
gsn_define_colormap(wks,"MPL_GnBu") ;BlueWhiteOrangeRed")         ; choose colormap

cmap = read_colormap_file("BlueWhiteOrangeRed")
ncmap = dimsizes(cmap)
ncolors = ncmap(0)
if justblue .EQ. 1 then
	newcmap = cmap(10:110,:) ;(30:226:4,:)
	newcmap = newcmap(::-1,:)
else
	newcmap = cmap(40:ncolors-40,:)
	
end if
plots = new((/numcols,singlesize/),graphic)                          ; create a plot array


res                      = True                 ; plot mods desired
res@gsnDraw  = False                          ; don't draw
res@gsnFrame = False                          ; don't advance frame

resvc			= True
resvc@gsnDraw = False
resvc@gsnFrame = False
resvc@vcZeroFLabelOn = False

;res@gsnLeftString = ""
res@cnMissingValFillColor = "grey30"
res@lbOrientation   = "Vertical"                ; vertical label bar
res@lbLabelFontHeightF =.017

res@tmXBLabelFontHeightF = 0.017
res@tmYLLabelFontHeightF = 0.017
res@gsnLeftStringFontHeightF = 0.012
res@gsnRightStringFontHeightF = 0.012

res@cnFillPalette = newcmap

if (plottype .EQ. "map" .OR. plottype .EQ. "CSZ" .OR. plottype .EQ. "CSM") then


	if (polar .NE. "true") then
		  res@mpCenterLonF = clon
		  res@mpMinLonF = slon
		  res@mpMaxLonF = elon
		  res@mpMinLatF = slat
		  res@mpMaxLatF = elat
	  
	else
		res@gsnPolar = "NH"
	end if


	if (plottype .EQ. "CSZ" .OR. plottype .EQ. "CSM") then
		print("cross-section")

		res@trYMinF = 150.0
		res@trYMaxF = 1000.0
		res@cnFillOn             = True                  ; turn on color fill


		res@vpXF            = 0.13                        ; change x-scale
		res@vpWidthF        = 0.85                        ; change height and width
		res@vpHeightF       = 0.45

		res@tmYRMode             = "Automatic"          ; turn off special labels on right axis
	 	
		nLabels                   = toint((elat - slat)/10)  
   		res@tmXBLabels           = new(nLabels,"string")
   		res@tmXBMode             = "Explicit"
	end if


	;res@gsnLeftString = ""
	if (variable .EQ. "UV") then
		res@vcRefMagnitudeF         = 5.0              ; make vectors larger
		res@vcRefLengthF            = 0.050            ; ref vec length
		res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
		res@vcMinDistanceF          = 0.017            ; thin out vectors
	else
		res@cnFillOn             = True                 ; turn on color fill
		res@cnLinesOn            = False                ; turn off contour lines
;		res@gsnSpreadColors      = True                 ; use full colormap
		res@lbOrientation   = "Vertical"                ; vertical label bar
	end if


	if (overplot .EQ. 1)
		  resOv = True
		  resOv@gsnDraw = False                        ; do not draw the plot
		  resOv@gsnFrame = False                       ; do not advance the frame
		  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
		  resOv@cnLevels = (/500.0,1500.0,2500.0,3500.0/)              ; set the contour levels
		  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
		  resOv@cnLineLabelsOn       = False
		  resOv@cnConstFLabelOn = False
		  resOv@cnInfoLabelOn       = False        ; no info label
	end if

	plotnum = new(numcols,"integer")
	plotnum(:) = 0
	extra = new(numcols,"integer")
	extra(:) = 0
	if linear .EQ. "true" then
		extra(:) = 1
	end if
	res@cnLevelSelectionMode = "ManualLevels"       ; manually set the contour levels

	do ic = 0,numcols-1
		if (plotERA(ic) .EQ. 1 .OR. plotERA(ic) .EQ. 2) then
			print("plotting ERA")
			extra(ic) = extra(ic) + 1
			res@gsnRightString = units(0,ic)
                        if papertitles .EQ. 0 then
				res@gsnLeftString=vartitles(0,ic) + " at " + tostring(ilevs(0,ic)) + " mb"
			else
				if ic .EQ. 0 then
					res@tiYAxisJust          = "CenterLeft"
					res@tiYAxisFontHeightF = 0.03
					if numcols .GE. 3 then
						res@tiYAxisOffsetXF = -0.01
					else
						res@tiYAxisOffsetXF = -0.03
					end if
					if nexps .GE. 3 then
						res@tiYAxisOffsetYF = -0.03
					else
                                                res@tiYAxisOffsetYF = 0.01
					end if
					res@tiYAxisString   = "ERA-I"
				else
					res@tiYAxisString   = " "
				end if
			end if

			res@cnMinLevelValF  = plotmins(0,ic,0)/plotfactor(0,ic)                 ; set the minimum contour level
			res@cnMaxLevelValF  = plotmaxs(0,ic,0)/plotfactor(0,ic)                    ; set the maximum contour level
			res@cnLevelSpacingF       = plotdifs(0,ic,0)/plotfactor(0,ic)      ; contour spacing
	        
			if (plotERA(ic) .EQ. 1) then
				res@gsnCenterString = ""
			else
                                res@gsnCenterString = "NCAR-NCEP"
			end if
			if (plottype .EQ. "map")
				if (polar .EQ. "true") then
					plots(ic,plotnum(ic)) = gsn_csm_contour_map_polar(wks,E_plotvar_RG(ic,:,:),res)
				else
					plots(ic,plotnum(ic)) = gsn_csm_contour_map_ce(wks,E_plotvar_RG(ic,:,:),res) ;
				end if
			            
				plot_ov = gsn_csm_contour(wks,toplotPHIS(ic,0,:,:),resOv)        
                		if overplot .EQ. 1 then
					overlay(plots(ic,plotnum(ic)),plot_ov)
				end if
		
			else if (plottype .EQ. "CSM" .OR. plottype .EQ. "CSZ")
	                        res@tmXBValues        = toint( fspan(lats(nlatstart),lats(nlatend),nLabels) )
				plots(ic,plotnum(ic)) = gsn_csm_pres_hgt(wks,E_plotvar_RG(ic,:,nlatstart:nlatend),res)
			end if
			end if

			plotnum(ic) = plotnum(ic) + 1

		end if
	end do


	startpp = 0
	do pp = startpp,nexps-1
		do ic = 0,numcols-1	
	                if (ExpCTLs(ic,pp) .GE. 0) then
	
				if (toplotCI(ic,pp) .EQ. 0) then
				
					res@cnMinLevelValF  = plotmins(pp,ic,0)/plotfactor(pp,ic)                   ; set the minimum contour level
					res@cnMaxLevelValF  = plotmaxs(pp,ic,0)/plotfactor(pp,ic)                 ; set the maximum contour level
					res@cnLevelSpacingF       = plotdifs(pp,ic,0)/plotfactor(pp,ic)      ; contour spacing
				else
		
					res@cnMinLevelValF  = plotmins(pp,ic,1)/plotfactor(pp,ic)                    ; set the minimum contour level
					res@cnMaxLevelValF  = plotmaxs(pp,ic,1)/plotfactor(pp,ic)                     ; set the maximum contour level
					res@cnLevelSpacingF       = plotdifs(pp,ic,1)/plotfactor(pp,ic)      ; contour spacing
				end if

				res@gsnRightString=units(pp,ic)
				if papertitles .EQ. 0 then
	                                res@gsnLeftString=vartitles(pp,ic) + " at " + tostring(ilevs(pp,ic)) + " mb"
				else
					if ic .EQ. 0 then
                                                res@tiYAxisFontHeightF = 0.03
                                                
						if numcols .GE. 3 then
							res@tiYAxisOffsetXF = -0.02
						else
							res@tiYAxisOffsetXF = -0.03
						end if
						if nexps .GE. 3 .AND. plotERA(ic) .GT. 0 then
							res@tiYAxisOffsetYF = -0.04
						else
	                                                res@tiYAxisFontHeightF = 0.024
							res@tiYAxisOffsetYF = 0.0
						end if
						res@tiYAxisString   = Titles(ic,pp)
					else
						res@tiYAxisString   = " "
					end if
				end if

				;res@gsnCenterString         = toplottitle(ic,pp)
                        	if (plottype .EQ. "map")
					if (polar .EQ. "true") then
						if (vars(pp,ic) .NE. "UV") then
							plots(ic,plotnum(ic)) = gsn_csm_contour_map_polar(wks,toplot(ic,pp,:,:),res)
						else
							plots(ic,plotnum(ic)) = gsn_csm_vector_map_polar(wks,toplot(ic,pp,:,:),toplot2(ic,pp,:,:),res)
						end if
					else
						if (vars(pp,ic) .NE. "UV") then
							plots(ic,plotnum(ic)) = gsn_csm_contour_map_ce(wks,toplot(ic,pp,:,:),res) ;
						else
							plots(ic,plotnum(ic)) = gsn_csm_vector_map_ce(wks,toplot(ic,pp,:,:),toplot2(ic,pp,:,:),res) ;
						end if
						
						if overplot .EQ. 1 then
							plot_ov = gsn_csm_contour(wks,toplotPHIS(ic,pp,:,:),resOv)
							overlay(plots(ic,plotnum(ic)),plot_ov)
						end if

						if vars(pp,ic) .EQ. "SFZA" .AND. ilevs(pp,ic) .EQ. 250 then
							resvc@vcRefMagnitudeF =vmagnitude
							resvc@vcLevelSelectionMode = "ManualLevels"
							resvc@vcMinLevelValF = 0
							resvc@vcRefLengthF = 0.03
							resvc@vcMaxLevelValF = vmax
					                resvc@vcLevelSpacingF = vspacing							
							resvc@vcMinDistanceF = 0.02       ; thin vectors
					                resvc@vcMinMagnitudeF = minmag
						
							plot_ov2 = gsn_csm_vector(wks,toplot2(ic,pp,:,:),toplot3(ic,pp,:,:),resvc)
							overlay(plots(ic,plotnum(ic)),plot_ov2)
						end if
					end if
				else if (plottype .EQ. "CSM" .OR. plottype .EQ. "CSZ")
					res@tmXBValues = toint( fspan(lats(nlatstart),lats(nlatend),nLabels) )
					do i=0,nLabels-1
       						res@tmXBLabels(i) = sprintf("%5.1f", res@tmXBValues(i))
    					end do
					plots(ic,plotnum(ic)) = gsn_csm_pres_hgt(wks,toplot(ic,pp,:,nlatstart:nlatend),res)

				end if
				end if
				
				plotnum(ic) = plotnum(ic) + 1
			else
				extra(ic) = extra(ic) - 1
			end if
		end do
	end do
	if linear .EQ. "true" then
                do ic = 0,numcols-1
			res@cnMinLevelValF  = nonlinplot * plotmins(pp-1,ic,1)/plotfactor(pp-1,ic)                   ; set the minimum contour level
			res@cnMaxLevelValF  =  nonlinplot * plotmaxs(pp-1,ic,1)/plotfactor(pp-1,ic)                 ; set the maximum contour level
			res@cnLevelSpacingF       = nonlinplot * plotdifs(pp-1,ic,1)/plotfactor(pp-1,ic)      ; contour spacing

			res@gsnRightString=units(pp-1,ic)
			if papertitles .EQ. 0 then
                                res@gsnLeftString = "non-linear T+M at " + tostring(ilevs(pp-1,ic)) + " mb"
			else
				if ic .EQ. 0 then
					res@tiYAxisString   = "Non-linear:~C~T + M - (T+M)"
				else
					res@tiYAxisString   = " "
				end if
			end if
			if papertitles .EQ. 0 then
				res@gsnLeftString = "non-linear T+M at " + tostring(ilevs(pp-1,ic)) + " mb"
			end if

			if (plottype .EQ. "map")

				if (vars(pp-1,ic) .NE. "UV") then
					plots(ic,plotnum(ic)) = gsn_csm_contour_map_ce(wks,toplot(ic,pp,:,:),res) ;
				else
					plots(ic,plotnum(ic)) = gsn_csm_vector_map_ce(wks,toplot(ic,pp,:,:),toplot2(ic,pp,:,:),res) ;
				end if
				if overplot .EQ. 1 then
					plot_ov = gsn_csm_contour(wks,toplotPHIS(ic,pp,:,:),resOv)
					overlay(plots(ic,plotnum(ic)),plot_ov)
				end if
			end if
			plotnum(ic) = plotnum(ic) + 1
		end do
	end if

else if (plottype .EQ. "ZMline") then

        ;res@gsnLeftString = ""
	res@xyLineColors = LineColors(0:nexps-1)
	;print(res@xyLineColors)
	res@xyLineThicknessF = 2.0
	res@xyDashPattern = 0

	; add a legend
	res@pmLegendDisplayMode    = "Off"              ; turn on legend

	res@trYMinF  = plotchar1(0)                   ; set the minimum contour level
	res@trYMaxF  = plotchar1(1)                    ; set the maximum contour level
	res@trXMinF = slat
	res@trXMaxF = elat

	if abs(plotchar1(1)) .LT. 0.0001 then
		res@tmYLFormat = "0*+^e"
	end if

	;res@gsnCenterString         = toplottitle(0,0)
	plot(0) = gsn_csm_xy(wks,toplot&lat,toplot(0,0,:),res) ;
	;res@gsnCenterString         = toplottitle(1,0)
	plot(1) = gsn_csm_xy(wks,toplot&lat,toplot(1,0,:),res) ;

	res@trYMinF  = plotchar1(3)                    ; set the minimum contour level
	res@trYMaxF  = plotchar1(4)                     ; set the maximum contour level

        res@pmLegendDisplayMode    = "Always"              ; turn on legend
        res@pmLegendSide           = "Bottom"                 ; Change location of
	res@pmLegendParallelPosF   = .5                  ; move units right
	res@pmLegendOrthogonalPosF = -0.4                ; move units down
	res@pmLegendWidthF         = 0.2
	res@lgPerimOn              = False               ; turn off box around
	res@lgLabelFontHeightF     = .017                 ; label font height

        res@xyExplicitLegendLabels = toplottitle(0,1:nexps-1)
	plot(2) = gsn_csm_xy(wks,toplot&lat,toplot(0,1:nexps-1,:),res) ;
        res@xyExplicitLegendLabels = toplottitle(1,1:nexps-1)
        plot(3) = gsn_csm_xy(wks,toplot&lat,toplot(1,1:nexps-1,:),res) ;
	plotnum = 4

end if
end if


labels = (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"/)
; if more columns than rows, then switch them around
if varswitch .EQ. 1 then
        temp = numrows
        numrows = numcols
        numcols = temp
end if
numProws = numrows + extra(0)
;print(numProws)
resP_1                   = True
resP_1@gsnFrame          = False
resP_1@gsnDraw		 = False	; Draw later in maximise mode
;if papertitles .EQ. 1 then
;	resP_1@txString = vartitles(0,0) + " at " + tostring(ilevs(0,0)) + " mb"
;end if
if nexps .GT. 3 then
	resP_1@txFontHeightF     = 0.011
	resP_1@txPosYF           = 0.983
else
        resP_1@txFontHeightF     = 0.011
        resP_1@txPosYF           = 0.83
end if

resP_1@gsnMaximize = True
resP_1@gsnPanelFigureStrings=labels(0:numProws-1)
if numProws .GE. 3 then
	resP_1@gsnPanelFigureStringsFontHeightF = 0.010
else
        resP_1@gsnPanelFigureStringsFontHeightF = 0.006
end if
resP_1@amJust   = "TopLeft"
resP_1@gsnPanelCenter = True
resP_1@gsnPanelTop = 0.97
resP_1@gsnPanelLeft     = 0.02


;print(numcols)

if (numcols .EQ. 1) then
	if papertitles .EQ. 1 then
	       resP_1@txString = vartitles(0,0) + " at " + tostring(ilevs(0,0)) + " mb"
	end if
else if (numcols .EQ. 2) then
        resP_1@gsnPanelRight     = 0.48

	resP_2                   = resP_1
	resP_2@gsnPanelLeft	= 0.52
        resP_2@gsnPanelRight     = 0.98
	
	resP_2@gsnPanelFigureStrings=labels(numProws:numProws*2-1)
	if nexps .GT. 3 then
		resP_2@txFontHeightF     = 0.011
		resP_2@txPosYF           = 0.983
                resP_2@txPosXF           = 0.7
                resP_1@txPosXF           = 0.25
	else
		resP_2@txFontHeightF     = 0.011
		resP_2@txPosYF           = 0.83
		resP_2@txPosXF		 = 0.7
		resP_1@txPosXF		 = 0.25
	end if
	if papertitles .EQ. 1 then
                resP_1@txString = vartitles(0,0) + " at " + tostring(ilevs(0,0)) + " mb"
		resP_2@txString = vartitles(0,1) + " at " + tostring(ilevs(0,1)) + " mb"
	end if

else if (numcols .GT. 2) then
        resP_2                   = resP_1

	resP_1@gsnPanelLeft	= 0.02
        resP_1@gsnPanelRight     = 0.33

        resP_2@gsnPanelLeft     = 0.34
        resP_2@gsnPanelRight     = 0.65
        resP_2@gsnPanelFigureStrings=labels(numProws:numProws*2-1)

        resP_3                   = resP_2
        resP_3@gsnPanelLeft     = 0.66
        resP_3@gsnPanelRight     = 0.97
       
        resP_1@txPosYF           = 0.73
        resP_2@txPosYF           = 0.73
        resP_3@txPosYF           = 0.73
 
        resP_1@txPosXF           = 0.16
        resP_2@txPosXF           = 0.48
        resP_3@txPosXF           = 0.79
        resP_3@gsnPanelFigureStrings=labels(numProws*2:numProws*3-1)

	if papertitles .EQ. 1 then
                resP_1@txString =  vartitles(0,0) + " at " + tostring(ilevs(0,0)) + " mb"
		resP_2@txString =  vartitles(0,1) + " at " + tostring(ilevs(0,1)) + " mb"
                resP_3@txString =  vartitles(0,2) + " at " + tostring(ilevs(0,2)) + " mb"

	end if

end if
end if
end if

if (numcols .GT. 3) then
	print ("not set up for 3 columns yet")
end if

if numcols .EQ. 1 then
	resP_1@txPosXF           = 0.48
	resP_1@gsnPanelXWhiteSpacePercent = 0
  	resP_1@gsnPanelRight     = 0.98
  	resP_1@gsnPanelYWhiteSpacePercent = 5
        resP_1@gsnPanelBottom = 0.1

else if numcols .EQ. 2 then
	if (latratio .le. 3) then
		resP_1@gsnPanelXWhiteSpacePercent = 0

		resP_2@gsnMaximize = True
		resP_2@amJust   = "TopLeft"
		resP_2@gsnPanelXWhiteSpacePercent = 0
		resP_2@gsnPanelCenter = True
		resP_2@gsnPanelTop = 0.97

		if (max(plotnum) .LT. 3) then
		  resP_1@gsnPanelLeft     = 0.05
		  resP_1@gsnPanelRight     = 0.5
		  resP_2@gsnPanelLeft       = 0.5
		  resP_2@gsnPanelRight       = 0.95
		  resP_1@gsnPanelBottom = 0.35
		  resP_2@gsnPanelBottom = 0.35
		  resP_2@gsnPanelYWhiteSpacePercent = 5
		  resP_1@gsnPanelYWhiteSpacePercent = 5
		else if (max(plotnum) .LT. 4) then
		  resP_1@gsnPanelLeft     = 0.02
		  resP_1@gsnPanelRight     = 0.52
		  resP_2@gsnPanelLeft       = 0.48
		  resP_2@gsnPanelRight       = 0.98
		  resP_1@gsnPanelBottom = 0.35
		  resP_2@gsnPanelBottom = 0.35
		  resP_2@gsnPanelYWhiteSpacePercent = 5
		  resP_1@gsnPanelYWhiteSpacePercent = 5
		else if (max(plotnum) .LT. 5) then
		  resP_1@gsnPanelLeft     = 0.02
		  resP_1@gsnPanelRight     = 0.5
		  resP_2@gsnPanelLeft       = 0.5
		  resP_2@gsnPanelRight       = 0.98
		  resP_1@gsnPanelBottom = 0.35
		  resP_2@gsnPanelBottom = 0.35
		  resP_2@gsnPanelYWhiteSpacePercent = 5
		  resP_1@gsnPanelYWhiteSpacePercent = 5
		else if (max(plotnum) .LT. 6) then
		  resP_1@gsnPanelLeft     = 0.03
		  resP_1@gsnPanelRight     = 0.5
		  resP_2@gsnPanelLeft       = 0.5
		  resP_2@gsnPanelRight       = 0.97
		  resP_1@gsnPanelBottom = 0.01
		  resP_2@gsnPanelBottom = 0.01
		  resP_1@gsnPanelYWhiteSpacePercent = 3
		  resP_2@gsnPanelYWhiteSpacePercent = 3
		else
		  resP_1@gsnPanelLeft       = 0.01
		  resP_1@gsnPanelRight     = 0.56
		  resP_2@gsnPanelLeft       = 0.44
		  resP_2@gsnPanelRight     = 0.99
		  resP_1@gsnPanelBottom = 0.01
		  resP_2@gsnPanelBottom = 0.01
		  resP_2@gsnPanelYWhiteSpacePercent = 3
		  resP_1@gsnPanelYWhiteSpacePercent = 3
		end if
		end if
		end if
		end if
	else
                resP_1@gsnPanelXWhiteSpacePercent = 0

                resP_2@txFontHeightF     = 0.011
                resP_2@gsnMaximize = True
                resP_2@amJust   = "TopLeft"
                resP_2@gsnPanelXWhiteSpacePercent = 0
                resP_2@gsnPanelCenter = True
                resP_2@gsnPanelTop = 0.97
                resP_2@gsnPanelFigureStringsFontHeightF = 0.011

                if (max(plotnum) .LT. 3) then
                  resP_1@gsnPanelLeft     = 0.02
                  resP_1@gsnPanelRight     = 0.5
                  resP_2@gsnPanelLeft       = 0.5
                  resP_2@gsnPanelRight       = 0.98
                  resP_1@gsnPanelBottom = 0.35
                  resP_2@gsnPanelBottom = 0.35
                  resP_2@gsnPanelYWhiteSpacePercent = 5
                  resP_1@gsnPanelYWhiteSpacePercent = 5
                else if (max(plotnum) .LT. 4) then
                  resP_1@gsnPanelLeft     = 0.02
                  resP_1@gsnPanelRight     = 0.5
                  resP_2@gsnPanelLeft       = 0.5
                  resP_2@gsnPanelRight       = 0.97
                  resP_1@gsnPanelBottom = 0.01
                  resP_2@gsnPanelBottom = 0.01
                  resP_1@gsnPanelYWhiteSpacePercent = 3
                  resP_2@gsnPanelYWhiteSpacePercent = 3
                else if (max(plotnum) .LT. 6) then
                  resP_1@gsnPanelLeft     = 0.01
                  resP_1@gsnPanelRight     = 0.48
                  resP_2@gsnPanelLeft       = 0.52
                  resP_2@gsnPanelRight       = 0.99
                  resP_1@gsnPanelBottom = 0.01
                  resP_2@gsnPanelBottom = 0.01
                  resP_1@gsnPanelYWhiteSpacePercent = 3
                  resP_2@gsnPanelYWhiteSpacePercent = 3
		else
		  print("here")
                  resP_1@gsnPanelLeft       = 0.01
                  resP_1@gsnPanelRight     = 0.48
                  resP_2@gsnPanelLeft       = 0.53
                  resP_2@gsnPanelRight     = 0.99
                  resP_1@gsnPanelBottom = 0.01
                  resP_2@gsnPanelBottom = 0.01
                  resP_2@gsnPanelYWhiteSpacePercent = 3
                  resP_1@gsnPanelYWhiteSpacePercent = 3
		end if
		end if
		end if
	end if

else if numcols .EQ. 3 then
	  resP_1@gsnPanelBottom = 0.01
	  resP_2@gsnPanelBottom = 0.0075
          resP_3@gsnPanelBottom = 0.01
          resP_1@gsnPanelTop = 0.98
          resP_2@gsnPanelTop = 0.9775
          resP_3@gsnPanelTop = 0.98
	  resP_1@gsnPanelYWhiteSpacePercent = 3
          resP_2@gsnPanelYWhiteSpacePercent = 3
          resP_3@gsnPanelYWhiteSpacePercent = 3
          resP_1@gsnPanelXWhiteSpacePercent = 0
          resP_2@gsnPanelXWhiteSpacePercent = 1.5
          resP_3@gsnPanelXWhiteSpacePercent = 0

else
	print("can't deal with more than 2 columns yet")
end if
end if
end if

if (plottype .EQ. "map" .OR. plottype .EQ. "CSZ" .OR. plottype .EQ. "CSM") then
        npanels = floattoint(ceil(panelsize/numcols))
else if (plottype .EQ. "ZMline") then
        npanels = 2
        panelsize = 4
end if
end if


;print(npanels)
print(numProws)
print(varswitch)
print(dimsizes(plots))
if varswitch .EQ. 1 then
	panelid_1 = gsn_panel_return(wks,plots(0:numProws-1,0),(/npanels,1/),resP_1)
else
        panelid_1 = gsn_panel_return(wks,plots(0,0:numProws-1),(/npanels,1/),resP_1)
end if

delete(resP_1@gsnPanelFigureStrings)
;gsn_panel(wks,plots(0,0:plotnum-1),(/npanels,1/),resP_1)               ; now draw as one plot


if numcols .GE. 2 then
	panelid_2 = gsn_panel_return(wks,plots(1,0:numProws-1),(/npanels,1/),resP_2)
	delete(resP_2@gsnPanelFigureStrings)
end if

if numcols .GE. 3 then
        panelid_3 = gsn_panel_return(wks,plots(2,0:numProws-1),(/npanels,1/),resP_3)
        delete(resP_3@gsnPanelFigureStrings)
	gsn_panel(wks,plots(2,0:numProws-1),(/npanels,1/),resP_3)               ; now draw as one plot
end if

  mres = True
  maximize_output(wks,mres)



end
