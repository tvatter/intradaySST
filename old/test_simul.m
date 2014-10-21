clear all
close all

%rng(1);
%randn(1)

addpath(genpath('SST'))
addpath(genpath('utils'))
addpath(genpath('mfetoolbox'))

pair = 'EURUSD';
options = get_sstoptions();
n = options.fs*150;
B = 2;

eval(['load data/ret_',pair,'.mat']);
eval(['ret = ret_',pair,';']);
eval(['clear ret_',pair]);

eval(['load data/b_',pair,'.mat']);
eval(['b = b_',pair,';']);
eval(['clear b_',pair]);

eval(['load data/T_',pair,'.mat']);
eval(['T = T_',pair,';']);
eval(['clear T_',pair]);

eval(['load data/s_',pair,'.mat']);
eval(['s = s_',pair,';']);
eval(['clear s_',pair]);

eval(['load data/res_',pair,'.mat']);
eval(['res = res_',pair,';']);
eval(['clear res_',pair]);

vol = get_logvol(ret);
[a1, a2, a3, ~] = get_acf(vol,T,s,5*options.fs);
epsilon = ret(:,2).*exp((-T-s)/2);

f = @(x) -gedloglik(epsilon,0,exp(x(1)),1+exp(x(2)));
[param1]=fminunc(f,[log(var(epsilon)),0]);
param1(1) = exp(param1(1));
param1(2) = 1+exp(param1(2));
[param2, ~, h2] = tarch(epsilon,1,0,1,'GED');
[param3, ~, h3] = eGarch(epsilon,1,1,1,'GED');
T = T(1:n);
s = s(1:n);

lambda = [1/options.fs, 1/(5*options.fs)];
sdj = [4,10];
nj = length(lambda)*length(sdj);
[X,Y] = ndgrid(lambda,sdj);
paramj = [reshape(X,nj,1,1),reshape(Y,nj,1,1)];

subplot(2,1,1)
plot(autocorr(abs(epsilon./sqrt(h2)),options.fs*5))
hold on
plot(autocorr(abs(epsilon./sqrt(h3)),options.fs*5), '-r')
hold off

subplot(2,1,2)
plot(h2(1:options.fs*5))
hold on
plot(h3(1:options.fs*5), '-r')
hold off

Bres1 = sqrt(param1(1))*gedrnd(param1(2),n,B);
Bres2 = reshape(tarch_simulate(n*B,param2,1,0,1,'GED'),n,B);
Bres3 = reshape(egarch_simulate(n*B,param3,1,1,1,'GED'),n,B);

q = NaN(n,nj,B);
k = NaN(n,nj,B);
for j = 1:nj
    q(:,j,:) = binornd(1,paramj(j,1),n,B);
    k(:,j,:) = paramj(j,2)*normrnd(0,1,n,B);
end

Bout1 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);
Bout2 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);
Bout3 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);

for i = 1:B
    
   [Bout1(:,1,i,1), ~, Bout1(:,2:5,i,1),Bout1(:,6:9,i,1)] = get_sstrecon(T1+s1+log(abs(Bres1(:,i))), options);
   [Bout2(:,1,i,1), ~, Bout2(:,2:5,i,1),Bout2(:,6:9,i,1)] = get_sstrecon(T2+s2+log(abs(Bres2(:,i))), options);
   [Bout3(:,1,i,1), ~, Bout3(:,2:5,i,1),Bout3(:,6:9,i,1)] = get_sstrecon(T3+s3+log(abs(Bres3(:,i))), options); 
   
   for j = 1:nj       
       [Bout1(:,1,i,1+j), ~, Bout1(:,2:5,i,1+j),Bout1(:,6:9,i,1+j)] = get_sstrecon(T1+s1+log(abs(Bres1(:,i)+q(:,j,i).*k(:,j,i))), options);
       [Bout2(:,1,i,1+j), ~, Bout2(:,2:5,i,1+j),Bout2(:,6:9,i,1+j)] = get_sstrecon(T2+s2+log(abs(Bres2(:,i)+q(:,j,i).*k(:,j,i))), options);
       [Bout3(:,1,i,1+j), ~, Bout3(:,2:5,i,1+j),Bout3(:,6:9,i,1+j)] = get_sstrecon(T3+s3+log(abs(Bres3(:,i)+q(:,j,i).*k(:,j,i))), options); 
   end
end

eval(['save out', num2str(seed),'.mat Bout1']);
eval(['save out', num2str(seed),'.mat Bout2 -append']);
eval(['save out', num2str(seed),'.mat Bout3 -append']);
eval(['save out', num2str(seed),'.mat Bout4 -append']);