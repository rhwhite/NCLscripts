load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"

; Calculate EP fluxes on a daily basis and then take the average.
; Based on NOAA NCL script at http://www.esrl.noaa.gov/psd/data/epflux/epflux.2010.ncl
; See also: http://www.esrl.noaa.gov/psd/data/epflux/img/EP_Flux_Calculation_and_Display.pdf
; Follows derivation of http://journals.ametsoc.org/doi/pdf/10.1175/1520-0469%281980%29037%3C2600%3AEPCSFT%3E2.0.CO%3B2
; produces Quasi-geostrophic Eliassen-Palm  Fluxes in spherical coordinates
; Plots the EP Flux vectors in a latitude-log(pressure) coordinate
; plot the divergence of EP-Flux

begin

; Get experiment names

logp = 0

print("Calc EP fluxes")

a = 6.37122e06	; radius of Earth
PI = 3.14159265358979

cp = 1.00464e3
Rd = 287.0
kappa = (Rd/cp)
omega =  7.2921e-5
g = 9.80616
P0 = 1000.0

expin = "WACCMSC_SOMSSTs"
years = "0002-0031"

dirin = "/home/disk/eos4/rachel/CESM_outfiles/StationaryWaves/" + expin + "/atm/hist/"
filein1 = "U_V_pldaily_" + expin + ".cam." + years + ".nc"
filein2 = "T_pldaily_" + expin + ".cam." + years + ".nc"

UVfile = addfile(dirin + filein1,"r")
Tfile = addfile(dirin + filein2,"r")

level = UVfile->lev_p

T = Tfile->T
U = UVfile->U
V = UVfile->V

; Calculate potential temperature
THETA = T
THETA = T * (conform(T,level,1)/1000.0)^(-1.0 * kappa)

filo = "EPfluxes_daily_" + expin + "." + years + ".nc"

check = printEP_levp(dirin,filo,U,V,THETA,level)
return(check)

end
