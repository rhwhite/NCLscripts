load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

basepath = "/n/huybers_lab/common/data/NCEP_R2/"
; No climatology, so will have to generate the long-term means manually for:
; air
; hgt
; uwnd
; vwnd

; daily mean data
varNames = (/"hgt","air","uwnd","vwnd"/)
do jvar = 0, 3, 1
;varName = "hgt"
varName = varNames(jvar)
fileNames = systemfunc("ls "+basepath+varName+"/"+varName+".????.nc")
theFile = addfiles(fileNames,"r")

; Load and compute climatology
theVar_daily = short2flt(theFile[:]->$varName$)
time = theFile[:]->time
TIME    = cd_calendar(time, 0)          ; type float 
year    = toint( TIME(:,0) )
month   = toint( TIME(:,1) )
day     = toint( TIME(:,2) ) 
ddd     = day_of_year(year, month, day) 
yyyyddd = year*1000 + ddd                                  
varClmDay    = clmDayTLLL(theVar_daily, yyyyddd)
varClmDay_sm = smthClmDayTLLL(varClmDay, 5)
; Save
system("/bin/rm -f "+basepath+varName+"/"+varName+".ltm.nc")   ; remove any pre-existing file
ncdf = addfile(basepath+varName+"/"+varName+".ltm.nc","c")  ; open output netCDF file
; create global attributes of the file (optional)
fAtt               = True            ; assign file attributes
fAtt@title         = varName+" daily long-term mean climatology."
fAtt@creation_date = systemfunc ("date")
fileattdef( ncdf, fAtt )            ; copy file attributes
; make time an UNLIMITED dimension; recommended  for most applications
filedimdef(ncdf,"time",-1,True) 
varNameClm = varName+"Clm"
varNameClm_sm = varName+"ClmSm"
ncdf->$varNameClm$ = varClmDay                         ; 3D 
ncdf->$varNameClm_sm$ = varClmDay_sm
delete(theVar_daily)
end do

;==============
end