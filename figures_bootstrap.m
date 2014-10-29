clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))
addpath(genpath('figures'))

options = get_sstoptions();
pair = ['CHFUSD';'EURUSD';'GBPUSD';'JPYUSD'];
dir_bootstrapci = 'temp/bootstrapci/';
L = size(pair);
L = L(1);
K = options.season.sst.ncomp;
cc = hsv(4);
for l = 1:4
   nn = pair(l,:);
   %boottrend_figure(nn, 'pdf')
   %bootam_figure(nn, 'pdf',options) 
   bootsst_figure(nn, 'pdf',options) 
end


