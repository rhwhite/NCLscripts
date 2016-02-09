#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
export NCLnumvars="2"
export NCLdifexps=0
export NCLexpdif="0"
export NCLfigtit="Paper"
export NCLdir1="/home/disk/rachel/CESM_outfiles/"
export NCLnumexps="4"
export NCLlinear="false"
export NCLclon="180.0"
export NCLslon="30.0"
export NCLelon="300."
export NCLslat="-30.0"
export NCLelat="90.0"
export NCLplottype="map"
export NCLplotctl1=1
export NCLplotERA1=0
export NCLplotctl2=1
export NCLplotERA2=0
export NCLtitleprefix="I4_"

exps1=("CESMnotopof19" "CESM_IG49N_West" "CESM_IG39_West" "CESM_IG29N_West")
titles1=("I\_CTL" "I\_58N\_West" "I\_48N\_West" "I\_38N\_West")
CTLS1=("100" "0" "0" "0" "0" "1" "1" "1")
starts1=("2" "2" "2" "2" "2" "2" "2" "2")
nyears1=("30" "30" "30" "30" "30" "30" "30" "30")
timespan1=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse1=("true" "true" "true" "true" "true" "true" "true" "true")


export NCLplotvar_1="SFZA"
export NCLilev_1="250"
export NCLvartitle_1="~F8~y'~F21~"
export NCLmin1_1="-1.8e7"
export NCLmax1_1="1.8e7"
export NCLdiffs1_1="4.0e6"
export NCLmin2_1="-1.08e7"
export NCLmax2_1="1.08e7"
export NCLdiffs2_1="2.4e6"
export NCLunits_1="m~S~2~N~s~S~-1~N~"

#export NCLplotvar_2="OMEGA"
#export NCLilev_2="850"
#export NCLvartitle_2="~F10~w~F21~"
#export NCLmin1_2="-3.0e-2"
#export NCLmax1_2="3.0e-2"
#export NCLdiffs1_2="0.6e-2"
#export NCLmin2_2="-2.75e-2"
#export NCLmax2_2="2.75e-2"
#export NCLdiffs2_2="0.5e-2"
#export NCLunits_2="m/s"
#

export NCLplotvar_2="PV"
export NCLilev_2="300"
export NCLvartitle_2="~F10~PV~F21~"
export NCLmin1_2="0.0"
export NCLmax1_2="1.8e-6"
export NCLdiffs1_2="0.2e-6"
export NCLmin2_2="-0.45e-6"
export NCLmax2_2="0.45e-6"
export NCLdiffs2_2="0.1e-6"
export NCLunits_2="PVU"

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
#export NCLplotvar_2="TH"
#export NCLilev_2="850.0"
#export NCLvartitle_2="~F8~q~F21~"
#export NCLmin1_2="265.0"
#export NCLmax1_2="310.0"
#export NCLdiffs1_2="5.0"
#export NCLmin2_2="-3.6"
#export NCLmax2_2="3.6"
#export NCLdiffs2_2="0.8"
#export NCLunits_2="K"
#
#export NCLplotvar_1="U"
#export NCLilev_1="250"
#export NCLvartitle_1="~F10~u~F21~"
#export NCLmin1_1="-12.0"
#export NCLmax1_1="60.0"
#export NCLdiffs1_1="8.0"
#export NCLmin2_1="-13.5"
#export NCLmax2_1="13.5"
#export NCLdiffs2_1="3.0"
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
#
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
	eval export NCLCTLs1_$index=${CTLS1[count]}
	eval export NCLstarts1_$index=${starts1[count]}
	eval export NCLnyears1_$index=${nyears1[count]}
  	eval export NCLtimespans1_$index=${timespan1[count]}
  	eval export NCLreverses1_$index=${reverse1[count]}

 	((count++))
done
if [ $NCLdifexps > 0 ]
then
	count=0
	for ((index=1; index<=$NCLnumexps; index++))
	do
	        eval export NCLexps2_$index=${exps2[count]}
	        eval export NCLtitles2_$index=${titles2[count]}
	        eval export NCLCTLs2_$index=${CTLS2[count]}
	        eval export NCLstarts2_$index=${starts2[count]}
	        eval export NCLnyears2_$index=${nyears2[count]}
	        eval export NCLtimespans2_$index=${timespan2[count]}
	        eval export NCLreverses2_$index=${reverse2[count]}

	        ((count++))
	done
fi

ncl plot_generic2.ncl


