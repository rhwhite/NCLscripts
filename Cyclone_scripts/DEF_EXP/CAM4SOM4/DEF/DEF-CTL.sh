#!/bin/sh
dir="/home/disk/rachel/CESM_outfiles/"
expDEF="CAM4SOM4def1"
expCTL="CAM4SOM4topo"

cd ${dir}/DEF-CTL/

startyrC=11
nyrsC=30

startyrD=20
nyrsD=30

imonth=1
while [ $imonth -le 9 ]; do
	ncdiff -O -v T ${dir}${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc T_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        ncdiff -O -v Q ${dir}${expDEF}/atm/hist/MonMean_SH_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_SH_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc Q_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        
	ncdiff -O -d lev_p,8,8 -v U ${dir}${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc U250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        ncdiff -O -d lev_p,14,14 -v U ${dir}${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc U850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        ncdiff -O -d lev_p,8,8 -v V ${dir}${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc V250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        ncdiff -O -d lev_p,14,14 -v V ${dir}${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc V850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}_pl.nc
        
        ncdiff -O -v SST ${dir}${expDEF}/atm/hist/MonMean_Surf_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_Surf_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc SST_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}.nc
        ncdiff -O -v ICEFRAC ${dir}${expDEF}/atm/hist/MonMean_Surf_${startyrD}_${nyrsD}_0${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_Surf_${startyrC}_${nyrsC}_0${imonth}_${expCTL}.cam2.h0.nc ICE_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_0${imonth}.nc

	let imonth=imonth+1

done

imonth=10
while [ $imonth -le 12 ]; do
        ncdiff -O -v T ${dir}/${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc T_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc
        ncdiff -O -v Q ${dir}/${expDEF}/atm/hist/MonMean_SH_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_SH_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc Q_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc

        ncdiff -O -d lev_p,8,8 -v U ${dir}/${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc U250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc
        ncdiff -O -d lev_p,14,14 -v U ${dir}/${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc U850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc
        ncdiff -O -d lev_p,8,8 -v V ${dir}/${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc V250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc
        ncdiff -O -d lev_p,14,14 -v V ${dir}/${expDEF}/atm/hist/MonMean_pl_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}/${expCTL}/atm/hist/MonMean_pl_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc V850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}_pl.nc

        ncdiff -O -v SST ${dir}${expDEF}/atm/hist/MonMean_Surf_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_Surf_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc SST_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}.nc
        ncdiff -O -v ICEFRAC ${dir}${expDEF}/atm/hist/MonMean_Surf_${startyrD}_${nyrsD}_${imonth}_${expDEF}.cam2.h0.nc ${dir}${expCTL}/atm/hist/MonMean_Surf_${startyrC}_${nyrsC}_${imonth}_${expCTL}.cam2.h0.nc ICE_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_${imonth}.nc

	let imonth=imonth+1

done

ncrcat -O Q_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc Q_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O T_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc T_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O U250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc U250_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O U850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc U850_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O V250_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc V250_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O V850_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*pl.nc V850_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O SST_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*.nc SST_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc
ncrcat -O ICE_S_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*.nc ICE_MonMean_DEF-CTL_${startyrD}_${nyrsD}.nc

rm -f *_MonMean_DEF-CTL_${startyrD}_${nyrsD}30yr_*.nc




