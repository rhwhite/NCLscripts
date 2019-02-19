load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Code to regrid data using an input dataset, a destination grid, and an output dataset
; Options for globally conservative, or more accurate regridding

begin

; Get experiment names
inputdir = "/home/disk/eos4/rachel/CMIP/CMIP5/"

; RCP85 models
;models = (/"ACCESS1-0","ACCESS1-3","CMCC-CESM","CMCC-CM","CMCC-CMS","CNRM-CM5","CSIRO-Mk3-6-0","CanESM2","EC-EARTH","GFDL-CM3","GFDL-ESM2G","GFDL-ESM2M","GISS-E2-H","GISS-E2-H-CC","GISS-E2-R","GISS-E2-R-CC","HadGEM2-AO","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR","IPSL-CM5B-LR","MIROC-ESM","MIROC-ESM-CHEM","MIROC5","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","MRI-ESM1","NorESM1-M","NorESM1-ME"/)

; 4xCO2 models 
models = (/"ACCESS1-0","ACCESS1-3","CanESM2","CNRM-CM5","CSIRO-Mk3-6-0","CSIRO-Mk3L-1-2","EC-EARTH","GFDL-ESM2G","GFDL-ESM2M","GISS-E2-H","GISS-E2-R","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR","IPSL-CM5B-LR","MIROC5","MIROC-ESM","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","NorESM1-ME"/)

;period="RCP85"
period = "4xCO2"

vars = (/"tos","sic"/)
diradds = (/"SST","CICE"/)
nmodels = dimsizes(models)

print(nmodels * 1)

months = (/1,2,3,4,5,6,7,8,9,10,11,12/)

