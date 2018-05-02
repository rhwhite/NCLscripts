; -------------------------------------
; Scripts to process CESM data
; Should be generic enough to work with most input, but they do make certain
; assumptions about dimensions and variables present
;
; Author: R. H. White rachel.white@cantab.net
; Created: 2016
;------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("hybrid2pres")
function hybrid2pres(cdf_file,fout,pnew)
begin
    lat = cdf_file->lat
    lon = cdf_file->lon
    P0mb = 0.01*cdf_file->P0

    hyam = cdf_file->hyam
    hybm = cdf_file->hybm
    PS = cdf_file->PS

    Tpres = vinth2p(cdf_file->T,hyam,hybm,pnew,PS,1,P0mb,1,True)
    Upres = vinth2p(cdf_file->U,hyam,hybm,pnew,PS,1,P0mb,1,True)
    Vpres = vinth2p(cdf_file->V,hyam,hybm,pnew,PS,1,P0mb,1,True)
    Z3pres = vinth2p(cdf_file->Z3,hyam,hybm,pnew,PS,1,P0mb,1,True)
    Qpres = vinth2p(cdf_file->Q,hyam,hybm,pnew,PS,1,P0mb,1,True)
    Omegapres = vinth2p(cdf_file->OMEGA,hyam,hybm,pnew,PS,1,P0mb,1,True)

    
    fout ->U      = Upres
    fout ->V      = Vpres
    fout ->T      = Tpres
    fout ->Z3      = Z3pres
    fout ->Q      = Qpres
    fout ->OMEGA      = Omegapres

    ; make time a record dimension
    filedimdef(fout,"time",-1,True)
    return(1)
end
