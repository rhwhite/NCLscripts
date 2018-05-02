% Sets paths, common options, etc...
addpath(genpath('../lib/m_map'))
addpath(genpath('../lib/export_fig'))
set(0,'DefaultFigureColor',[1 1 1])
set(0,'DefaultAxesFontSize', 14)
set(0,'DefaultTextFontSize', 14)
basepath = '/n/huybers_lab/common/data/NCEP_R2/';
% air, hgt, uwnd, vwnd
TN2001path = [basepath 'derived/misc/'];