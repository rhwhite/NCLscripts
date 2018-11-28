#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/rhwhite/NCLscripts/cesm_scripts/Analysis/Standard/scripts/
dir="/data/ESS/rhwhite/cesm_archive/"

numexps="1"
exps=("WACCMSC_CTL_122" "WACCMSC_f19_1979-2010_4" "WACCMSC_f19_1979-2010_5")
#exps=("WACCM_f19_NoM" "WACCM_f19_NoT" "WACCM_f19_NoR" "WACCM_f19_LGM" "WACCM_f19_CTL")
#expsctl=("WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL")
#exps=("WACCM_f19_highR")
dirbase="/data/ESS/rhwhite/cesm_archive/"
expsctl=("CAM4SOM4_noMT") 
start="32"
end="101"
version="122"

# For Tak-Nak fluxes:
export NCL_startyrC=11
export NCL_nyearsC=20

nsecs="00000"   # default = 00000, when running hybrid will be 21600
h2start="01"    # default = 01, when running hybrid this will be 02

export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/hist/"
export NCL_Ozone=0
export NCL_Mtrans=0
export NCL_GW=0
export NCL_xrad=0
export NCL_N_ARGS=$#
export NCL_CESMversion=122
export NCL_h2mon="01"
export NCL_omega=0
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


echo Initial_analysis_addvars.ncl
ncl Initial_analysis_addvars.ncl

#echo 'Initial_analysis_means.ncl'
#ncl Initial_analysis_means.ncl  # Add variables to monthly resolution files
                                # including PV, SF, divergences MSE, etc
                                # then calculate climatological means
                                # on monthly and annual time resolution
###NOT CURRENTLY USED echo 'Calc_VertGrad.ncl'    
###ncl Calc_VertGrad.ncl   # Calculate climatological mean vertical gradients
                        # of omega and T, TH, and omegaT NOT on pressure levels

#echo 'hybrid2pres_morelev.ncl'
#ncl hybrid2pres_morelev.ncl # convert many variables onto hybrid levels from
                            # monthly resolution data including caluclation of
                            # potential temperaturei, PV, etc and vertical
                            # gradients etc
                            # Calculates these ON Pressure levels, rather than
                            # calculating them on hybrid and then converting

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
#echo 'Calc_Eady.ncl'
#ncl Calc_Eady.ncl
#echo 'LanczosF_Z850_250.ncl'
#ncl LanczosF_Z850_250.ncl
#echo 'Calc_varZ850.ncl'
#ncl Calc_varZ850.ncl
#echo 'LanczosF_UVT_EKE_EV.ncl'
#ncl LanczosF_UVT_EKE_EV.ncl
#echo 'Calc_EKE_VT.ncl'
#ncl Calc_EKE_VT.ncl
##########

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

##### Not used anymore - done in python Calculate FFT on geopotential heights
#####ncl Calc_Z_FFT.ncl


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

