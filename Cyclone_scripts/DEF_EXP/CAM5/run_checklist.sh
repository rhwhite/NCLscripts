#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/DEF_EXP/

#ncl Create_DJF_mean.ncl
#echo 'Create_DJF_mean.ncl'
#ncl Create_JJA_mean.ncl
#echo 'Create_JJA_mean.ncl'
#ncl Create_annual_mean.ncl
#echo 'Create_annual_mean.ncl'

ncl Create_CLM_DJF_mean.ncl
echo 'Create_CLM_DJF_mean.ncl'
ncl Create_CLM_JJA_mean.ncl
echo 'Create_CLM_JJA_mean.ncl'
ncl Create_CLM_annual_mean.ncl
echo 'Create_CLM_annual_mean.ncl'

