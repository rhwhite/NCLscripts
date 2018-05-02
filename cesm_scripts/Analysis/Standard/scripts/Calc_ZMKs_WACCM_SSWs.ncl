load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/disk/eos4/rachel/git/NCL/functions.ncl"


; Code to calculate Rossby stationary wave number, following Hoskins and Ambrizzi 1993. 
; Rossby waves are refracted in latitude towards regions of higher Ks
; As dl/dt = cg dKs/dy
; Ks is defined as (Beta*/Uzm)^0.5
; Or on a Mercator coordinate:
; Ks = (2Omega - 1/a(1/cos(phi) d/dphi(1/cos(phi) d/dphi(cos(phi)U))))*cos2(phi)/a
begin

; Get experiment names

startyr=1979
endyr=2015
nyears = endyr-startyr+1

Dir = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_CTL/atm/hist/SSWs/"

print("Calc Rossby Refractive Index")

;lev_p = 10^fspan(0,3.0,30)   ; interpolation targets

lev_p = (/1,    2,    3,    4,    5,    6,    8,   10,   15,   20,   25,   30, 40,   50,   70,  100,  150,  200,  250,  300,  400,  500,  600,  700, 750, 775, 850,  925, 1000/) ; same as monthly

;lev_p = (/1, 2, 3, 5, 7,10,20,30,50,70,100,125,150,175,200,225,250,300,350,400,450,500,550,600,650,700,750,775,800,825,850,875,900,925,950,975,1000/)                 ; ERA-interim levels
lev_p!0 = "lev_p"



dimslevint = dimsizes(lev_p)

filenames = (/"pre62","pre52","pre51","pre41","pre31","pre1","pre2","pre3","pre4","dur","post","whole"/)
nfiles = dimsizes(filenames)
print(nfiles)
;open file with topography
filename_PHIS = "/home/disk/eos4/rachel/CESM_outfiles/HYAK/WACCM_f19_CTL/atm/hist/WACCM_f19_CTL.cam2.h0.0002-01.nc"
cdf_file_PHIS = addfile(filename_PHIS,"r")

PHIS = cdf_file_PHIS->PHIS(0,:,:)
hyam = cdf_file_PHIS->hyam
hybm = cdf_file_PHIS->hybm

P0mb = 0.01*cdf_file_PHIS->P0



do i = 0,nfiles-1
    var = filenames(i)

    cdf_fileUml = addfile(Dir + "U" + var + "ml.nc","r")
    cdf_fileTml = addfile(Dir + "T" + var + "ml.nc","r")
    cdf_fileZml = addfile(Dir + "Z" + var + "ml.nc","r")
    cdf_filePSml = addfile(Dir + "PS" + var + "ml.nc","r")
    cdf_fileTBOTml = addfile(Dir + "TBOT" + var + "ml.nc","r")

    ; get pressure levels
    lat = cdf_fileUml->lat
    lat!0="lat"
    lon = cdf_fileUml->lon


    Uml = cdf_fileUml->U
    Tml = cdf_fileTml->T
    Zml = cdf_fileZml->Z
    PSml = cdf_filePSml->PS
    TBOTml = cdf_fileTBOTml->TBOT

    levml = cdf_fileUml->lev

    ; convert to pressure levels

    Tpl=vinth2p_ecmwf(Tml,hyam,hybm,lev_p,PSml,1,P0mb,1,True,1,TBOTml,conform(PSml,PHIS,(/1,2/)))
    Upl=vinth2p_ecmwf(Uml,hyam,hybm,lev_p,PSml,1,P0mb,1,True,0,TBOTml,conform(PSml,PHIS,(/1,2/)))
    Zpl=vinth2p_ecmwf(Zml,hyam,hybm,lev_p,PSml,1,P0mb,1,True,-1,TBOTml,conform(PSml,PHIS,(/1,2/)))

    dims = dimsizes(Tpl)
    ntimes = dims(0)
    nlat = dimsizes(lat)
    nlon = dimsizes(lon)
    level = lev_p
    level!0="lev_p"
    nlevels = dimsizes(lev_p)

    fileUo = Dir + "/U" + var + "_pl.nc"
    system("/bin/rm -f " + fileUo) 
    fout_std = addfile(fileUo, "c")
    setfileoption(fout_std,"DefineMode",True)

    ;set attributes of output file
    fAtt = True
    fAtt@creation_date = systemfunc("date")
    fileattdef(fout_std,fAtt)

    fout_std->U = Upl

    ; mask out regions below ground
    ;print(level)
    ;do ilat = 0,nlat-1
    ;    do ilon = 0,nlon-1
    ;        do ilevp = 0,nlevels-1
    ;            do itime = 0,ntimes-1
    ;                if PSml(itime,ilat,ilon) .LT. (level(ilevp)+20)*100.0
    ;                    Upl(itime,ilevp,ilat,ilon) = Upl@_FillValue
    ;                    Zpl(itime,ilevp,ilat,ilon) = Zpl@_FillValue
    ;                    Tpl(itime,ilevp,ilat,ilon) = Tpl@_FillValue
    ;                end if
    ;                end do
    ;            end do
    ;        end do
    ;    end do


    ; Set up filename
    ;fileo = Dir + "/Ks" + var + "_ZM.nc" 
    ;system("/bin/rm -f " + fileo)

    ; Call CalcZMKs
    ;Calc TH

    ;lev_id = 1

    ;TH = T*((1000.0/conform(T,level,lev_id))^0.286)
    ;copy_VarCoords(T,TH)

    ;returned = calcZMKs(U,TH,Z,level,lat,fileo)
    ;print(returned)



    ; Set up filename
    fileo = Dir + "/Ks" + var + "_ZM_pl.nc"
    system("/bin/rm -f " + fileo)
    
    ; Call CalcZMKs
    ;Calc TH

    lev_id = 1

    THpl = Tpl*((1000.0/conform(Tpl,level,lev_id))^0.286)
    copy_VarCoords(Tpl,THpl)

    ; Calculate zonal mean
    lon_id = 3
    Upl_zm = dim_avg_n_Wrap(Upl,lon_id)
    THpl_zm = dim_avg_n_Wrap(THpl,lon_id)
    Zpl_zm = dim_avg_n_Wrap(Zpl,lon_id) 

    returned = calcZMKs(Upl_zm,THpl_zm,Zpl_zm,level,lat,fileo)

end do

end
