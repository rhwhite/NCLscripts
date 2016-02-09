#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
difvars="1"
expdif="0"
figtit="Paper"
numexps="6"
dir1="/home/disk/rachel/CESM_outfiles/"
exps1=("CESMnotopof19" "CESM_onlyIT" "CESM_onlyITSh" "CESM_onlyIT2" "CESM_onlyITVS" "CESM_onlyIM2")
titles1=("I_CTL" "I_33N_4km" "I_48N_2km" "I_48N_4km" "I_48N_1km" "I_48N_MerHalf")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMnotopof19" "CESM_onlyIT" "CESM_onlyITSh" "CESM_onlyIT2" "0" "CESM_onlyIM2")
titles2=("I_CTL" "I_33N_4km" "I_48N_2km" "I_48N_4km" "I_48N_1km" "I_48N_MerHalf")
start1="2"
end1="31"
start2="2"
end2="41"
timespan="DJF"
reverse="false"
linear="false"
clon="180.0"
slon="0.0"
elon="210."
slat="0.0"
elat="90.0"
plottype="map"

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


plotvar="U"
ilev="250"
min1="0.0"
max1="60.0"
diffs1="5.0"
min2="-15.0"
max2="15.0"
diffs2="3.0"
units="ms:S:-1:N:"

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

plotvar="Zvar"
ilev="850"
min1="0.0"
max1="3000.0"
diffs1="300.0"
min2="-750.0"
max2="750.0"
diffs2="150.0"
units="m:S:2:N:"

# save command line arguments to environment variable NCL_ARG_#
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

ncl plot_generic.ncl


