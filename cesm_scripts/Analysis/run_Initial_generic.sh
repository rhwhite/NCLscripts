#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis//scripts/
Lvar="PRECT"
dir="/home/disk/eos4/rachel/CESM_outfiles/"
numexps="1"
exps=("CESMtopof19")  #"CAM4_f09f09_CTL_ICC14" 
start="2"
end="71"
nsecs="00000"
hfile="h1"

export NCL_ARG_hfile=$hfile
export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/hist/raw/"
export NCL_outdirstr="/atm/hist/"
export NCL_Mtrans=0
export NCL_N_ARGS=$#

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

export NCL_ARG_var=$Lvar

# save command line arguments to environment variable NCL_ARG_#
for ((index=3; index<=2+$numexps; index++))
do
  eval export NCL_ARG_$index=${exps[index-3]}
done
echo $index
eval export NCL_ARG_$index=$start
((index++))
echo $index
eval export NCL_ARG_$index=$end
((index++))
echo $index
eval export NCL_ARG_$index=$nsecs

#echo "Initial_analysis_means.ncl"
#ncl Initial_analysis_means.ncl

#echo "monthly hybrid levels"
#ncl hybrid2pres_climmonth.ncl

#echo 'Calc_6hrly.ncl'
#ncl Calc_6hrly.ncl

echo 'Calc_Lanczos'
echo $Lvar
ncl LanczosF_2-6.ncl

ncl LanczosF_10+.ncl 

#echo "monthly hybrid levels"
#ncl hybrid2pres_monthly.ncl

#echo "monthly Ks"
#ncl Calc_Ks_monthly.ncl

#echo "Initial_means because we already ran Initial_analysis_means on all required files"
#ncl Initial_means.ncl

#echo 'Create_all_means.ncl'
#ncl Create_all_means.ncl
#echo 'Calc_VertGrad.ncl'
#ncl Calc_VertGrad.ncl
#echo 'hybrid2pres_morelev.ncl'
#ncl hybrid2pres_morelev.ncl

# Calc EP fluxes
#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl
#echo 'Calc_RIdx.ncl'
#ncl Calc_RIdx.ncl
#echo 'Calc_Ks.ncl'
#ncl Calc_Ks.ncl

#ncl Initial_means.ncl
#export NCL_season="DJF"
#echo 'Create_Seas_ts.ncl'
#ncl Create_Seas_ts.ncl
#echo 'hybrid2pres_ts.ncl'
#ncl hybrid2pres_ts.ncl
#export NCL_season="JJA"
#echo 'hybrid2pres_ts.ncl'
#ncl hybrid2pres_ts.ncl

echo 'finished'

