#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
dir1="/home/disk/eos4/rachel/CESM_outfiles/"
numexps="4"
exps1=("CESMSOM4topof19g16" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles1=("CAM4_SOM4_CTL" "CAM4_SOM4_noT" "CAM4_SOM4_noM" "CAM4_SOM4_noMT")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMtopof19" "CESMnoTf19" "CESMnoT4f19" "CESMnoT2f19")
titles2=("CAM4_CTL" "CAM4_noT" "CAM4_noM" "CAM4_noMT")
start1="160"
end1="189"
start2="1"
end2="40"

export NCL_N_ARGS=$#

# save command line arguments to environment variable NCL_ARG_#
index=1
export NCL_ARG_$index=$numexps
((index++))
eval export NCL_ARG_$index=$dir1
((index++))
# save command line arguments to environment variable NCL_ARG_#
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG_$index=${exps1[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG_$index=${titles1[count]}
  ((count++))
done

eval export NCL_ARG_$index=$dir2
((index++))
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG_$index=${exps2[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG_$index=${titles2[count]}
  ((count++))
done

eval export NCL_ARG_$index=$start1
((index++))
eval export NCL_ARG_$index=$end1
((index++))
eval export NCL_ARG_$index=$start2
((index++))
eval export NCL_ARG_$index=$end2
((index++))

plotvar="Tadv"
ilev="850"
min1="-0.0001"
max1="0.0001"
diffs1="0.00002"
min2="-0.00005"
max2="0.00005"
diffs2="0.00001"
units="Ks:S:-1:N:"
eval export NCL_ARG_$index=$plotvar
((index++))
eval export NCL_ARG_$index=$ilev
((index++))
eval export NCL_ARG_$index=$min1
((index++))
eval export NCL_ARG_$index=$max2
((index++))
eval export NCL_ARG_$index=$diffs1
((index++))
eval export NCL_ARG_$index=$min2
((index++))
eval export NCL_ARG_$index=$max2
((index++))
eval export NCL_ARG_$index=$diffs2
((index++))
eval export NCL_ARG_$index=$units

ncl plot_generic.ncl
echo 'finished'

