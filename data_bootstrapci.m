clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

options = get_sstoptions();
pair = ['CHFUSD';'EURUSD';'GBPUSD';'JPYUSD'];
dir_bootstrapci = 'temp/bootstrapci/';
nseed = 100;
B = 10;
L = length(pair);
K = options.season.sst.ncomp;

nn = 'EURUSD';
eval(['load temp/ret_',nn,'.mat']);
eval(['n = length(ret_',nn,');']);
eval(['clear ret_',nn]);

for l = 1:K
   tic
   disp(pair(l,:))
   disp('trend')
   get_bootdata(dir_bootstrapci,pair(l,:),'T',n,nseed,B,options)
   for k = 1:K
     disp(['am', num2str(k)])
     get_bootdata(dir_bootstrapci,pair(l,:),['am',num2str(k)],n,nseed,B,options)
     disp(['ph', num2str(k)])
     get_bootdata(dir_bootstrapci,pair(l,:),['ph',num2str(k)],n,nseed,B,options)
   end
   toc
end