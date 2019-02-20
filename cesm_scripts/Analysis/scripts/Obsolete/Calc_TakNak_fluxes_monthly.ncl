load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Based on http://www.atmos.rcast.u-tokyo.ac.jp/nishii/programs/TakayaNakamura2001-ncep-daily-10d-lpf.ncl
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469(2001)058%3C0608:AFOAPI%3E2.0.CO%3B2
; Calculated fluxes from climatological seasonal means
; with perturbations as differences between two experiments
; Quasi-geostrophic, in spherical coordinates

begin

; Get experiment names

logp = 0

print("Calc EP fluxes")
Direc = getenv("NCL_ARG_1")
nexps = toint(getenv("NCL_ARG_2"))
Experiments = new(nexps,"string")
Experiments2 = new(nexps,"string")

do ne = 0,nexps-1
        Experiments(ne) = getenv("NCL_Exp_" + tostring(ne))
        Experiments2(ne) = getenv("NCL_Exp2_" + tostring(ne))
end do

startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

timespan = getenv("NCL_season")

pnew = (/975,950,925,850,750,700,600,500,400,350,300,250,200,150,125,100,85,70,55,40,25,15,10,5/)
nplevels = dimsizes(pnew)

a = 6.371e06	; radius of Earth
pi = 3.14159265358979

g = 9.80665
P0 = 1000.0

dimsexps = dimsizes(Experiments)
nexps = dimsexps(0)

