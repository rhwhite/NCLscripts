#!/bin/sh
cd /home/disk/eos4/rachel/NCL/echam_scripts/Standard
dir="eos4/rachel/MPIESM/ECHAM4.6/echam_PDO_fSST/output/"
numexps="1"
exps=("PDO_fSST")
start="88"
end="117"

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
echo export NCL_ARG_$index=$start
eval export NCL_ARG_$index=$start
((index++))
echo $index
eval export NCL_ARG_$index=$end

echo NCL_N_ARGS 
ncl Create_all_means.ncl 
#:echo 'Create_all_means.ncl'
#ncl hybrid2pres.ncl
#echo 'hybrid2pres.ncl'
#ncl Calc_Eady40.ncl
#echo 'Calc_Eady40.ncl'
#ncl LanczosF_Z850.ncl
#echo 'LanczosF_Z850.ncl'
#ncl Calc_varZ850.ncl
#echo 'Calc_varZ850.ncl'
echo 'finished'

