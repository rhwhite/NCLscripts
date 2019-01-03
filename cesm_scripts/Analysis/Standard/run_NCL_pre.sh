#!/bin/sh
# source cshrc_version cshrcSTD and load ncl/6.2
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
#dir="/home/disk/eos4/rachel/CESM_outfiles/"
dir="/home/disk/eos4/rachel/CESM_outfiles/HYAK/"

exps=("WACCM_f19_CTL")
numexps="1"
start="2"
end="51"

export NCL_dirstr="/atm/hist/"

# save command line arguments to environment variable NCL_ARG_#
export NCL_ARG_1=$dir
export NCL_ARG_2=$numexps

# save command line arguments to environment variable NCL_ARG_#
for ((index=3; index<=2+$numexps; index++))
do
  eval export NCL_ARG_$index=${exps[index-3]}
done
echo $index
eval export NCL_startyr=$start
((index++))
echo $index
eval export NCL_endyr=$end
((index++))
echo $index

echo NCL_N_ARGS 
#echo "Initial_analysis_means.ncl"
#ncl Initial_analysis_means.ncl
#echo 'hybrid2pres_TH_Z_N.ncl'
#ncl hybrid2pres_TH_Z_N.ncl

export NCL_forCasey="1"
#echo 'Create_Seas_ts.ncl'
#ncl Create_Seas_ts.ncl  # create timeseries of all years of monthly data for
                        # DJF, MAM, JJA and SON
echo 'hybrid2pres_ts.ncl' 
ncl hybrid2pres_ts.ncl  # convert the files created by Create_Seas_ts.ncl
                            # onto pressure levels specified in this file


echo 'finished'

