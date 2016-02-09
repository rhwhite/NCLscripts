#!/bin/sh
cd ./scripts/
difvars="1"
expdif="0"
figtit="Paper"
numexps="8"
dir1="/home/disk/eos4/rachel/CESM_outfiles/"
exps1=("CAM4SOM4topo" "CESMtopof19" "CAM4SOM4notopo" "CAM4SOM4_noMT" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_IG44" "CAM4SOM4_IG34")
titles1=("RSOM\_CTL" "R\_CTL" "ISOM\_CTL" "RSOM\_noMT" "RSOM\_noT" "RSOM\_noM" "ISOM\_IG53N" "ISOM\_IG43N")
CTLS=("1" "-1" "-1" "0" "0" "0" "2" "2")
starts=("11" "2" "11" "11" "11" "11" "11" "11")
nyears=("30" "30" "30" "30" "30" "30" "30" "30")
timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("true" "false" "false" "false" "false" "false" "true" "true")
linear="false"
clon="180.0"
slon="30.0"
elon="300.0"
slat="-30.0"
elat="90.0"
plottype="map"
plotctl=0
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


plotvar="U"
ilev="250"
vartitle="~F10~U~F21~"
min1="-5.0"
max1="50.0"
diffs1="5.0"
min2="-13.5"
max2="13.5"
diffs2="3.0"
units="ms~S~-1~N~"

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
plotvar="Zvar"
ilev="850"
vartitle="~F10~Z~F21~\'~S~2~N~~F21~"
min1="0.0"
max1="2400.0"
diffs1="200.0"
min2="-450.0"
max2="450.0"
diffs2="100.0"
units="m~S~2~N~"
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

ncl plot_specific_U_Zvar_SOM_fSST.ncl

