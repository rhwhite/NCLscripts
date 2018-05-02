#!/bin/sh
cd /home/disk/eos4/rachel/git/NCL/cesm_scripts/Analysis/Plotting/scripts/
plotvars="UU"

export NCLnumvars="2"
export NCLdifexps="0"
export NCLexpdif="0"
export NCLfigtit="Mongolia/newPaper"
export NCLdir1="/home/disk/rachel/CESM_outfiles/"
export NCLnumexps="4"
export NCLlinear="true"
export NCLclon="180.0"
export NCLslon="30.0"
export NCLelon="270.0"
export NCLslat="0.0"
export NCLelat="90.0"
export NCLplottype="map"
export NCLplotctl=0
export NCLplotERA1=1
export NCLtitleprefix="Real_"

exps1=("CESMtopof19" "CESMnoT2f19" "CESMnoT4f19" "CESMnoTf19")
titles1=("CTL" "\ Impact\ of~C~Tib\ \&\ Mon" "Impact\ of~C~Mongolia" "Impact\ of~C~\ \ \ Tibet")
CTLS=("100" "0" "0" "0" "0" "0" "2" "2")
starts=("2" "2" "2" "2" "2" "11" "11" "11")
nyears=("40" "40" "40" "40" "30" "30" "30" "30")
#timespan=("MAM" "MAM" "MAM" "MAM" "MAM" "MAM" "MAM" "MAM")

#timespan=("AMJ" "AMJ" "AMJ" "AMJ" "AMJ" "AMJ" "AMJ" "AMJ")

timespan=("DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF" "DJF")
reverse=("false" "false" "false" "false" "false" "false" "true" "true")

export NCLallblue=0
export NCLplottitles=1


if test "$plotvars" == "SFZA"; then
        export NCLallblue=0
        export NCLplotvar_1="SFZA"
        export NCLilev_1="850"
        export NCLvartitle_1="~F8~y'~F21~"
        export NCLmin1_1="-0.75e7"
        export NCLmax1_1="0.75e7"
        export NCLdiffs1_1="0.15e7"
        export NCLmin2_1="-7.5e6"
        export NCLmax2_1="7.5e6"
        export NCLdiffs2_1="1.5e6"
        export NCLunits_1="10~S~6~N~s~S~-1~N~"

        export NCLplotvar_2="SFZA"
        export NCLilev_2="250"
        export NCLvartitle_2="~F8~y'~F21~"
        export NCLmin1_2="-2.0e7"
        export NCLmax1_2="2.0e7"
        export NCLdiffs1_2="4.0e6"
        export NCLmin2_2="-10.0e6"
        export NCLmax2_2="10.0e6"
        export NCLdiffs2_2="2.0e6"
        export NCLunits_2="10~S~6~N~s~S~-1~N~"

elif test "$plotvars" == "THU"; then
        export NCLplotvar_1="TH"
        export NCLilev_1="850.0"
        export NCLvartitle_1="~F8~q~F21~"
        export NCLmin1_1="265.0"
        export NCLmax1_1="310.0"
        export NCLdiffs1_1="5.0"
        export NCLmin2_1="-5.0"
        export NCLmax2_1="5.0"
        export NCLdiffs2_1="1.0"
        export NCLunits_1="K"


	export NCLplotvar_2="U"
        export NCLilev_2="250"
        export NCLvartitle_2="~F10~U~F21~"
        export NCLmin1_2="-7.0"
        export NCLmax1_2="77.0"
        export NCLdiffs1_2="7.0"
        export NCLmin2_2="-20.0"
        export NCLmax2_2="20.0"
        export NCLdiffs2_2="4.0"
        export NCLunits_2="ms~S~-1~N~"
elif test "$plotvars" == "UU"; then
        export NCLplotvar_1="U"
        export NCLilev_1="850.0"
        export NCLvartitle_1="~F10~U~F21~"
        export NCLmin1_1="-10.0"
        export NCLmax1_1="10.0"
        export NCLdiffs1_1="2.0"
        export NCLmin2_1="-5.0"
        export NCLmax2_1="5.0"
        export NCLdiffs2_1="1.0"
        export NCLunits_1="ms~S~-1~N~"


        export NCLplotvar_2="U"
        export NCLilev_2="250"
        export NCLvartitle_2="~F10~U~F21~"
        export NCLmin1_2="-7.0"
        export NCLmax1_2="77.0"
        export NCLdiffs1_2="7.0"
        export NCLmin2_2="-20.0"
        export NCLmax2_2="20.0"
        export NCLdiffs2_2="4.0"
        export NCLunits_2="ms~S~-1~N~"

