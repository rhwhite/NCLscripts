#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis//scripts/
dir="/home/disk/eos4/rachel/SPCAM/Outputs/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="1"
exps=("spcam3.5_som1") #"DEF_spcam3.5_som1"
start="1"	#16
end="30"	#45
nsecs="00000" #"00000"

export NCL_dirstr="/raw/"
export NCL_N_ARGS=$#
export NCL_Mtrans=0

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

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

echo NCL_N_ARGS 
#echo "Initial_analysis_means.ncl"
#ncl Initial_analysis_means.ncl
echo "Initial_analysis_std.ncl"
ncl Initial_analysis_std.ncl
#echo 'hybrid2pres_morelev.ncl'
#export NCL_season="DJF"
#ncl hybrid2pres_morelev.ncl
#export NCL_season="MAM"
#ncl hybrid2pres_morelev.ncl
#export NCL_season="JJA"
#ncl hybrid2pres_morelev.ncl
#export NCL_season="SON"
#ncl hybrid2pres_morelev.ncl

# Calc EP fluxes
#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl
#echo 'Calc_RIdx.ncl'
#ncl Calc_RIdx.ncl
#echo 'Calc_Ks.ncl'
#ncl Calc_Ks.ncl

# Calc daily PV

#ncl Create_Seas_ts.ncl
#echo 'Create_Seas_ts.ncl'
#ncl hybrid2pres_ts.ncl
#echo 'hybrid2pres_ts.ncl'
#ncl Calc_PV.ncl
#echo 'Calc_PV.ncl'


#ncl Calc_Eady.ncl
#echo 'Calc_Eady.ncl'
#ncl LanczosF_Z850.ncl
#echo 'LanczosF_Z850.ncl'
#ncl Calc_varZ850.ncl
#echo 'Calc_varZ850.ncl'
#echo 'Calc_dTHdy.ncl'
#ncl Calc_dTHdy.ncl
#echo 'Calc_Vpr_Upr_THpr'
#ncl Calc_Vpr_Upr_THpr.ncl
#echo 'Calc_VprTHpr_UprTHpr.ncl'
#ncl Calc_VprTHpr_UprTHpr.ncl
#echo 'Calc_Vpr_Upr_THpr_annual.ncl'
#ncl Calc_Vpr_Upr_THpr_annual.ncl
#echo 'Calc_VprTHpr_UprTHpr_annual.ncl'
#ncl Calc_VprTHpr_UprTHpr_annual.ncl

echo 'finished'

