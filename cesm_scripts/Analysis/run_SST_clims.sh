#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/inputdata/ssts/SOMclims/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="3"
exps=("CAM4SOM4topo" "CAM4SOM4_noMT" "CAM4SOM4_noT")
start="11"
end="40"
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
ncl Create_SST_means.ncl
echo 'finished'

