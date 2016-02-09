load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; set some defaults
diffdiffs = "false"
linear = "false"

LineColors = (/"blue","red","green","cyan","black","yellow"/)

index = 1
figtitle = getenv("NCL_ARG2_" + tostring(index))
print(figtitle)
index = index + 1
nexps = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
dir = new(2,"string")
dir(0) = getenv("NCL_ARG2_" + tostring(index))
index = index + 1

Experiments = new((/1,nexps/),"string")
Titles = new((/1,nexps/),"string")
do ne = 0,nexps-1
        Experiments(0,ne) = getenv("NCL_ARG2_" + tostring(index))
	index = index + 1
end do
do ne = 0,nexps-1
        Titles(0,ne) = getenv("NCL_ARG2_" + tostring(index))
        index = index + 1
end do
startyr = new(1,"integer")
endyr = new(1,"integer")
nyears = new(1,"integer")
startyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
endyr(0) = toint(getenv("NCL_ARG2_" + tostring(index)))
index = index + 1
nyears(0) = endyr(0)-startyr(0)+1

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


index = 1
variable = getenv("NCL_ARG_" + tostring(index))
print(variable)
index = index + 1
ilev = toint(getenv("NCL_ARG_" + tostring(index)))
index = index + 1

plotchar = new(6,"float")
do xx = 0,5
        plotchar(xx) = tofloat(getenv("NCL_ARG_" + tostring(index)))
        index = index + 1
end do
units = getenv("NCL_ARG_" + tostring(index))
index = index + 1
plottype = getenv("NCL_ARG_" + tostring(index))
print(plottype)
print(dir)

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

if (ilev .NE. 0) then
; Find correct pressure level
	levs_mean = cdf_file->lev_p

	levsizes = dimsizes(levs_mean)
	nlevs = levsizes(0)

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
	print(dim_avg(lons(nlonstart:nlonend)))
end if

delete(cdf_file)
es = 0
do iexp = 0,nexps-1
		filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
		cdf_file = addfile(dir(es) + filo, "r")

		PS(es,iexp,:,:) = cdf_file->PS(0,:,:)
	        PHIS(es,iexp,:,:) = cdf_file->PHIS/9.8

                delete(cdf_file)
end do

