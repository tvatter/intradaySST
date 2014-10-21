clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

t = linspace(0,4,1000);
xi = sign(rand(1,1000)-0.5);
%xi(1:500) = xi(1000:-1:501);

noise = randn(1,1000);

x = cos(2*pi*(t.^(1.1)));
x1 = cos(2*pi*(t));
x1hat = fft(x1)./1000;
xhat = fft(x)./1000;
fhat = xhat.*xi;

g = x + noise;
ghat = fft(g)./1000;

y1 = x;
y1(501:1000)=0;
y = y1 + noise;
yhat=fft(y)./1000;

scrsz = get(0,'ScreenSize');
fig = figure(1)
set(fig,'position',scrsz);
%set(fig,'position',[0 0 scrsz(4) scrsz(4)]);
p = panel();
p.pack('v', {1/2 1/2});
p(1).pack(1,4);
p(2).pack(1,4);

y1lim = [-3 3];
y1tick = [-2:2:2];
y2lim = [10^-5 2*10^-1];
y2tick = [10^-4 10^-2];

p(1,1,1).select(); 
plot(t,x, '-k');
xlabel('Time (t)')
ylabel('Signal')
set(gca, 'Xtick', 1:4)
set(gca, 'Ylim', y1lim)
set(gca, 'Ytick', y1tick)

p(1,1,2).select(); 
plot(t,real(ifft(fhat*1000)), '-k');
xlabel('Time (t)')
set(gca, 'Xtick', 1:4)
set(gca, 'Ylim', y1lim)
set(gca, 'Ytick', y1tick)
set(gca, 'yticklabel', {[]})

p(1,1,3).select(); 
plot(t,g, '-k');
hold on
plot(t,x,'-r','LineWidth',2);
xlabel('Time (t)')
set(gca, 'Xtick', 1:4)
set(gca, 'Ylim', y1lim)
set(gca, 'Ytick', y1tick)
set(gca, 'yticklabel', {[]})

p(1,1,4).select(); 
plot(t,y, '-k');
hold on
plot(t,y1,'-r','LineWidth',2);
xlabel('Time (t)')
set(gca, 'Xtick', 1:4)
set(gca, 'Ylim', y1lim)
set(gca, 'Ytick', y1tick)
set(gca, 'yticklabel', {[]})

eta=[1/10:1/10:10];

p(2,1,1).select(); 
plot(eta,abs(xhat(2:101)).^2, '-k');
axis tight
xlabel('Frequency (1/t)')
ylabel('Spectrum')
set(gca, 'Ylim', y2lim)
set(gca, 'Ytick', y2tick)
set(gca, 'YScale', 'log')

p(2,1,2).select(); 
plot(eta,abs(fhat(2:101)).^2, '-k');
axis tight
xlabel('Frequency (1/t)')
set(gca, 'Ylim', y2lim)
set(gca, 'Ytick', y2tick)
set(gca, 'yticklabel', {[]})
set(gca, 'YScale', 'log')

p(2,1,3).select(); 
plot(eta,abs(ghat(2:101)).^2, '-k');
axis tight
xlabel('Frequency (1/t)')
set(gca, 'Ylim', y2lim)
set(gca, 'Ytick', y2tick)
set(gca, 'yticklabel', {[]})
set(gca, 'YScale', 'log')

p(2,1,4).select(); 
plot(eta,abs(yhat(2:101)).^2, '-k');
axis tight
xlabel('Frequency (1/t)')
set(gca, 'Ylim', y2lim)
set(gca, 'Ytick', y2tick)
set(gca, 'yticklabel', {[]})
set(gca, 'YScale', 'log')


p.de.margin = 4;
p.fontsize = 20;
p.marginleft = 22;
p(1).marginbottom = 20;
%p(2).marginleft = 15;
%p.margintop = 15;
p.marginbottom = 20;

export_fig -transparent figures/fourier.pdf