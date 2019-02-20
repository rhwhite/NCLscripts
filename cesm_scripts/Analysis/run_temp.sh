#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"
#dir="/home/disk/rachel/CESM_outfiles/WACCM/"
numexps="1"
exps=("WACCM_f19_NoM" "WACCM_f19_NoT" "WACCM_f19_NoR" "WACCM_f19_NoM")
expsctl=("WACCM_f19_NoM" "WACCM_f19_NoT" "WACCM_f19_NoR" "WACCM_f19_CTL")

#exps=("CESM_Topo_R_2km_40_0" "CESM_Topo_R_2km_50_0" "CESM_Topo_R_2km_60_0")
#exps=("CESMtopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19" "CESM_IG39N_6km" "CESMnotopof19" "CESM_IG54" "CESM_IG29" "CESM_IG44" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49" "CESM_IG54" "CESMtopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19")
start="2"
end="41"

export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/hist/"
export NCL_Mtrans=0
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
echo $index
eval export NCL_startyr=$start
((index++))
echo $index
eval export NCL_endyr=$end
((index++))
echo $index
eval export NCL_ARG_$index=$nsecs

echo NCL_N_ARGS 

ncl Calc_Vorticity.ncl

echo 'finished'

