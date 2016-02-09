#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/


plotvar="-dTHdx"
ilev="850"
min1="-6.0e-6"
max1="6.0e-6"
diffs1="1.0e-6"
min2="-3.0e-6"
max2="3.0e-6"
diffs2="0.5e-6"
units="Km:S:-1:N:"
plottype="ZMline"

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
((index++))
eval export NCL_ARG_$index=$plottype


ncl plot_generic.ncl
echo 'finished'

