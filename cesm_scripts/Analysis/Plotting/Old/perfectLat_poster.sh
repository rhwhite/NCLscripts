#!/bin/sh
cd ./scripts/individual/
figtit="PerfectLat"
dir1="/home/disk/rachel/CESM_outfiles/"
numexps="5"
exps1=("CESMnotopof19" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles1=("CAM4_flat" "CAM4_IG34N" "CAM4_IG39N" "CAM4_IG44N" "CAM4_IG49N")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMnotopof19" "CESM_onlyIT" "CESM_onlyIT2" "CESM_onlyIT4" "CESM_onlyITSh")
titles2=("CAM4_flat" "CAM4_idealT" "CAM4_idealT_N" "CAM4_wallN" "CAM4_short_T")
start1="2"
end1="31"
start2="2"
end2="41"
timespan="DJF"
reverse="true"
linear="false"
clon="180.0"
slon="60.0"
elon="210.0"
slat="0.0"
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

#./plot_Zvar.sh
#./plot_U250.sh
#./plot_Tadv850_ZMline.sh
#./plot_DT_Tadv850_ZMline.sh
#./plot_DU_Tadv850_ZMline.sh

#./plot_Tadv500_ZMline.sh
#./plot_DT_Tadv500_ZMline.sh
#./plot_DU_Tadv500_ZMline.sh

#./plot_dtdy600.sh
#./plot_dtdy250.sh
#./plot_dtdy850.sh
#./plot_V250.sh
#./plot_V850.sh

#./plot_DU_Tadv250.sh
#./plot_DU_Tadv850.sh

#./plot_DT_Tadv250.sh
#./plot_DT_Tadv850.sh


#./plot_PV250.sh
#./plot_PV850.sh
#./plot_PV300.sh
#./plot_PV400.sh

#./plot_VbpfTbpf250.sh
#./plot_VbpfTbpf850.sh
#./plot_ZeventsMag.sh
#./plot_ZeventsLen.sh
#./plot_ZeventsMax.sh
#./plot_ZeventsNum.sh
#./plot_EKE250.sh
#./plot_EKE850.sh
#./plot_Tadv600.sh
#./plot_Tadv500.sh
#./plot_TS.sh
#./plot_U250.sh
#./plot_U850.sh
#./plot_U1000.sh
#./plot_EMGR.sh
#./plot_Tadv850.sh
#./plot_Tadv250.sh
./plot_Tdia850.sh
./plot_Tdia250.sh
./plot_Tdis500.sh
#./plot_UV250.sh
#./plot_UV850.sh
#./plot_dtdy600.sh
#./plot_SF850.sh
#./plot_SF250.sh

#./plot_EKE250.sh
#./plot_EKE850.sh
#./plot_Zvar.sh
#./plot_uH.sh
#./plot_uP.sh
#./plot_SFZA700.sh
#./plot_TH700.sh


