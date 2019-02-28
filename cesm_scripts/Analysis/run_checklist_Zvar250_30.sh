#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis//scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/rachel/CESM_outfiles/"
numexps="6"
#exps=("CESM_Topo_R_2km_40_0" "CESM_Topo_R_2km_50_0" "CESM_Topo_R_2km_60_0")
exps=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
start="2"
end="31"
nsecs="00000" #"00000"

export NCL_N_ARGS=$#
export NCL_plev="250"

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
ncl LanczosF_Z.ncl
echo 'LanczosF_Z.ncl'
ncl Calc_varZ.ncl
echo 'Calc_varZ.ncl'

echo 'finished'

