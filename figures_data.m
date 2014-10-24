clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

ask = read_price('data/USDCHF_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/USDCHF_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p1 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/EURUSD_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/EURUSD_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p2 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/GBPUSD_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/GBPUSD_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p3 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/USDJPY_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/USDJPY_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p4 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ret1 = get_return(p1);
ret2 = get_return(p2);
ret3 = get_return(p3);
ret3(:,2) = -ret3(:,2);
ret4 = get_return(p4);
ret4(:,2) = -ret4(:,2);

retlim = [-5 5]*10^(-3);
vollim = [-35 -10];
Plim = [10^(-4) 10^2];
alim = [-0.1 0.2];
acf_periodogram(ret1, 'CHFUSD', 'pdf', retlim, vollim, Plim, alim)
acf_periodogram(ret2, 'EURUSD', 'pdf', retlim, vollim, Plim, alim)
acf_periodogram(ret3, 'GBPUSD', 'pdf', retlim, vollim, Plim, alim)
acf_periodogram(ret4, 'JPYUSD', 'pdf', retlim, vollim, Plim, alim)

sst_figure(ret1, 'CHFUSD', 'pdf')
sst_figure(ret2, 'EURUSD', 'pdf')
sst_figure(ret3, 'GBPUSD', 'pdf')
sst_figure(ret4, 'JPYUSD', 'pdf')


