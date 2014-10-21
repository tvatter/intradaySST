clear all
close all

addpath figures
addpath SST
addpath(genpath('utils'))
addpath(genpath('Econometrics'))

ask = read_price('data/EURUSD_5 Mins_Ask_2012.03.11_2012.11.03.csv');
bid = read_price('data/EURUSD_5 Mins_Bid_2012.03.11_2012.11.03.csv');
[n] = size(ask);
n = n(1) - 1;
fs = 288;

p = [ask(:,1),(log(ask(:,2))+log(ask(:,2)))/2];
[ret1, mm1] = compute_ret(p);
vol1 = log(ret1(:,2).^2);
Rv1 = smooth(vol1,fs);

ask = read_price('data/USDJPY_5 Mins_Ask_2012.03.11_2012.11.03.csv');
bid = read_price('data/USDJPY_5 Mins_Bid_2012.03.11_2012.11.03.csv');

p = [ask(:,1),(log(ask(:,2))+log(ask(:,2)))/2];
[ret2, mm2] = compute_ret(p);
vol2 = log(ret2(:,2).^2);
Rv2 = smooth(vol2,fs);


pad = 50*fs;
sst = setup_param;
sst.t = [1:(n+2*pad+1)]/fs;
sst.freqrange.high = 30;
sst.freqrange.low = 0;
sst.TFR.MAXFREQ = sst.freqrange.high;
sst.TFR.MINFREQ = sst.freqrange.low;
sst.usemex = 0;

sst.TFRtype = 'STFT';
sst.TFR.alpha = 0.1;
sst.TFR.FWHM = 0.5;
sst.reconstruction = 0;

sst.x = [flipud(vol1(1:pad)); vol1; flipud(vol1(end-pad:end))];
rslt = synchrosqueezing(sst);
T = vol1 - 2*rslt.alpha*real(sum(rslt.stfd(pad+1:end-pad-1,round(0.95/rslt.alpha):end),2));
T1 = smooth(T,fs);

sst.x = [flipud(vol2(1:pad)); vol2; flipud(vol2(end-pad:end))];
rslt = synchrosqueezing(sst);
T = vol2 - 2*rslt.alpha*real(sum(rslt.stfd(pad+1:end-pad-1,round(0.95/rslt.alpha):end),2));
T2 = smooth(T,fs);

sst.freqrange.high = 4.5;
sst.freqrange.low = 0.5;
sst.TFR.MAXFREQ = sst.freqrange.high;
sst.TFR.MINFREQ = sst.freqrange.low;
sst.TFR.alpha = 0.01;
sst.TFR.FWHM = 0.05;
sst.reconstruction = 1;
sst.extractcurv.no = 4;
sst.extractcurv.range = 1+2*(ceil(sst.TFR.FWHM/sst.TFR.alpha)+2);
sst.extraction = 0;
sst.extractcurv.iff1 = 1;
sst.extractcurv.iff2 = 2;
sst.extractcurv.iff3 = 3;
sst.extractcurv.iff4 = 4;

sst.display.fontsize = 20;
sst.display.reconband = 1;
sst.display.signal = 0;

vvol12 = vol1 - T1;
sst.x = [flipud(vvol12(1:pad)); vvol12; flipud(vvol12(end-pad:end))];
rslt = synchrosqueezing(sst);
recon1 = [rslt.recon1(pad+1:end-pad-1)' rslt.recon2(pad+1:end-pad-1)' rslt.recon3(pad+1:end-pad-1)' rslt.recon4(pad+1:end-pad-1)'];
display_SST(sst,rslt,n,pad,'EUR/USD')
close all
%export_fig('sst-eurusd.pdf', '-transparent') 

vvol22 = vol2 - T2;
sst.x = [flipud(vvol22(1:pad)); vvol22; flipud(vvol22(end-pad:end))];
rslt = synchrosqueezing(sst);
recon2 = [rslt.recon1(pad+1:end-pad-1)' rslt.recon2(pad+1:end-pad-1)' rslt.recon3(pad+1:end-pad-1)' rslt.recon4(pad+1:end-pad-1)'];
display_SST(sst,rslt,n,pad,'USD/JPY')
%export_fig('sst-usdjpy.pdf', '-transparent') 