elif test "$plotvars" == "Zvar"; then
        export NCLplotvar_1="Zvar"
        export NCLilev_1="250.0"
        export NCLvartitle_1="~F10~Z~F21~'~S~2~N~~F21~"
        export NCLmin1_1="0"
        export NCLmax1_1="8000"
        export NCLdiffs1_1="800"
        export NCLmin2_1="-2400"
        export NCLmax2_1="2400"
        export NCLdiffs2_1="400"
        export NCLunits_1="m~S~2~N~"

        export NCLplotvar_2="Zvar"
        export NCLilev_2="850.0"
        export NCLvartitle_2="~F10~Z~F21~'~S~2~N~~F21~"
        export NCLmin1_2="250"
        export NCLmax1_2="2500"
        export NCLdiffs1_2="250"
        export NCLmin2_2="-450"
        export NCLmax2_2="450"
        export NCLdiffs2_2="100"
        export NCLunits_2="m~S~2~N~"

elif test "$plotvars" == "UV"; then
        export NCLplotvar_1="V"
        export NCLilev_1="250.0"
        export NCLvartitle_1="~F10~V~F21~"
        export NCLmin1_1="-8.0"
        export NCLmax1_1="64.0"
        export NCLdiffs1_1="8.0"
        export NCLmin2_1="-10.0"
        export NCLmax2_1="10.0"
        export NCLdiffs2_1="2.0"
        export NCLunits_1="ms~S~-1~N~"

        export NCLplotvar_2="U"
        export NCLilev_2="250"
        export NCLvartitle_2="~F10~U~F21~"
        export NCLmin1_2="-8.0"
        export NCLmax1_2="64.0"
        export NCLdiffs1_2="8.0"
        export NCLmin2_2="-10.0"
        export NCLmax2_2="10.0"
        export NCLdiffs2_2="2.0"
        export NCLunits_2="ms~S~-1~N~"

elif test "$plotvars" == "UVPrec"; then
        export NCLplotvar_1="UV"
        export NCLilev_1="850.0"
        export NCLvartitle_1="~F10~V~F21~"
        export NCLmin1_1="-10.0"
        export NCLmax1_1="10.0"
        export NCLdiffs1_1="2.0"
        export NCLmin2_1="-5.0"
        export NCLmax2_1="5.0"
        export NCLdiffs2_1="1.0"
        export NCLunits_1="ms~S~-1~N~"

	export NCLplotvar_2="PREC"
	export NCLilev_2="0"
	export NCLvartitle_2="DJF Precip"
	export NCLmin1_2="0"
	export NCLmax1_2="13.5"
	export NCLdiffs1_2="1.5"
	export NCLmin2_2="-0.9"
	export NCLmax2_2="0.9"
	export NCLdiffs2_2="0.2"
	export NCLunits_2="mm/day"


elif test "$plotvars" == "WW"; then
        export NCLplotvar_1="OMEGA"
        export NCLilev_1="850.0"
        export NCLvartitle_1="~F10~W~F21~"
        export NCLmin1_1="-0.1"
        export NCLmax1_1="0.1"
        export NCLdiffs1_1="0.02"
        export NCLmin2_1="-0.02"
        export NCLmax2_1="0.02"
        export NCLdiffs2_1="0.004"
        export NCLunits_1="ms~S~-1~N~"

        export NCLplotvar_2="OMEGA"
        export NCLilev_2="700"
        export NCLvartitle_2="~F10~W~F21~"
        export NCLmin1_2="-0.1"
        export NCLmax1_2="0.1"
        export NCLdiffs1_2="0.02"
        export NCLmin2_2="-0.02"
        export NCLmax2_2="0.02"
        export NCLdiffs2_2="0.004"
        export NCLunits_2="ms~S~-1~N~"



