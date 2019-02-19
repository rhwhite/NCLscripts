load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/inputdata/LGM/PMIP3/"

models = (/"MPI-ESM-P","CCSM4","IPSL-CM5A-LR","MIROC-ESM","CNRM-CM5","GISS-E2-R","MRI-CGCM3"/)
vars = (/"sic","tos"/)
diradds = (/"CICE","SST"/)
nmodels = 7

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)
LGM = 0

do i = 0,nmodels-1
    model = models(i)
    print(model)

    do ivar = 0,0
        var = vars(ivar)

        if LGM .EQ. 1 then
            fulldir = inputdir + "/LGM/" + diradds(ivar) + "/" 
            inputfilename = var + "_LGM_" + model + ".nc"

        else
            fulldir = inputdir + "/Historical/" + diradds(ivar) + "/"
            inputfilename = var + "_1980-2000_" + model + ".nc"
        end if
        
        inputfile = addfile(fulldir + "/" + inputfilename,"r")
        inlats = inputfile->lat
        inlons = inputfile->lon
        if var .EQ. "tos" then
            infield = inputfile->tos
        else
            infield = inputfile->sic
        end if

        if LGM .EQ. 1 then
            inputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/PMIP3/LGM/" + model + "_mask.nc"
            outputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/domain.camocn.1.9x2.5_gx1v6_LGM_new.nc"

        else
            inputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/PMIP3/Historical/" + model + "_mask.nc"
            outputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/domain.camocn.1.9x2.5_gx1v6_090403.nc"

        end if

        inputmaskfile = addfile(inputmaskfilename,"r")
        inputmask = inputmaskfile->mask(0,:,:)
        inlatcorn = inputmaskfile->lat_vertices
        inloncorn = inputmaskfile->lon_vertices

        printVarSummary(inputmask)
        outputmaskfile = addfile(outputmaskfilename,"r")
        outputmask = outputmaskfile->mask
        outlatcorn = outputmaskfile->yv
        outloncorn = outputmaskfile->xv

        indimsize = dimsizes(infield)
        ntime = indimsize(0)
        nlon = indimsize(1)
        nlat = indimsize(2) 
         
        print(nlat)
        print(nlon)

        outputgrid = addfile("/home/disk/eos4/rachel/inputdata/LGM/sst_HadOIBl_bc_1.9x2.5_1850_2014_c150416.nc","r") 
        outlats = outputgrid->lat
        outlons = outputgrid->lon

        nolat = dimsizes(outlats)
        nolon = dimsizes(outlons)

        Opt = True
        ;Opt@SrcFileName = inputfilename
        if var .EQ. "tos"
            Opt@InterpMethod = "bilinear"
        else
            Opt@InterpMethod = "conserve"
        end if
        Opt@SrcGridCornerLat = inlatcorn
        Opt@SrcGridCornerLon = inloncorn
        Opt@DstGridCornerLat = outlatcorn
        Opt@DstGridCornerLon = outloncorn

        Opt@SrcRegional = False
        Opt@DstGridLat = outlats
        Opt@DstGridLon = outlons
        Opt@SrcGridLat = inlats
        Opt@SrcGridLon = inlons
        Opt@ForceOverwrite = True

        Opt@SrcGridMask = inputmask
        Opt@DstGridMask = outputmask

        ;If weights have not already been calculated:
        printVarSummary(infield)
        print("about to calculate")

        ofield = ESMF_regrid(infield,Opt)
        print(typeof(infield))

        ;----------------------------------------------------------------------
        ; Write out results to a new netcdf file
        ;-----------------------------------------------------------------------

        outputname = fulldir + "regrid_" + inputfilename

        system("/bin/rm -f " + outputname)
        setfileoption("nc","Format","LargeFile")

        fout_std = addfile(outputname, "c")

        setfileoption(fout_std,"DefineMode",True)

        ;set attributes of output file
        fAtt = True
        fAtt@creation_date = systemfunc("date")
        fileattdef(fout_std,fAtt)

        ;set dimensions of output file
        dimNames = (/"time","lat","lon"/)
        dimSizes = (/ntime,nolat,nolon/)
        dimUnlim = (/True,False,False/)
        filedimdef(fout_std,dimNames,dimSizes,dimUnlim)
        ;
        filevardef(fout_std,"time",typeof(months),(/"time"/))
        filevardef(fout_std,"lat",typeof(outlats),getvardims(outlats))
        filevardef(fout_std,var,typeof(ofield),(/"time","lat","lon"/))
        filevardef(fout_std,"lon",typeof(outlons),getvardims(outlons))

        setfileoption(fout_std,"DefineMode",False)

        printVarSummary(ofield)
        if var .EQ. "tos" then
            fout_std->tos = (/ofield/)
        else
            fout_std->sic = (/ofield/)
        end if
        fout_std->lat = outlats
        fout_std->lon = outlons

        fout_std->time = (/months/)

        delete(ofield)
        delete(infield)
        delete(inlats)
        delete(inlons)
        delete(Opt@SrcGridLat)
        delete(Opt@SrcGridLon)
        delete(inputmask)
        delete(Opt@SrcGridMask)
        print("printed it")
        
        delete([/inlatcorn,inloncorn,outlatcorn,outloncorn/])
        delete([/Opt@SrcGridCornerLon,Opt@SrcGridCornerLat,Opt@DstGridCornerLon,Opt@DstGridCornerLat/])
 

    end do
end do

end
