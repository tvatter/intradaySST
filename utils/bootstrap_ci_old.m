myrunnumber = str2num(myrunnumber);
seed = str2num(seed);
rng('default')
rng(seed);

addpath(genpath('../sst'))
addpath(genpath('../utils'))
addpath(genpath('../mfetoolbox'))

pair = ['CHFUSD';'EURUSD';'GBPUSD';'JPYUSD'];
l = size(pair);
eval(['options = get_sstoptions();']);
B = 10;

for j = 1:l(1)
    nn = pair(j,:);
    eval(['load ../data/b_',nn,'.mat']);
    eval(['load ../data/T_',nn,'.mat']);
    if(j == 1)
       eval(['n = length(T_',nn,');']);
    end
    eval(['load ../data/s_',nn,'.mat']);
    eval(['load ../data/res_',nn,'.mat']);
    eval(['Bres_',nn,' = block_bootstrap(res_',nn,',B,ceil(b_',nn,'(2)));']);
    eval(['Bout_',nn,' = NaN(n,1+2*options.season.sst.ncomp,B);']);
end

for i = 1:B
    disp(['Iteration ', num2str(i)])
   for j = 1:l(1)
       nn = pair(j,:);
       disp(nn)
       eval(['[Bout_',nn,'(:,1,i), ~, Bout_',nn,'(:,2:5,i),Bout_',nn,'(:,6:9,i)] = get_sstrecon(T_',nn,'+s_',nn,'+Bres_',nn,'(:,i), options);']);  
   end
   disp('-----')
end

for j = 1:l(1)
   nn = pair(j,:);
   if(j == 1)
       eval(['save ../data/bootstrap_CI', num2str(seed),'.mat Bout_',nn]);
   else
       eval(['save ../data/bootstrap_CI', num2str(seed),'.mat Bout_',nn,' -append']);
   end
end

quit;


