load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/inputdata/LGM/PMIP3/"

models = (/"GISS-E2-R","MRI-CGCM3","MPI-ESM-P","CCSM4","IPSL-CM5A-LR","MIROC-ESM","CNRM-CM5"/)
vars = (/"tos","sic"/)
diradds = (/"SST","CICE"/)
nmodels = 7

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)
LGM = 0

do i = 0,nmodels-1
    model = models(i)
    print(model)

    do ivar = 0,1
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
            outputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/f09/LGM_domain.ocn.fv0.9x1.25_gx1v7.151020.nc"

        else
            inputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/PMIP3/Historical/" + model + "_mask.nc"
            outputmaskfilename = "/home/disk/eos4/rachel/inputdata/LGM/f09/domain.ocn.fv0.9x1.25_gx1v7.151020.nc"

        end if

        inputmaskfile = addfile(inputmaskfilename,"r")
        inputmask = inputmaskfile->mask(0,:,:)
        lat_vertices = inputmaskfile->lat_vertices
        lon_vertices = inputmaskfile->lon_vertices

        ; test to see if inlatcorn is 3D (it should be!)
        temp = dimsizes(lat_vertices)

        if dimsizes(temp) .EQ. 3 then
            inlatcorn = lat_vertices
            inloncorn = lon_vertices

        else if dimsizes(temp) .EQ. 2 then
            ; need to make it 3D
            mdims = dimsizes(inputmask)
            nlat = mdims(0)
            nlon = mdims(1)
            templon = table_attach_columns(lon_vertices,lon_vertices,0)
            inloncorn = conform_dims((/nlat,nlon,4/),templon,(/1,2/))
            delete(templon)
            inlatcorn = new(dimsizes(inloncorn),"double")
            ; need to copy to all other longitudes
            do ilon=0,nlon-1
                inlatcorn(:,ilon,0) = lat_vertices(:,0)
                inlatcorn(:,ilon,1) = lat_vertices(:,0)
                inlatcorn(:,ilon,2) = lat_vertices(:,1)
                inlatcorn(:,ilon,3) = lat_vertices(:,1)
            end do
        end if
        end if


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

        outputgrid = addfile("/home/disk/eos4/rachel/inputdata/LGM/f09/sst_HadOIBl_bc_0.9x1.25_clim_c040926.nc","r") 
        outlats = outputgrid->lat
        outlons = outputgrid->lon

        nolat = dimsizes(outlats)
        nolon = dimsizes(outlons)

        Opt = True
        ;Opt@SrcFileName = inputfilename
        if var .EQ. "tos" then
            Opt@InterpMethod = "bilinear"
        else if model .EQ. "CNRM-CM5" then
            Opt@InterpMethod = "bilinear"
        else
            Opt@InterpMethod = "conserve"
        end if
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

        outputname = fulldir + "regrid_f09_" + inputfilename

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
        
        delete([/inlatcorn,inloncorn,lat_vertices,lon_vertices,temp/])
        delete([/outlatcorn,outloncorn/])

        delete([/Opt@SrcGridCornerLon,Opt@SrcGridCornerLat,Opt@DstGridCornerLon,Opt@DstGridCornerLat/])
 

    end do
end do

end
