#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
export NCLnumvars="2"
export NCLdifexps="0"
export NCLexpdif="0"
export NCLfigtit="MountainsWind"
export NCLdir1="/home/disk/rachel/CESM_outfiles/"
export NCLnumexps="6"
export NCLlinear="false"
export NCLclon="0.0"
export NCLslon="135.0"
export NCLelon="140.0"
export NCLslat="0.0"
export NCLelat="90.0"
export NCLplottype="CSM"
export NCLplotERA1=0
export NCLtitleprefix="I3CS_"

exps1=("CESMnotopof19" "CESM_IG54" "CESM_IG49" "CESM_IG44" "CESM_IG34" "CESM_IG29")
titles1=("I\_CTL" "I\_63N\_2km" "I\_58N\_2km" "I\_53N\_2km" "I\_43N\_2km" "I\_38N\_2km")
CTLS=("100" "0" "0" "0" "0" "0" "0" "2")
starts=("2" "2" "2" "2" "2" "2" "2" "11")
nyears=("30" "30" "30" "30" "30" "30" "30" "30")
timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("true" "true" "true" "true" "true" "true" "true" "true")


export NCLplotvar_2="OMEGA"
export NCLilev_2="-1"
export NCLvartitle_2="~F10~w~F21~"
export NCLmin1_2="-3.0e-2"
export NCLmax1_2="3.0e-2"
export NCLdiffs1_2="0.6e-2"
export NCLmin2_2="-2.75e-2"
export NCLmax2_2="2.75e-2"
export NCLdiffs2_2="0.5e-2"
export NCLunits_2="m/s"

#export NCLplotvar_2="V"
#export NCLilev_2="-1"
#export NCLvartitle_2="~F10~v~F21~"
#export NCLmin1_2="-2.0"
#export NCLmax1_2="2.0"
#export NCLdiffs1_2="0.4"
#export NCLmin2_2="-1.8"
#export NCLmax2_2="1.8"
#export NCLdiffs2_2="0.4"
#export NCLunits_2="m~S~-1~N~"
#
#export NCLplotvar_1="TdiaSRF"
#export NCLilev_1="0"
#export NCLvartitle_1="DJF\ LH\ +\ SH\ +\ LW\ +\ SW"
#export NCLmin1_1="-180.0"
#export NCLmax1_1="180.0"
#export NCLdiffs1_1="40.0"
#export NCLmin2_1="-45.0"
#export NCLmax2_1="45.0"
#export NCLdiffs2_1="10.0"
#export NCLunits_1="W/m~S~2~N~"

#export NCLplotvar_1="SFZA"
#export NCLilev_1="700"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.35e7"
#export NCLmax1_1="1.35e7"
#export NCLdiffs1_1="3.0e6"
#export NCLmin2_1="-0.45e7"
#export NCLmax2_1="0.45e7"
#export NCLdiffs2_1="1.0e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#
#export NCLplotvar_1="SFZA"
#export NCLilev_1="500"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.35e7"
#export NCLmax1_1="1.35e7"
#export NCLdiffs1_1="3.0e6"
#export NCLmin2_1="-0.9e7"
#export NCLmax2_1="0.9e7"
#export NCLdiffs2_1="2.0e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#
#export NCLplotvar_1="SFZA"
#export NCLilev_1="400"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.35e7"
#export NCLmax1_1="1.35e7"
#export NCLdiffs1_1="3.0e6"
#export NCLmin2_1="-0.9e7"
#export NCLmax2_1="0.9e7"
#export NCLdiffs2_1="2.0e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#
#export NCLplotvar_1="SFZA"
#export NCLilev_1="300"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.35e7"
#export NCLmax1_1="1.35e7"
#export NCLdiffs1_1="3.0e6"
#export NCLmin2_1="-0.9e7"
#export NCLmax2_1="0.9e7"
#export NCLdiffs2_1="2.0e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#
#export NCLplotvar_1="SFZA"
#export NCLilev_1="250"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.35e7"
#export NCLmax1_1="1.35e7"
#export NCLdiffs1_1="3.0e6"
#export NCLmin2_1="-0.9e7"
#export NCLmax2_1="0.9e7"
#export NCLdiffs2_1="2.0e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#

