load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; Calculate various variables including PV, SF, divergences, MSE
; and add to monthly average files
; then calculate climatological means on monthly
; and annual resolution using NCO command line functions

begin


Dir = "/home/disk/eos4/rachel/CESM_outfiles/"
Experiment = "CAM4POP_f19g16C_noMT"

startyr = 34
endyr = 160

do iy = startyr,endyr
    print(tostring(iy))
    if iy .lt. 10 then
        stringyear = "000" + tostring(iy)
    else 
        if iy .lt. 100 then
            stringyear = "00" + tostring(iy)
        else
            stringyear = "0" + tostring(iy)
        end if
    end if
    
    do im = 1,12
        if im .lt. 10 then
            stringmonth = "0" + tostring(im)
        else
            stringmonth = tostring(im)
        end if


        ;   Now for each month calculate RHO

        ocnfile = (Dir + Experiment + "/ocn/hist/raw/limited/limited_" + Experiment + ".pop.h." + stringyear + "-" + stringmonth + ".nc")
        focn = addfile(ocnfile, "rw")
        salt = focn->SALT(:,:,:,:)   ;(time, z_t, lat,lon)
        temp = focn->TEMP(:,:,:,:)

        ;============== compute potenial density (PD), using rho_mwjf
        ;
        ; for potential density, depth = 0. (i.e. density as if brought to surface)
        ;
        ;===========================================================================
        ; WARNING: T-S diagrams use POTENTIAL DENSITY... if set depth to something
        ; other then 0, then you will be plotting density contours computed for the
        ; specified depth layer.
        ;===========================================================================

        depth = 5.0  ;in meters
        pd = new((/dimsizes(salt)/),float)
        ; need to convert SALT from PSU to kg/kg (multiply by 1000)
        pd(0,0,:,:) = rho_mwjf(temp(0,0,:,:),salt(0,0,:,:)*1000,depth)

        copy_VarCoords(salt,pd) 
        focn->RHO = pd
			
	end do
end do
end
