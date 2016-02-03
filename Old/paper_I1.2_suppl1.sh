#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
difvars="1"
expdif="0"
figtit="Paper"
numexps="4"
dir1="/home/disk/rachel/CESM_outfiles/"
exps1=("CESMnoTf19" "CESMnoT4f19" "CESM_IdealRealT" "CESM_IdealRealM")
titles1=("R_noT" "R_noR" "R_noT_33N_5km" "R_noM_48N_2km")
CTLS=("-1" "-1" "0" "1" "0" "0" "2" "2")
starts=("2" "2" "2" "2" "2" "2" "2" "11")
nyears=("30" "30" "30" "30" "30" "30" "30" "30")
timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("true" "true" "true" "true" "true")
linear="false"
clon="180.0"
slon="30.0"
elon="300."
slat="-30.0"
elat="90.0"
plottype="map"
plotctl=0
plotERA=0
titleprefix="I1.2_"

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

count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${CTLS[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${starts[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${nyears[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${timespan[count]}
  ((count++))
done
count=0
limit=$((index+numexps-1))
for ((index=$index; index<=$limit; index++))
do
  eval export NCL_ARG2_$index=${reverse[count]}
  ((count++))
done
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

plotvar="SFZA"
ilev="300"
vartitle="~F8~y\'~F21~"
min1="-0.9e7"
max1="0.9e7"
diffs1="2.0e6"
min2="-0.9e7"
max2="0.9e7"
diffs2="2.0e6"
units="m~S~2~N~s~S~-1~N~"

index=1
eval export NCL_ARG_$index=$plotvar
((index++))
eval export NCL_ARG_$index=$ilev
((index++))
eval export NCL_ARG_$index=$vartitle
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
((index++))

plotvar="PV"
ilev="300"
vartitle="~F10~PV~F21~"
min1="0.0"
max1="7.2e-6"
diffs1="0.8e-6"
min2="-0.9e-6"
max2="0.9e-6"
diffs2="0.2e-6"
units="PVU"
plottype="map"

# save command line arguments to environment variable NCL_ARG_#
eval export NCL_ARG_$index=$plotvar
((index++))
eval export NCL_ARG_$index=$ilev
((index++))
eval export NCL_ARG_$index=$vartitle
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


