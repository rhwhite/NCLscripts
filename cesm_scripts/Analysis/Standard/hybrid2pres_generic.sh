#!/bin/sh
# Script to calculate variables that are useful for analysing Rossby wave
# behaviour

cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Standard/scripts/
dir="/home/disk/eos4/rachel/Projects/SeasonalCycle/"
file="Monthly_Clim_CAM4POP_f19g16C_noTopo.cam2.h0.0300-0349.nc" #Monthly_Clim_b40.1850.track1.2deg.003.cam.h0.500-529.nc"

export NCL_dir=$dir
export NCL_file=$file

ncl hybrid2pres_generic.ncl

echo 'finished'

