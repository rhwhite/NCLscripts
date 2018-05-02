#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/eos4/rachel/CESM_outfiles/"

exps=("CAM4POP_f19g16C_noMT")
numexps="1"
start="160"
end="200"

export NCL_dirstr="/atm/hist/"

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

echo NCL_N_ARGS 
#echo "Initial_analysis_means.ncl"
#ncl Initial_analysis_means.ncl
echo 'hybrid2pres_TH_Z_N.ncl'
ncl hybrid2pres_TH_Z_N.ncl

echo 'finished'

