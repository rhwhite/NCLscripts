#!/bin/sh
cd /home/disk/eos4/rachel/NCL/cesm_scripts/Analysis/Plotting/scripts/
export NCLnumvars="2"
export NCLdifexps="0"
export NCLexpdif="0"
export NCLfigtit="Mongolia/newPaper"
export NCLdir1="/home/disk/rachel/CESM_outfiles/"
export NCLnumexps="2"
export NCLlinear="false"
export NCLclon="180.0"
export NCLslon="30.0"
export NCLelon="300."
export NCLslat="-30.0"
export NCLelat="90.0"
export NCLplottype="map"
export NCLplotctl=0
export NCLplotERA1=0
export NCLtitleprefix="CTLs2_"

exps1=("CESMnotopof19" "CESMnoT2f19" "CESMnoT2f19" "CESMnoT4f19")
titles1=("CTL" "noMT" "CESM\_no\_MorT" "CESM\_no\_M")
CTLS=("100" "100" "100" "100" "0" "0" "0" "2")
starts=("2" "2" "2" "2" "2" "2" "2" "11")
nyears=("30" "30" "30" "30" "30" "30" "30" "30")
timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("true" "true" "true" "true" "true" "true" "true" "true")



export NCLplotvar_2="dPVdy"
export NCLilev_2="925"
export NCLvartitle_2="dPVdy"
export NCLmin1_2="0"
export NCLmax1_2="0.9e-12"
export NCLdiffs1_2="0.1e-12"
export NCLmin2_2="-7"
export NCLmax2_2="20"
export NCLdiffs2_2="3.0"
export NCLunits_2="1E-6 PVU/m"

#export NCLplotvar_2="dPVdy"
#export NCLilev_2="850"
#export NCLvartitle_2="dPVdy"
#export NCLmin1_2="0"
#export NCLmax1_2="0.45e-12"
#export NCLdiffs1_2="0.05e-12"
#export NCLmin2_2="-7"
#export NCLmax2_2="20"
#export NCLdiffs2_2="3.0"
#export NCLunits_2="1E-12 PVU/m"
#

export NCLplotvar_1="U"
export NCLilev_1="925"
export NCLvartitle_1="U"
export NCLmin1_1="-7"
export NCLmax1_1="20"
export NCLdiffs1_1="3.0"
export NCLmin2_1="-7"
export NCLmax2_1="20"
export NCLdiffs2_1="3.0"
export NCLunits_1="m/s"
#
#export NCLplotvar_2="U"
#export NCLilev_2="850"
#export NCLvartitle_2="U"
#export NCLmin1_2="-7"
#export NCLmax1_2="20"
#export NCLdiffs1_2="3.0"
#export NCLmin2_2="-7"
#export NCLmax2_2="20"
#export NCLdiffs2_2="3.0"
#export NCLunits_2="m/s"
#
#
#export NCLplotvar_2="dTHdzdTHdy"
#export NCLilev_2="925"
#export NCLvartitle_2="(dTH/dz)/(dTH/dy)"
#export NCLmin1_2="-2000.0"
#export NCLmax1_2="2000.0"
#export NCLdiffs1_2="200.0"
#export NCLmin2_2="-2000.0"
#export NCLmax2_2="2000.0"
#export NCLdiffs2_2="200.0"
#export NCLunits_2=""
#

#export NCLplotvar_1="dTHdy"
#export NCLilev_1="775"
#export NCLvartitle_1="dTH/dy"
#export NCLmin1_1="-0.00001"
#export NCLmax1_1="0.00001"
#export NCLdiffs1_1="0.000002"
#export NCLmin2_1="-0.00001"
#export NCLmax2_1="0.00001"
#export NCLdiffs2_1="0.000002"
#export NCLunits_1="K/m"
#
#export NCLplotvar_2="dTHdz"
#export NCLilev_2="775"
#export NCLvartitle_2="dTH/dz"
#export NCLmin1_2="0.002"
#export NCLmax1_2="0.012"
#export NCLdiffs1_2="0.001"
#export NCLmin2_2="0.002"
#export NCLmax2_2="0.012"
#export NCLdiffs2_2="0.001"
#export NCLunits_2="K/m"
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
#export NCLilev_1="250"
#export NCLvartitle_1="~F8~y'~F21~"
#export NCLmin1_1="-1.8e7"
#export NCLmax1_1="1.8e7"
#export NCLdiffs1_1="4.0e6"
#export NCLmin2_1="-1.08e7"
#export NCLmax2_1="1.08e7"
#export NCLdiffs2_1="2.4e6"
#export NCLunits_1="m~S~2~N~s~S~-1~N~"

#export NCLplotvar_1="PV"
#export NCLilev_1="500"
#export NCLvartitle_1="~F10~PV~F21~"
#export NCLmin1_1="0.0"
#export NCLmax1_1="0.8e-6"
#export NCLdiffs1_1="0.05e-6"
#export NCLmin2_1="-0.9e-6"
#export NCLmax2_1="0.9e-6"
#export NCLdiffs2_1="0.2e-6"
#export NCLunits_1="PVU"
#
#export NCLplotvar_2="PV"
#export NCLilev_2="775"
#export NCLvartitle_2="~F10~PV~F21~"
#export NCLmin1_2="0.0"
#export NCLmax1_2="2.4e-6"
#export NCLdiffs1_2="0.15e-6"
#export NCLmin2_2="-0.9e-6"
#export NCLmax2_2="0.9e-6"
#export NCLdiffs2_2="0.2e-6"
#export NCLunits_2="PVU"


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


