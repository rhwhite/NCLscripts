#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
export NCLnumvars="2"
export NCLdifexps="0"
export NCLexpdif="0"
export NCLfigtit="Mongolia/newPaper"
export NCLdir1="/home/disk/rachel/CESM_outfiles/"
export NCLnumexps="3"
export NCLlinear="false"
export NCLclon="180.0"
export NCLslon="30.0"
export NCLelon="300."
export NCLslat="-30.0"
export NCLelat="90.0"
export NCLplottype="map"
export NCLplotctl=0
export NCLplotERA1=0
export NCLtitleprefix="I1_"

exps1=("CESMnotopof19" "CESM_onlyIT" "CESM_onlyITSh")
titles1=("Flat" "T_gauss" "M_gauss")
CTLS=("100" "0" "0" "0" "0" "0" "2" "2")
starts=("2" "2" "2" "2" "2" "11" "11" "11")
nyears=("30" "30" "30" "30" "30" "30" "30" "30")
timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("true" "true" "true" "true" "false" "false" "true" "true")

#export NCLplotvar_1="Z"
#export NCLilev_1="850"
#export NCLvartitle_1="~F8~Z~F21~"
#export NCLmin1_1="1275"
#export NCLmax1_1="1550"
#export NCLdiffs1_1="25"
#export NCLmin2_1="-100"
#export NCLmax2_1="100"
#export NCLdiffs2_1="20"
#export NCLunits_1="m"
#
#export NCLplotvar_2="Z"
#export NCLilev_2="250"
#export NCLvartitle_2="~F8~Z~F21~"
#export NCLmin1_2="9400"
#export NCLmax1_2="11050"
#export NCLdiffs1_2="150"
#export NCLmin2_2="-100"
#export NCLmax2_2="100"
#export NCLdiffs2_2="20"
#export NCLunits_2="m"

export NCLplotvar_2="SFZA"
export NCLilev_2="250"
export NCLvartitle_2="~F8~y'~F21~"
export NCLmin1_2="-1.8e7"
export NCLmax1_2="1.8e7"
export NCLdiffs1_2="4.0e6"
export NCLmin2_2="-1.08e7"
export NCLmax2_2="1.08e7"
export NCLdiffs2_2="2.4e6"
export NCLunits_2="m~S~2~N~s~S~-1~N~"

#export NCLplotvar_2="PV"
#export NCLilev_2="300"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="3.6e-6"
#export NCLdiffs1_2="0.4e-6"
#export NCLmin2_2="-0.9e-6"
#export NCLmax2_2="0.9e-6"
#export NCLdiffs2_2="0.2e-6"
#export NCLunits_2="PVU"

export NCLplotvar_1="SFZA"
export NCLilev_1="850"
export NCLvartitle_1="~F8~y'~F21~"
export NCLmin1_1="-0.9e7"
export NCLmax1_1="0.9e7"
export NCLdiffs1_1="2.0e6"
export NCLmin2_1="-0.675e7"
export NCLmax2_1="0.675e7"
export NCLdiffs2_1="1.5e6"
export NCLunits_1="m~S~2~N~s~S~-1~N~"

#export NCLplotvar_1="TH"
#export NCLilev_1="850.0"
#export NCLvartitle_1="~F8~q~F21~"
#export NCLmin1_1="265.0"
#export NCLmax1_1="310.0"
#export NCLdiffs1_1="5.0"
#export NCLmin2_1="-4.5"
#export NCLmax2_1="4.5"
#export NCLdiffs2_1="1.0"
#export NCLunits_1="K"
#
#export NCLplotvar_1="TH"
#export NCLilev_1="300.0"
#export NCLvartitle_1="~F8~q~F21~"
#export NCLmin1_1="265.0"
#export NCLmax1_1="310.0"
#export NCLdiffs1_1="5.0"
#export NCLmin2_1="-3.6"
#export NCLmax2_1="3.6"
#export NCLdiffs2_1="0.8"
#export NCLunits_1="K"
#
#export NCLplotvar_2="TH"
#export NCLilev_2="250.0"
#export NCLvartitle_2="~F8~q~F21~"
#export NCLmin1_2="265.0"
#export NCLmax1_2="310.0"
#export NCLdiffs1_2="5.0"
#export NCLmin2_2="-3.6"
#export NCLmax2_2="3.6"
#export NCLdiffs2_2="0.8"
#export NCLunits_2="K"
#
#export NCLplotvar_2="U"
#export NCLilev_2="250"
#export NCLvartitle_2="~F10~u~F21~"
#export NCLmin1_2="-12.0"
#export NCLmax1_2="60.0"
#export NCLdiffs1_2="8.0"
#export NCLmin2_2="-18.0"
#export NCLmax2_2="18.0"
#export NCLdiffs2_2="4.0"
#export NCLunits_2="m~S~-1~N~"
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


