#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/

plotvar="DTV"
ilev="850"
min1="-1e-5"
max1="1e-5"
diffs1="2e-6"
min2="-1e-6"
max2="1e-6"
diffs2="2e-7"
units="Ks:S:-1:N:"

# save command line arguments to environment variable NCL_ARG_#
index=1
eval export NCL_ARG_$index=$plotvar
((index++))
eval export NCL_ARG_$index=$ilev
((index++))
eval export NCL_ARG_$index=$min1
((index++))
eval export NCL_ARG_$index=$max1
((index++))
eval export NCL_ARG_$index=$diffs1
((index++))
eval export NCL_ARG_$index=$min2
((index++))
eval export NCL_ARG_$index=$max2
((index++))
eval export NCL_ARG_$index=$diffs2
((index++))
eval export NCL_ARG_$index=$units

ncl plot_generic.ncl
echo 'finished'

