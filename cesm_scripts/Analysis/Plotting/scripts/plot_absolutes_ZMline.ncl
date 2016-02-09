load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

nvars = 8

x = 850

lvars = new((/nvars/),"string")
llevs = new((/nvars/),"integer")
lplotmins = new((/nvars/),"float")
lplotmaxs = new((/nvars/),"float")

lvars(0) = "U"
llevs(0) = 250
lplotmins(0) = 40.0
lplotmaxs(0) = 65.0

lvars(1) = "-DVdTHdY" ;"V"
llevs(1) = x
lplotmins(1) = -2.5e-5
lplotmaxs(1) = 2.5e-5

;lvars(2) = "TH"
;llevs(2) = x
;lplotmins(2) = -4.0
;lplotmaxs(2) = 4.0

lvars(2) = "-dTHdy"
llevs(2) = x
lplotmins(2) = -1.0e-5
lplotmaxs(2) = 1.0e-5


lvars(3) = "V"
llevs(3) = 850
lplotmins(3) = -4.0
lplotmaxs(3) = 4.0

lvars(4) = "-DVdTHdY-UDdTHdX-DOMdTHdp"
llevs(4) = x
lplotmins(4) = -2.5e-5
lplotmaxs(4) = 2.5e-5

;lvars(5) = "-DVdTHdY-UDdTHdX-DOMdTHdp"
;llevs(5) = 500
;lplotmins(5) = -2.5e-5
;lplotmaxs(5) = 2.5e-5

lvars(5) = "-DOMdTHdp"
llevs(5) = x
lplotmins(5) = -2.5e-5
lplotmaxs(5) = 2.5e-5

lvars(6) = "-UDdTHdX"
llevs(6) = x
lplotmins(6) = -2.5e-5
lplotmaxs(6) = 2.5e-5

;lvars(5) = "SF"
;llevs(5) = 850
;lplotmins(5) = -5.5e6
;lplotmaxs(5) = 5.5e6

lvars(7) = "-DOMdTHdp"
llevs(7) = 500
lplotmins(7) = -2.5e-5
lplotmaxs(7) = 2.5e-5

;lvars(7) = "dTHdp" ;"V"
;llevs(7) = 850
;lplotmins(7) = -1.5e-4
;lplotmaxs(7) = 1.5e-4

;lvars(8) = "OM"
;llevs(8) = 850
;lplotmins(8) = -2e-2
;lplotmaxs(8) = 2e-2

;lvars(7) = "SF"
;llevs(7) = 850
;lplotmins(7) = -5.5e6
;lplotmaxs(7) = 5.5e6



; set some defaults
diffdiffs = "false" ;;!!!!!! diffdiffs=.true. no longer an option!
linear = "false"

LineColors = (/32,50,90,146,187,220,239/)
dashpatterns = (/0,0,0,0,0,0,11/)

;LineColors = (/"blue","red","green","cyan","black",239/)

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
index = index + 1
plotctl = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
plotERA = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
titleprefix = getenv("NCL_ARG2_" + tostring(index))



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
PHIS = new((/nexps,nlats,nlons/),typeof(vartest))
PS = new((/nexps,nlats,nlons/),typeof(vartest))

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
	es = 0
	if (Experiments(es,iexp) .EQ. "0") then
		PS(iexp,:,:) = 10000.0
		PHIS(iexp,:,:) = 10000.0
	else
		filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
		cdf_file = addfile(dir(es) + filo, "r")

		PS(iexp,:,:) = cdf_file->PS(0,:,:)
		PHIS(iexp,:,:) = cdf_file->PHIS/9.8

		delete(cdf_file)
	end if
end do

; Find which variable is to be plotted
plotvar = new((/nvars,nexps,nlats,nlons/),typeof(vartest))
dia_gen_temp = new((/nexps-1,nlats,nlons/),typeof(vartest))
Hor_500_temp = new((/nexps-1,nlats,nlons/),typeof(vartest))

