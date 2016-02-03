#!/bin/sh
cd ./scripts/individual/
difvars="0"
expdif="0"
figtit="TfSST"
numexps="4"
dir1="/home/disk/rachel/CESM_outfiles/"
exps1=("CESMtopof19" "CESMnoTf19" "CESMnoT4f19" "CESMnoT2f19")
titles1=("CAM4_CTL" "CAM4_noT" "CAM4_noM" "CAM4_noMT")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMtopof19" "CESMnoTf19" "CESMnoT4f19" "CESMnoT2f19")
titles2=("CAM4_CTL" "CAM4_noT" "CAM4_noM" "CAM4_noMT")
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
slat="-90.0"
elat="90.0"
plottype="map"
plotctl=1
plotERA=1
titleprefix="Global_"


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




./plot_PREC.sh
#./plot_topo.sh
#./plot_TS.sh
#./plot_TH700.sh
#./plot_U250.sh
#./plot_U850.sh
#./plot_U1000.sh
#./plot_EMGR.sh
#./plot_Tadv850.sh
#./plot_Tadv250.sh
#./plot_Tdia850.sh
#./plot_Tdia250.sh
#./plot_UV250.sh
#./plot_UV850.sh
#./plot_dtdy600.sh
#./plot_SF850.sh
#./plot_SF250.sh
#./plot_SFZA700.sh
#./plot_EMGR.sh

#./plot_EKE250.sh
#./plot_EKE850.sh
#./plot_Zvar.sh
#./plot_uH.sh
#./plot_uP.sh


