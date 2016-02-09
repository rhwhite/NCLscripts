load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; set some defaults
diffdiffs = "false" ;;!!!!!! diffdiffs=.true. no longer an option!
linear = "false"

LineColors = (/"blue","red","green","cyan","black","yellow"/)

index = 1
difvars = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
expdif = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1

figtitle = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
nexps = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
dir = new(2,"string")
dir(0) = getenv("NCL_ARG2_" + tostring(index))
index = index + 1

Experiments = new((/2,nexps/),"string")
Titles = new((/2,nexps/),"string")
do ne = 0,nexps-1
        Experiments(0,ne) = getenv("NCL_ARG2_" + tostring(index))
	index = index + 1
end do
do ne = 0,nexps-1
        Titles(0,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do

dir(1) = getenv("NCL_ARG2_" + tostring(index))
index = index + 1

do ne = 0,nexps-1
        Experiments(1,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do
do ne = 0,nexps-1
        Titles(1,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do

print(Experiments)
startyr = new(2,"integer")
endyr = new(2,"integer")
nyears = new(2,"integer")
startyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
endyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
nyears(0) = endyr(0)-startyr(0)+1

startyr(1) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
endyr(1) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
nyears(1) = endyr(1)-startyr(1)+1
timespan = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
reverse = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
linear = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
clon = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
slon = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
elon = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
slat = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
elat = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
plottype = getenv("NCL_ARG2_" + tostring(index))
index = index + 1
plotctl = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
plotERA = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
titleprefix = getenv("NCL_ARG2_" + tostring(index))

if (slat .GT. 1000) then
	polar = "true"
else
	polar = "false"
end if

index = 1
var1 = getenv("NCL_ARG_" + tostring(index))
print(var1)
index = index + 1
ilev1 = toint(getenv("NCL_ARG_" + tostring(index)))
index = index + 1

plotchar1 = new(6,"float")
do xx = 0,5
        plotchar1(xx) = tofloat(getenv("NCL_ARG_" + tostring(index)))
        index = index + 1
end do
units1 = getenv("NCL_ARG_" + tostring(index))

if (difvars .EQ. 0) then
        print("variable the same on each side of plot")
        var2 = var1
	ilev2 = ilev1
	plotchar2 = plotchar1
else
        print("variables different - plot for paper!")
        var2 = getenv("NCL_ARG_" + tostring(index))
        print(var2)
        index = index + 1
	ilev2 = toint(getenv("NCL_ARG_" + tostring(index)))
	index = index + 1

	plotchar2 = new(6,"float")
	do xx = 0,5
	        plotchar2(xx) = tofloat(getenv("NCL_ARG_" + tostring(index)))
	        index = index + 1
	end do
	units2 = getenv("NCL_ARG_" + tostring(index))

end if

blankcount = 0

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

if (plotERA .EQ. 1 .OR. plotERA .EQ. 2) then

	; Read in ERA-I

	if (plotERA .EQ. 1) then
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

	if (ilev1 .NE. 0) then
	; Find correct pressure level
		Eplevs = new((/2/),integer)

		do nl = 0,nlevsE-1
			if levelsE(nl) .EQ. ilev1 then
				Eplevs(0) = nl
			end if
		end do

		do nl = 0,nlevsE-1
			if levelsE(nl) .EQ. ilev2 then
				Eplevs(1) = nl
			end if
		end do

		if (Eplevs(0) .LT. 0 .OR. Eplevs(1) .LT. 0) then
			print("didnt find a level")
			exit
		end if
	end if

	E_plotvar = new((/2,nlatsE,nlonsE/),typeof(Etemp))

	do es = 0,1
		if (es .EQ. 0) then
			variable = var1
			ilev = ilev1
		else
			variable = var2
			ilev = ilev2
		end if

		if (variable .EQ. "U") then
			E_plotvar(es,:,:) = tofloat(cdf_Obs->u(0,Eplevs(es),:,:))
                        if (fliplat .EQ. 1) then 
                                E_plotvar(es,:,:) = E_plotvar(es,::-1,:)
                        end if
		else if (variable .EQ. "V") then
			E_plotvar(es,:,:) = tofloat(cdf_Obs->v(0,Eplevs(es),:,:))
		        if (fliplat .EQ. 1) then 
                                E_plotvar(es,:,:) = E_plotvar(es,::-1,:)
                        end if
		else if (variable .EQ. "SFZA" .OR. variable .EQ. "SF") then

			SFtempE = new((/nlatsE,nlonsE/), typeof(Etemp))
			tempE = new((/nlatsE,nlonsE/),typeof(Etemp))
			print(Eplevs)
			print(Eplevs(es))
			E_U = tofloat(cdf_Obs->u(0,Eplevs(es),:,:))
			E_V = tofloat(cdf_Obs->v(0,Eplevs(es),:,:))
                
			if (fliplat .EQ. 1) then
                        	E_U(:,:) = E_U(::-1,:)
                                E_V(:,:) = E_V(::-1,:)
                	end if

			uv2sfvpf(E_U,E_V,SFtempE,tempE)

			if (variable .EQ. "SF") then
				E_plotvar(es,:,:) = SFtempE
			else
				SFZM = dim_avg_n(SFtempE,1)
				do ix = 0,nlonsE-1
					E_plotvar(es,:,ix) = SFtempE(:,ix) - SFZM
				end do
			delete(SFZM)

			end if
			delete(SFtempE)
			delete(tempE)
		else if (variable .EQ. "TH") then
			if (plotERA .EQ. 1) then
				E_plotvar(es,:,:) = cdf_Obs->t(0,Eplevs(es),:,:) * (1013.0/tofloat(ilev))^(kappa)
			else
                                E_plotvar(es,:,:) = cdf_Obs->th(0,Eplevs(es),:,:)
			end if

		else if (variable .EQ. "Zvar") then
			if (plotERA .EQ. 1) then
	                	fileObs2 = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_Z850bpf_DJF_6hrly_1979_37.nc"
		        	cdf_Obs2 = addfile(fileObs2, "r")
				Zbpfvar = cdf_Obs2->Z850bpf_var
	                        if (fliplat .EQ. 1) then
	                                Zbpfvar(:,:) = Zbpfvar(::-1,:)
                        	end if
	
				E_plotvar(es,:,:) = Zbpfvar
				delete(Zbpfvar)
			end if
		else if (variable .EQ. "PREC") then
                        if (plotERA .EQ. 1) then
                                fileObs2 = "/home/disk/eos4/rachel/Obs/ERAI/ERAI_DJFclim_PRECIP_1979-2015.nc"
                                cdf_Obs2 = addfile(fileObs2, "r")
                                Precip = cdf_Obs2->tp(0,:,:)
                                if (fliplat .EQ. 1) then
                                        Precip(:,:) = Precip(::-1,:)
                                end if
				; Change units: read in in m/12-hrs
				; want to change to mm/day

				Precip = Precip * (2.0) * 1000.0 
                                E_plotvar(es,:,:) = Precip
                                delete(Precip)
                        end if
		end if
		end if
		end if
		end if
		end if
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

filo = Experiments(0,0) + "/atm/hist/" + timespan + tostring(startyr(0)) + "_" + tostring(nyears(0)) + "_mean_pl_" + Experiments(0,0) + ".cam2.h0.nc"
cdf_file = addfile(dir(0) + filo, "r")

lats = cdf_file->lat
lons = cdf_file->lon

nlons = dimsizes(lons)
nlats = dimsizes(lats)

vartest = cdf_file->U

levs_mean = cdf_file->lev_p

levsizes = dimsizes(levs_mean)
nlevs = levsizes(0)

ndims2 = dimsizes(vartest)
PHIS = new((/2,nexps,nlats,nlons/),typeof(vartest))
PS = new((/2,nexps,nlats,nlons/),typeof(vartest))

if (plottype .EQ. "ZMline" .OR. plottype .EQ. "CS") then
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
	;print(dim_avg(lons(nlonstart:nlonend)))
end if

delete(cdf_file)

do iexp = 0,nexps-1
	do es = 0,1
		if (Experiments(es,iexp) .EQ. "0") then
			PS(es,iexp,:,:) = 10000.0
			PHIS(es,iexp,:,:) = 10000.0
		else
			filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir(es) + filo, "r")

			PS(es,iexp,:,:) = cdf_file->PS(0,:,:)
			PHIS(es,iexp,:,:) = cdf_file->PHIS/9.8

			delete(cdf_file)
		end if
	end do
end do

; Find which variable is to be plotted


if (plottype .EQ. "CS") then
	print("cross-section")
	plotvar = new((/2,nexps,nlevs,nlats,nlons/),typeof(vartest))
else
	plotvar = new((/2,nexps,nlats,nlons/),typeof(vartest))
	plotvar2 = new((/2,nexps,nlats,nlons/),typeof(vartest))
end if

do es = 0,1
	if (es .EQ. 0) then
		variable = var1
		ilev = ilev1
	else if (es .EQ. 1) then
		variable = var2
		ilev = ilev2
	else
		print("too many variable!")
		exit
	end if
	end if


	if (plottype .EQ. "CS") then
		print("cross-section")
		do iexp = 1,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")
                        filo2 = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file2 = addfile(diro + filo2, "r")

			U(iexp,:,:,:) = cdf_file->U(0,:,:,:)
			V(iexp,:,:,:) = cdf_file->V(0,:,:,:)
			OMEGA(iexp,:,:,:) = cdf_file->OMEGA(0,:,:,:)

			PHIS(iexp,:,:) = cdf_file2->PHIS(0,:,:)
			PS = cdf_file2->PS(0,:,:) / 100.0

			delete(cdf_file)
			delete(cdf_file2)

			do iy = 0,nlons-1
				do ix = 0,nlats-1
					do il = 0,nlevs -1
						if (PS(ix,iy) .LT. levs_mean(il)) then
							U(iexp,il,ix,iy) = U@_FillValue
                                                        V(iexp,il,ix,iy) = V@_FillValue
                                                        TH(iexp,il,ix,iy) = TH@_FillValue
                                                        OMEGA(iexp,il,ix,iy) = OMEGA@_FillValue
						end if
					end do
				end do
			end do

			if (variable .EQ. "U") then
				plotvar = U
			else if (variable .EQ. "V") then
				plotvar = V
			else if (variable .EQ. "OMEGA") then
				plotvar = OMEGA
			else if (variable .EQ. "TH") then
				plotvar = TH
			end if
			end if
			end if
			end if 

		end do


	else

		var = new((/nexps,nlats,nlons/),typeof(vartest))
		if (ilev .NE. 0) then
		; Find correct pressure level
			plev = -1

			do nl = 0,nlevs-1
				if levs_mean(nl) .EQ. ilev then
					plev = nl
				end if
			end do

			if (plev .LT. 0) then
				print("didnt find a level")
				exit
			end if
		end if

		if (variable .EQ. "U" .OR. variable .EQ. "V" .OR. variable .EQ. "dudz" .OR. variable .EQ. "SF" .OR. variable .EQ. "SFZA" .OR. variable .EQ. "UV") then

			do iexp = 0,nexps-1
				if (Experiments (es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
					blankcount = blankcount + 1
				else

					filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
					cdf_file = addfile(dir(es) + filo, "r")

					levs_mean = cdf_file->lev_p

					; Check levs
					if levs_mean(plev) .NE. ilev then
						print("should be " + tostring(ilev))
						exit
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
					end if
					end if
					end if
					end if
					end if
					delete(cdf_file)
				end if
			end do

		else if (variable .EQ. "Tdia" .OR. variable .EQ. "DTCOND" .OR. variable .EQ. "DTV" .OR. variable .EQ. "QRL" .OR. variable .EQ. "QRS") then
			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir(es) + filo, "r")
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
			end do

		else if (variable .EQ. "TH") then

			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir(es) + filo, "r")

				levs_mean = cdf_file->lev_p

				; Check levs
				if levs_mean(plev) .NE. ilev then
					print("should be " + tostring(ilev))
					exit
				end if

				plotvar(es,iexp,:,:) = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

				delete(cdf_file)
			end do

		else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PREC" .OR. variable .EQ. "Topo" .OR. variable .EQ. "TdiaSRF" .OR. variable .EQ. "TradSRF" .OR. variable .EQ. "SHFLX" .OR. variable .EQ. "LHFLX" .OR. variable .EQ. "U10") then
			
			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir(es) + filo, "r")
				
				if (variable .EQ. "THS") then
					plotvar(es,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(es,iexp,:,:))^kappa)
				else if (variable .EQ. "PREC") then
					plotvar(es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
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
			end do

		else if (variable .EQ. "EMGR") then
			do iexp = 0,nexps-1

				filo = Experiments(es,iexp) + "/atm/hist/EMGR_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h0.nc"

				cdf_file = addfile(dir(es) + filo, "r")
				plotvar(es,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

				delete(cdf_file)

			end do

		else if (variable .EQ. "Zvar") then
			do iexp = 0,nexps-1

				if (Experiments(es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
				else

					filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
					cdf_file = addfile(dir(es) + filo, "r")

					plotvar(es,iexp,:,:) = cdf_file->Z850bpf_var(:,:)

					delete(cdf_file)
				end if
			end do


		else if (variable .EQ. "uP" .OR. variable .EQ. "uH") then
			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/EV_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

				cdf_file = addfile(dir(es) + filo, "r")
			
				if (variable .EQ. "uH") then
					plotvar(es,iexp,:,:) = cdf_file->u_H_bpf250(:,:)
				else if (variable .EQ. "uP") then
					print("***warning*** factor of -1.0 that we don't understand yet!!!")
					plotvar(es,iexp,:,:) = -1.0 * cdf_file->u_P_bpf850(:,:)
				end if
				end if
			
				delete(cdf_file)
			end do

		else if (variable .EQ. "PV") then
			do iexp = 0,nexps-1

				filo = Experiments(es,iexp) + "/atm/hist/" + timespan +tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
				cdf_file = addfile(dir(es) + filo, "r")

				levs_mean = cdf_file->lev_p
				; Check levs
				if levs_mean(plev) .NE. ilev then
					print("should be " + tostring(ilev))
					exit
				end if

				PVlevs = levs_mean * 100.0
				PVlevs@units = "Pa"

				T = cdf_file->T(0,:,:,:)
				U = cdf_file->U(0,:,:,:)
				V = cdf_file->V(0,:,:,:)
				PVlats = cdf_file->lat

				gridtype = 1 ; regular grid
				opt = 0 ; just potential vorticity for now
				PVall = pot_vort_isobaric(PVlevs,U,V,T,PVlats, gridtype, opt)

				plotvar(es,iexp,:,:) = PVall(plev,:,:)
				delete(cdf_file)
			end do
		
		else if (variable .EQ. "vort" .OR. variable .EQ. "-DuDdTHdx" .OR. variable .EQ. "-dTHdy" .OR. variable .EQ. "-dTHdx" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-Tadv") then
			lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

			U = new((/nexps,nlats,nlons/),typeof(vartest))
			V = new((/nexps,nlats,nlons/),typeof(vartest))
			
			dTHdy = new((/nexps,nlats,nlons/),typeof(vartest))
			dTHdx = new((/nexps,nlats,nlons/),typeof(vartest))

			vort = new((/nexps,nlats,nlons/),typeof(vartest))

			do iexp = 0,nexps-1
				if (Experiments(es,iexp) .EQ. "0") then
					plotvar(es,iexp,:,:) = 0.0
					blankcount = blankcount + 1
				else

					filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
					cdf_file = addfile(dir(es) + filo, "r")

					levs_mean = cdf_file->lev_p
					
					; Check levs
					if levs_mean(plev) .NE. ilev then
						print("should be " + tostring(ilev))
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
			end do
		
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

		else if (variable .EQ. "EKEbpf" .OR. variable .EQ. "divVbpfTbpf") then
			vartemp = new((/nlats,nlons/),typeof(vartest))
			lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/EKE_mean_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

				cdf_file = addfile(dir(es) + filo, "r")

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
			end do

		else if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/Z850_bpf_Events_" + tostring(ilev) + "_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".nc"

				cdf_file = addfile(dir(es) + filo, "r")

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
			end do

		else if (variable .EQ. "-DivVprTpr") then
			VprTpr = new((/nlats,nlons/),typeof(vartest))
			lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

			do iexp = 0,nexps-1
				filo = Experiments(es,iexp) + "/atm/hist/VprTpr_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
				cdf_file = addfile(dir(es) + filo, "r")
				
				if (ilev .EQ. "850") then
					VprTpr = cdf_file->meanVprTHpr850
				else if (ilev .EQ. "250") then
					VprTpr = cdf_file->meanVprTHpr250
				end if
				end if

				plotvar(es,iexp,:,:) = -1.0 * center_finite_diff_n(VprTpr,lat_dist, False, 0, 0)

			end do

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

	if (ilev .NE. 1000) then
		do iexp = 0,nexps-1
			do iy = 0,nlons-1
				do ix = 0,nlats-1
					if (PS(es,iexp,ix,iy) .LT. (ilev*100 + 2000)) then
						plotvar(es,iexp,ix,iy) = plotvar@_FillValue
						if (variable .EQ. "UV") then
							plotvar2(es,iexp,ix,iy) = plotvar2@_FillValue
						end if
					end if
				end do
			end do
		end do
	end if


end do

if (diffdiffs .EQ. "true") then
	pwidths = 3
else
	pwidths = 2
end if

panelsize = pwidths * nexps
singlesize = nexps
if (linear .EQ. "true") then
	panelsize = panelwize + pwidths
	singlesize= singlesize + pwidths
end if
if (plotctl .EQ. 0) then
	panelsize = panelsize - pwidths
end if
if (plotERA .GE. 1) then
	panelsize = panelsize + pwidths
end if

if (reverse .EQ. "true") then
	factor = -1.0
else
	factor = 1.0
end if

if (plottype .EQ. "map") then
        toplot = new((/2,singlesize,nlats,nlons/),typeof(plotvar))
        toplot2 = new((/2,singlesize,nlats,nlons/),typeof(plotvar))
	toplottitle = new((/2,singlesize/),"string")
	toplotPHIS = new((/2,singlesize,nlats,nlons/),typeof(PHIS))


        toplot(0,0,:,:) = plotvar(0,0,:,:)
        toplottitle(0,0) = Titles(0,0)
	toplotPHIS(0,0,:,:) = 0.0

        if (expdif .EQ. 1) then
                toplot(1,0,:,:) = plotvar(1,0,:,:) - plotvar(0,0,:,:)
                toplottitle(1,0) = Titles(1,0) + " - " + Titles(0,0)
        	toplotPHIS(1,0,:,:) =  PHIS(1,0,:,:) - PHIS(0,0,:,:)
	else
                toplot(1,0,:,:) = plotvar(1,0,:,:)
                toplottitle(1,0) = Titles(1,0)
		toplotPHIS(1,0,:,:) = 0.0
        end if

	if (variable .EQ. "UV") then
		toplot2(0,0,:,:) = plotvar2(0,0,:,:)
	        if (expdif .EQ. 1) then
			toplot2(1,0,:,:) = plotvar2(1,0,:,:) - plotvar(0,0,:,:)
		else
			toplot2(1,0,:,:) = plotvar2(1,0,:,:)
		end if
	end if


        do ep = 1,nexps-1
                do iplot = 0,1
                        if (variable .EQ. "-DuDdTHdx") then
                                toplot(iplot,ep,:,:) = factor * plotvar(iplot,ep,:,:)
                        else
                                toplot(iplot,ep,:,:) = factor * (plotvar(iplot,0,:,:) - plotvar(iplot,ep,:,:))
				if (variable .EQ. "UV") then
					toplot2(iplot,ep,:,:) = factor * (plotvar2(iplot,0,:,:) - plotvar2(iplot,ep,:,:))
				end if
			end if
			
			toplotPHIS(iplot,ep,:,:) =  factor * (PHIS(iplot,0,:,:) - PHIS(iplot,ep,:,:))

			if (reverse .EQ. "true") then
                                toplottitle(iplot,ep) = Titles(iplot,ep) + " - " + Titles(iplot,0)
                        else
                                toplottitle(iplot,ep) = Titles(iplot,0) + " - " + Titles(iplot,ep)
                        end if
                end do

                if (linear .EQ. "true") then
                        if (nexps .NE. 4) then
                                print("linear only compatible with 4 experiments")
                                exit
                        end if

                        do iplot=0,1
                                toplot(iplot,nexps,:,:) = plotvar(iplot,0,:,:) - plotvar(iplot,1,:,:) - plotvar(iplot,2,:,:) + plotvar(iplot,3,:,:)
                                if (variable .EQ. "UV") then
                                        toplot2(iplot,nexps,:,:) = plotvar2(iplot,0,:,:) - plotvar2(iplot,1,:,:) - plotvar2(iplot,2,:,:) + plotvar2(iplot,3,:,:)
                                end if
                                toplotPHIS(iplot,nexps,:,:) = PHIS(iplot,0,:,:) - PHIS(iplot,1,:,:) - PHIS(iplot,2,:,:) + PHIS(iplot,3,:,:)
                                toplottitle(iplot,nexps) = Titles(iplot,0) + " - " + Titles(iplot,1) + " - " + Titles(iplot,2) + " + " + Titles(iplot,3)
                        end do
                end if

		if (expdif .EQ. 1) then
			toplot(1,ep,:,:) = toplot(1,ep,:,:) - toplot(0,ep,:,:)

			if (reverse .EQ. "true") then
				toplottitle(1,ep) = "(" + Titles(1,ep) + " - " + Titles(1,0) + ")" + " - " + "(" + Titles(0,ep) + " - " + Titles(0,0) + ")"
			else
				toplottitle(1,ep) = "(" + Titles(1,0) + " - " + Titles(1,ep) + ")" + " - " + "(" + Titles(0,0) + " - " + Titles(0,ep) + ")"
			end if
		end if
        end do

	toplot!2 = "lat"
	toplot!3 = "lon"

	toplot&lat = lats
	toplot&lon = lons

	toplot&lat@units="degree_north"
	toplot&lon@units="degree_east"

	copy_VarCoords(toplot,toplotPHIS)
	if (variable .EQ. "UV") then
		copy_VarCoords(toplot,toplot2)
	end if

else if (plottype .EQ. "ZMline")
        toplot = new((/2,nexps+1,nlats/),typeof(plotvar))
	toplottitle = new((/2,nexps+1/),"string")
	
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
		do iplot = 0,1
			if (variable .EQ. "-DuDdTHdx") then
				toplot(iplot,ep,:,:) = factor * dim_avg_n(plotvar(iplot,ep,:,nlonstart:nlonend),1)
			else
				toplot(iplot,ep,:) = factor * (dim_avg_n(plotvar(iplot,0,:,nlonstart:nlonend),1) - dim_avg_n(plotvar(iplot,ep,:,nlonstart:nlonend),1))	
			end if
			if (reverse .EQ. "true") then
				toplottitle(iplot,ep) = Titles(iplot,ep) + " - " + Titles(iplot,0)
			else
				toplottitle(iplot,ep) = Titles(iplot,0) + " - " + Titles(iplot,ep)
			end if
		end do

		if (expdif .EQ. 1) then
			toplot(1,ep,:,:) = toplot(1,ep,:,:) - toplot(0,ep,:,:)
			
			if (reverse .EQ. "true") then
				toplottitle(iplot,ep) = "(" + Titles(1,ep) + " - " + Titles(1,0) + ")" + " - " + "(" + Titles(0,ep) + " - " + Titles(0,0) + ")"
			else
				toplottitle(iplot,ep) = "(" + Titles(1,0) + " - " + Titles(1,ep) + ")" + " - " + "(" + Titles(0,0) + " - " + Titles(0,ep) + ")"
			end if
		end if
	end do
	

	toplot!2 = "lat"
	toplot&lat = lats
	toplot&lat@units="degree_north"

else if (plottype .EQ. "CS") then
	print("cross-section")
        toplot = new((/2,singlesize,nlevs,nlats/),typeof(plotvar))
        toplot2 = new((/2,singlesize,nlevs,nlats/),typeof(plotvar))
        toplottitle = new((/2,singlesize/),"string")
        
        toplot(0,0,:,:) = dim_avg_n(plotvar(0,0,:,:,nlonstart:nlonend),2)
        toplottitle(0,0) = Titles(0,0)

        do ep = 1,nexps-1
                do iplot = 0,1
                	toplot(iplot,ep,:,:) = factor *(dim_avg_n(plotvar(iplot,0,:,:,nlonstart:nlonend),2) - dim_avg_n(plotvar(iplot,ep,:,:,nlonstart:nlonend),2))

                        if (reverse .EQ. "true") then
                                toplottitle(iplot,ep) = Titles(iplot,ep) + " - " + Titles(iplot,0)
                        else
                                toplottitle(iplot,ep) = Titles(iplot,0) + " - " + Titles(iplot,ep)
                        end if
       		end do
	end do 

	toplot!1 = "lev"
	toplot!2 = "lat"

	toplot&lev = levs_mean
	toplot&lat = lats

	toplot&lat@units="degrees_north"
	toplot&lev@units="mb"

end if
end if
end if

; plot

if (plottype .EQ. "map" .OR. plottype .EQ. "CS") then
	npanels = floattoint(ceil(panelsize/2.0))
else if (plottype .EQ. "ZMline") then
	npanels = 2
	panelsize = 4
end if
end if

if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
	plotname = variable + tostring(ilev) + "_" + plottype + "_" + slon + "-" + elon
	plottitle = variable + " threshold " + tostring(ilev)  + " " + slon + "-" + elon
else
	if (ilev .EQ. 0) then
	  plotname = var1 + "_" + var2 + "_" + plottype + "_" + slon + "-" + elon
	  plottitle = variable  + "_" + slon + "-" + elon
	else
	  plotname = var1 + tostring(ilev1) + "_" + var2 + tostring(ilev2) + "_" + plottype + "_" + slon + "-" + elon
	  plottitle = variable + " at " + tostring(ilev) + "mb, " + " " + slon + "-" + elon
	end if
end if

if (difvars .EQ. "1") then
	plottitle = ""
end if

if (diffdiffs .EQ. "true")
  plotname = plotname + "_dds"
end if

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/" + titleprefix + plotname + "_" + timespan + "_" + figtitle) 


  gsn_define_colormap(wks,"BlueWhiteOrangeRed")         ; choose colormap
  plot = new(panelsize,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@gsnLeftString = ""
  res@cnMissingValFillColor = "white"
  res@lbOrientation   = "Vertical"                ; vertical label bar

if (plottype .EQ. "map") then
	if (polar .NE. "true") then
		  res@mpCenterLonF = clon
		  res@mpMinLonF = slon
		  res@mpMaxLonF = elon
		  res@mpMinLatF = slat
		  res@mpMaxLatF = elat
	  
	else
		res@gsnPolar = "NH"
	end if

	res@gsnLeftString = ""
	if (variable .EQ. "UV") then
		res@vcRefMagnitudeF         = 5.0              ; make vectors larger
		res@vcRefLengthF            = 0.050            ; ref vec length
		res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
		res@vcMinDistanceF          = 0.017            ; thin out vectors
	else
		res@cnFillOn             = True                 ; turn on color fill
		res@cnLinesOn            = False                ; turn off contour lines
		res@gsnSpreadColors      = True                 ; use full colormap
		;		res@gsnSpreadColorStart  = 10                   ; start at color 10
		;		res@gsnSpreadColorEnd    = 96                   ; end at color 96
		;  	res@gsnAddCyclic         = True                 ; add cyclic point
		res@lbOrientation   = "Vertical"                ; vertical label bar
	end if

	  resOv = True
	  resOv@gsnDraw = False                        ; do not draw the plot
	  resOv@gsnFrame = False                       ; do not advance the frame
	  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
	  resOv@cnLevels = (/500.0,1500.0,2500.0,3500.0/)              ; set the contour levels
	  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
	  resOv@cnLineLabelsOn       = False
	  resOv@cnConstFLabelOn = False
	  resOv@cnInfoLabelOn       = False        ; no info label

	if (variable .EQ. "UV") then
		do pp = 0,singlesize-1
			res@gsnCenterString         = toplottitle(0,pp)
			plot(pp*2) = gsn_csm_vector_map_ce(wks,toplot(0,pp,:,:),toplot2(0,pp,:,:),res) ;
			plot_ov = gsn_csm_contour(wks,toplotPHIS(0,pp,:,:),resOv)
			overlay(plot(pp),plot_ov)

                        res@gsnCenterString         = toplottitle(1,pp)
                        plot((pp*2)+1) = gsn_csm_vector_map_ce(wks,toplot(1,pp,:,:),toplot2(1,pp,:,:),res) ;
                        plot_ov = gsn_csm_contour(wks,toplotPHIS(1,pp,:,:),resOv)
                        overlay(plot(pp*2+1),plot_ov)
		end do

	else
		plotnum = 0
		res@cnLevelSelectionMode = "ManualLevels"       ; manually set the contour levels

		if (plotERA .EQ. 1 .OR. plotERA .EQ. 2) then

			res@cnMinLevelValF  = plotchar1(0)                   ; set the minimum contour level
			res@cnMaxLevelValF  = plotchar1(1)                    ; set the maximum contour level
			res@cnLevelSpacingF       = plotchar1(2)      ; contour spacing
			if (plotERA .EQ. 1) then
				res@gsnCenterString = "ERA-I, 1979-2015"
			else
                                res@gsnCenterString = "NCAR-NCEP"
			end if
			if (polar .EQ. "true") then
				plot(plotnum) = gsn_csm_contour_map_polar(wks,E_plotvar(0,:,:),res)
			else
				plot(plotnum) = gsn_csm_contour_map_ce(wks,E_plotvar(0,:,:),res) ;
			end if
			plotnum = plotnum + 1

			res@cnMinLevelValF  = plotchar2(0)                   ; set the minimum contour level
			res@cnMaxLevelValF  = plotchar2(1)                    ; set the maximum contour level
			res@cnLevelSpacingF       = plotchar2(2)      ; contour spacing
                        if (polar .EQ. "true") then
                                plot(plotnum) = gsn_csm_contour_map_polar(wks,E_plotvar(1,:,:),res)
                        else
				plot(plotnum) = gsn_csm_contour_map_ce(wks,E_plotvar(1,:,:),res) ;
			end if
			plotnum = plotnum + 1
		end if

		res@cnMinLevelValF  = plotchar1(0)                   ; set the minimum contour level
		res@cnMaxLevelValF  = plotchar1(1)                    ; set the maximum contour level
		res@cnLevelSpacingF       = plotchar1(2)      ; contour spacing
		
		if (plotctl .EQ. 1) then

			res@gsnCenterString         = toplottitle(0,0)
                        if (polar .EQ. "true") then
			        plot(plotnum) = gsn_csm_contour_map_polar(wks,toplot(0,0,:,:),res)
                        else
				plot(plotnum) = gsn_csm_contour_map_ce(wks,toplot(0,0,:,:),res) ;
			end if
			plotnum = plotnum + 1

			if (expdif .EQ. 1) then
				res@cnMinLevelValF  = plotchar1(3)    
				res@cnMaxLevelValF  = plotchar1(4)     
				res@cnLevelSpacingF       = plotchar1(5)
			else
				res@cnMinLevelValF  = plotchar2(0)       
				res@cnMaxLevelValF  = plotchar2(1)        
				res@cnLevelSpacingF       = plotchar2(2)   

			end if

			res@gsnCenterString         = toplottitle(1,0)
                        if (polar .EQ. "true") then
                                plot(plotnum) = gsn_csm_contour_map_polar(wks,toplot(1,0,:,:),res)
                        else
				plot(plotnum) = gsn_csm_contour_map_ce(wks,toplot(1,0,:,:),res) ;
			end if	
			plotnum = plotnum + 1
		end if

		do pp = 1,singlesize-1
			res@cnMinLevelValF  = plotchar1(3)                    ; set the minimum contour level
			res@cnMaxLevelValF  = plotchar1(4)                     ; set the maximum contour level
			res@cnLevelSpacingF       = plotchar1(5)      ; contour spacing

			res@gsnCenterString         = toplottitle(0,pp)
                        if (polar .EQ. "true") then
                                plot(plotnum) = gsn_csm_contour_map_polar(wks,toplot(0,pp,:,:),res)
                        else
				plot(plotnum) = gsn_csm_contour_map_ce(wks,toplot(0,pp,:,:),res) ;
				plot_ov = gsn_csm_contour(wks,toplotPHIS(0,pp,:,:),resOv)
				overlay(plot(plotnum),plot_ov)
			end if
			plotnum = plotnum + 1

                        res@cnMinLevelValF  = plotchar2(3)                    ; set the minimum contour level
                        res@cnMaxLevelValF  = plotchar2(4)                     ; set the maximum contour level
                        res@cnLevelSpacingF       = plotchar2(5)      ; contour spacing

                        res@gsnCenterString         = toplottitle(1,pp)
                        if (polar .EQ. "true") then
				plot(plotnum) = gsn_csm_contour_map_polar(wks,toplot(1,pp,:,:),res)
                        else
                        	plot(plotnum) = gsn_csm_contour_map_ce(wks,toplot(1,pp,:,:),res) ;
				plot_ov = gsn_csm_contour(wks,toplotPHIS(1,pp,:,:),resOv)
				overlay(plot(plotnum),plot_ov)
			end if
			plotnum = plotnum + 1

		end do

	end if

else if (plottype .EQ. "CS") then
	print("cross-section")

  res@trYMinF = 50.0
  res@trYMaxF = 1000.0
;  res@trXMinF = 48.0
;  res@trXMaxF = 96.0

;  res@tmXBMode        = "Explicit"
;  res@tmXBValues      = (/120.0,140.0,160.0,180.0,200.0,220.0,241.0/)
;  res@tmXBLabels      = (/"0N","15N","30N","45N","60N","75N","90N"/)

;  res@lbLabelAutoStride    = True                 ; optimal labels

  res@tmYRMode             = "Automatic"          ; turn off special labels on right axis


  res@cnLevelSelectionMode = "ManualLevels"     ; manually set the contour levels with the following 3 resources

	plotnum = 0
	res@cnMinLevelValF  = plotchar1(0)                   ; set the minimum contour level
	res@cnMaxLevelValF  = plotchar1(1)                    ; set the maximum contour level
	res@cnLevelSpacingF       = plotchar1(2)      ; contour spacing

	if (plotctl .EQ. 1) then

		res@gsnCenterString         = toplottitle(0,0)
		plot(plotnum) = gsn_csm_pres_hgt(wks,toplot(0,0,:,:),res) ;

		plotnum = plotnum + 1

		res@cnMinLevelValF  = plotchar2(0)
		res@cnMaxLevelValF  = plotchar2(1)
		res@cnLevelSpacingF       = plotchar2(2)

		res@gsnCenterString         = toplottitle(1,0)
		plot(plotnum) = gsn_csm_pres_hgt(wks,toplot(1,0,:,:),res) ;
		plotnum = plotnum + 1
	end if



	do pp = 1,singlesize-1
		res@cnMinLevelValF  = plotchar1(3)                    ; set the minimum contour level
		res@cnMaxLevelValF  = plotchar1(4)                     ; set the maximum contour level
		res@cnLevelSpacingF       = plotchar1(5)      ; contour spacing

		res@gsnCenterString         = toplottitle(0,pp)
                plot(plotnum) = gsn_csm_pres_hgt(wks,toplot(0,pp,:,:),res) ;
		plotnum = plotnum + 1

		res@cnMinLevelValF  = plotchar2(3)                    ; set the minimum contour level
		res@cnMaxLevelValF  = plotchar2(4)                     ; set the maximum contour level
		res@cnLevelSpacingF       = plotchar2(5)      ; contour spacing

		res@gsnCenterString         = toplottitle(1,pp)
		plot(plotnum) = gsn_csm_pres_hgt(wks,toplot(1,pp,:,:),res) ;
		plotnum = plotnum + 1

	end do
  
else if (plottype .EQ. "ZMline") then

        res@gsnLeftString = ""
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

	res@gsnCenterString         = toplottitle(0,0)
	plot(0) = gsn_csm_xy(wks,toplot&lat,toplot(0,0,:),res) ;
	res@gsnCenterString         = toplottitle(1,0)
	plot(1) = gsn_csm_xy(wks,toplot&lat,toplot(1,0,:),res) ;

	res@trYMinF  = plotchar1(3)                    ; set the minimum contour level
	res@trYMaxF  = plotchar1(4)                     ; set the maximum contour level

        res@pmLegendDisplayMode    = "Always"              ; turn on legend
        res@pmLegendSide           = "Bottom"                 ; Change location of
	res@pmLegendParallelPosF   = .5                  ; move units right
	res@pmLegendOrthogonalPosF = -0.4                ; move units down
	res@pmLegendWidthF         = 0.2
	res@lgPerimOn              = False               ; turn off box around
	res@lgLabelFontHeightF     = .015                 ; label font height

        res@xyExplicitLegendLabels = toplottitle(0,1:nexps-1)
	plot(2) = gsn_csm_xy(wks,toplot&lat,toplot(0,1:nexps-1,:),res) ;
        res@xyExplicitLegendLabels = toplottitle(1,1:nexps-1)
        plot(3) = gsn_csm_xy(wks,toplot&lat,toplot(1,1:nexps-1,:),res) ;
	plotnum = 4

end if
end if
end if

  resP                  = True                   ; modify the panel plot
;    a4_height = 29.7 ; in centimeters, if my
;    a4_width = 23.0 ; reference is correct
;    cm_per_inch = 2.54
    resP@gsnMaximize = True
;    resP@gsnPaperWidth = a4_width/cm_per_inch
;    resP@gsnPaperHeight = a4_height/cm_per_inch


  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
;  resP@gsnPanelTop   = 0.95                   ; add space at top

  ;resP@txString   = plottitle + ", " + units

if (plotnum .EQ. 8) then  
  resP@gsnPanelFigureStrings= (/"a.","e.","b.","f.","c.","g","d","h"/) ;,"e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
else if (plotnum .EQ. 6) then
  resP@gsnPanelFigureStrings= (/"a.","d.","b.","e.","c.","f"/)
else if (plotnum .EQ. 10) then
  resP@gsnPanelFigureStrings= (/"a.","f.","b.","g.","c.","h","d","i","e","j"/);
else if (plotnum .EQ. 12) then
  resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
end if
end if
end if
end if

  resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)



  resP@gsnDraw = False                           ; draw later, in maximize mode

  panelid1 = gsn_panel_return(wks,plot(0:plotnum-1),(/npanels,2/),resP)

  gsn_panel(wks,plot(0:plotnum-1),(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