do ivar = 0,nvars -1
	es = 0

	variable = lvars(ivar)
	ilev = llevs(ivar)

	print(variable)	
	print(ilev)
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
				plotvar(ivar,iexp,:,:) = cdf_file->PHIS/9.8
			else if (variable .EQ. "PREC") then
				plotvar(ivar,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			end if
			end if
			delete(cdf_file)

		end do
	
	else if (variable .EQ. "U" .OR. variable .EQ. "V" .OR. variable .EQ. "dudz" .OR. variable .EQ. "SF" .OR. variable .EQ. "SFZA" .OR. variable .EQ. "UV") then

		do iexp = 0,nexps-1
			if (Experiments (es,iexp) .EQ. "0") then
				plotvar(ivar,iexp,:,:) = 0.0
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
						plotvar(ivar,iexp,:,:) = SFtemp
					else
						SFZM = dim_avg_n(SFtemp,1)
						do ix = 0,nlons-1
							plotvar(ivar,iexp,:,ix) = SFtemp(:,ix) - SFZM
						end do

					end if

				else if (variable .EQ. "U") then
					plotvar(ivar,iexp,:,:) = cdf_file->U(0,plev,:,:)
				else if (variable .EQ. "V") then
					plotvar(ivar,iexp,:,:) = cdf_file->V(0,plev,:,:)
				else if (variable .EQ. "dudz") then
					dudz = center_finite_diff_n(cdf_file->U(0,:,:,:),levs_mean,False,0,0)
					plotvar(ivar,iexp,:,:) = dudz(plev,:,:)
				else if (variable .EQ. "UV") then
					plotvar(ivar,iexp,:,:) = cdf_file->U(0,plev,:,:)
					plotvar2(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
				end if
				end if
				end if
				end if
				end if
				delete(cdf_file)
			end if
		end do

	else if (variable .EQ. "THdia" .OR. variable .EQ. "DTCOND" .OR. variable .EQ. "DTV" .OR. variable .EQ. "QRL" .OR. variable .EQ. "QRS") then
		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			levs_mean = cdf_file->lev_p

			; Check levs
			if levs_mean(plev) .NE. ilev then
				print("should be " + tostring(ilev))
				exit
			end if

			if (variable .EQ. "THdia") then
				plotvar(ivar,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) + cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)
			else if (variable .EQ. "DTCOND") then
				plotvar(ivar,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:)
			else if (variable .EQ. "QRL") then
				plotvar(ivar,iexp,:,:) = cdf_file->QRL(0,plev,:,:)
			else if (variable .EQ. "QRS") then
				plotvar(ivar,iexp,:,:) = cdf_file->QRS(0,plev,:,:)
			else if (variable .EQ. "DTV") then
				plotvar(ivar,iexp,:,:) = cdf_file->DTV(0,plev,:,:)
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

			plotvar(ivar,iexp,:,:) = tofloat(cdf_file->TH(0,plev,:,:)) 

			delete(cdf_file)
		end do

	else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PRECT" .OR. variable .EQ. "TdiaSRF" .OR. variable .EQ. "TradSRF" .OR. variable .EQ. "SHFLX" .OR. variable .EQ. "LHFLX" .OR. variable .EQ. "U10") then
		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			
			if (variable .EQ. "THS") then
				plotvar(ivar,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(iexp,:,:))^kappa)
			else if (variable .EQ. "PRECT") then
				plotvar(ivar,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			else if (variable .EQ. "TS") then
				plotvar(ivar,iexp,:,:) = cdf_file->TS(0,:,:)
			else if (variable .EQ. "TdiaSRF") then
				plotvar(ivar,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:) - cdf_file->SHFLX(0,:,:) - cdf_file->LHFLX(0,:,:)
			else if (variable .EQ. "TradSRF") then
				plotvar(ivar,iexp,:,:) = cdf_file->FSNS(0,:,:) - cdf_file->FLNS(0,:,:)    
			else if (variable .EQ. "SHFLX") then
				plotvar(ivar,iexp,:,:) = -1.0 * cdf_file->SHFLX(0,:,:)
			else if (variable .EQ. "LHFLX") then
				plotvar(ivar,iexp,:,:) = -1.0 * cdf_file->LHFLX(0,:,:)
			else if (variable .EQ. "U10") then
				plotvar(ivar,iexp,:,:) = cdf_file->U10(0,:,:)
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
			plotvar(ivar,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

			delete(cdf_file)

		end do

	else if (variable .EQ. "Zvar") then
		do iexp = 0,nexps-1

			filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
			cdf_file = addfile(dir(es) + filo, "r")

			plotvar(ivar,iexp,:,:) = cdf_file->Z850bpf_var(:,:)

			delete(cdf_file)
		end do

	else if (variable .EQ. "uP" .OR. variable .EQ. "uH") then
		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/EV_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

			cdf_file = addfile(dir(es) + filo, "r")
		
			if (variable .EQ. "uH") then
				plotvar(ivar,iexp,:,:) = cdf_file->u_H_bpf250(:,:)
			else if (variable .EQ. "uP") then
				print("***warning*** factor of -1.0 that we don't understand yet!!!")
				plotvar(ivar,iexp,:,:) = -1.0 * cdf_file->u_P_bpf850(:,:)
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

			plotvar(ivar,iexp,:,:) = PVall(plev,:,:)
			delete(cdf_file)
		end do
	
	else if (variable .EQ. "-DUdTHdX-VDdTHdY" .OR. variable .EQ. "-DVdTHdY-UDdTHdX" .OR. variable .EQ. "-DuDdTHdx" .OR. variable .EQ. "-dTHdy" .OR. variable .EQ. "-dTHdx" .OR. variable .EQ. "-uDdTHdx" .OR. variable .EQ. "-DudTHdx" .OR. variable .EQ. "-DUdTHdX" .OR. variable .EQ. "-DVdTHdY" .OR. variable .EQ. "-UDdTHdX" .OR. variable .EQ. "-VDdTHdY" .OR. variable .EQ. "-THadv" .OR. variable .EQ. "residual" .OR. variable .EQ. "everything" .OR. variable .EQ. "everything-dia" .OR. variable .EQ. "sum" .OR. variable .EQ. "-OMdTHdp" .OR. variable .EQ. "-DOMdTHdp" .OR. variable .EQ. "OM" .OR. variable .EQ. "dTHdp" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY" .OR. variable .EQ.  "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY-DUDTHdX-DVDTHdY" .OR. variable .EQ.  "THadv+transients" .OR. variable .EQ. "transients" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY-OMdTHdp" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-OMdTHdp" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp-VertTrans" .OR. variable .EQ. "VerticalMotion" .OR. variable .EQ. "MeanAdvection+VertTrans") then
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		U = new((/nexps,nlats,nlons/),typeof(vartest))
		V = new((/nexps,nlats,nlons/),typeof(vartest))
                TH = new((/nexps,nlats,nlons/),typeof(vartest))
		
		dTHdy = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdx = new((/nexps,nlats,nlons/),typeof(vartest))

		dia = new((/nexps,nlats,nlons/),typeof(vartest))
		Ddia = new((/nexps,nlats,nlons/),typeof(vartest))

		dia_nonLH = new((/nexps,nlats,nlons/),typeof(vartest))
		dia_LH = new((/nexps,nlats,nlons/),typeof(vartest))

		UCTL = new((/nexps,nlats,nlons/),typeof(vartest))
		VCTL = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdxCTL = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdyCTL = new((/nexps,nlats,nlons/),typeof(vartest))

		DU = new((/nexps,nlats,nlons/),typeof(vartest))
		DV = new((/nexps,nlats,nlons/),typeof(vartest))
		DdTHdx = new((/nexps,nlats,nlons/),typeof(vartest))
		DdTHdy = new((/nexps,nlats,nlons/),typeof(vartest))

                VprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))
                divVprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))
                DdivVprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))

                UprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))
                divUprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))
                DdivUprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))

		OM = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdp = new((/nexps,nlats,nlons/),typeof(vartest))
                DeltaOMdTHdp = new((/nexps,nlats,nlons/),typeof(vartest))
		dTHdpCTL = new((/nexps,nlats,nlons/),typeof(vartest))

		do iexp = 0,nexps-1
			if (Experiments(es,iexp) .EQ. "0") then
				plotvar(ivar,iexp,:,:) = 0.0
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
				TH(iexp,:,:) = tofloat(cdf_file->TH(0,plev,:,:))

                                OM(iexp,:,:) = cdf_file->OMEGA(0,plev,:,:)


				; OM is defined as positive downwards, as is dTHdp.
                                dTHdp(iexp,:,:) = tofloat(cdf_file->dTHdp(0,plev,:,:))
				
				dTHdy(iexp,:,:) = center_finite_diff_n(TH(iexp,:,:),lat_dist, False, 0, 0)
				
				do iy=0,nlats-1
					lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
					dTHdx(iexp,iy,:) = center_finite_diff_n(TH(iexp,iy:iy,:),lon_dist, False, 0, 1)
				end do
				

				UCTL(iexp,:,:) = U(0,:,:)
				VCTL(iexp,:,:) = V(0,:,:)
				dTHdxCTL(iexp,:,:) = dTHdx(0,:,:)
				dTHdyCTL(iexp,:,:) = dTHdy(0,:,:)
			
				dTHdpCTL(iexp,:,:) = dTHdp(0,:,:)
	
				DU(iexp,:,:) = U(0,:,:) - U(iexp,:,:)
                                DV(iexp,:,:) = V(0,:,:) - V(iexp,:,:)
                                DdTHdx(iexp,:,:) = dTHdx(0,:,:) - dTHdx(iexp,:,:)
                                DdTHdy(iexp,:,:) = dTHdy(0,:,:) - dTHdy(iexp,:,:)



                                DeltaOMdTHdp(iexp,:,:) = (OM(0,:,:) * dTHdp(0,:,:)) - (OM(iexp,:,:) * dTHdp(iexp,:,:))

                                filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"

                                cdf_file = addfile(dir(es) + filo, "r")
                                levs_mean = cdf_file->lev_p
                                
                                ; Check levs
                                if levs_mean(plev) .NE. ilev then
                                        print("should be " + tostring(ilev))
                                        exit
                                end if  
                                
                                dia(iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) + cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)
                   		dia_nonLH(iexp,:,:) = cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)
				dia_LH(iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) 

				Ddia(iexp,:,:) = dia(0,:,:) - dia(iexp,:,:)

                                delete(cdf_file)

                                filo = Experiments(es,iexp) + "/atm/hist/VprTHpr_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"                      
                                cdf_file = addfile(dir(es) + filo, "r")
                                
                                if (ilev .EQ. "850") then
                                        VprTHpr(iexp,:,:) = cdf_file->meanVprTHpr850
                                        UprTHpr(iexp,:,:) = cdf_file->meanUprTHpr850
                                        
                                        else if (ilev .EQ. "250") then
                                                VprTHpr(iexp,:,:) = cdf_file->meanVprTHpr250
                                                UprTHpr(iexp,:,:) = cdf_file->meanUprTHpr250
                	        	else
						VprTHpr(iexp,:,:) = 0.0
						UprTHpr(iexp,:,:) = 0.0
		        	        end if  
                                end if  
                                
                                divVprTHpr(iexp,:,:) = center_finite_diff_n(VprTHpr(iexp,:,:),lat_dist, False, 0, 0)
                                

                                do iy=0,nlats-1
                                        lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
                                        divUprTHpr(iexp,iy,:) = center_finite_diff_n(UprTHpr(iexp,iy:iy,:),lon_dist, False, 0, 1)
                                end do  
                                
                                DdivVprTHpr(iexp,:,:) = divVprTHpr(0,:,:) - divVprTHpr(iexp,:,:)
                                DdivUprTHpr(iexp,:,:) = divUprTHpr(0,:,:) - divUprTHpr(iexp,:,:)
                                
                                delete(cdf_file)

			end if	
		end do


		vertTran = (-1.0 *((U * dTHdx) + (V * dTHdy) + (OM * dTHdp) + divVprTHpr + divUprTHpr) + dia)

		midpoint = toint(ceil(nexps/2.0) - 1)

		if (ilev .EQ. x) then
			U_CTL = U(0,:,:)
			dia_gen_nonLH = dia_nonLH(0,:,:) - dia_nonLH(midpoint,:,:)
        	        dia_gen_LH = dia_LH(0,:,:) - dia_LH(midpoint,:,:)

			do iiexp=1,nexps-1
	                	dia_gen_temp(iiexp-1,:,:) = dia(0,:,:) - dia(iiexp,:,:)
			end do
			;dia_gen = dim_avg_n(dia_gen_temp,0)
			dia_gen = dia(0,:,:) - dia(2,:,:)

		end if

		if (variable .EQ. "-THadv") then
                        plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy))
		else if (variable .EQ. "-UDdTHdX") then
			plotvar(ivar,:,:,:) = -1.0 * (UCTL * dTHdx)
		else if (variable .EQ. "-DUdTHdX") then
			plotvar(ivar,:,:,:) = -1.0 * (U * dTHdxCTL)
		else if (variable .EQ. "-DuDdTHdx") then
			plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy))
		else if (variable .EQ. "-dTHdy") then
			plotvar(ivar,:,:,:) = -1.0 * dTHdy
		else if (variable .EQ. "-dTHdx") then
			plotvar(ivar,:,:,:) = -1.0 * dTHdx
                else if (variable .EQ. "-DVdTHdY") then
                        plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX") then
			plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx)
		else if (variable .EQ. "-DUdTHdX-VDdTHdY") then
			plotvar(ivar,:,:,:) = -1.0 * (U * dTHdxCTL + VCTL * dTHdy)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY") then
			plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx + U * dTHdxCTL + VCTL * dTHdy)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY-OMdTHdp") then
                        plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx + U * dTHdxCTL + VCTL * dTHdy + OM * dTHdp)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY-DUDTHdX-DVDTHdY") then
			plotvar(ivar,:,:,:) = -1.0 * (DV*dTHdyCTL + UCTL*DdTHdx + DU*dTHdxCTL + VCTL*DdTHdy); + DU*DdTHdx + DV*DdTHdy)
                else if (variable .EQ. "residual") then
			;plotvar(ivar,:,:,:) = -1.0 * (DdivVprTHpr + DdivUprTHpr)

                        plotvar(ivar,:,:,:) = -1.0 * ((DU * dTHdx) + (V * DdTHdy) + (DU * DdTHdx) + (DV * DdTHdy) + DdivVprTHpr + DdivUprTHpr) ; + DeltaOMdTHdp
                else if (variable .EQ. "everything") then
                        plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy) + (OM * dTHdp) + divVprTHpr + divUprTHpr) + dia
		else if (variable .EQ. "everything-dia") then
                        plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy) + (OM * dTHdp) + divVprTHpr + divUprTHpr + vertTran)
                else if (variable .EQ. "MeanAdvection+VertTrans") then
                        plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy) + (OM * dTHdp) + vertTran)

		else if (variable .EQ. "-OMdTHdp") then
                        plotvar(ivar,:,:,:) = -1.0 * (OM * dTHdp)
                else if (variable .EQ. "-DOMdTHdp") then
                        plotvar(ivar,:,:,:) = -1.0 * (OM * dTHdpCTL)
                else if (variable .EQ. "OM") then
                        plotvar(ivar,:,:,:) = OM
                else if (variable .EQ. "dTHdp") then
                        plotvar(ivar,:,:,:) = dTHdp
		else if (variable .EQ. "THadv+transients") then
			plotvar(ivar,:,:,:) = -1.0 * ((U * dTHdx) + (V * dTHdy) + divVprTHpr + divUprTHpr)
                else if (variable .EQ. "transients") then
			plotvar(ivar,:,:,:) = -1.0 * (divVprTHpr + divUprTHpr)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX-OMdTHdp") then
			plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx + OM * dTHdp)
		else if (variable .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp") then
			plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx + OM * dTHdpCTL)
                else if (variable .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp-VertTrans") then
                        plotvar(ivar,:,:,:) = -1.0 * (V * dTHdyCTL + UCTL * dTHdx + OM * dTHdpCTL + vertTran)
		else if (variable .EQ. "VerticalMotion") then
			plotvar(ivar,:,:,:) = -1.0 * (OM * dTHdp + vertTran) 
		else
                        print("wrong variable inside loop")
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

		delete(dTHdy)
		delete(dTHdx)
		delete(U)
		delete(V)
		delete(dia)	
		delete(VprTHpr)
		delete(UprTHpr) 
		delete(divVprTHpr)
		delete(divUprTHpr)


	else if (variable .EQ. "EKEbpf" .OR. variable .EQ. "divVbpfTbpf") then
		vartemp = new((/nlats,nlons/),typeof(vartest))
		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/EKE_mean_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

			cdf_file = addfile(dir(es) + filo, "r")

			if (ilev .EQ. "850") then
				if (variable .EQ. "EKEbpf") then	
					plotvar(ivar,iexp,:,:) = cdf_file->EKE_bpf850(:,:)
				else if (variable .EQ. "divVbpfTbpf") then		
					vartemp(:,:) = cdf_file->VprTpr_bpf850(:,:)	
					plotvar(ivar,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)

				end if
				end if
			else if (ilev .EQ. "250") then
				if (variable .EQ. "EKEbpf") then
					plotvar(ivar,iexp,:,:) = cdf_file->EKE_bpf250(:,:)
				else if (variable .EQ. "divVbpfTbpf") then	
					vartemp(:,:) = cdf_file->VprTpr_bpf250(:,:)                               
					plotvar(ivar,iexp,:,:) = center_finite_diff_n(vartemp,lat_dist, False, 0, 0)	
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
				plotvar(ivar,iexp,:,:) = cdf_file->max_values(:,:)
			else if (variable .EQ. "Zlen") then
				plotvar(ivar,iexp,:,:) = cdf_file->lengths(:,:)
			else if (variable .EQ. "Znum") then
				plotvar(ivar,iexp,:,:) = tofloat(cdf_file->counter(:,:))
			else if (variable .EQ. "Zmag") then
				plotvar(ivar,iexp,:,:) = tofloat(cdf_file->mean_values(:,:))
			end if
			end if
			end if
			end if
		end do

	else if (variable .EQ. "-divVprTHpr") then
		VprTHpr = new((/nlats,nlons/),typeof(vartest))
                UprTHpr = new((/nlats,nlons/),typeof(vartest))

		divVprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))
                divUprTHpr = new((/nexps,nlats,nlons/),typeof(vartest))


		lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

		do iexp = 0,nexps-1
			filo = Experiments(es,iexp) + "/atm/hist/VprTHpr_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"
			cdf_file = addfile(dir(es) + filo, "r")
			
			if (ilev .EQ. "850") then
				VprTHpr = cdf_file->meanVprTHpr850
				UprTHpr = cdf_file->meanUprTHpr850
			else if (ilev .EQ. "250") then
				VprTHpr = cdf_file->meanVprTHpr250
                                UprTHpr = cdf_file->meanVprTHpr250
			end if
			end if

                	do iy=0,nlats-1
                	        lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
                	        divUprTHpr(iexp,iy,:) = center_finite_diff_n(UprTHpr(iy:iy,:),lon_dist, False, 0, 1)
                	end do  

			divVprTHpr(iexp,:,:) = center_finite_diff_n(VprTHpr,lat_dist, False, 0, 0)

		end do
		
		plotvar(ivar,:,:,:) = -1.0 * (divUprTHpr + divVprTHpr)

		delete(VprTHpr)
                delete(UprTHpr)

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
                                        if (PHIS(iexp,ix,iy) .GT. (PHIS(0,ix,iy) +1)) then
						plotvar(ivar,iexp,ix,iy) = plotvar@_FillValue
						if (variable .EQ. "UV") then
							plotvar2(ivar,iexp,ix,iy) = plotvar2@_FillValue
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

