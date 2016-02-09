#!/bin/sh
cd ./scripts/individual/
difvars="0"
expdif="0"
figtit="RvsT"
dir1="/home/disk/eos4/rachel/CESM_outfiles/Rockies/"
numexps="3"
exps1=("CESMtopof19" "CESMnoRf19" "CESMnoRT2f19")
titles1=("CESM_CTL" "CESM_noR" "CESM_noRTM")
dir2="/home/disk/eos4/rachel/CESM_outfiles/Rockies/"
exps2=("CESMtopof19" "CESMnoRf19" "CESMnoRT2f19")
titles2=("CESM_CTL" "CEAM_noR" "CESM_noRTM")
start1="2"
end1="41"
start2="2"
end2="41"
timespan="DJF"
reverse="false"
linear="false"
clon="0.0"
slon="-180.0"
elon="180.0"
slat="0.0"
elat="90.0"
plottype="map"
plotctl=1
plotERA=0
titleprefix=""

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




./plot_TS.sh
./plot_TH850.sh
./plot_TH700.sh
./plot_U250.sh
./plot_U850.sh

#./plot_U1000.sh
#./plot_EMGR.sh
#./plot_Tadv850.sh
#./plot_Tadv250.sh
#./plot_Tdia850.sh
#./plot_Tdia250.sh
#./plot_UV250.sh
#./plot_UV850.sh
#./plot_dtdy600.sh
./plot_SF850.sh
./plot_SF250.sh
./plot_SFZA700.sh
./plot_EMGR.sh

#./plot_EKE250.sh
#./plot_EKE850.sh
#./plot_Zvar.sh
#./plot_uH.sh
#./plot_uP.sh


