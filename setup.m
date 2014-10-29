clear all
close all

%% Compile mex files

system('rm -r ./mex/*.mex*')
files = dir('mex/*.c');
for i = 1 : length(files); eval(['mex -outdir mex/ mex/' files(i).name]) ; end 

%% Preliminary SST and data preparation

%system('rm -r ./temp/*.mat')
display_results = 0;
run('data_sst')
display_results = 0;
run('data_simul')

%% Test of doOne_bootstrapci 

clear all
close all
addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))


seed = '2';
B = '2';
pair = 'EURUSD';
batchjob = 'FALSE';
doOne_bootstrapci
%paramGrid_bootstrapci(1, 20, 10)

%% Test of doOne_simul 

clear all
close all
addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

paramGrid_simul('EURUSD',1, 25, 10)
seed = '1';
B = '4';
pair = 'EURUSD';
n = '150';
method = 'sst';
batchjob = 'FALSE';
doOne_simul