if (reverse .EQ. "true") then
	factor = -1.0
else
	factor = 1.0
end if

if (plottype .EQ. "map") then

	print("ooops!")
	exit

else if (plottype .EQ. "ZMline")
	if (linear .EQ. "true") then
		panelsize = pwidths*(toint(ceil(nvars/2))+1)
		singlesize=toint(ceil(nvars/2))+1
	else    
		panelsize = pwidths*toint(ceil(nvars/2))
		singlesize = toint(ceil(nvars/2))
	end if 

        toplot = new((/nvars,nexps+1,nlats/),typeof(plotvar))
	toplottitle = new((/nexps-1/),"string")
	
	do ivar = 0,nvars-1
	        variable = lvars(ivar)
        	ilev = llevs(ivar)

	;	toplot(ivar,0,:) = dim_avg_n(plotvar(0,0,:,nlonstart:nlonend),1)
	;	toplottitle(0) = Titles(0,0)
	

		do ep = 1,nexps-1
			if (variable .EQ. "-DuDdTdx" .OR. variable .EQ. "residual" .OR. variable .EQ. "-DVdTHdY-UDdTHdX-DUdTHdX-VdTHdY-DUDTHdX-DVDTHdY") then
				print("here")
				toplot(ivar,ep-1,:) = factor * dim_avg_n(plotvar(ivar,ep,:,nlonstart:nlonend),1)
			else
				toplot(ivar,ep-1,:) = dim_avg_n(plotvar(ivar,ep,:,nlonstart:nlonend),1)	
			end if
			if (reverse .EQ. "true") then
				toplottitle(ep-1) = Titles(0,ep) + " - " + Titles(0,0)
			else
				toplottitle(ep-1) = Titles(0,0) + " - " + Titles(0,ep)
			end if
		end do

	end do

	toplot!2 = "lat"
	toplot&lat = lats
	toplot&lat@units="degree_north"


