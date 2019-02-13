load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"
load "/home/disk/eos4/rachel/git/NCL/Functions/TakNakflux_daily.ncl"

; Calculates TakNak fluxes on daily data from CTL, with seasonal means from No
; mountain experiments (i.e. the base state on which the effect of the mountains
; is acting

begin

; Get experiment names
;event = "1-Aug-15-Aug-2003"
event = "1-Aug-15-Aug-2010"
logp = 0

Dirb = "/home/disk/eos4/rachel/Obs/ERAI/Daily/TakNak_extremes/"
Direc = "/home/disk/eos4/rachel/Obs/ERAI/Daily/TakNak_extremes/"

lonstart = 0 
lonend = 360

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
P0 = 1000.0

; lev_int is used as an argument for runTakNakdaily
lev_int = 10^fspan(0,3,30)   ; interpolation targets
lev_int!0 = "lev_int"
dimslevint = dimsizes(lev_int)

; Read in base state variables
clim_inU = addfile(Dirb + "/" + "U_clim_" + event + ".nc","r")
clim_inV = addfile(Dirb + "/" + "V_clim_" + event + ".nc","r")
clim_inZ = addfile(Dirb + "/" + "Z_clim_" + event + ".nc","r")
clim_inT = addfile(Dirb + "/" + "T_clim_" + event + ".nc","r")

Ubase = clim_inU->u(:,:,:)
Vbase = clim_inV->v(:,:,:)
Zbase = clim_inZ->z(:,:,:)/9.81
Tbase = clim_inT->t(:,:,:)

lat = clim_inU->latitude
lon = clim_inU->longitude

dims = dimsizes(Ubase)
nlevels=dims(0)
nlats=dims(1)
nlons = dims(2)

print(nlats)
print(nlons)

uvmsg = 1e+36

plevs = clim_inU->level

SFbase    = new ( (/nlevels,nlats,nlons /), float, uvmsg )  ; stream function
vp    = new ( (/nlevels,nlats,nlons /), float, uvmsg )  ; velocity potential


uv2sfvpf (Ubase,Vbase, SFbase,vp)             ; u,v ==> stream function + velocity pot

THbase = pot_temp(plevs, Tbase, 0, False)  ; dim=0


; Read in event variables
event_inU = addfile(Dirb + "/" + "U_event_" + event + ".nc","r")
event_inV = addfile(Dirb + "/" + "V_event_" + event + ".nc","r")
event_inZ = addfile(Dirb + "/" + "Z_event_" + event + ".nc","r")
event_inT = addfile(Dirb + "/" + "T_event_" + event + ".nc","r")

U = event_inU->u(:,:,:)
V = event_inV->v(:,:,:)
Z = event_inZ->z(:,:,:)/9.81
T = event_inT->t(:,:,:)
uvmsg = 1e+36

SF    = new ( (/nlevels,nlats,nlons /), float, uvmsg )  ; stream function
vp    = new ( (/nlevels,nlats,nlons /), float, uvmsg )  ; velocity potential

uv2sfvpf (U,V, SF,vp)             ; u,v ==> stream function + velocity pot
TH = pot_temp(plevs, T, 0, False)  ; dim=0

filo_out = "TakNakfluxes_" + event + ".nc"

check = printTakNaksingle(Dirb,filo_out,SF,SFbase,Ubase,Vbase,THbase,Zbase,plevs,lat,lon)
return(check)


end
