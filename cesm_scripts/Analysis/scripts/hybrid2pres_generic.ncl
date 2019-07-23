load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


Dirin = getenv("NCL_dir")
Filein = getenv("NCL_file")

; Set some constants
PI = 3.14159265358979
cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
g = 9.81

pnew = (/ 10.0, 20.0,30.0,50.0,70.0,90.0,120.0,150.0,200.0,250.0 \
                 , 300.0,400.0,500.0,600.0,700.0,750.0,775.0,850.0,925.0,1000.0 /)

p_int = 10^fspan(1,3,15)   ; interpolation targets
p_int!0 = "lev_int" 
dimslevint = dimsizes(p_int)
		
filename = (Dirin + Filein)

cdf_file = addfile(filename,"r")

; Set up output file
setfileoption("nc","Format","NetCDF4Classic")
filo = "pl_" + Filein

system("/bin/rm -f " + Dirin + filo)
fout = addfile(Dirin + filo, "c")

setfileoption(fout,"DefineMode",True)
; set attributes of output file
fAtt = True
fAtt@creation_date = systemfunc("date")
fileattdef(fout,fAtt)


vNames = getfilevarnames(cdf_file)
nvars = dimsizes(vNames)

lat = cdf_file->lat
lon = cdf_file->lon
nlats = dimsizes(lat)
nlons = dimsizes(lon)
P0mb = 0.01*cdf_file->P0

levs = cdf_file->lev
nlevs = dimsizes(levs)

hyam = cdf_file->hyam
hybm = cdf_file->hybm
PS = cdf_file->PS
print(getvardims(PS))
;PHIS = cdf_file->PHIS
do ivar =0,nvars-1

    invar = cdf_file->$vNames(ivar)$

    ; get dimensions
    dimv = dimsizes(invar)
    dims = getvardims(invar)
    rank = dimsizes(dimv)

    if rank .GE. 2 then
        if (dims(1)) .EQ. "lev" then
            print(vNames(ivar))
            if vNames(ivar) .EQ. "T" then
                varp = vinth2p(invar,hyam,hybm,pnew,PS,1,P0mb,1,False)
            else if vNames(ivar) .EQ. "Z3" then
                varp = vinth2p(invar,hyam,hybm,pnew,PS,1,P0mb,1,False)
            else
                varp = vinth2p(invar,hyam,hybm,pnew,PS,1,P0mb,1,False)
            end if 
            end if
            fout->$vNames(ivar)$ = varp
        else
            fout->$vNames(ivar)$ = invar
        end if
    else
        fout->$vNames(ivar)$ = invar

    end if
    delete(invar) 
    delete(dimv)
    delete(dims) 
end do

end
