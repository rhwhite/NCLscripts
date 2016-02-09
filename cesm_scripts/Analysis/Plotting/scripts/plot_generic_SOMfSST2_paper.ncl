load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nvars = 2

lvars = new((/nvars/),"string")
llevs = new((/nvars/),"integer")
lplotmins = new((/nvars/),"float")
lplotmaxs = new((/nvars/),"float")
lplotdiffs = new((/nvars/),"float")


lvars(0) = "U"
llevs(0) = 250
lplotmins(0) = -10.0
lplotmaxs(0) = 10.0
lplotdiffs(0) = 2.0

lvars(1) = "Zvar"
llevs(1) = 850
lplotmins(1) = -750
lplotmaxs(1) = 750
lplotdiffs(1) = 150

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


blankcount = 0

secdays = 86400.0
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)

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

if (plottype .EQ. "ZMline") then
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
plotvar = new((/nvars,2,nexps,nlats,nlons/),typeof(vartest))

do ivar = 0,nvars-1

        variable = lvars(ivar)
        ilev = llevs(ivar)

        do es=0,1

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


	if (variable .EQ. "Topo" .OR. variable .EQ. "PREC") then
	       do iexp = 0,nexps-1

			filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			if (variable .EQ. "Topo") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->PHIS/9.8
			else if (variable .EQ. "PREC") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			end if
			end if
			delete(cdf_file)

		end do
	
	else if (variable .EQ. "U" .OR. variable .EQ. "V" .OR. variable .EQ. "dudz" .OR. variable .EQ. "SF" .OR. variable .EQ. "SFZA" .OR. variable .EQ. "UV") then

		do iexp = 0,nexps-1
			if (Experiments (es,iexp) .EQ. "0") then
				plotvar(ivar,es,iexp,:,:) = 0.0
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
						plotvar(ivar,es,iexp,:,:) = SFtemp
					else
						SFZM = dim_avg_n(SFtemp,1)
						do ix = 0,nlons-1
							plotvar(ivar,es,iexp,:,ix) = SFtemp(:,ix) - SFZM
						end do

					end if

				else if (variable .EQ. "U") then
					plotvar(ivar,es,iexp,:,:) = cdf_file->U(0,plev,:,:)
				else if (variable .EQ. "V") then
					plotvar(ivar,es,iexp,:,:) = cdf_file->V(0,plev,:,:)
				else if (variable .EQ. "dudz") then
					dudz = center_finite_diff_n(cdf_file->U(0,:,:,:),levs_mean,False,0,0)
					plotvar(ivar,es,iexp,:,:) = dudz(plev,:,:)
				else if (variable .EQ. "UV") then
					plotvar(ivar,es,iexp,:,:) = cdf_file->U(0,plev,:,:)
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
				plotvar(ivar,es,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) + cdf_file->DTV(0,plev,:,:) + cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)
			else if (variable .EQ. "DTCOND") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:)
			else if (variable .EQ. "QRL") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->QRL(0,plev,:,:)
			else if (variable .EQ. "QRS") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->QRS(0,plev,:,:)
			else if (variable .EQ. "DTV") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->DTV(0,plev,:,:)
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

			plotvar(ivar,es,iexp,:,:) = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

			delete(cdf_file)
		end do

	else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PRECT" .OR. variable .EQ. "TdiaSRF" .OR. variable .EQ. "TradSRF" .OR. variable .EQ. "SHFLX" .OR. variable .EQ. "LHFLX" .OR. variable .EQ. "U10") then
		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			
			if (variable .EQ. "THS") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(es,iexp,:,:))^kappa)
			else if (variable .EQ. "PRECT") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			else if (variable .EQ. "TS") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->TS(0,:,:)
			else if (variable .EQ. "TdiaSRF") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:) - cdf_file->SHFLX(0,:,:) - cdf_file->LHFLX(0,:,:)
			else if (variable .EQ. "TradSRF") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:)    
			else if (variable .EQ. "SHFLX") then
				plotvar(ivar,es,iexp,:,:) = -1.0 * cdf_file->SHFLX(0,:,:)
			else if (variable .EQ. "LHFLX") then
				plotvar(ivar,es,iexp,:,:) = -1.0 * cdf_file->LHFLX(0,:,:)
			else if (variable .EQ. "U10") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->U10(0,:,:)
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
			plotvar(ivar,es,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

			delete(cdf_file)

		end do

	else if (variable .EQ. "Zvar") then
		do iexp = 0,nexps-1

			filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
			cdf_file = addfile(dir(es) + filo, "r")

			plotvar(ivar,es,iexp,:,:) = cdf_file->Z850bpf_var(:,:)

			delete(cdf_file)
		end do

	else if (variable .EQ. "uP" .OR. variable .EQ. "uH") then
		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/EV_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

			cdf_file = addfile(dir(es) + filo, "r")
		
			if (variable .EQ. "uH") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->u_H_bpf250(:,:)
			else if (variable .EQ. "uP") then
				print("***warning*** factor of -1.0 that we don't understand yet!!!")
				plotvar(ivar,es,iexp,:,:) = -1.0 * cdf_file->u_P_bpf850(:,:)
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

			plotvar(ivar,es,iexp,:,:) = PVall(plev,:,:)
			delete(cdf_file)
		end do
	
	else if (variable .EQ. "-DuDdTHdx" .OR. variable .EQ. "-dTHdy" .OR. variable .EQ. "-dTHdx" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-Tadv") then
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		U = new((/nexps,nlats,nlons/),typeof(vartest))
		V = new((/nexps,nlats,nlons/),typeof(vartest))
		
		dTHdy = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdx = new((/nexps,nlats,nlons/),typeof(vartest))

		do iexp = 0,nexps-1
			if (Experiments(es,iexp) .EQ. "0") then
				plotvar(ivar,es,iexp,:,:) = 0.0
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
			plotvar(ivar,es,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy))
		else if (variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-DUdTHdX") then
			plotvar(ivar,es,:,:,:) = -1.0 * U * dTHdx
		else if (variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-DVdTHdY") then
			plotvar(ivar,es,:,:,:) = -1.0 * V * dTHdy
		else if (variable .EQ. "-dTHdy") then
			plotvar(ivar,es,:,:,:) = -1.0 * dTHdy
		else if (variable .EQ. "-dTHdx") then
			plotvar(ivar,es,:,:,:) = -1.0 * dTHdx
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
					plotvar(ivar,es,iexp,:,:) = cdf_file->EKE_bpf850(:,:)
				else if (variable .EQ. "divVbpfTbpf") then		
					vartemp(:,:) = cdf_file->VprTpr_bpf850(:,:)	
					plotvar(ivar,es,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)

				end if
				end if
			else if (ilev .EQ. "250") then
				if (variable .EQ. "EKEbpf") then
					plotvar(ivar,es,iexp,:,:) = cdf_file->EKE_bpf250(:,:)
				else if (variable .EQ. "divVbpfTbpf") then	
					vartemp(:,:) = cdf_file->VprTpr_bpf250(:,:)                               
					plotvar(ivar,es,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)	
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
				plotvar(ivar,es,iexp,:,:) = cdf_file->max_values(:,:)
			else if (variable .EQ. "Zlen") then
				plotvar(ivar,es,iexp,:,:) = cdf_file->lengths(:,:)
			else if (variable .EQ. "Znum") then
				plotvar(ivar,es,iexp,:,:) = tofloat(cdf_file->counter(:,:))
			else if (variable .EQ. "Zmag") then
				plotvar(ivar,es,iexp,:,:) = tofloat(cdf_file->mean_values(:,:))
			end if
			end if
			end if
			end if
		end do

	else if (variable .EQ. "-DivVprTpr") then
		var = new((/nlats,nlons/),typeof(vartest))
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/VprTpr_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			
			if (ilev .EQ. "850") then
				var = cdf_file->meanVprTHpr850
			else if (ilev .EQ. "250") then
				var = cdf_file->meanVprTHpr250
			end if
			end if

			plotvar(ivar,es,iexp,:,:) = -1.0 * center_finite_diff_n(var,lat_dist, False, 0, 0)

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

end do
end do

if (ilev .NE. 1000) then
	do es = 0,1
		do iexp = 0,nexps-1
			do iy = 0,nlons-1
				do ix = 0,nlats-1
					if (PS(es,iexp,ix,iy) .LT. ilev*100) then
						plotvar(:,es,iexp,ix,iy) = plotvar@_FillValue
					end if
				end do
			end do
		end do
	end do
end if
if (diffdiffs .EQ. "true") then
	pwidths = 3
else
	pwidths = 2
end if

if (linear .EQ. "true") then
	panelsize = pwidths*(nexps+1)
	singlesize=nexps+1
else
	panelsize = pwidths*nexps
	singlesize = nexps
end if

if (reverse .EQ. "true") then
	factor = -1.0
else
	factor = 1.0
end if

if (plottype .EQ. "map") then
        toplot = new((/2,singlesize,nlats,nlons/),typeof(plotvar))
        toplottemp = new((/nvars,2,singlesize,nlats,nlons/),typeof(plotvar))
	toplottitle = new((/2,singlesize/),"string")
	toplotPHIS = new((/2,singlesize,nlats,nlons/),typeof(PHIS))


	do ivar = 0,1

	        toplottemp(ivar,0,0,:,:) = plotvar(ivar,0,0,:,:)
	        toplottitle(0,0) = Titles(0,0)
		toplotPHIS(0,0,:,:) = 0.0

                toplottemp(ivar,1,0,:,:) = plotvar(ivar,1,0,:,:) - plotvar(ivar,0,0,:,:)
                toplottitle(1,0) = Titles(1,0) + " - " + Titles(0,0)
        	toplotPHIS(1,0,:,:) =  PHIS(1,0,:,:) - PHIS(0,0,:,:)

		toplot(ivar,0,:,:) = plotvar(ivar,1,0,:,:) - plotvar(ivar,0,0,:,:)

		print(nexps-1)
       		do ep = 1,nexps-1
        	        do iplot = 0,1

				toplot(ivar,ep,:,:) = factor * (plotvar(ivar,1,0,:,:) - plotvar(ivar,1,ep,:,:)) - factor * (plotvar(ivar,0,0,:,:) - plotvar(ivar,0,ep,:,:))
;                                toplottemp(ivar,iplot,ep,:,:) = factor * (plotvar(ivar,iplot,0,:,:) - plotvar(ivar,iplot,ep,:,:))
			
				toplotPHIS(iplot,ep,:,:) =  factor * (PHIS(iplot,0,:,:) - PHIS(iplot,ep,:,:))

				if (reverse .EQ. "true") then
	                                toplottitle(iplot,ep) = Titles(iplot,ep) + " - " + Titles(iplot,0)
	                        else
	                                toplottitle(iplot,ep) = Titles(iplot,0) + " - " + Titles(iplot,ep)
	                        end if
	                end do


;			toplot(ivar,ep,:,:) = toplottemp(ivar,1,ep,:,:) - toplottemp(ivar,0,ep,:,:)

			if (reverse .EQ. "true") then
				toplottitle(1,ep) = "(" + Titles(1,ep) + " - " + Titles(1,0) + ")" + " - " + "(" + Titles(0,ep) + " - " + Titles(0,0) + ")"
			else
				toplottitle(1,ep) = "(" + Titles(1,0) + " - " + Titles(1,ep) + ")" + " - " + "(" + Titles(0,0) + " - " + Titles(0,ep) + ")"
			end if
        	end do

	toplot!2 = "lat"
	toplot!3 = "lon"

	toplot&lat = lats
	toplot&lon = lons

	toplot&lat@units="degree_north"
	toplot&lon@units="degree_east"

	copy_VarCoords(toplot,toplotPHIS)

	end do
end if


; plot

if (plottype .EQ. "map") then
	npanels = floattoint(ceil(panelsize/2.0))
else if (plottype .EQ. "ZMline") then
	npanels = 2
	panelsize = 4
end if
end if

	plotname = lvars(0) + "_" + lvars(1) + "_" + slon + "-" + elon
	if (ilev .EQ. 0) then
		plottitle =  slon + "-" + elon
	else
		plottitle =  slon + "-" + elon
	end if

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/SOM_fSST_U250_Zvar850_" + plotname + "_" + timespan + "_" + figtitle) 


  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  plot = new(panelsize,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@gsnLeftString = ""


if (plottype .EQ. "map") then
	  res@mpCenterLonF = clon
	  res@mpMinLonF = slon
	  res@mpMaxLonF = elon
	  res@mpMinLatF = slat
	  res@mpMaxLatF = elat
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
		res@gsnSpreadColorStart  = 10                   ; start at color 10
		res@gsnSpreadColorEnd    = 96                   ; end at color 96
	;  	res@gsnAddCyclic         = True                 ; add cyclic point
		res@lbOrientation   = "Vertical"                ; vertical label bar
	  end if

	  resOv = True
	  resOv@gsnDraw = False                        ; do not draw the plot
	  resOv@gsnFrame = False                       ; do not advance the frame
	  resOv@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
	  resOv@cnLevels = (/-100.0,100.0,500.0,2000.0,4000.0/)              ; set the contour levels
	  resOv@gsnContourPosLineDashPattern = 1        ; sets negative contours to dash pattern 1
	  resOv@cnLineLabelsOn       = False
	  resOv@cnConstFLabelOn = False
	  resOv@cnInfoLabelOn       = False        ; no info label

		res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels 


		do pp = 0,singlesize-1
                res@gsnCenterString         = toplottitle(1,pp)

	                res@cnMinLevelValF  = lplotmins(0)                   ; set the minimum contour level
	                res@cnMaxLevelValF  = lplotmaxs(0)                    ; set the maximum contour level
	                res@cnLevelSpacingF       = lplotdiffs(0)      ; contour spacing

			plot(pp*2) = gsn_csm_contour_map_ce(wks,toplot(0,pp,:,:),res) ;
                        plot_ov = gsn_csm_contour(wks,toplotPHIS(0,pp,:,:),resOv)
                        overlay(plot(pp*2),plot_ov)
	
                        res@cnMinLevelValF  = lplotmins(1)                   ; set the minimum contour level
                        res@cnMaxLevelValF  = lplotmaxs(1)                    ; set the maximum contour level
                        res@cnLevelSpacingF       = lplotdiffs(1)      ; contour spacing


			res@gsnCenterString         = toplottitle(1,pp)
			plot(pp*2 + 1) = gsn_csm_contour_map_ce(wks,toplot(1,pp,:,:),res) ;
			plot_ov = gsn_csm_contour(wks,toplotPHIS(1,pp,:,:),resOv)
			overlay(plot(pp*2+1),plot_ov)
		end do


end if


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPanelBottom   = 0.1                   ; add space at bottom
  ;resP@txString   = plottitle + ", " + units

if (nexps .EQ. 4) then  
  resP@gsnPanelFigureStrings= (/"a.","e.","b.","f.","c.","g","d","h"/) ;,"e","k","f","l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
else if (nexps .EQ. 6) then
  resP@gsnPanelFigureStrings= (/"a.","g.","b.","h.","c.","i","d","j","e","k","f"/);,"l"/); (/"a.","f.","b.","g.","c.","h","d","i","e","j"/) ; add strings to panel
end if
end if

  resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

      delete(resP@gsnPanelFigureStrings)



  resP@gsnDraw = False                           ; draw later, in maximize mode

  print(blankcount)
  nplots = panelsize - blankcount
  panelid1 = gsn_panel_return(wks,plot(0:nplots-1),(/npanels,2/),resP)

  gsn_panel(wks,plot(0:nplots-1),(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