else

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
#
#export NCLplotvar_2="SF"
#export NCLilev_2="250"
#export NCLvartitle_2="~F8~y'~F21~"
#export NCLmin1_2="-10.0e7"
#export NCLmax1_2="10.0e7"
#export NCLdiffs1_2="2.0e7"
#export NCLmin2_2="-1.0e7"
#export NCLmax2_2="1.0e7"
#export NCLdiffs2_2="2.0e6"
#export NCLunits_2="m~S~2~N~s~S~-1~N~"
#
#
export NCLplotvar_2="SFZA"
export NCLilev_2="250"
export NCLvartitle_2="~F8~y'~F21~"
export NCLmin1_2="-2.0e7"
export NCLmax1_2="2.0e7"
export NCLdiffs1_2="4.0e6"
export NCLmin2_2="-12.0e6"
export NCLmax2_2="12.0e6"
export NCLdiffs2_2="2.0e6"
export NCLunits_2="10e6m~S~2~N~s~S~-1~N~"
#
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
##
export NCLplotvar_1="SFZA"
export NCLilev_1="850"
export NCLvartitle_1="~F8~y'~F21~"
export NCLmin1_1="-1.0e7"
export NCLmax1_1="1.0e7"
export NCLdiffs1_1="2.0e6"
export NCLmin2_1="-7.5e6"
export NCLmax2_1="7.5e6"
export NCLdiffs2_1="1.5e6"
export NCLunits_1="10e6m~S~2~N~s~S~-1~N~"
##
#export NCLplotvar_1="SF"
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
#
#export NCLplotvar_1="TH"
#export NCLilev_1="850.0"
#export NCLvartitle_1="~F8~q~F21~"
#export NCLmin1_1="265.0"
#export NCLmax1_1="310.0"
#export NCLdiffs1_1="5.0"
#export NCLmin2_1="-5.0"
#export NCLmax2_1="5.0"
#export NCLdiffs2_1="1.0"
#export NCLunits_1="K"
#
#export NCLplotvar_1="dTHdy"
#export NCLilev_1="850.0"
#export NCLvartitle_1="~F8~q~F21~"
#export NCLmin1_1="265.0"
#export NCLmax1_1="310.0"
#export NCLdiffs1_1="5.0"
#export NCLmin2_1="-0.000005"
#export NCLmax2_1="0.000005"
#export NCLdiffs2_1="0.000001"
#export NCLunits_1="K"
#
#
#export NCLplotvar_2="dTHdy"
#export NCLilev_2="400.0"
#export NCLvartitle_2="~F8~q~F21~"
#export NCLmin1_2="265.0"
#export NCLmax1_2="310.0"
#export NCLdiffs1_2="5.0"
#export NCLmin2_2="-0.000005"
#export NCLmax2_2="0.000005"
#export NCLdiffs2_2="0.000001"
#export NCLunits_2="K"
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
#export NCLplotvar_1="U"
#export NCLilev_1="850"
#export NCLvartitle_1="~F10~u~F21~"
#export NCLmin1_1="-7.0"
#export NCLmax1_1="11.0"
#export NCLdiffs1_1="2.0"
#export NCLmin2_1="-9.0"
#export NCLmax2_1="9.0"
#export NCLdiffs2_1="2.0"
#export NCLunits_1="m~S~-1~N~"
#
#export NCLplotvar_2="U"
#export NCLilev_2="250"
#export NCLvartitle_2="~F10~u~F21~"
#export NCLmin1_2="-7.0"
#export NCLmax1_2="77.0"
#export NCLdiffs1_2="7.0"
#export NCLmin2_2="-20.0"
#export NCLmax2_2="20.0"
#export NCLdiffs2_2="4.0"
#export NCLunits_2="ms~S~-1~N~"
##
#export NCLplotvar_1="V"
#export NCLilev_1="850"
#export NCLvartitle_1="~F10~v~F21~"
#export NCLmin1_1="-1.0"
#export NCLmax1_1="6.0"
#export NCLdiffs1_1="0.8"
#export NCLmin2_1="-1.8"
#export NCLmax2_1="1.8"
#export NCLdiffs2_1="0.4"
#export NCLunits_1="m~S~-1~N~"
#
#export NCLplotvar_2="V"
#export NCLilev_2="250"
#export NCLvartitle_2="~F10~v~F21~"
#export NCLmin1_2="-1.0"
#export NCLmax1_2="6.0"
#export NCLdiffs1_2="0.8"
#export NCLmin2_2="-1.80"
#export NCLmax2_2="1.80"
#export NCLdiffs2_2="0.4"
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

fi


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