% am1 = abs(recon1);
% am2 = abs(recon2);
% ams1 = NaN(size(recon1));
% ams2 = NaN(size(recon1));
ph1 = NaN(size(recon1));
ph2 = NaN(size(recon1));

for i = 1:4
    %ams1(:,i) = smooth(am1(:,i),5*fs);
    ph1(:,i) = -unwrap(angle(recon1(:,i)));
    %ams2(:,i) = smooth(am2(:,i),5*fs);
    ph2(:,i) = -unwrap(angle(recon2(:,i)));
end

load data/resboot.mat
am1 = Am;
qam1 = qAm;
T1 = T;
qT1 = qT;
vvol12 = vol1 - T1;

load data/resboot2.mat
am2 = Am;
qam2 = qAm;
T2 = T;
qT2 = qT;
vvol22 = vol2 - T2;

s13 = sum(am1.*cos(ph1),2);
s23 = sum(am2.*cos(ph2),2);

% Set up predictors matrix
K = 4;
time = [1:n]'/fs;
X = NaN(n,2*K);
for j = 1:K
  X(:,[j j+K]) = [cos(2*pi*j*time) sin(2*pi*j*time)];
end

% Weekly FFF
sel = [5*fs:5*fs:n+1];
vvol11 = vol1-Rv1;
b11 = NaN(n,2*K+1);
ff1 = NaN(n,K);
vvol21 = vol2-Rv2;
ff2 = NaN(n,K);
b12 = NaN(n,2*K+1);

[~, temp] = estimate_FFF(vvol11(1:sel(1)-1), [1:sel(1)-1]'/fs,4);
b11(1:sel(1)-1,:) = repmat(temp',5*fs-1,1);

[~, temp] = estimate_FFF(vvol21(1:sel(1)-1), [1:sel(1)-1]'/fs,4);
b21(1:sel(1)-1,:) = repmat(temp',5*fs-1,1);

for i = 1:(length(sel)-1)
    
    [~, temp] = estimate_FFF(vvol11(sel(i):sel(i+1)-1), [1:5*fs]'/fs,4);
    b11(sel(i):sel(i+1)-1,:) = repmat(temp',5*fs,1);
    
    [~, temp] = estimate_FFF(vvol21(sel(i):sel(i+1)-1), [1:5*fs]'/fs,4);
    b21(sel(i):sel(i+1)-1,:) = repmat(temp',5*fs,1);
     
end

for jj = 1:4
   ff1(:,jj) = sqrt(sum(b11(:,[jj+1 jj+5]).^2,2)); 
   ff2(:,jj) = sqrt(sum(b21(:,[jj+1 jj+5]).^2,2)); 
end

% s11 = b11(:,1) + sum(X.*b11(:,2:end),2);
% s21 = b21(:,1) + sum(X.*b21(:,2:end),2);

s11 = sum(X.*b11(:,2:end),2);
s21 = sum(X.*b21(:,2:end),2);
    
% Rolling FFF
wsize = 10*fs;
b12=rollregress(X,vvol11,wsize);
b22=rollregress(X,vvol21,wsize);

for jj = 1:4  
        rollfff1(:,jj) = sqrt(sum(b12(:,[jj+1 jj+5]).^2,2));
        rollfff2(:,jj) = sqrt(sum(b22(:,[jj+1 jj+5]).^2,2));
end

sel2 = round(wsize/2):n-round(wsize/2);
s12 = sum(X(sel2,:).*b12(:,2:end),2);
s22 = sum(X(sel2,:).*b22(:,2:end),2);
% s12 = b12(:,1) + sum(X(sel2,:).*b12(:,2:end),2);
% s22 = b22(:,1) + sum(X(sel2,:).*b22(:,2:end),2);

panel1

vvol1 = vol1-s13;
vvol2 = vol2-s23;

vsvol1 = vvol1-T1;
vsvol2 = vvol2-T2;

a11 = autocorr(vol1,5*fs);
a12 = autocorr(vvol1,5*fs);
a13 = autocorr(vsvol1,5*fs);

a21 = autocorr(vol2,5*fs);
a22 = autocorr(vvol2,5*fs);
a23 = autocorr(vsvol2,5*fs);

[temp1, ptemp1] = estimate_FFF(vvol11, [1:n]'/fs,4);
[temp2, ptemp2] = estimate_FFF(vvol21, [1:n]'/fs,4);

panel2