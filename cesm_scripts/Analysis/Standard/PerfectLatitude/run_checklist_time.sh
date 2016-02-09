#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/CESM_outfiles/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="1"
exps=("CESM_IG54")
start="2"
end="31"
nsecs="00000"

export NCL_N_ARGS=$#

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

echo 'LanczosF_time.ncl'
ncl LanczosF_time.ncl
echo 'Calc_EV.ncl'
ncl Calc_EV.ncl
echo 'Calc_meanEKE.ncl'
ncl Calc_meanEKE.ncl
echo 'Calc_EKE_VT.ncl'
ncl Calc_EKE_VT.ncl
echo 'Calc_Vpr_Upr_THpr'
ncl Calc_Vpr_Upr_THpr.ncl
echo 'Calc_VprTHpr_UprTHpr.ncl'
ncl Calc_VprTHpr_UprTHpr.ncl
echo 'Calc_Vpr_Upr_THpr_annual.ncl'
ncl Calc_Vpr_Upr_THpr_annual.ncl
echo 'Calc_VprTHpr_UprTHpr_annual.ncl'
ncl Calc_VprTHpr_UprTHpr_annual.ncl
echo 'finished'

