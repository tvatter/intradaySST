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
n = 288000;
L = length(pair);
K = options.season.sst.ncomp;

for l = 1:L
   nn = pair(l,:);
   eval(['load temp/T_',nn,'.mat']);
   eval(['T = T_',nn,';']);
   eval(['clear T_',nn]);
    
   eval(['load temp/Tboot_',nn,'.mat']);
   eval(['Tb = Tboot_',nn,';']);
   eval(['clear Tboot_',nn,'']);   
   Tm = mean(Tb,2);
   Tv = var(Tb')';
   Tq = quantile(Tb',[.025 .975])';
   
   n1 = 50*288;
   n2 = 55*288;
   
   plot(T(n1:n2), '-b')
   hold on
   plot(Tm(n1:n2), '-r')
   plot(Tq(n1:n2,:), '-c')
   plot(Tm(n1:n2)*[1 1]+1.96*sqrt(Tv(n1:n2))*[-1 1], '-g')
   %plot(T(n1:n2)-Tm(n1:n2))
   legend('actual', 'mean','quantile','normquantile')
   
   
end





