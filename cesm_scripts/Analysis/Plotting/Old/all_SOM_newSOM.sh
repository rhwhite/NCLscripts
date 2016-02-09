#!/bin/sh
cd ./scripts/individual/
figtit="SOM_newSOM"
dir1="/home/disk/eos4/rachel/CESM_outfiles/OldSOM/"
numexps="4"
exps1=("CESMSOM4topof19g16" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles1=("Old_CAM4_SOM4_CTL" "Old_CAM4_SOM4_noT" "Old_CAM4_SOM4_noM" "Old_CAM4_SOM4_noMT")
dir2="/home/disk/eos4/rachel/CESM_outfiles/"
exps2=("CAM4SOM4topo" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles2=("CAM4SOM4_CTL" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
start1="160"
end1="189"
start2="11"
end2="40"

# save command line arguments to environment variable NCL_ARG_#
index=1
export NCL_ARG2_$index=$figtit
((index++))
export NCL_ARG2_$index=$numexps
((index++))
eval export NCL_ARG2_$index=$dir1
((index++))
# save command line arguments to environment variable NCL_ARG_#
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${exps1[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${titles1[count]}
  ((count++))
done

eval export NCL_ARG2_$index=$dir2
((index++))
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${exps2[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${titles2[count]}
  ((count++))
done
eval export NCL_ARG2_$index=$start1
((index++))
eval export NCL_ARG2_$index=$end1
((index++))
eval export NCL_ARG2_$index=$start2
((index++))
eval export NCL_ARG2_$index=$end2
((index++))

./plot_U250_dd.sh




