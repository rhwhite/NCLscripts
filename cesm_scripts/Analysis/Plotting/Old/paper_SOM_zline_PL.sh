#!/bin/sh
cd ./scripts/
difvars="0"
expdif="0"
figtit="Paper"
dir1="/home/disk/eos4/rachel/CESM_outfiles/"
numexps="3"
exps1=("CAM4SOM4notopo" "CAM4SOM4_IG34" "CAM4SOM4_IG44")
#"CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles1=("CAM4SOM4_flat" "CAM4SOM4_IG43N" "CAM4SOM4_IG53N")
# "CAM4_IG48N" "CAM4_IG53N" "CAM4_IG58N")
dir2="/home/disk/eos4/rachel/CESM_outfiles/"
exps2=("CAM4SOM4notopo" "CAM4SOM4_IG34" "CAM4SOM4_IG44")
titles2=("CAM4SOM4_flat" "CAM4SOM4_IG43N" "CAM4SOM4_IG53N")
start1="11"
end1="40"
start2="11"
end2="40"
timespan="DJF"
reverse="true"
linear="false"
clon="180.0"
slon="150.0"
elon="170.0"
slat="0.0"
elat="90.0"
plottype="ZMline"
plotctl=1
plotERA=0
titleprefix="SOM"

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



ncl plot_generic_ZMline_paper.ncl



