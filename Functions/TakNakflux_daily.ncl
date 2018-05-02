load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Based on
; http://www.atmos.rcast.u-tokyo.ac.jp/nishii/programs/TakayaNakamura2001-ncep-daily-10d-lpf.ncl
; Follows derivation of
; http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469(2001)058%3C0608:AFOAPI%3E2.0.CO%3B2
; Calculated fluxes from daily values
; with perturbations as differences between two experiments, or from
; climatological seasonal mean
; Quasi-geostrophic, in spherical coordinates

undef("printTakNakdaily")
function printTakNakdaily(Dir,filo:string,SF,SFbase,Ubase,Vbase,THbase,Zbase,level,lat,lon,time)
begin

    a = 6.37122e06  ; radius of Earth
    pi = 3.14159265358979
    omega =  7.2921e-5
    g = 9.80616
    P0 = 1000.0

    ; conform pressure levels
    levels = conform_dims(dimsizes(SF),level,1)

    ; Calculate lat and lon in radians
    latr = pi/180.0 * lat(:)
    lonr = pi/180.0 * lon(:)

    nlat = dimsizes(lat)
    ; Calculate sin and cos of lat
    sinlat = conform_dims(dimsizes(SF),sin(latr),2)
    coslat = conform_dims(dimsizes(SF),cos(latr),2)

    ; read in

    ; Calculate coriolis frequency
    ftmp =  2.*2.*pi/(60.*60.*24.)*sin(latr)
    ftmp!0 = "lat"
    ftmp&lat = lat
    ftmp@_FillValue = SF@_FillValue

    ; missing for 10S - 10N
    do ilat = 0, nlat-1
        if (abs(lat(ilat) ).lt. 10. ) then
            ftmp(ilat)= ftmp@_FillValue
        end if
    end do


    ; Calculate deviation streamfunction
    PSIdev = SF - conform(SF,SFbase,(/1,2,3/))

    ; Calculate buoyancy
    zdim = 1    ; z dimension is 2nd dimensions
    dthdz = center_finite_diff_n(THbase,Zbase,False,0,zdim)

    NNtemp = (g/THbase) * dthdz

    ; Calculate magnitude of U
    magUt = sqrt(Ubase*Ubase + Vbase*Vbase)
    magUt@_FillValue = SF@_FillValue

    magU = conform(SF,magUt,(/1,2,3/)) 

    ; Conform remaining:
    U = conform(SF,Ubase,(/1,2,3/))
    V = conform(SF,Vbase,(/1,2,3/))
    Z = conform(SF,Zbase,(/1,2,3/))
    NN = conform(SF,NNtemp,(/1,2,3/))
    f = conform(SF,ftmp,2)
  
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

    ; Add together terms with appropriate multipliers, taking cosphi inside the
    ; bracket, and a2 outside
    ; Mask out where westerlies are small, or negative
    Fx = mask((levels/1000. / (a * a * 2.0 *magU)) * (U * xuterm /coslat + V * xvterm),U .lt. 2,False)

    Fy = mask((levels/1000. / (a * a * 2.0 * magU)) * (U * yuterm + V * coslat * yvterm), U .lt. 2, False)

    denom = mask(NN  * a * 2.0 * magU, (NN  * a * 2.0 * magU) .eq. 0,False)
    Fz = mask((levels/1000. * f * f / (denom)) * (U * zuterm + V * coslat * zvterm),U .lt. 2,False)


    ; for output
    Fx!0 = "time"
    Fx&time = time
    Fx!1 = "level"
    Fx&level = level
    Fx!2 = "lat"
    Fx&lat = lat
    Fx!3 = "lon"
    Fx&lon = lon

    copy_VarMeta(Fx,Fy)
    copy_VarMeta(Fx,Fz)
    copy_VarMeta(Fx,PSIdev)
    copy_VarMeta(Fx,NN)
    copy_VarMeta(Fx,SF)

    copy_VarMeta(Fx,dPSIdevdlon)
    copy_VarMeta(Fx,dPSIdevdlat)
    copy_VarMeta(Fx,ddPSIdevdlonlon)
    copy_VarMeta(Fx,ddPSIdevdlonlat)


    Fx@units = "m^2/s^2"
    Fy@units = "m^2/s^2"
    Fz@units = "m^2/s^2"

    PSIdev@units = "m^2/s"

    NN@units = "1/s^2"

    ;-----------------------------------------------------------------------

    system("/bin/rm -f " + Dir + filo)
    ncF = addfile(Dir + filo, "c")

    setfileoption(ncF,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(ncF,fAtt)
    ; make time a record dimension
    filedimdef(ncF,"time",-1,True)

    ncF->Fx = Fx
    ncF->Fy = Fy
    ncF->Fz = Fz
    ;ncF->NN = NN
    ;ncF->PSIdev = PSIdev
    ;ncF->SF = SF
    ;ncF->SFno = SFno
    ;ncF->Uno = Uno
    ;ncF->Vno = Vno
    ;ncF->magU = magU
    ;ncF->dPSIdevdlon = dPSIdevdlon
    ;ncF->dPSIdevdlat = dPSIdevdlat
    ;ncF->ddPSIdevdlonlon = ddPSIdevdlonlon
    ;ncF->ddPSIdevdlonlat = ddPSIdevdlonlat

    ; make time a record dimension
    filedimdef(ncF,"time",-1,True)

    return(1)

end
