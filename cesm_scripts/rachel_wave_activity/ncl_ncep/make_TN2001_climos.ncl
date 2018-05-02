load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

basepath = "/n/huybers_lab/common/data/NCEP_R2/derived/misc/"

; daily mean data
fileNames = systemfunc("ls "+basepath+"TN2001.daily.????.nc")

;** preallocate and then generate monthly files
theFile = addfile(fileNames(0),"r")
lat = theFile->lat
lon = theFile->lon
level = theFile->level
nmo = (2013-1979)*12
yyyy = toint(floor(fspan(1980.,2013.+11./12.,nmo)));
mm = toint(mod(ispan(1,nmo,1)-1,12)+1)
printVarSummary(yyyy)
onefill = new(dimsizes(yyyy),typeof(yyyy));
onefill = (/1/)
time = cd_inv_calendar(yyyy,mm,15*onefill,0*onefill,0*onefill,0*onefill,"hours since 1800-1-1 00:00:0.0",0)
time!0 = "time"
varNames = (/"Fx","Fy","Fz","DivF","psidev","NN"/)
do jvar = 0, dimsizes(varNames)-1, 1
varName = varNames(jvar)
theVar_monthly_all = new((/12*dimsizes(fileNames),dimsizes(level),dimsizes(lat),dimsizes(lon)/),"float")
do jfile = 0, (dimsizes(fileNames)-1), 1
  theFile = addfile(fileNames(jfile),"r")
  theVar_daily = theFile->$varName$
  theVar_monthly = calculate_monthly_values(theVar_daily,"avg",0,False)
  theVar_monthly_all((12*jfile):(12*(jfile+1)-1),:,:,:) = (/theVar_monthly/);
  delete(theVar_daily)
  delete(theVar_monthly)
end do
theVar_monthly_all!0 = "time"
theVar_monthly_all&time = time
theVar_monthly_all!1 = "level"
theVar_monthly_all&level = level
theVar_monthly_all!2 = "lat"
theVar_monthly_all&lat = lat
theVar_monthly_all!3 = "lon"
theVar_monthly_all&lon = lon

system("/bin/rm -f "+basepath+"TN2001."+varName+".monthly.nc")   ; remove any pre-existing file
ncdf = addfile(basepath+"TN2001."+varName+".monthly.nc","c")  ; open output netCDF file
; create global attributes of the file (optional)
; make time an UNLIMITED dimension; recommended  for most applications
filedimdef(ncdf,"time",-1,True)
ncdf->$varName$ = theVar_monthly_all                        ; 4D

; ** Climos
theVarClmMon = clmMonTLLL(theVar_monthly_all)
system("/bin/rm -f "+basepath+"TN2001."+varName+".ClmMon.nc")   ; remove any pre-existing file
ncdf = addfile(basepath+"TN2001."+varName+".ClmMon.nc","c")  ; open output netCDF file
filedimdef(ncdf,"time",-1,True)
varSaveName = varName+"Clm"
ncdf->$varSaveName$ = theVarClmMon                        ; 4D

delete(theVar_monthly_all)
delete(theVarClmMon)

end do


;==============
end