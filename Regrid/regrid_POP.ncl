load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
nexps = 1

;dirs = (/"/home/disk/rachel/CESM_outfiles/CAM4POP_B1850_NCAR/ocn/hist/","/home/disk/eos4/rachel/CESM_outfiles/CAM4POP_f19g16C_noTopo/ocn/hist/","/home/disk/eos4/rachel/CESM_outfiles/CAM4POP_f19g16C_noMT/ocn/hist/","/home/disk/eos4/rachel/CESM_outfiles/CAM4POP_f19g16C_noR/ocn/hist/"/)

;files = (/"_HMXL_TEMP_MOC_SALT_RHO_b40.1850.track1.2deg.003.pop.080001-089912.nc", "_CAM4POP_f19g16C_noTopo.pop.h.0350-0373.nc","_CAM4POP_f19g16C_noMT.pop.h.0250-0273.nc","_CAM4POP_f19g16C_noR.pop.h.0411-0450.nc"/)

;dirs = (/"/home/disk/eos4/rachel/CESM_outfiles/Cheyenne/CAM4POP_NoMThosing/ocn/hist/"/)
dirs = (/"/home/disk/eos4/rachel/CESM_outfiles/CAM4POP_f19g16C_noMT/ocn/hist/"/)

;files = (/"clim_CAM4POP_NoMThosing.pop.h.0251-0300.nc"/)
files = (/"clim_ROFF_F_CAM4POP_f19g16C_noMT.pop.h.0001-0049.nc"/)
seasons = (/"ANN","DJF","MAM","JJA","SON"/)


do ifile = 0,nexps-1
    do iseas = 0,4
        seas = seasons(iseas)
        inputdir = dirs(ifile)
        print(inputdir)

        filein = files(ifile)

        print(filein)
        in = addfile(inputdir + seas + filein,"r")
        outputfile = inputdir + "regrid_" + seas + filein

        HMXL = in->HMXL
        TEMP = in->TEMP
        SALT = in->SALT
        RHO = in->RHO 
        MOC = in->MOC
        ROFF = in->ROFF_F

        remapHMXL = PopLatLon(HMXL,"gx1v6","1x1d","bilin","da","100716")
        remapTEMP = PopLatLon(TEMP,"gx1v6","1x1d","bilin","da","100716")
        remapSALT = PopLatLon(SALT,"gx1v6","1x1d","bilin","da","100716")
        remapRHO = PopLatLon(RHO,"gx1v6","1x1d","bilin","da","100716")
        remapROFF = PopLatLon(ROFF,"gx1v6","1x1d","bilin","da","100716")

        system("rm " + outputfile) 
        fout_std = addfile(outputfile, "c")

        setfileoption(fout_std,"DefineMode",True)

        ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

        setfileoption(fout_std,"DefineMode",False)

        fout_std->HMXL = remapHMXL
        fout_std->TEMP = remapTEMP
        fout_std->SALT = remapSALT
        fout_std->RHO = remapRHO
        fout_std->MOC = MOC
        fout_std->ROFF = remapROFF
        print("printed it")

        delete(MOC)
    end do
end do
end
