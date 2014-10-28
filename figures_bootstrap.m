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

for l = 1:4
   nn = pair(l,:);
   boottrend_figure(nn, 'pdf')
   bootam_figure(nn, 'pdf',options) 
   bootsst_figure(nn, 'pdf',options) 
end

%    ci1 = get_bootnorm(T,Tb,0.05);
%    ci2 = get_bootper(Tb,0.05);
%    ci3 = get_bootcper(T,Tb,0.05);
%    
%    jbtest(Tb(50*288,:))
%    lillietest(Tb(50*288,:))
%    adtest(Tb(50*288,:))
%    chi2gof(Tb(50*288,:))

%    n1 = 1+10*288;
%    n2 = n1+20*288;
%    
%    subplot(2,1,1)
%    plot(T(n1:n2), '-b')
%    hold on
%    plot(Tc(n1:n2), '-c')
%    plot(Tm(n1:n2), '-r')
%    plot(ci1(n1:n2,:), '-y')
%    %plot(ci2(n1:n2,:), '-g')
%    plot(ci3(n1:n2,:), '-m')
%    legend('actual', 'corrected','mean','norm1','norm2','cper1','cper2')
%    %legend('actual', 'mean','norm1','norm2','per1','per2','cper1','cper2')
%    hold off
%    subplot(2,1,2)
%    plot(bias(n1:n2))


