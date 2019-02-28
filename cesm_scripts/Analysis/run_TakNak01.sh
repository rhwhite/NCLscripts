#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis//scripts/
dir="/home/disk/rachel/CESM_outfiles/"
numexps="4"
exps1=("WACCM_f19_CTL" "CESMtopof19" "CESMtopof19" "CESMtopof19" "CESMtopof19" "CESMtopof19")
exps2=("CESMnotopof19" "CESMnoT2f19" "CESMnoTf19" "CESMnoT4f19")

#exps2=("CESM_Topo_IG44") #"CESM_onlyITVS" "CESM_onlyITSh" "CESM_IG39N_6km" "CESM_onlyITVS" "CESM_onlyIT2" "CESM_IG29" "CESM_IG34" "CESM_onlyITSh" "CESM_IG44" "CESM_IG49" "CESM_IG54") #("CESMtopof19") # "CESM_IG58N_ZRGH") # "CAM4SOM4_4xCO2_noMT") 
#exps2=("CESMnotopof19" "CESMnotopof19" "CESMnotopof19" "CESMnotopof19" "CESMnotopof19" "CESMnotopof19")
start="2"
end="41"
nsecs="00000" #"00000"

export NCL_N_ARGS=$#

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=0; index<=$numexps-1; index++))
do
  eval export NCL_Exp_$index=${exps1[index]}
  eval export NCL_Exp2_$index=${exps2[index]}

done

eval export NCL_startyr=$start
eval export NCL_endyr=$end

echo NCL_N_ARGS 
echo 'Calc_TakNak_fluxes.ncl'
export NCL_season="DJF"
ncl Calc_TakNak_fluxes.ncl
export NCL_season="MAM"
ncl Calc_TakNak_fluxes.ncl
export NCL_season="JJA"
ncl Calc_TakNak_fluxes.ncl
export NCL_season="SON"
ncl Calc_TakNak_fluxes.ncl


echo 'finished'

