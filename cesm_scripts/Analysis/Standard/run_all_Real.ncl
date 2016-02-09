#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/rachel/CESM_outfiles/"
numexps="5"
exps=("CESMtopof19" "CESMnotopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19") 
start="2"
end="41"
nsecs="00000"


export NCL_ARG_lonstart=120
export NCL_ARG_lonend=240

export NCL_dirstr="/atm/hist/"
export NCL_Mtrans=0
export NCL_N_ARGS=$#

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=3; index<=2+$numexps; index++))
do
  eval export NCL_ARG_$index=${exps[index-3]}
done
echo $index
eval export NCL_ARG_$index=$start
((index++))
echo $index
eval export NCL_ARG_$index=$end
((index++))
echo $index
eval export NCL_ARG_$index=$nsecs

echo NCL_N_ARGS 
#echo 'Create_Seas_ts.ncl'
#ncl Create_Seas_ts.ncl
#echo 'hybrid2pres_ts.ncl'
#ncl hybrid2pres_ts.ncl 
#echo 'Calc_VertGrad.ncl'
#ncl Calc_VertGrad.ncl 
echo 'hybrid2pres_morelev.ncl'
ncl hybrid2pres_morelev.ncl
#echo 'Calc_EPfluxes.ncl'
#ncl Calc_EPfluxes.ncl
#echo 'Calc_RIdx.ncl'
#ncl Calc_RIdx.ncl
#echo 'Calc_Ks.ncl'
#ncl Calc_Ks.ncl
echo 'finished'