end if
end if


; plot

print(plottype)

if (plottype .EQ. "map") then
	npanels = floattoint(ceil(panelsize/2.0))
else if (plottype .EQ. "ZMline") then
	
        npanels = floattoint(ceil(panelsize/2.0))
	print(npanels)
	print(nvars)
	panelsize = nvars
end if
end if

print(panelsize)

	if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
		plotname = variable + tostring(ilev) + "_" + plottype + "_" + slon + "-" + elon
		plottitle = variable + " threshold " + tostring(ilev)  + " " + slon + "-" + elon
	else
		if (ilev .EQ. 0) then
		  plotname = variable + "_" + plottype + "_" + slon + "-" + elon
		  plottitle = variable  + "_" + slon + "-" + elon
		else
		  plotname = variable + tostring(ilev) + "_" + plottype + "_" + slon + "-" + elon
		  plottitle = variable + " at " + tostring(ilev) + "mb, " + " " + slon + "-" + elon
		end if
	end if

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/" + titleprefix + "ZMline_" + x + "mb_" + slon + "-" + elon + "_" + timespan + "_" + figtitle) 


  plot = new(panelsize,graphic)                          ; create a plot array

  res                      = True                 ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@gsnLeftString = ""


if (plottype .EQ. "map") then
  	gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap

	print("oops")
	exit

