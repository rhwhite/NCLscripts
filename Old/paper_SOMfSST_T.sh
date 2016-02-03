#!/bin/sh
cd ./scripts/
difvars="0"
expdif="0"
figtit="Paper"
numexps="4"
dir1="/home/disk/rachel/CESM_outfiles/"
exps1=("CESMtopof19" "CESMnoTf19" "CESMnoT4f19" "CESMnoT2f19")
titles1=("R\_CTL" "R\_noT" "R\_noM" "R\_noMT")
dir2="/home/disk/eos4/rachel/CESM_outfiles/"
exps2=("CAM4SOM4topo" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles2=("R\_CTL\_SOM" "R\_noT\_SOM" "R\_noM\_SOM" "R\_noMT\_SOM")
start1="2"
end1="31"
start2="11"
end2="40"
timespan="DJF"
reverse="false"
linear="false"
clon="180.0"
slon="0.0"
elon="210.0"
slat="0.0"
elat="90.0"
plottype="map"
plotctl=1
plotERA=0
titleprefix="SOM_fSST_"


# save command line arguments to environment variable NCL_ARG_#
index=1
export NCL_ARG2_$index=$difvars
((index++))
export NCL_ARG2_$index=$expdif
((index++))
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
((index++))
eval export NCL_ARG2_$index=$plottype
((index++))
eval export NCL_ARG2_$index=$plotctl
((index++))
eval export NCL_ARG2_$index=$plotERA
((index++))
eval export NCL_ARG2_$index=$titleprefix


plotvar="TS"
ilev="0"
min1="260.0"
max1="305.0"
diffs1="5.0"
min2="-3.0"
max2="3.0"
diffs2="0.5"
units="K"

index=1
eval export NCL_ARG_$index=$plotvar
((index++))
eval export NCL_ARG_$index=$ilev
((index++))
eval export NCL_ARG_$index=$min1
((index++))
eval export NCL_ARG_$index=$max1
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

ncl plot_generic_SOMfSST1_paper.ncl


ncl plot_generic_SOMfSST2_paper.ncl

