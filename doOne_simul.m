seed = str2num(seed);
B = str2num(B);
n = str2num(n);
nn = pair;

disp('->simulation setup')
tic
addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

% sst options
options = get_sstoptions();
n = options.fs*n;

% jump params
lambda = [1/options.fs, 1/(5*options.fs)];
sdj = [4,10];
nj = length(lambda)*length(sdj);
[X,Y] = ndgrid(lambda,sdj);
paramj = [reshape(X,nj,1,1),reshape(Y,nj,1,1)];

% load other parameters
eval(['load temp/T_',nn,'.mat']);
eval(['T = T_',nn,'(1:n);']);
eval(['clear T_',nn]);
    
if(method == 'sst')
    eval(['load temp/s_',nn,'.mat']);
    eval(['s = s_',nn,'(1:n);']);
    eval(['clear s_',nn]);
elseif(method == 'fff')
    eval(['load temp/fff_',nn,'.mat']);
    eval(['load temp/paramfff_',nn,'.mat']);
    eval(['s = fff_',nn,'(1:n)-paramfff_',nn,'(1);']);
    eval(['clear fff_',nn]);
end

eval(['load temp/param1_',nn,'.mat']);
eval(['param1 = param1_',nn,';']);
eval(['clear param1_',nn]);

eval(['load temp/param2_',nn,'.mat']);
eval(['param2 = param2_',nn,';']);
eval(['clear param2_',nn]);

eval(['load temp/param3_',nn,'.mat']);
eval(['param3 = param3_',nn,';']);
eval(['clear param3_',nn]);

% Simulate GED, EGARCH, GARCH random variables
Bres1 = sqrt(param1(1))*gedrnd(param1(2),n,B);
Bres2 = reshape(egarch_simulate(n*B,param2,1,1,1,'GED'),n,B);
Bres3 = reshape(tarch_simulate(n*B,param3,1,0,1,'GED'),n,B);

% Simulate jumps
q = NaN(n,nj,B);
k = NaN(n,nj,B);
for j = 1:nj
    q(:,j,:) = binornd(1,paramj(j,1),n,B);
    k(:,j,:) = paramj(j,2)*normrnd(0,1,n,B);
end

% Preallocate memory
Bout1 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);
Bout2 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);
Bout3 = NaN(n,1+2*options.season.sst.ncomp,B,1+nj);
toc

% Estimation
for i = 1:B    
   disp(['->iteration ',num2str(i)])
   tic
   [Bout1(:,1,i,1), ~, Bout1(:,2:5,i,1),Bout1(:,6:9,i,1)] = get_sstrecon(T+s+log(abs(Bres1(:,i))), options);
   [Bout2(:,1,i,1), ~, Bout2(:,2:5,i,1),Bout2(:,6:9,i,1)] = get_sstrecon(T+s+log(abs(Bres2(:,i))), options);
   [Bout3(:,1,i,1), ~, Bout3(:,2:5,i,1),Bout3(:,6:9,i,1)] = get_sstrecon(T+s+log(abs(Bres3(:,i))), options); 

   for j = 1:nj   
       toc
       [Bout1(:,1,i,1+j), ~, Bout1(:,2:5,i,1+j),Bout1(:,6:9,i,1+j)] = get_sstrecon(T+s+log(abs(Bres1(:,i)+q(:,j,i).*k(:,j,i))), options);
       [Bout2(:,1,i,1+j), ~, Bout2(:,2:5,i,1+j),Bout2(:,6:9,i,1+j)] = get_sstrecon(T+s+log(abs(Bres2(:,i)+q(:,j,i).*k(:,j,i))), options);
       [Bout3(:,1,i,1+j), ~, Bout3(:,2:5,i,1+j),Bout3(:,6:9,i,1+j)] = get_sstrecon(T+s+log(abs(Bres3(:,i)+q(:,j,i).*k(:,j,i))), options); 
   end
   toc
end

% Save results
eval(['save temp/simul/simul_',method,'_',nn,num2str(n/options.fs),'_',num2str(seed),'_',num2str(B),'.mat Bout1']);
eval(['save temp/simul/simul_',method,'_',nn,num2str(n/options.fs),'_',num2str(seed),'_',num2str(B),'.mat Bout2 -append']);
eval(['save temp/simul/simul_',method,'_',nn,num2str(n/options.fs),'_',num2str(seed),'_',num2str(B),'.mat Bout3 -append']);

if(strcmp(batchjob,'TRUE'))
    quit;
end
