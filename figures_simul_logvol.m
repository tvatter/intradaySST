clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

alpha = 0.1; % standard value for financial data
beta = 0.82; % standard value for financial data
omega = (1-alpha-beta); % normalization to have var(h_n w_n) = E(h_n^2 w_n^2) = 1

pj = 1/288; % jump probability (on jump a day on average)
sj = 4; % jump standard deviation (conditional on a jump occuring)

n = round(logspace(1,4,100));
m = 10;
resM = NaN(m, length(n));
resS = NaN(m, length(n));
resMj = NaN(m, length(n));
resSj = NaN(m, length(n));
for i =1:m
    z1 = tarch_simulate(n(end), [omega alpha beta] ,1, 0, 1)'; % simulate a GARCH(1,1)
    z2 = z1+sj*randn(1,n(end)).*binornd(1,pj,1,n(end)); % add jumps
    for j = 1:length(n)
       resM(i,j) = mean(log(z1(1:n(j)).^2)); 
       resS(i,j) = var(log(z1(1:n(j)).^2)); 
       resMj(i,j) = mean(log(z2(1:n(j)).^2)); 
       resSj(i,j) = var(log(z2(1:n(j)).^2)); 
    end
end

% Display "results"
cc=hsv(m);
figure; 
subplot(2,2,1)
hold on;
for i =1:m
    plot(n,resM(i,:),'color',cc(i,:))
end
set(gca,'XScale','log')
title('Mean (without jumps)')
hold off;
subplot(2,2,2)
hold on;
for i =1:m
    plot(n,resS(i,:),'color',cc(i,:))
end
set(gca,'XScale','log')
title('Variance (without jumps)')
hold off;
subplot(2,2,3)
hold on;
for i =1:m
    plot(n,resMj(i,:),'color',cc(i,:))
end
set(gca,'XScale','log')
title('Mean (with jumps)')
hold off;
subplot(2,2,4)
hold on;
for i =1:m
    plot(n,resSj(i,:),'color',cc(i,:))
end
set(gca,'XScale','log')
title('Variance (with jumps)')
hold off;