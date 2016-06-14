#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/TWP/Outputs/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="1"
exps=("CAM4_f09f09_CTL_ICC14" "CAM4_f09f09_noTWP_FakeSU") 
start="2"
end="41"
nsecs="00000" #"00000"

export NCL_dirstr="/"
export NCL_N_ARGS=$#
export NCL_Mtrans=1

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
echo 'Create_all_means.ncl'
ncl Create_all_means.ncl 
echo 'Calc_VertGrad.ncl'
ncl Calc_VertGrad.ncl
echo 'hybrid2pres_morelev.ncl'
ncl hybrid2pres_morelev.ncl

# Calc EP fluxes
echo 'Calc_EPfluxes.ncl'
ncl Calc_EPfluxes.ncl
echo 'Calc_RIdx.ncl'
ncl Calc_RIdx.ncl
echo 'Calc_Ks.ncl'
ncl Calc_Ks.ncl

# Calc daily PV
ncl Create_Seas_ts.ncl
echo 'Create_Seas_ts.ncl'
ncl hybrid2pres_ts.ncl
echo 'hybrid2pres_ts.ncl'
ncl Calc_PV.ncl
echo 'Calc_PV.ncl'


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

