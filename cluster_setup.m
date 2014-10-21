clear all
close all

%% Compile mex files

system('rm -r ./mex/*.mex*')
files = dir('mex/*.c');
for i = 1 : length(files); eval(['mex -outdir mex/ mex/' files(i).name]) ; end 

%% Preliminary SST and data preparation

system('rm -r ./temp/*.mat')
run('prepare_data_sst')

%% A simple test

clear all
close all
addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

cluster_paramGrid(1, 10, 10)
seed = '1';
B = '2';
pair = 'EURUSD';

seed = str2num(seed);
B = str2num(B);
bootstrap_ci(seed,pair,B)