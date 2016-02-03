#!/bin/sh
cd ./scripts/individual/
figtit="CAM5_DEF"
dir1="/home/disk/rachel/CESM_outfiles/CAM5/"
numexps="2"
exps1=("CAM5topo" "CAM5def1")
titles1=("CAM5_CTL" "CAM5_DEF_ALL")
dir2="/home/disk/rachel/CESM_outfiles/CAM5/"
exps2=("CAM5def1" "CAM5def1")
titles2=("CAM5_DEF_ALL" "CAM5_DEF_ALL")
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
slat="-80.0"
elat="80.0"


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


#./plot_PV250.sh
./plot_PV850.sh
./plot_PV300.sh
#./plot_PV400.sh
./plot_PREC.sh
#./plot_VbpfTbpf250.sh
#./plot_VbpfTbpf850.sh
#./plot_ZeventsMag.sh
#./plot_ZeventsLen.sh
#./plot_ZeventsMax.sh
#./plot_ZeventsNum.sh
./plot_EKE250.sh
./plot_EKE850.sh
#./plot_Tadv600.sh
#./plot_Tadv500.sh
./plot_TS.sh
./plot_U250.sh
./plot_U850.sh
./plot_U1000.sh
./plot_EMGR.sh
#./plot_Tadv850.sh
#./plot_Tadv250.sh
#./plot_Tdia850.sh
#./plot_Tdia250.sh
#./plot_UV250.sh
#./plot_UV850.sh
#./plot_dtdy600.sh
#./plot_SF850.sh
#./plot_SF250.sh

./plot_Zvar.sh
./plot_uH.sh
./plot_uP.sh
#./plot_SFZA700.sh
#./plot_TH700.sh


