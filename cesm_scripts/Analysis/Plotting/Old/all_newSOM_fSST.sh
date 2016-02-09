#!/bin/sh
cd ./scripts/individual/
difvars="0"
expdif="1"
figtit="newSOM_fSST"
numexps="4"
dir1="/home/disk/rachel/CESM_outfiles/"
exps1=("CESMtopof19" "CESMnoTf19" "CESMnoT4f19" "CESMnoT2f19")
titles1=("CAM4_CTL" "CAM4_noT" "CAM4_noM" "CAM4_noMT")
dir2="/home/disk/eos4/rachel/CESM_outfiles/"
exps2=("CAM4SOM4topo" "CAM4SOM4_noT" "CAM4SOM4_noM" "CAM4SOM4_noMT")
titles2=("CAM4_SOM4_CTL" "CAM4_SOM4_noT" "CAM4_SOM4_noM" "CAM4_SOM4_noMT")
start1="2"
end1="31"
start2="11"
end2="40"
timespan="DJF"
reverse="false"
linear="true"
clon="180.0"
slon="0.0"
elon="280.0"
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

./plot_EMGR.sh
#./plot_TH850.sh
#./plot_DU_Tadv850.sh
#./plot_DT_Tadv850.sh
#./plot_DUDT_Tadv850.sh
#./plot_Tadv850.sh
#./plot_dtdy850.sh
#./plot_U250.sh
#./plot_U850.sh
./plot_Zvar.sh
#./plot_TS.sh

#./plot_U10.sh
#./plot_TdiaSRF.sh
#./plot_TradSRF.sh
#./plot_SHFLX.sh
#./plot_LHFLX.sh

#./plot_dudz850.sh
#./plot_dudz600.sh
#./plot_dudz250.sh
#./plot_dtdy850.sh
#./plot_Tdia850.sh

#./plot_PV850.sh
#./plot_PV300.sh
./plot_PV250.sh
#./plot_PREC.sh
#./plot_Tadv500.sh
#./plot_TH700.sh
#./plot_topo.sh
#./plot_U850.sh
#./plot_EMGR.sh
#./plot_Tadv850.sh
#./plot_Tadv250.sh
#./plot_Tdia850.sh
#./plot_Tdia250.sh
#./plot_UV250.sh
#./plot_UV850.sh
#./plot_dtdy600.sh
#./plot_dtdy850.sh
#./plot_dtdy250.sh
#./plot_SF850.sh
#./plot_SF250.sh
#./plot_EKE250.sh
#./plot_EKE850.sh
#./plot_Zvar.sh



