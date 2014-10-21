clear all
close all

addpath(genpath('utils'))

ask = read_price('data/EURUSD_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/EURUSD_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p1 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/GBPUSD_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/GBPUSD_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p2 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/USDCHF_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/USDCHF_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p3 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ask = read_price('data/USDJPY_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv');
bid = read_price('data/USDJPY_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv');
p4 = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];

ret1 = get_return(p1);
ret2 = get_return(p2);
ret3 = get_return(p3);
ret4 = get_return(p4);

[rv1, bv1] = get_rvbv(ret1);
[rv2, bv2] = get_rvbv(ret2);
[rv3, bv3] = get_rvbv(ret3);
[rv4, bv4] = get_rvbv(ret4);

ret1 = get_return(p1);
ret = ret1;

[rv, bv] = get_rvbv(ret);
mu = mean(ret(:,2));
vol = (ret(:,2)-mu).^2;
m = 288;


semilogy(sqrt(m)*vol)
hold on
semilogy(rv, '-r')
semilogy(bv, '-g')

vol = log(vol./[repmat(bv(1),m-1,1);bv/sqrt(m)]);

[s1, shape] = estimate_shape(vol, m);
K = 5;
[s2, param] = estimate_FFF(vol, m, K);

a = autocorr(vol, 5*288);
a1 = autocorr(vol-s1, 5*288);
a2 = autocorr(vol-s2, 5*288);


subplot(2,2,1)
plot(ret(:,1),ret(:,2))
axis tight
xtick = [ret(1,1), arrayfun(@(Year) datenum(Year,1,1),2011:2014)];
set(gca,'Xtick',xtick);
set(gca,'Xticklabel',datestr(xtick, 'yyyy'));

subplot(2,2,2)
plot(ret(:,1),vol)
axis tight
xtick = [ret(1,1), arrayfun(@(Year) datenum(Year,1,1),2011:2014)];
set(gca,'Xtick',xtick);
set(gca,'Xticklabel',datestr(xtick, 'yyyy'));

subplot(2,2,3)
plot(ret(1:288,1),s1(1:288))
vline(datenum('03-Jan-2010 21:00', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 06:00', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 07:00', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 12:30', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 14:00', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 20:00', 'dd-mmm-yyyy HH:MM'))
vline(datenum('04-Jan-2010 00:00', 'dd-mmm-yyyy HH:MM'))
hold on
plot(ret(1:288,1),s2(1:288), '-g')
hold off
datetick('x', 'HH:MM')
axis tight

subplot(2,2,4)
plot(a)
hold on
plot(a1, '-g')
plot(a2, '-r')