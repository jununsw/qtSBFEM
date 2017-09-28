clear
close all
clc
dbstop if error

%% set path
%restoredefaultpath;
workfolder  = '.\';
casefolder = [workfolder,'case\'];
addpath(genpath(workfolder));
addpath([workfolder,'tool\Chan-Vese']);
addpath([workfolder,'tool\quadTree']);
addpath([workfolder,'src\mesh']);
addpath([workfolder,'src\analysis']);
addpath([workfolder,'src\io']);
addpath([workfolder,'qa']);

%% set debug option
UNSW_DEBUG       = 0;
UNSW_PROFILE     = 0;