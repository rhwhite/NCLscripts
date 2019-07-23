#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis//scripts/
dir="/home/disk/eos4/rachel/CESM_outfiles/AMOC/"
#dir="/home/disk/rachel/CESM_outfiles/"
numexps="4"
#exps=("CAM4POP_CTL_f19" "CAM4POP_CTL_f19")
#exps=("CAM4POP_NoMT_f19" "CAM4POP_NoMT_f09" "CAM4POP_NoR_f19" "CAM4POP_NoR_f09" "CAM4POP_NoTopo_f19" "CAM4POP_NoTopo_f09") 
exps=("CAM4SLAB_CTL_f19" "CAM4SLAB_NoMT_f19" "CAM4SLAB_NoR_f19" "CAM4SLAB_NoTopo_f19")
start="11"
end="40"
version="122" # 122 for cesm 1.2.2, 106 for cesm 1.0.6

# For Tak-Nak fluxes:

nsecs="00000"   # default = 00000, when running hybrid will be 21600
h2start="01"    # default = 01, when running hybrid this will be 02

export NCL_ARG_lonstart=0
export NCL_ARG_lonend=360

export NCL_dirstr="/atm/"
export NCL_Ozone=0
export NCL_Mtrans=0
export NCL_GW=0
export NCL_xrad=0
export NCL_dia=1
export NCL_N_ARGS=$#
export NCL_h2mon="02"
export NCL_dailyfile='h2'
export NCL_dia=1
export NCL_ERAlev=0
export NCL_CESMversion=$version

export NCL_nsecs=$nsecs
export NCL_h2start=$h2start
# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=0; index<=$numexps-1; index++))
do
  eval export NCL_Exp_$index=${expsctl[index]}  # with topography
  eval export NCL_Exp2_$index=${exps[index]}    # without topography
done

export NCL_Dirb=$dirbase

for ((index=3; index<=2+$numexps; index++))
do
  eval export NCL_ARG_$index=${exps[index-3]}
done
eval export NCL_startyr=$start
eval export NCL_endyr=$end

((index++))
echo $index
eval export NCL_ARG_$index=$nsecs

echo NCL_N_ARGS 
ncl hybrid2pres_morelev.ncl
echo 'hybrid2pres_morelev.ncl'
## Eddy characteristics
echo 'Calc_Eady_long.ncl'
ncl Calc_Eady_long.ncl

echo 'finished'

