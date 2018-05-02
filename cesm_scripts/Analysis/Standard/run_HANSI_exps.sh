#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"
dir="/home/disk/eos4/rachel/Rockies_vs_Antarctica"
numexps="1"
#exps=("WACCM_f19_CTL" "WACCM_f19_NoM" "WACCM_f19_NoT" "WACCM_f19_NoR")
#expsctl=("WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL")
exps="FlatAll_FC"
start="211"
end="240"

export NCL_dir=$dir
export NCL_exp=$exps
export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr=""
export NCL_Ozone=0
export NCL_Mtrans=0
export NCL_GW=0
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

ncl hybrid2pres_HANSI.ncl

echo 'finished'

