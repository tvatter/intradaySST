seed = str2num(seed);
B = str2num(B);

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

bootstrap_ci(seed,pair,B)
quit;