#export NCLplotvar_2="PV"
#export NCLilev_2="700"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.045e-6"
#export NCLmax2_2="0.045e-6"
#export NCLdiffs2_2="0.01e-6"
#export NCLunits_2="PVU"
#
#
#export NCLplotvar_2="PV"
#export NCLilev_2="500"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.045e-6"
#export NCLmax2_2="0.045e-6"
#export NCLdiffs2_2="0.01e-6"
#export NCLunits_2="PVU"
#
#export NCLplotvar_2="PV"
#export NCLilev_2="-1"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.045e-6"
#export NCLmax2_2="0.045e-6"
#export NCLdiffs2_2="0.01e-6"
#export NCLunits_2="PVU"
#
#export NCLplotvar_2="PV"
#export NCLilev_2="300"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.045e-6"
#export NCLmax2_2="0.045e-6"
#export NCLdiffs2_2="0.01e-6"
#export NCLunits_2="PVU"
#
#export NCLplotvar_2="PV"
#export NCLilev_2="250"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.045e-6"
#export NCLmax2_2="0.045e-6"
#export NCLdiffs2_2="0.01e-6"
#export NCLunits_2="PVU"
#
##export NCLplotvar_2="PV"
#export NCLilev_2="300"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.9e-6"
#export NCLmax2_2="0.9e-6"
#export NCLdiffs2_2="0.2e-6"
#export NCLunits_2="PVU"
#
#export NCLplotvar_1="SFZA"
#export NCLilev_1="850"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-0.9e7"
#export NCLmax1_1="0.9e7"
#export NCLdiffs1_1="2.0e6"
#export NCLmin2_1="-0.675e7"
#export NCLmax2_1="0.675e7"
#export NCLdiffs2_1="1.5e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"
#
export NCLplotvar_1="TH"
export NCLilev_1="-1"
export NCLvartitle_1="~F8~q~F21~"
export NCLmin1_1="265.0"
export NCLmax1_1="345.0"
export NCLdiffs1_1="10.0"
export NCLmin2_1="-2.25"
export NCLmax2_1="2.25"
export NCLdiffs2_1="0.5"
export NCLunits_1="K"

#export NCLplotvar_1="U"
#export NCLilev_1="-1"
#export NCLvartitle_1="~F10~u~F21~"
#export NCLmin1_1="-12.0"
#export NCLmax1_1="60.0"
#export NCLdiffs1_1="8.0"
#export NCLmin2_1="-9.0"
#export NCLmax2_1="9.0"
#export NCLdiffs2_1="2.0"
#export NCLunits_1="m~S~-1~N~"
#
#export NCLplotvar_2="Zvar"
#export NCLilev_2="850.0"
#export NCLvartitle_2="~F10~Z~F21~'~S~2~N~~F21~"
#export NCLmin1_2="250"
#export NCLmax1_2="2500"
#export NCLdiffs1_2="250"
#export NCLmin2_2="-450"
#export NCLmax2_2="450"
#export NCLdiffs2_2="100"
#export NCLunits_2="m~S~2~N~"

#export NCLplotvar_1="PREC"
#export NCLilev_1="0"
#export NCLvartitle_1="DJF Precip"
#export NCLmin1_1="0"
#export NCLmax1_1="13.5"
#export NCLdiffs1_1="1.5"
#export NCLmin2_1="-0.9"
#export NCLmax2_1="0.9"
#export NCLdiffs2_1="0.2"
#export NCLunits_1="mm/day"
#
#export NCLplotvar_2="TdiaSRF"
#export NCLilev_2="0"
#export NCLvartitle_2="DJF LH + SH + LW + SW"
#export NCLmin1_2="-200"
#export NCLmax1_2="200"
#export NCLdiffs1_2="40"
#export NCLmin2_2="-90"
#export NCLmax2_2="90"
#export NCLdiffs2_2="20"
#export NCLunits_2="W/m~S~2~N~"



# save command line arguments to environment variable NCL_ARG_#
count=0
for ((index=1; index<=$NCLnumexps; index++))
do
	eval export NCLexps1_$index=${exps1[count]}
	eval export NCLtitles1_$index=${titles1[count]}
	eval export NCLCTLs1_$index=${CTLS[count]}
	eval export NCLstarts1_$index=${starts[count]}
	eval export NCLnyears1_$index=${nyears[count]}
  	eval export NCLtimespans1_$index=${timespan[count]}
  	eval export NCLreverses1_$index=${reverse[count]}

 	((count++))
done


ncl plot_generic2.ncl


