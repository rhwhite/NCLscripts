#!/bin/sh
cd ./scripts/individual/
figtit="PerfectLat"
dir1="/home/disk/rachel/CESM_outfiles/"
numexps="6"
exps1=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles1=("CAM4_flat" "CAM4_IG29N" "CAM4_IG34N" "CAM4_IG39N" "CAM4_IG44N" "CAM4_IG49N")
dir2="/home/disk/rachel/CESM_outfiles/"
exps2=("CESMnotopof19" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49")
titles2=("CAM4_flat" "CAM4_IG29N" "CAM4_IG34N" "CAM4_IG39N" "CAM4_IG44N" "CAM4_IG49N")
start1="2"
end1="31"
start2="2"
end2="31"
timespan="DJF"
reverse="true"
linear="false"
clon="180.0"
slon="30.0"
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

./plot_Tadv850.sh

./plot_DivVprTpr250.sh
./plot_DivVprTpr850.sh

#./plot_DU_Tadv250.sh
#./plot_DU_Tadv600.sh
./plot_DU_Tadv850.sh

#./plot_DT_Tadv250.sh
#./plot_DT_Tadv600.sh
./plot_DT_Tadv850.sh


#./plot_DUDT_Tadv250.sh
#./plot_DUDT_Tadv600.sh
./plot_DUDT_Tadv850.sh

./plot_Tdia850.sh
#./plot_Tdia600.sh
#./plot_Tdia250.sh



#./plot_DTCOND850.sh
#./plot_DTCOND600.sh
#./plot_DTCOND250.sh

#./plot_QRL850.sh
#./plot_QRS850.sh


