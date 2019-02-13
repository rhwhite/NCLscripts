#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/echam_scripts/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/eos4/rachel/MPIESM/ECHAM6.1/outfiles/"

numexps="1"
exps=("ECHAM6_LR_MLO_NoR")
#exps=("WACCM_f19_NoM" "WACCM_f19_NoT" "WACCM_f19_NoR" "WACCM_f19_LGM" "WACCM_f19_CTL")
#expsctl=("WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL" "WACCM_f19_CTL")
#exps=("WACCM_f19_highR")
start="10"
end="25"

nsecs="00000"   # default = 00000, when running hybrid will be 21600
h2start="01"    # default = 01, when running hybrid this will be 02

export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr=""
export NCL_N_ARGS=$#

export NCL_nsecs=$nsecs
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

echo NCL_N_ARGS 

# Calc EKE etc
echo 'Calc EKE etc'
ncl LanczosF_UVT_EKE_EV.ncl 

echo 'finished'

