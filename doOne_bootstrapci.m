seed = str2num(seed);
B = str2num(B);

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

disp([pair,',seed',num2str(seed)])

nn=pair;
rng('default')
rng(seed);

eval(['options=get_sstoptions();']);
eval(['load temp/b_',nn,'.mat']);
eval(['load temp/T_',nn,'.mat']);
eval(['n=length(T_',nn,');']);
eval(['load temp/s_',nn,'.mat']);
eval(['load temp/res_',nn,'.mat']);
eval(['Bres_',nn,'=block_bootstrap(res_',nn,',B,ceil(b_',nn,'(2)));']);
eval(['Bout_',nn,'=NaN(n,1+2*options.season.sst.ncomp,B);']);

for i=1:B
    disp(['->iteration',num2str(i)])
    eval(['[Bout_',nn,'(:,1,i),~,Bout_',nn,'(:,2:5,i),Bout_',nn,'(:,6:9,i)]=get_sstrecon(T_',nn,'+s_',nn,'+Bres_',nn,'(:,i),options);']);
end

eval(['save temp/bootstrapci/bootstrapci_',nn,'_',num2str(seed),'_',num2str(B),'.matBout_',nn]);

if(strcmp(batchjob,'TRUE'))
    quit;
end
