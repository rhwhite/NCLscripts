load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


; Get inputs from environment variables set in shell script
Dir = getenv("NCL_dir")
infile = getenv("NCL_infile")
FileO = getenv("NCL_fileo")
PSfile = getenv("NCL_PSfile")
PHISfile = getenv("NCL_PHISfile")
startyr = toint(getenv("NCL_startyr"))
endyr = toint(getenv("NCL_endyr"))

nyears = endyr-startyr+1

; calculating for pressure levels 250 and 850mb
plevs = (/250,850/)
nlevs = dimsizes(plevs)

do ilev = 0,nlevs-1

    pnew = plevs(ilev)
    cdf_file = addfile(Dir + infile,"r")
    PS_file = addfile(Dir + PSfile,"r")
    PHIS_file = addfile(Dir + PHISfile,"r")

    PHIS = PHIS_file->PHIS(0,:,:)
    PS = PS_file->PS

    U = cdf_file->U
    V = cdf_file->V

    dimsizesU = dimsizes(U)
    ntimes = dimsizesU(0)
    print(ntimes)

    dimsizesPS = dimsizes(PS)
    nPStimes = dimsizesPS(0)
    if nPStimes .gt. ntimes
        tempPS = PS
        delete(PS)
        PS = tempPS(0:ntimes-1,:,:)
    end if

    P0mb = 0.01*cdf_file->P0
    hyam = cdf_file->hyam
    hybm = cdf_file->hybm

    ; replace TBOT with PS - only uses TBOT if interpolating as temperature,
    ; which we are not, but still requires the field. Hopefully it doesn't
    ; check unit or anything!

    Upres = vinth2p_ecmwf(U,hyam,hybm,pnew,PS,1,P0mb,1,True,0,PS,conform(PS,PHIS,(/1,2/)))
    Vpres = vinth2p_ecmwf(V,hyam,hybm,pnew,PS,1,P0mb,1,True,0,PS,conform(PS,PHIS,(/1,2/)))

;-----------------------------------------------------------------------
;Write variables to a new netcdf file
;-----------------------------------------------------------------------
    pname = "U" + tostring(pnew)

    filo = pname + "_daily_" + FileO
    system("/bin/rm -f " + Dir + filo)
    fout = addfile(Dir + filo, "c")


    ; set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout,fAtt)
    filedimdef(fout,"time",-1,True)   
 
    fout ->$pname$ = Upres

    pname = "V" + tostring(pnew)

    filo = pname + "_daily_" + FileO
    system("/bin/rm -f " + Dir + filo)
    fout = addfile(Dir + filo, "c")


    ; set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout,fAtt)
    filedimdef(fout,"time",-1,True)   

    fout ->$pname$ = Vpres
    delete(PS)
    delete(U)
    delete(V)
    delete(PHIS) 
end do

end
