clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

options = get_sstoptions();
pair = 'EURUSD';
dir_simul = 'temp/simul/';
nseed = 100;
n = 150*288;
B = 10;
L = length(pair);
K = options.season.sst.ncomp;

disp('trend')
tic
get_simuldata(dir_simul,pair,'T',n,nseed,B,options)
toc
for k = 1:K
     disp(['am', num2str(k)])
     tic
     get_simuldata(dir_simul,pair,['am',num2str(k)],n,nseed,B,options)
     toc
     disp(['ph', num2str(k)])
     tic
     get_simuldata(dir_simul,pair,['ph',num2str(k)],n,nseed,B,options)
     toc
end