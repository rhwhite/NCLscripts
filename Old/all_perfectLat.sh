#!/bin/sh
cd ./scripts/individual/
difvars="0"
expdif="0"
figtit="PerfectLat"
dir1="/home/disk/rachel/CESM_outfiles/"
numexps="6"
exps1=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles1=("CAM4_flat" "CAM4_IG38N" "CAM4_IG43N" "CAM4_IG48N" "CAM4_IG53N" "CAM4_IG58N")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles2=("CAM4_flat" "CAM4_IG38N" "CAM4_IG43N" "CAM4_IG48N" "CAM4_IG53N" "CAM4_IG58N")
start1="2"
end1="31"
start2="2"
end2="31"
timespan="DJF"
reverse="true"
linear="false"
clon="180.0"
slon="30.0"
elon="240.0"
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

./plot_DivVprTpr850.sh
./plot_DivVprTpr250.sh

#./plot_VORT850.sh
#./plot_VORT250.sh

#./plot_DUDT_Tadv850.sh
#./plot_PREC.sh
#./plot_dtdx850_ZMline.sh
#./plot_dtdx600_ZMline.sh

#./plot_Zvar.sh
#./plot_Tadv250.sh
#./plot_Tadv850.sh
#./plot_Tadv600.sh

#./plot_U250.sh

#./plot_dtdy600.sh
#./plot_dtdy250.sh
#./plot_dtdy850.sh
#./plot_V250.sh
#./plot_V850.sh

#./plot_DU_Tadv250.sh
#./plot_DU_Tadv600.sh
#./plot_DU_Tadv850.sh

#./plot_DT_Tadv250.sh
#./plot_DT_Tadv600.sh
#./plot_DT_Tadv850.sh

#./plot_DUDT_Tadv250.sh
#./plot_DUDT_Tadv600.sh
#./plot_DUDT_Tadv850.sh

#./plot_DU_x_Tadv850.sh
#./plot_DU_y_Tadv850.sh
#./plot_DT_x_Tadv850.sh
#./plot_DT_y_Tadv850.sh

#./plot_DU_x_Tadv600.sh
#./plot_DU_y_Tadv600.sh
#./plot_DT_x_Tadv600.sh
#./plot_DT_y_Tadv600.sh


#./plot_TH850.sh
#./plot_TH250.sh
#./plot_TH600.sh
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
#./plot_Tdia850.sh
#./plot_Tdia250.sh
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


