#!/bin/bash
export HDF5_DISABLE_VERSION_CHECK=2
for yrnum in {1980..2013}; 
do echo $yrnum; 
sed -i "s/fyear = ..../fyear = ${yrnum}/g" TN2001_ncep_daily.ncl
ncl TN2001_ncep_daily.ncl
done