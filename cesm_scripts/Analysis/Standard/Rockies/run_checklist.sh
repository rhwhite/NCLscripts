#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/eos4/rachel/CESM_outfiles/Rockies/"
numexps="2"
exps=("CESMnoRTf19" "CESMnoRT2f19")
start="2"
end="41"
nsecs="00000"

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
#ncl Create_all_means.ncl 
#echo 'Create_all_means.ncl'
ncl hybrid2pres.ncl
echo 'hybrid2pres.ncl'
ncl Calc_Eady.ncl
echo 'Calc_Eady.ncl'
ncl LanczosF_Z850.ncl
echo 'LanczosF_Z850.ncl'
ncl Calc_varZ850.ncl
echo 'Calc_varZ850.ncl'
echo 'finished'

