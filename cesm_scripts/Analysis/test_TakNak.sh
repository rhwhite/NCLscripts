#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
numexps="2"
exps=("WACCM_f19_NoM" "WACCM_f19_NoM" "WACCM_f19_CTL")
expsctl=("WACCM_f19_NoM" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL")
#exps=("CAM4SOM4_noR" "CESM_Topo_R_2km_50_0" "CESM_Topo_R_2km_60_0")
#expsctl=("CAM4SOM4topo" "CESMtopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19" "CESM_IG39N_6km" "CESMnotopof19" "CESM_IG54" "CESM_IG29" "CESM_IG44" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49" "CESM_IG54" "CESMtopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19")
start="2"
end="41"

export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/hist/"
export NCL_Ozone=0
export NCL_Mtrans=0
export NCL_GW=1
export NCL_N_ARGS=$#

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=0; index<=$numexps-1; index++))
do
  eval export NCL_Exp_$index=${expsctl[index]}  # with topography
  eval export NCL_Exp2_$index=${exps[index]}    # without topography
done

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

#echo 'Create_Seas_ts.ncl'
#ncl Create_Seas_ts.ncl  # create timeseries of all years of monthly data for
                        # DJF, MAM, JJA and SON
#echo 'hybrid2pres_ts.ncl' 
#ncl hybrid2pres_ts.ncl  # convert the files created by Create_Seas_ts.ncl
                            # onto pressure levels specified in this file
 
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

#echo 'hybrid2pres_morelev.ncl'
#ncl hybrid2pres_morelev.ncl # convert many variables onto hybrid levels from
                            # monthly resolution data including caluclation of
                            # potential temperaturei, PV, etc and vertical
                            # gradients etc
                            # Calculates these ON Pressure levels, rather than
                            # calculating them on hybrid and then converting

#echo 'hybrid2pres_daily_limlev.ncl'
#ncl hybrid2pres_daily_limlev.ncl


#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl
#echo 'Calc_RIdx.ncl'
#ncl Calc_RIdx.ncl
#echo 'Calc_Ks.ncl'
#ncl Calc_Ks.ncl
# Calculate Ks on lat-lon-pressure levels, incuding buoyancy term
#ncl Calc_Ks_full.ncl


#ncl Calc_ZMKs.ncl
#ncl Calc_ZMKs_monthly.ncl
#ncl Calc_ZMKs_bimonth.ncl 
#ncl Calc_QGKS_test.ncl

# Calculate EP fluxes on daily data
#ncl Calc_EPfluxes_daily.ncl

# Calculate wavenumber 1 and 2 EP fluxes on daily data
#ncl Calc_EPfluxes_wave12_daily.ncl

#ncl Calc_EPfluxes_wave2_daily.ncl

##### Not used anymore - done in python Calculate FFT on geopotential heights
#####ncl Calc_Z_FFT.ncl


echo 'Calc_TakNak_fluxes_daily.ncl'
export NCL_seas="DJF"
ncl Calc_TakNak_fluxes_daily.ncl

#export NCL_seas="DJF"
#ncl Calc_TakNak_fluxes_daily.ncl
#export NCL_seas="JJA"
#ncl Calc_TakNak_fluxes_daily.ncl


echo 'finished'