do i = 0,nmodels-1
    model = models(i)
    print(tostring(model))

    fulldir = inputdir + period + "/SST/"
    if period .EQ. "HIS" then
        inputfilename = "clim1970-2005_" + model + ".nc"
    else if period .EQ. "RCP85" then
        inputfilename = "clim2070-2099_" + model + ".nc"
    else if period .EQ. "4xCO2" then
        inputfilename = "clim
    end if
    end if

    inputfile = addfile(fulldir + "/" + inputfilename,"r")
 
    infield = inputfile->tos
    inputmask = infield(0,:,:)
    if model .EQ. "EC-EARTH" then
        inputmask = where(inputmask.eq.273.15,0.0,1.0)
    else if model .EQ. "MRI-CGCM3" .OR. model .EQ. "MRI-ESM1" .OR. model .EQ. "MIROC5" then
        inputmask = where(inputmask.le.10,0.0,1.0)
    else
        inputmask = where(inputmask.gt.0, 1.0, 0.0)
    end if
    end if

    inputmask = where(ismissing(inputmask),0.0,inputmask(:,:))


    do ivar = 0,1
        var = vars(ivar)
        print(tostring(var))

        Opt = True
        ;Opt@SrcFileName = inputfilename
        if var .EQ. "tos"
            Opt@InterpMethod = "bilinear"
        else
            Opt@InterpMethod = "conserve"
        end if

        fulldir = inputdir + period + "/" + diradds(ivar) + "/"
        if period .EQ. "HIS" then
            inputfilename = "clim1970-2005_" + model + ".nc"
        else if period .EQ. "RCP85" then
            inputfilename = "clim2070-2099_" + model + ".nc"
        end if
        end if   
 
        inputfile = addfile(fulldir + "/" + inputfilename,"r")
        inlats = inputfile->lat
        inlons = inputfile->lon
        if var .EQ. "tos" then
            infield = inputfile->tos
        else
            infield = inputfile->sic
        end if

        indimsize = dimsizes(infield)
        ntime = indimsize(0)
        nlon = indimsize(1)
        nlat = indimsize(2)

        outputmaskfilename = "/home/disk/eos4/rachel/inputdata/share/domains/domain.ocn.1.9x2.5_gx1v6_090403.nc"

        if period .EQ. "RCP85" .AND. (model .EQ. "CSIRO-Mk3-6-0" .OR. model .EQ. "GISS-E2-H" .OR. model .EQ. "GISS-E2-R" .OR. model .EQ. "HadGEM2-ES") then
            ; no lat_vertices - need to create
            latbnds = inputfile->lat_bnds(:,:)
            lonbnds = inputfile->lon_bnds(:,:)
            
            templon = table_attach_columns(lonbnds,lonbnds,0)
            inloncorn = conform_dims((/nlon,nlat,4/),templon,(/1,2/))
            printVarSummary(inloncorn)
            
            inlatcorn = new(dimsizes(inloncorn),"double")
            ; need to copy to all other longitudes
            do ilon=0,nlon-1
                inlatcorn(:,ilon,0) = latbnds(:,0)
                inlatcorn(:,ilon,1) = latbnds(:,0)
                inlatcorn(:,ilon,2) = latbnds(:,1)
                inlatcorn(:,ilon,3) = latbnds(:,1)
            end do
            printVarSummary(inlatcorn)
            delete(latbnds)
            delete(lonbnds)
            delete(templon)
        else if period .EQ. "RCP85" .AND. (model .EQ. "CMCC-CM" .OR. model .EQ. "CNRM-CM5" .OR. model .EQ. "IPSL-CM5A-LR" .OR. model .EQ. "MPI-ESM-LR") then
            inlatcorn = inputfile->lat_bnds(:,:,:)
            inloncorn = inputfile->lon_bnds(:,:,:)
            Opt@SrcGridCornerLat = inlatcorn
            Opt@SrcGridCornerLon = inloncorn

        else if model .EQ. "CSIRO-Mk3-6-0" .OR. model .EQ. "CanESM2" .OR. model .EQ. "GISS-E2-H" .OR. model .EQ. "GISS-E2-H-CC" .OR. model .EQ. "GISS-E2-R" .OR. model .EQ. "GISS-E2-R-CC" .OR. model .EQ. "HadGEM2-AO" .OR. model .EQ. "HadGEM2-CC" .OR. model .EQ. "HadGEM2-ES" .OR. model .EQ. "MIROC-ESM-CHEM" .OR. model .EQ. "MIROC-ESM"
            ; no lat_vertices - need to create
            latbnds = inputfile->lat_bnds(0,:,:)
            lonbnds = inputfile->lon_bnds(0,:,:)

            templon = table_attach_columns(lonbnds,lonbnds,0)
            inloncorn = conform_dims((/nlon,nlat,4/),templon,(/1,2/))   
            printVarSummary(inloncorn)
 
            inlatcorn = new(dimsizes(inloncorn),"double")
            ; need to copy to all other longitudes
            do ilon=0,nlon-1
                inlatcorn(:,ilon,0) = latbnds(:,0)
                inlatcorn(:,ilon,1) = latbnds(:,0)
                inlatcorn(:,ilon,2) = latbnds(:,1)
                inlatcorn(:,ilon,3) = latbnds(:,1)            
            end do
            printVarSummary(inlatcorn)
            delete(latbnds)
            delete(lonbnds)
            delete(templon)
        else
            inlatcorn = inputfile->lat_vertices(0,:,:,:)
            inloncorn = inputfile->lon_vertices(0,:,:,:)
            Opt@SrcGridCornerLat = inlatcorn
            Opt@SrcGridCornerLon = inloncorn
        end if
        end if
        end if

        outputmaskfile = addfile(outputmaskfilename,"r")
        outputmask = outputmaskfile->mask
        outlatcorn = outputmaskfile->yv
        outloncorn = outputmaskfile->xv

        indimsize = dimsizes(infield)
        ntime = indimsize(0)
        nlon = indimsize(1)
        nlat = indimsize(2) 
         
        outputgrid = addfile("/home/disk/eos4/rachel/inputdata/ssts/sst_HadOIBl_bc_1.9x2.5_1970_2012_c130411.nc","r") 
        outlats = outputgrid->lat
        outlons = outputgrid->lon

        nolat = dimsizes(outlats)
        nolon = dimsizes(outlons)

        Opt@DstGridCornerLat = outlatcorn
        Opt@DstGridCornerLon = outloncorn

        Opt@SrcRegional = False
        Opt@DstGridLat = outlats
        Opt@DstGridLon = outlons
        Opt@SrcGridLat = inlats
        Opt@SrcGridLon = inlons
        Opt@ForceOverwrite = True

        ;Opt@WgtFileName = "/weights/CMIP_weights.nc"

        Opt@SrcGridMask = inputmask
        Opt@DstGridMask = outputmask

        ;If weights have not already been calculated (i.e. ivar = 0)
        if ivar .EQ. 0
            printVarSummary(infield)
            print("about to calculate")
            
            ofield = ESMF_regrid(infield,Opt)
            print(typeof(infield))
        else ; weights have already been calculated: use these!
            ofield = ESMF_regrid_with_weights(infield,"weights_file.nc",False)
        end if

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

        fout_std->inmask = inputmask
        delete(ofield)
        delete(infield)
        delete(inlats)
        delete(inlons)
        delete(Opt@SrcGridLat)
        delete(Opt@SrcGridLon)
        delete(Opt@SrcGridMask)
        print("printed it")
        
        delete([/inlatcorn,inloncorn,outlatcorn,outloncorn/])
        delete([/Opt@SrcGridCornerLon,Opt@SrcGridCornerLat,Opt@DstGridCornerLon,Opt@DstGridCornerLat/])
 

    end do
delete(inputmask)

end do

end
