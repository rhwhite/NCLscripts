#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis//scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/eos4/rachel/CESM_outfiles/AMOC/"

numexps="5"
#exps=("CAM4POP_NoMTR_f19" "CAM4POP_NoMT_f19" "CAM4POP_NoR_f19" "CAM4POP_NoMT_f09" "CAM4POP_NoR_f09" "CAM4POP_NoTopo_f19" "CAM4POP_NoTopo_f09")
exps=("CAM4slab_CTL_f19" "CAM4slab_NoTopo_f19" "CAM4slab_NoMT_f19" "CAM4slab_NoR_f19" "CAM4slab_NoMTR_f19")
#expsctl=("WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL")
dirbase="/home/disk/rachel/CESM_outfiles/"
expsctl=("CESMnoTf19") 
start="11"
end="40"
version="122" # 122 for cesm 1.2.2, 106 for cesm 1.0.6

# For Tak-Nak fluxes:
export NCL_startyrC=11
export NCL_nyearsC=20

nsecs="00000"   # default = 00000, when running hybrid will be 21600
h2start="01"    # default = 01, when running hybrid this will be 02


export NCL_low_bpf=2 # 2 days minimum filter
export NCL_high_bpf=6 # 6 days maximum filter
export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/"
export NCL_Ozone=0
export NCL_Mtrans=1
export NCL_GW=0
export NCL_xrad=0
export NCL_dia=1
export NCL_N_ARGS=$#
export NCL_h2mon="02"
export NCL_dailyfile='h1'
export NCL_ERAlev=0
export NCL_CESMversion=$version

export NCL_nsecs=$nsecs
export NCL_h2start=$h2start
# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=0; index<=$numexps-1; index++))
do
  eval export NCL_Exp_$index=${expsctl[index]}  # with topography
  eval export NCL_Exp2_$index=${exps[index]}    # without topography
done

export NCL_Dirb=$dirbase

for ((index=3; index<=2+$numexps; index++))
do
  eval export NCL_ARG_$index=${exps[index-3]}
done
eval export NCL_startyr=$start
eval export NCL_endyr=$end

((index++))
echo $index
eval export NCL_ARG_$index=$nsecs

echo NCL_N_ARGS 

#echo 'Initial_analysis_means.ncl'
#ncl Initial_analysis_means.ncl  # Add variables to monthly resolution files
                                # including PV, SF, divergences MSE, etc
                                # then calculate climatological means
                                # on monthly and annual time resolution
###NOT CURRENTLY USED echo 'Calc_VertGrad.ncl'    
###ncl Calc_VertGrad.ncl   # Calculate climatological mean vertical gradients
                        # of omega and T, TH, and omegaT NOT on pressure levels

#echo 'hybrid2pres.ncl'
#ncl hybrid2pres.ncl

#export NCL_ERAlev=0 # if 1 put onto ERAI pressure levels

echo 'hybrid2pres_morelev.ncl'
ncl hybrid2pres_morelev.ncl # convert many variables onto hybrid levels from
                            # monthly resolution data including caluclation of
                            # potential temperaturei, PV, etc and vertical
                            # gradients etc
                            # Calculates these ON Pressure levels, rather than
                            # calculating them on hybrid and then converting

#export NCL_ERAlev=1 # if 1 put onto ERAI pressure levels

#echo 'hybrid2pres_morelev.ncl'
#ncl hybrid2pres_morelev.ncl # convert many variables onto hybrid levels from


# Use to get U, V, TH  on limited pressure levels
#echo 'hybrid2pres_daily_limlev.ncl'
#ncl hybrid2pres_daily_limlev.ncl

#echo 'Create_Seas_ts.ncl'
#ncl Create_Seas_ts.ncl  # create timeseries of all years of monthly data for
                        # DJF, MAM, JJA and SON
#echo 'hybrid2pres_ts.ncl' 
#ncl hybrid2pres_ts.ncl  # convert the files created by Create_Seas_ts.ncl
                            # onto pressure levels specified in this file
## Refractive index

#echo CalcZMKs.ncl
#ncl Calc_ZMKs.ncl

#echo Calc_ZMKa_monthly.ncl
#ncl Calc_ZMKs_monthly.ncl

## Eddy characteristics
#echo 'Calc_Eady_long.ncl'
#ncl Calc_Eady_long.ncl
#echo 'LanczosF_Z850_250.ncl'
#ncl LanczosF_Z850_250.ncl
#echo 'Calc_varZ850.ncl'
#ncl Calc_varZ850.ncl

#export NCL_var="V"
#export NCL_inlev="850"
#echo 'Lanczos bandpass filter'
#ncl LanczosF_bandpass_pres.ncl
#export NCL_inlev="250"
#echo 'Lanczos bandpass filter'
#ncl LanczosF_bandpass_pres.ncl

#echo 'LanczosF_UVT_EKE_EV.ncl'
#ncl LanczosF_UVT_EKE_EV.ncl
#echo 'Calc_EKE_VT.ncl'
#ncl Calc_EKE_VT.ncl
##########

#export NCL_ERAlev=1
#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl

#export NCL_ERAlev=0
#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl


#echo 'Calc_RIdx.ncl'
#ncl Calc_RIdx.ncl
#echo 'Calc_Ks.ncl'
#ncl Calc_Ks.ncl
# Calculate Ks on lat-lon-pressure levels, incuding buoyancy term
#echo Calc_Ks_full.ncl
#ncl Calc_Ks_full.ncl

#ncl Calc_ZMKs_bimonth.ncl 
#ncl Calc_QGKS_test.ncl

# Calculate EP fluxes on daily data
#echo Calc_EPfluxes_daily.ncl
#ncl Calc_EPfluxes_daily.ncl

# Calculate wavenumber 1 and 2 EP fluxes on daily data
#ncl Calc_EPfluxes_wave12_daily.ncl

#ncl Calc_EPfluxes_wave2_daily.ncl

#eval export NCL_seas="DJF"
#ncl Calc_TEMcirc_daily.ncl
#eval export NCL_seas="Annual"
#ncl Calc_TEMcirc_daily.ncl
#eval export NCL_seas="JJA"
#ncl Calc_TEMcirc_daily.ncl

#echo 'Calc_TakNak_fluxes.ncl'
#export NCL_season="DJF"
#ncl Calc_TakNak_fluxes.ncl
#export NCL_season="SON"
#ncl Calc_TakNak_fluxes.ncl
#export NCL_season="MAM"
#ncl Calc_TakNak_fluxes.ncl
#export NCL_season="JJA"
#ncl Calc_TakNak_fluxes.ncl


echo 'finished'