else if (plottype .EQ. "ZMline") then

	gsn_define_colormap(wks,"rainbow+white+gray")

        res@gsnLeftString = ""
	res@xyLineColors = LineColors(0:nexps-1)
	print(res@xyLineColors)
	res@xyLineThicknessF = 2.0
	res@xyDashPatterns = dashpatterns
	res@txFontHeightF     = 0.028
	res@tmXBLabelFontHeightF = 0.028
  	res@tmYLLabelFontHeightF = 0.028
	res@gsnYRefLine = 0.0
	; add a legend
	res@pmLegendDisplayMode    = "Off"              ; turn on legend

	do ivar=0,nvars-1

		res@trYMinF  = lplotmins(ivar)                   ; set the minimum contour level
		res@trYMaxF  = lplotmaxs(ivar)                    ; set the maximum contour level
		res@trXMinF = slat
		res@trXMaxF = elat

		if abs(lplotmaxs(ivar)) .LT. 0.0001 then
			res@tmYLFormat = "0*+^e"
		else
		        res@tmYLFormat = "0@*+^sg"
		end if

	        if (ivar .EQ. 0) then
			res@pmLegendDisplayMode    = "Always"              ; turn on legend
	                res@pmLegendSide           = "Bottom"                 ; Change location of

	        else
			res@pmLegendDisplayMode    = "Never"
		end if
 
		res@pmLegendParallelPosF   = .5                  ; move units right
		res@pmLegendOrthogonalPosF = -0.4                ; move units down
		res@pmLegendWidthF         = 0.2
		res@lgPerimOn              = False               ; turn off box around
		res@lgLabelFontHeightF     = .022                 ; label font height

	        res@xyExplicitLegendLabels = toplottitle(0:nexps-2); + " at " + tostring(llevs(ivar)) + "mb"

		if (lvars(ivar) .EQ. "U") then
                	res@gsnCenterString         = "~F33~D~F10~u~F25~ at " + tostring(llevs(ivar)) + "mb, m/s" 
                else if (lvars(ivar) .EQ. "-UDdTHdX") then
                        res@gsnCenterString         = "-~F10~u~B~noM~N~~F34~6~F33~D~F10~T/~F34~6~F10~x~F25~ at " + tostring(llevs(ivar)) + "mb K/s"
		else if (lvars(ivar) .EQ. "everything") then
                        res@gsnCenterString         = "all heat divergence terms at " + tostring(llevs(ivar)) + "mb, K/s" ;"~F33~D~F21~T, K"
		else if (lvars(ivar) .EQ. "-DVdTHdY-UDdTHdX") then
                        res@gsnCenterString         = "-~F33~D~F10~v~F34~6~F10~T~B~noM~N~/~F34~6~F10~y - u~B~noM~N~~F34~6~F33~D~F10~T/~F34~6~F10~y~F25~ at " + tostring(llevs(ivar)) + "mb, K/s"
                else if (lvars(ivar) .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp") then
                        res@gsnCenterString         = "-~F33~D~F10~v~F34~6~F10~T~B~noM~N~/~F34~6~F10~y-u~B~noM~N~~F34~6~F33~D~F10~T/~F34~6~F10~y-~F33~Dw~F34~6~F10~T~B~noM~N~/~F34~6~F10~p~F25~ ~C~                         at " + tostring(llevs(ivar)) + "mb, K/s"
		else if (lvars(ivar) .EQ. "V") then
        	        res@gsnCenterString         = "~F33~D~F10~v~F25~ at " + tostring(llevs(ivar)) + "mb, m/s"
		else if (lvars(ivar) .EQ. "-divVprTHpr") then
			res@gsnCenterString         = "-~F33~D~F21~(~F34~6~F2~V'T'/~F34~6~F21~y)~F25~ at " + tostring(llevs(ivar)) + "mb, K/s" 
		else if (lvars(ivar) .EQ. "-DVdTHdY") then
                        res@gsnCenterString         = "-~F33~D~F10~v~F34~6~F10~T~B~noM~N~/~F34~6~F10~y~F25~ at " + tostring(llevs(ivar)) + "mb, K/s"
		else if (lvars(ivar) .EQ. "residual") then
                        res@gsnCenterString         = "-~F33~D~F21~U~F34~W6~F21~T~B~noM~N~/~F34~6~F21~x - V~B~noM~N~~F34~W~F34~6~F33~D~F21~T/~F34~6~F21~y - ~F33~D~F22~U~F34~W~F34~6~F33~D~F21~T/~F34~6~F22~x - ~F33~D~F21~(~F34~6~F2~V'T'/~F34~6~F21~y) - ~F33~D~F21~(~F34~6~F2~U'T'/~F34~6~F21~x) at " + tostring(llevs(ivar)) + "mb, K/s"
		else if (lvars(ivar) .EQ. "VerticalMotion") then
			res@gsnCenterString         = "~F33~D~F21~(~F33~w~F34~W6~F21~T/~F34~6~F21~p) + ~F33~D~F21~(~F34~6~F33~w~F2~'T'/~F34~6~F21~p) ~F25~ at " + tostring(llevs(ivar)) + "mb, K/s"
		else if (lvars(ivar) .EQ. "TH") then
			res@gsnCenterString         = "~F33~D~F8~q~F21~ at " + tostring(llevs(ivar)) + "mb, K/s"
		else if (lvars(ivar) .EQ. "-OMdTHdp") then
			res@gsnCenterString         = "-~F33~D~F10~(~F33~w~F34~6~F10~T/~F34~6~F10~p)~F25~ at " + tostring(llevs(ivar)) + "mb, K/s"
                else if (lvars(ivar) .EQ. "-DOMdTHdp") then
                        res@gsnCenterString         = "-~F33~Dw~F34~6~F10~T~B~noM~N~/~F34~6~F10~p~F25~ at " + tostring(llevs(ivar)) + "mb, K/s"


		else
			res@gsnCenterString         = lvars(ivar)
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
		if (midpoint .GT. 0) then
			if (lvars(ivar) .EQ. "-UDdTHdX") then
				toplot(ivar,nexps-1,:) = dim_avg_n(U_CTL(:,nlonstart:nlonend),1)
				toplot(ivar,nexps-1,:) = 2.0e-5 * toplot(ivar,nexps-1,:) / max(toplot(ivar,nexps-1,:))
				plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-1,:),res) ;
			else if (lvars(ivar) .EQ. "TH") then
				toplot(ivar,nexps-1,:) = factor * dim_avg_n(dia_gen(:,nlonstart:nlonend),1)
				toplot(ivar,nexps-1,:) = 2.0 * toplot(ivar,nexps-1,:) / max(toplot(ivar,nexps-1,:))
				plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-1,:),res) ;
			else if (lvars(ivar) .EQ. "-dTHdy") then
                                toplot(ivar,nexps-1,:) = factor * dim_avg_n(dTHdyCTL(0,:,nlonstart:nlonend),1)
                                toplot(ivar,nexps-1,:) = 1.0e-5 * toplot(ivar,nexps-1,:) / max(toplot(ivar,nexps-1,:))
                                plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-1,:),res) ;
			else if (lvars(ivar) .EQ. "-DVdTHdY-UDdTHdX" .OR. lvars(ivar) .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp-VertTrans" .OR. lvars(ivar) .EQ. "MeanAdvection" .OR. lvars(ivar) .EQ. "MeanAdvection+VertTrans") then  ;.OR. lvars(ivar) .EQ. "-DVdTHdY-UDdTHdX-DOMdTHdp"
				toplot(ivar,nexps-1,:) = factor * dim_avg_n(dia_gen(:,nlonstart:nlonend),1)
				plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-1,:),res) ;
			else if(lvars(ivar) .EQ. "VerticalMotion" .OR. lvars(ivar) .EQ. "-OMdTHdp" .AND. llevs(ivar) .LT. 750) then
				do iiexp=1,nexps-1
                                	Hor_500_temp(iiexp-1,:,:) = Hor_500(0,:,:) - Hor_500(iiexp,:,:)
                        	end do

		                Hor_500_plot = dim_avg_n(Hor_500_temp,0)

				toplot(ivar,nexps-1,:) = factor * dim_avg_n(Hor_500_plot(:,nlonstart:nlonend),1)
				plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-1,:),res) ;
			else
				plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-2,:),res) ;
			end if
			end if
			end if
			end if
			end if
		else
                        plot(ivar) = gsn_csm_xy(wks,toplot&lat,toplot(ivar,0:nexps-2,:),res) ;
		end if
	end do

