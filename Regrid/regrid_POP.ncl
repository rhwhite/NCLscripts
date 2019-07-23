load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
dir = "/home/disk/eos4/rachel/CESM_outfiles/AMOC/"

exps = (/"CAM4POP_NoMTR_f19"/) ;,"CAM4POP_NoMT_f09","CAM4POP_NoR_f19","CAM4POP_NoR_f09","CAM4POP_NoTopo_f19","CAM4POP_NoTopo_f09","CAM4POP_NoMT_AtAr_hosing_f19"/)
;exps = (/"CAM4POP_CTL_f09","CAM4POP_CTL_f19"/)

nexps = dimsizes(exps)

seasons = (/"ANN","DJF","MAM","JJA","SON"/)

startyr = "0251"
endyr = "0300"

do iexp = 0,nexps-1
    do iseas = 0,4
        seas = seasons(iseas)
        ifile = seas + "clim_" + exps(iexp) + ".pop.h." + startyr + "-" + endyr + ".nc"
        inputdir = dir + "/" + exps(iexp) + "/ocn/"

        print(inputdir + ifile)
        in = addfile(inputdir + ifile,"r")
        outputfile = inputdir + "regrid_" + ifile

        HMXL = in->HMXL
        TEMP = in->TEMP
        SALT = in->SALT
        RHO = in->RHO 
        MOC = in->AMOC
        GMOC = in->GlobalMOC
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
        fout_std->AMOC = MOC
        fout_std->GlobalMOC = GMOC
        fout_std->ROFF = remapROFF
        print("printed it")

        delete(MOC)
    end do
end do
end
