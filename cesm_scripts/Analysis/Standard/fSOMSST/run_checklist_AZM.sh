#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/CESM_outfiles/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="2"
exps=("CAM4_SOMssts_noMT" "CAM4_SOMssts_noT")
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

echo 'Calc_ZMAs.ncl'
ncl Calc_ZMAs.ncl
echo 'Calc_VTzma.ncl'
ncl Calc_VTzma.ncl

echo 'finished'

