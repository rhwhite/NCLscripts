#!/bin/sh
cd ./scripts/individual/
figtit="newSOMonly"
dir1="/home/disk/eos4/rachel/CESM_outfiles/"
numexps="4"
exps1=("CAM4SOM4topo" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles1=("CAM4_SOM4_CTL" "CAM4_SOM4_noT" "CAM4_SOM4_noM" "CAM4_SOM4_noMT")
dir2="/home/disk/eos4/rachel/CESM_outfiles/"
exps2=("CAM4SOM4topo" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles2=("CAM4_SOM4_CTL" "CAM4_SOM4_noT" "CAM4_SOM4_noM" "CAM4_SOM4_noMT")
start1="11"
end1="40"
start2="11"
end2="40"
timespan="DJF"
reverse="false"
linear="false"
clon="90.0"
slon="0.0"
elon="210.0"
slat="020.0"
elat="90.0"


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
eval export NCL_ARG2_$index=$timespan
((index++))
eval export NCL_ARG2_$index=$reverse
((index++))
eval export NCL_ARG2_$index=$linear
((index++))
eval export NCL_ARG2_$index=$clon
((index++))
eval export NCL_ARG2_$index=$slon
((index++))
eval export NCL_ARG2_$index=$elon
((index++))
eval export NCL_ARG2_$index=$slat
((index++))
eval export NCL_ARG2_$index=$elat

./plot_Tadv500.sh
#./plot_U250.sh
#./plot_Tdia500.sh
#./plot_Tdia250.sh
#./plot_Tdia850.sh
#./plot_Tadv250.sh
#./plot_Tadv850.sh



