#!/bin/sh
cd /home/disk/eos4/rachel/NCL/Cyclone_scripts/DEF_EXP/CAM4SOM4/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/rachel/CESM_outfiles/"
numexps="1"
exps=("CAM4SOM4def1") #("CAM4SOM4def1") ("CAM4SOM4topo") ("CAM4SOM4def1")
start="26" # "11"
end="40" #  "40"
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
ncl Create_monthly_means.ncl 
echo 'Create_monthly_means.ncl'
ncl monthly_hybrid2pres.ncl
echo 'monthly_hybrid2pres.ncl'
ncl Calc_Precip.ncl
echo 'Calc_Precip.ncl'
echo 'finished'