do exps = 0,nexps-1
	Experiment1= Experiments(exps)
	Dir1 = (Direc + Experiment1 + "/atm/hist/")
	print(Experiment1)

	Experiment2 = Experiments2(exps)
	Dir2 = (Direc + Experiment2 + "/atm/hist/")

	do imonth = 1,12
		if imonth .LT. 10 then
			strmonth = "0" + tostring(imonth)
		else
			strmonth = tostring(imonth)
		end if

		filename1 = Dir1 + ClimMon + strmonth + "_" + Experiment1 + "_" + tostring(startyr) + "-" + tostring(endyr) + "_mean_" + Experiment1 + ".cam2.h0.nc"
        print(filename1)
        ; open file with seasonal averages
        cdf_file = addfile(filename1,"r")

        filename2 = Dir2 + timespan + tostring(startyr) + "_" + tostring(nyears) + "_mean_" + Experiment2 + ".cam2.h0.nc"
        ; open file with seasonal averages
        cdf_file2 = addfile(filename2,"r")

        ; get pressure levels

        nlevels = filevardimsizes(cdf_file,"lev")
        
        time = cdf_file->time
        level = cdf_file->lev

        nlat = filevardimsizes(cdf_file,"lat")
        nlon = filevardimsizes(cdf_file,"lon")

        lat = tofloat(cdf_file->lat)
        lat!0="lat"
        lon = tofloat(cdf_file->lon)
        lon!0="lon"
        hyam = cdf_file->hyam
        hybm = cdf_file->hybm
        P0mb = cdf_file->P0/100.0


        U1 = cdf_file->U
        V1 = cdf_file->V
        TH1 = cdf_file->TH
        Z1 = cdf_file->Z3
        PS1 = cdf_file->PS
        PHIS1 = cdf_file->PHIS

        U2 = cdf_file2->U
        V2 = cdf_file2->V
        hyam2 = cdf_file2->hyam
        hybm2 = cdf_file2->hybm
        PS2 = cdf_file2->PS
        PHIS2 = cdf_file2->PHIS

        ; Convert to pressure levels

        U = vinth2p_ecmwf(U1,hyam,hybm,pnew,PS1,1,P0mb,1,True,0,PS1,PHIS1)
        V = vinth2p_ecmwf(V1,hyam,hybm,pnew,PS1,1,P0mb,1,True,0,PS1,PHIS1)
        TH = vinth2p(TH1,hyam,hybm,pnew,PS1,1,P0mb,1,False)
        Z = vinth2p(Z1,hyam,hybm,pnew,PS1,2,P0mb,1,False)

        temp = uv2sfvpF(U,V)
        SF = temp(0,:,:,:,:)

        Uno = vinth2p_ecmwf(U2,hyam2,hybm2,pnew,PS2,1,P0mb,1,True,0,PS2,PHIS2)
        Vno = vinth2p_ecmwf(V2,hyam2,hybm2,pnew,PS2,1,P0mb,1,True,0,PS2,PHIS2)

        temp = uv2sfvpF(Uno,Vno)
        SFno = temp(0,:,:,:,:)

        SF@_FillValue = U@_FillValue
        SFno@_FillValue = U@_FillValue

        ; mask out regions below ground in control simulation with mountain
        ;print(level)
        do ilat = 0,nlat-1
            do ilon = 0,nlon-1
                do ilevp = 0,nplevels-1
                    if PS1(0,ilat,ilon) .LT. (pnew(ilevp)+20) *100.0
                    ;	print(tostring(ilevp) + ", " + tostring(ilat) + ", " + tostring(ilon))
                        U(:,ilevp,ilat,ilon) = U@_FillValue
                        V(:,ilevp,ilat,ilon) = V@_FillValue
                        Uno(:,ilevp,ilat,ilon) = Uno@_FillValue
                        Vno(:,ilevp,ilat,ilon) = Vno@_FillValue

                        TH(:,ilevp,ilat,ilon) = TH@_FillValue
                        SF(:,ilevp,ilat,ilon) = SF@_FillValue
                        SFno(:,ilevp,ilat,ilon) = SFno@_FillValue

                    end if
                end do
            end do
        end do

        ; Calculate deviation streamfunction: effect of mountains

        PSIdev = SF - SFno

        ; conform pressure levels
        levels = conform_dims(dimsizes(U),pnew,1)

        ; Calculate lat and lon in radians
        latr = pi/180.0 * lat(:)
        lonr = pi/180.0 * lon(:)

        ; Calculate sin and cos of lat
        sinlat = conform_dims(dimsizes(U),sin(latr),2)
        coslat = conform_dims(dimsizes(U),cos(latr),2)

        ; Calculate coriolis frequency
        ftmp =  2.*2.*pi/(60.*60.*24.)*sin(latr)
        ftmp!0 = "lat"
        ftmp&lat = lat
        ftmp@_FillValue = U@_FillValue

        ; missing for 10S - 10N
        do ilat = 0, nlat-1
            if (abs(lat(ilat) ).lt. 10. ) then
                ftmp(ilat)= ftmp@_FillValue
            end if
        end do

        f = conform_dims(dimsizes(U),ftmp,2)

        ; Calculate buoyancy
        zdim = 1	; z dimension is 2nd dimensions
        dthdz = center_finite_diff_n(TH,Z,False,0,zdim) 
        
        NN = (g/TH) * dthdz

        ; Calculate magnitude of U
        magU = sqrt(Uno*Uno + Vno*Vno)
        magU@_FillValue = U@_FillValue

        ; Calculate various derivatives of PSIdev

        dPSIdevdlon = center_finite_diff_n(PSIdev,lonr,True,0,3)

        ddPSIdevdlonlon = center_finite_diff_n(dPSIdevdlon,lonr,True,0,3)
        
        dPSIdevdlat = center_finite_diff_n(PSIdev,latr,False,0,2)

        ddPSIdevdlatlat = center_finite_diff_n(dPSIdevdlat,latr,False,0,2)

        ddPSIdevdlonlat = center_finite_diff_n(dPSIdevdlon,latr,False,0,2)

        ; Different to original script: using Z instead of -scaleheight * log(level/1000)
        dPSIdevdz = center_finite_diff_n(PSIdev,Z,False,0,1)

        ddPSIdevdlonz = center_finite_diff_n(dPSIdevdlon,Z,False,0,1)

        ddPSIdevdlatz = center_finite_diff_n(dPSIdevdlat,Z,False,0,1)
        
        ; Calculate terms, taking cosphi inside the bracket mostly

        xuterm = (dPSIdevdlon * dPSIdevdlon - PSIdev * ddPSIdevdlonlon)	
        xvterm = (dPSIdevdlat * dPSIdevdlon - PSIdev * ddPSIdevdlonlat)

        yuterm = xvterm
        yvterm = (dPSIdevdlat * dPSIdevdlat - PSIdev * ddPSIdevdlatlat)
        
        zuterm = (dPSIdevdlon * dPSIdevdz - PSIdev * ddPSIdevdlonz)
        zvterm = (dPSIdevdlat * dPSIdevdz - PSIdev * ddPSIdevdlatz)


        ; Add together terms with appropriate multipliers, taking cosphi inside the bracket, and a2 outside
        ; Mask out where westerlies are small, or negative
        Fx = mask((levels/1000. / (a * a * 2.0 *magU)) * (Uno * xuterm /coslat + Vno * xvterm),Uno .lt. 2,False)

        Fy = mask((levels/1000. / (a * a * 2.0 * magU)) * (Uno * yuterm + Vno * coslat * yvterm), Uno .lt. 2, False)

        Fz = mask((levels/1000. * f * f / (NN  * a * 2.0 * magU)) * (Uno * zuterm + Vno * coslat * zvterm),Uno .lt. 2,False)

        ; for output
        print(dimsizes(Fx))
        Fx!0 = "time"
        Fx&time = time
        Fx!1 = "level"
        Fx&level = pnew
        Fx!2 = "lat"
        Fx&lat = lat
        Fx!3 = "lon"
        Fx&lon = lon

        
        copy_VarMeta(Fx,Fy)
        copy_VarMeta(Fx,Fz)
        copy_VarMeta(Fx,PSIdev)
        copy_VarMeta(Fx,NN)
        copy_VarMeta(Fx,SF)
        copy_VarMeta(Fx,SFno)
        copy_VarMeta(Fx,Uno)
        copy_VarMeta(Fx,Vno)
        copy_VarMeta(Fx,magU)

        copy_VarMeta(Fx,dPSIdevdlon)
        copy_VarMeta(Fx,dPSIdevdlat)
        copy_VarMeta(Fx,ddPSIdevdlonlon)
        copy_VarMeta(Fx,ddPSIdevdlonlat)


        Fx@units = "m^2/s^2"
        Fx@units = "m^2/s^2"
        Fz@units = "m^2/s^2"

        PSIdev@units = "m^2/s"

        NN@units = "1/s^2"

        filo = "TakNak01_fluxes_" + timespan + "_" + Experiment1 + "-" + Experiment2 + ".nc"
        system("/bin/rm -f " + Dir1 + filo)
        ncF = addfile(Dir1 + filo,"c")
        ncF->Fx = Fx
        ncF->Fy = Fy
        ncF->Fz = Fz
        ncF->NN = NN
        ncF->PSIdev = PSIdev
        ncF->SF = SF
        ncF->SFno = SFno
        ncF->Uno = Uno
        ncF->Vno = Vno
        ncF->magU = magU
        ncF->dPSIdevdlon = dPSIdevdlon
        ncF->dPSIdevdlat = dPSIdevdlat
        ncF->ddPSIdevdlonlon = ddPSIdevdlonlon
        ncF->ddPSIdevdlonlat = ddPSIdevdlonlat


        print("printed it")
    end do
end do

end