end if
end if

  resP                  = True                   ; modify the panel plot
    a4_height = 29.7 ; in centimeters, if my 
    a4_width = 23.0 ; reference is correct 
    cm_per_inch = 2.54 
    resP@gsnMaximize = True 
    resP@gsnPaperWidth = a4_width/cm_per_inch 
    resP@gsnPaperHeight = a4_height/cm_per_inch 


  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
 resP@gsnPanelYWhiteSpacePercent = 5
 resP@gsnPanelXWhiteSpacePercent = 5

  ;resP@txString   = plottitle + ", " + units

if (nvars .EQ. 8) then  
  resP@gsnPanelFigureStrings= (/"a.","e.","b.","f.","c.","g","d","h"/) 
else if (nvars .EQ. 6) then
  resP@gsnPanelFigureStrings= (/"a.","d.","b.","e.","c.","f."/) ;
end if
end if
  resP@gsnPanelFigureStringsFontHeightF = 0.009
  resP@gsnPanelFigureStringsPerimOn = False

  resP@amJust   = "TopLeft"
  panelid1 = gsn_panel_return(wks,plot,(/npanels,2/),resP)

  delete(resP@gsnPanelFigureStrings)

  resP@gsnDraw = False                           ; draw later, in maximize mode

  nplots = panelsize
  panelid1 = gsn_panel_return(wks,plot(0:nplots-1),(/npanels,2/),resP)

  gsn_panel(wks,plot(0:nplots-1),(/npanels,2/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
