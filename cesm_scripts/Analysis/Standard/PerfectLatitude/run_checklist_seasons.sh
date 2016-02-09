#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/rachel/CESM_outfiles/"
numexps="1"
#exps=("CESM_IG39_West") # "CESM_IG39_West" "CESM_IG49N_West")
#exps=("CESM_Topo_R_2km_40_0" "CESM_Topo_R_2km_50_0" "CESM_Topo_R_2km_60_0")
exps=("CESM_IG54")
#exps=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49" "CESM_IG54")
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
ncl Create_all_means.ncl 
echo 'Create_all_means.ncl'
ncl Calc_VertGrad.ncl
echo 'Calc_VertGrad.ncl'
ncl hybrid2pres_more.ncl
echo 'hybrid2pres_more.ncl'
ncl Calc_Eady.ncl
echo 'Calc_Eady.ncl'

echo 'finished'