if (variable .EQ. "Topo" .OR. variable .EQ. "PREC") then
       var = new((/1,nexps,nlats,nlons/),typeof(vartest))
       do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")
			if (variable .EQ. "Topo") then
				var(es,iexp,:,:) = cdf_file->PHIS/9.8
			else if (variable .EQ. "PREC") then
				var(es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			end if
			end if
                        delete(cdf_file)

        end do
	plotvar = var
else if (variable .EQ. "U" .OR. variable .EQ. "V" .OR. variable .EQ. "dudz") then
        var = new((/2,nexps,nlats,nlons/),typeof(vartest))

        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

			if (variable .EQ. "U") then
				var(es,iexp,:,:) = cdf_file->U(0,plev,:,:)
                	else if (variable .EQ. "V") then
                                var(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
			else if (variable .EQ. "dudz") then
				dudz = center_finite_diff_n(cdf_file->U(0,:,:,:),levs_mean,False,0,0)
				var(es,iexp,:,:) = dudz(plev,:,:)
			end if
			end if
			end if
		        delete(cdf_file)

        end do
      	plotvar = var

else if (variable .EQ. "Tdia") then
        Tdia = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

                        Tdia(es,iexp,:,:) = cdf_file->DTCOND(0,plev,:,:) + cdf_file->DTV(0,plev,:,:) + cdf_file->QRL(0,plev,:,:) + cdf_file->QRS(0,plev,:,:)

                        delete(cdf_file)

        end do

        plotvar = Tdia

else if (variable .EQ. "TH") then
        TH = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")

                        levs_mean = cdf_file->lev_p

                        ; Check levs
                        if levs_mean(plev) .NE. ilev then
                                print("should be " + tostring(ilev))
                                exit
                        end if

                        TH(es,iexp,:,:) = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

                        delete(cdf_file)

        end do

        plotvar = TH

else if (variable .EQ. "THS" .OR. variable .EQ. "TS" .OR. variable .EQ. "PRECT") then
        vartemp = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_" + Experiments(es,iexp) + ".cam2.h0.nc"
                        cdf_file = addfile(dir(es) + filo, "r")
			
			if (variable .EQ. "THS") then
                        	vartemp(es,iexp,:,:) = cdf_file->TS(0,:,:) * ((1013.0/PS(es,iexp,:,:))^kappa)
			else if (variable .EQ. "PRECT") then
	                        vartemp(es,iexp,:,:) = cdf_file->PRECT(0,:,:) * secdays * 1000.0
			else if (variable .EQ. "TS") then
				vartemp(es,iexp,:,:) = cdf_file->TS(0,:,:)
			end if
			end if
			end if

                        delete(cdf_file)

        end do

        plotvar = vartemp

else if (variable .EQ. "EMGR") then
        EMGR = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/EMGR_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h0.nc"

                        cdf_file = addfile(dir(es) + filo, "r")

                        EMGR(es,iexp,:,:) = cdf_file->EMGR600(:,:) * secdays

                        delete(cdf_file)

        end do

        plotvar = EMGR

else if (variable .EQ. "Zvar") then
        Zvar = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/Z850bpf_var_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

                        cdf_file = addfile(dir(es) + filo, "r")

                        Zvar(es,iexp,:,:) = cdf_file->Z850bpf_var(:,:)

                        delete(cdf_file)

        end do

        plotvar = Zvar

else if (variable .EQ. "uP" .OR. variable .EQ. "uH") then
        EV = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/EV_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

                        cdf_file = addfile(dir(es) + filo, "r")
		
			if (variable .EQ. "uH") then
                        	EV(es,iexp,:,:) = cdf_file->u_H_bpf250(:,:)
			else if (variable .EQ. "uP") then
				print("***warning*** factor of -1.0 that we don't understand yet!!!")
                                EV(es,iexp,:,:) = -1.0 * cdf_file->u_P_bpf850(:,:)
			end if
			end if
                
		        delete(cdf_file)

        end do
	
        plotvar = EV

else if (variable .EQ. "PV") then
        PV = new((/1,nexps,nlats,nlons/),typeof(vartest))

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

			PV(es,iexp,:,:) = PVall(plev,:,:)
                        delete(cdf_file)

        end do

        plotvar = PV

else if (variable .EQ. "DuDdTHdx" .OR. variable .EQ. "dTHdy" .OR. variable .EQ. "uDdTHdx" .OR. variable .EQ. "DudTHdx" .OR. variable .EQ. "SF" .OR. variable .EQ. "SFZA" .OR. variable .EQ. "Tadv" .OR. variable .EQ. "UDdTHdx" .OR. variable .EQ. "VDdTHdy" .OR. variable .EQ. "DUdThdx" .OR. variable .EQ. "DVdTHdy" .OR. variable .EQ. "UV") then
	lat_dist = tofloat(gc_latlon(lats(0),lons(0),lats(1),lons(0),2,3))

	U = new((/1,nexps,nlats,nlons/),typeof(vartest))
	V = new((/1,nexps,nlats,nlons/),typeof(vartest))
	
        SF = new((/1,nexps,nlats,nlons/),typeof(vartest))
        SFZA = new((/1,nexps,nlats,nlons/),typeof(vartest))


	TH = new((/nlats,nlons/),typeof(vartest))
	
	dTHdy = new((/1,nexps,nlats,nlons/),typeof(vartest))
	dTHdx = new((/1,nexps,nlats,nlons/),typeof(vartest))

        do iexp = 0,nexps-1

		        filo = Experiments(es,iexp) + "/atm/hist/" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_mean_pl_" + Experiments(es,iexp) + ".cam2.h0.nc"
		        cdf_file = addfile(dir(es) + filo, "r")

       			levs_mean = cdf_file->lev_p
       		 	
			; Check levs
        		if levs_mean(plev) .NE. ilev then
        	        	print("should be " + tostring(ilev))
        	        	exit
        		end if

			U(es,iexp,:,:) = cdf_file->U(0,plev,:,:)
			V(es,iexp,:,:) = cdf_file->V(0,plev,:,:)
	
			TH = cdf_file->T(0,plev,:,:) * (1013.0/tofloat(ilev))^(kappa)

			dTHdy(es,iexp,:,:) = center_finite_diff_n(TH,lat_dist, False, 0, 0)
			
			do iy=0,nlats-1
				lon_dist = tofloat(gc_latlon(lats(iy),lons(0),lats(iy),lons(1),2,3))
				dTHdx(es,iexp,iy,:) = center_finite_diff_n(TH(iy:iy,:),lon_dist, False, 0, 1)
			end do

					
	
			if (variable .EQ. "SF" .OR. variable .EQ. "SFZA") then
				SFtemp = new((/nlats,nlons/), typeof(vartest))
				temp = new((/nlats,nlons/),typeof(vartest))
				uv2sfvpf(U(es,iexp,:,:),V(es,iexp,:,:),SFtemp,temp)
				
				if (variable .EQ. "SF") then
					SF(es,iexp,:,:) = SFtemp
				else
					SFZM = dim_avg_n(SFtemp,1)
					do ix = 0,nlons-1
						SFZA(es,iexp,:,ix) = SFtemp(:,ix) - SFZM
					end do

				end if
			else if (variable .EQ. "uDdTHdx") then
				U(es,iexp,:,:) = U(es,0,:,:)
			else if (variable .EQ. "DudTHdx") then
				dTHdx(es,iexp,:,:) = dTHdx(es,0,:,:)
				dTHdy(es,iexp,:,:) = dTHdy(es,0,:,:)
			else if (variable .EQ. "DuDdTHdx") then
				U(es,iexp,:,:) = U(es,0,:,:) - U(es,iexp,:,:)
                                V(es,iexp,:,:) = V(es,0,:,:) - V(es,iexp,:,:)
                                dTHdx(es,iexp,:,:) = dTHdx(es,0,:,:) - dTHdx(es,iexp,:,:)
                                dTHdy(es,iexp,:,:) = dTHdy(es,0,:,:) - dTHdy(es,iexp,:,:)
			end if
			end if 
			end if
			end if
	end do
	if (variable .EQ. "Tadv" .OR. variable .EQ. "uDdTHdx" .OR. variable .EQ. "DudTHdx") then
		plotvar = -1.0 * ((U * dTHdx) + (V * dTHdy))
	else if (variable .EQ. "UDdTHdx") then
		plotvar = -1.0 * U(:,0,:,:) * dTHdx
	else if (variable .EQ. "VDdTHdy") then
		plotvar = -1.0 * V(:,0,:,:) * dTHdy
	else if (variable .EQ. "DUdTHdx") then
		plotvar = -1.0 * U * dTHdx(:,0,:,:)
	else if (variable .EQ. "DVdTHdy") then
		plotvar = -1.0 * V * dTHdy(:,0,:,:)
	else if (variable .EQ. "DUDdTHdy") then
		plotvar = -1.0 * ((U * dTHdx) + (V * dTHdy))
	else if (variable .EQ. "UV") then
		plotvar = U
		plotvar2 = V
	else if (variable .EQ. "SF") then
		plotvar = SF
	else if (variable .EQ. "SFZA") then
		plotvar = SFZA
	else if (variable .EQ. "dTHdy") then
		plotvar = -1.0 * dTHdy
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

else if (variable .EQ. "EKEbpf" .OR. variable .EQ. "VbpfTbpf") then
        var = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/EKE_mean_bpf_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".cam2.h1.nc"

                        cdf_file = addfile(dir(es) + filo, "r")

			if (ilev .EQ. "850") then
				if (variable .EQ. "EKEbpf") then	
					var(es,iexp,:,:) = cdf_file->EKE_bpf850(:,:)
				else if (variable .EQ. "VbpfTbpf") then		
					var(es,iexp,:,:) = cdf_file->VprTpr_bpf850(:,:)
				end if
				end if
			else if (ilev .EQ. "250") then
                                if (variable .EQ. "EKEbpf") then
					var(es,iexp,:,:) = cdf_file->EKE_bpf250(:,:)
				else if (variable .EQ. "VbpfTbpf") then
                                        var(es,iexp,:,:) = cdf_file->VprTpr_bpf250(:,:)
				end if
				end if
			else
				print("invalid EKE level, only 250 and 850 accepted")
				exit
			end if
			end if

        end do

        plotvar = var
else if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
       var = new((/2,nexps,nlats,nlons/),typeof(vartest))
        do iexp = 0,nexps-1

                        filo = Experiments(es,iexp) + "/atm/hist/Z850_bpf_Events_" + tostring(ilev) + "_" + timespan + tostring(startyr(es)) + "_" + tostring(nyears(es)) + "_" + Experiments(es,iexp) + ".nc"

                        cdf_file = addfile(dir(es) + filo, "r")

			if (variable .EQ. "Zmax") then
				var(es,iexp,:,:) = cdf_file->max_values(:,:)
			else if (variable .EQ. "Zlen") then
				var(es,iexp,:,:) = cdf_file->lengths(:,:)
			else if (variable .EQ. "Znum") then
                                var(es,iexp,:,:) = tofloat(cdf_file->counter(:,:))
			else if (variable .EQ. "Zmag") then
				var(es,iexp,:,:) = tofloat(cdf_file->mean_values(:,:))
			end if
			end if
			end if
			end if

        end do

	plotvar = var
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

if (ilev .NE. 1000) then
		do iexp = 0,nexps-1
			do iy = 0,nlons-1
				do ix = 0,nlats-1
					if (PS(es,iexp,ix,iy) .LT. ilev*100) then
						plotvar(es,iexp,ix,iy) = plotvar@_FillValue
						if (variable .EQ. "UV") then
							plotvar2(es,iexp,ix,iy) = plotvar2@_FillValue
						end if
					end if
				end do
			end do
		end do
end if

pwidths = 1

if (linear .EQ. "true") then
	panelsize = pwidths*(nexps+1)
else
	panelsize = pwidths*nexps
end if

if (reverse .EQ. "true") then
	factor = -1.0
else
	factor = 1.0
end if

iplot = 0

if (plottype .EQ. "map") then

	toplottitle = new(panelsize,"string")
	toplot = new((/panelsize,nlats,nlons/),typeof(plotvar))
	toplot2 = new((/panelsize,nlats,nlons/),typeof(plotvar))
	toplotPHIS = new((/panelsize,nlats,nlons/),typeof(PHIS))

		toplot(iplot,:,:) = plotvar(iplot,0,:,:)
		if (variable .EQ. "UV") then
			toplot2(iplot,:,:) = plotvar2(iplot,0,:,:)
		end if
		toplottitle(iplot) = Titles(iplot,0)
		toplotPHIS(iplot,:,:) = 0.0

	do ep = 1,nexps-1
			if (variable .EQ. "DuDdTHdx") then
	                        toplot(ep*pwidths+iplot,:,:) = factor * (plotvar(iplot,ep,:,:))
			else
				toplot(ep*pwidths+iplot,:,:) = factor * (plotvar(iplot,0,:,:) - plotvar(iplot,ep,:,:))
				if (variable .EQ. "UV") then
					toplot2(ep*pwidths+iplot,:,:) = factor * (plotvar2(iplot,0,:,:) - plotvar2(iplot,ep,:,:))
				end if
				toplotPHIS(ep*pwidths+iplot,:,:) =  PHIS(iplot,0,:,:) - PHIS(iplot,ep,:,:)
				if (reverse .EQ. "true") then
					toplottitle(ep*pwidths+iplot) = Titles(iplot,ep) + " - " + Titles(iplot,0)
				else
					toplottitle(ep*pwidths+iplot) = Titles(iplot,0) + " - " + Titles(iplot,ep)
				end if
			end if
	end do

	toplot!1 = "lat"
	toplot!2 = "lon"

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
        toplot(1,0,:) = dim_avg_n(plotvar(1,0,:,nlonstart:nlonend),1)

	toplottitle(0,0) = Titles(0,0)
        toplottitle(1,0) = Titles(1,0)

        do ep = 1,nexps-1
			if (variable .EQ. "DuDdTHdx") then
                                toplot(iplot,ep,:,:) = factor * dim_avg_n(plotvar(iplot,ep,:,nlonstart:nlonend),1)
                        else
				toplot(iplot,ep,:) = factor * (dim_avg_n(plotvar(iplot,0,:,nlonstart:nlonend),1) - dim_avg_n(plotvar(iplot,ep,:,nlonstart:nlonend),1))
				if (reverse .EQ. "true") then
					toplottitle(iplot,ep) = Titles(iplot,ep) + " - " + Titles(iplot,0)
				else
					toplottitle(iplot,ep) = Titles(iplot,0) + " - " + Titles(iplot,ep)
				end if
			end if

        end do
	

        toplot!2 = "lat"
        toplot&lat = lats
        toplot&lat@units="degree_north"

end if
end if


; plot

if (plottype .EQ. "map") then
	npanels = floattoint(ceil(panelsize))
	print(npanels)
	print(panelsize)
else if (plottype .EQ. "ZMline") then
	npanels = 2
	panelsize = 4
end if
end if

if (variable .EQ. "Zmax" .OR. variable .EQ. "Zlen" .OR. variable .EQ. "Znum" .OR. variable .EQ. "Zmag") then
	plotname = variable + tostring(ilev) + "_" + plottype
	plottitle = variable + " threshold " + tostring(ilev)
else
	if (ilev .EQ. 0) then
	  plotname = variable + "_" + plottype
	  plottitle = variable
	else
	  plotname = variable + tostring(ilev) + "_" + plottype
	  plottitle = variable + " at " + tostring(ilev) + "mb"
	end if
end if

if (diffdiffs .EQ. "true")
  plotname = plotname + "_dds"
end if

  wks   = gsn_open_wks ("eps","/home/disk/eos4/rachel/Figures/" + figtitle + "/" + plotname + "_poster_" + timespan + "_" + figtitle) 


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

	if (variable .EQ. "UV") then
	  do pp = 0,panelsize-1
	    res@gsnCenterString         = toplottitle(pp)
	    plot(pp) = gsn_csm_vector_map_ce(wks,toplot(pp,:,:),toplot2(pp,:,:),res) ;
	    plot_ov = gsn_csm_contour(wks,toplotPHIS(pp,:,:),resOv)
	    overlay(plot(pp),plot_ov)
	  end do

	else
	  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels 
	  res@cnMinLevelValF  = plotchar(0)                   ; set the minimum contour level
	  res@cnMaxLevelValF  = plotchar(1)                    ; set the maximum contour level
	  res@cnLevelSpacingF       = plotchar(2)      ; contour spacing

	  res@gsnCenterString         = toplottitle(0)
	  plot(0) = gsn_csm_contour_map_ce(wks,toplot(0,:,:),res) ;

	  res@cnMinLevelValF  = plotchar(3)                    ; set the minimum contour level
	  res@cnMaxLevelValF  = plotchar(4)                     ; set the maximum contour level
	  res@cnLevelSpacingF       = plotchar(5)      ; contour spacing

	  do pp = 1,panelsize-1
	    res@gsnCenterString         = toplottitle(pp)
	    plot(pp) = gsn_csm_contour_map_ce(wks,toplot(pp,:,:),res) ;
	    plot_ov = gsn_csm_contour(wks,toplotPHIS(pp,:,:),resOv)
	    overlay(plot(pp),plot_ov)
	  end do
	end if
else if (plottype .EQ. "ZMline") then

        res@gsnLeftString = ""
	res@xyLineColors = LineColors(0:nexps-1)
	print(res@xyLineColors)
	res@xyLineThicknessF = 2.0
	res@xyDashPattern = 0

	; add a legend
	res@pmLegendDisplayMode    = "Off"              ; turn on legend

	res@trYMinF  = plotchar(0)                   ; set the minimum contour level
	res@trYMaxF  = plotchar(1)                    ; set the maximum contour level
	res@trXMinF = slat
	res@trXMaxF = elat


	res@gsnCenterString         = toplottitle(0,0)
	plot(0) = gsn_csm_xy(wks,toplot&lat,toplot(0,0,:),res) ;

	res@trYMinF  = plotchar(3)                    ; set the minimum contour level
	res@trYMaxF  = plotchar(4)                     ; set the maximum contour level

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

end if
end if


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@txString   = plottitle + ", " + units

  resP@gsnDraw = False                           ; draw later, in maximize mode

print(npanels)
print(dimsizes(plot))
print(typeof(plot))
  panelid1 = gsn_panel_return(wks,plot,(/1,npanels/),resP)

  gsn_panel(wks,plot,(/1,npanels/),resP)               ; now draw as one plot

  mres = True
  maximize_output(wks,mres)


end
