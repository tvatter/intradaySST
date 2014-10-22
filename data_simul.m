clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))

pair = ['CHFUSD';'EURUSD';'GBPUSD';'JPYUSD'];
l = size(pair);
options = get_sstoptions();

for j = 1:l(1)
    nn = pair(j,:);
    disp(['Read and prepare data: ',nn])
    tic
    
    % load data
    eval(['load temp/ret_',nn,'.mat']);
    eval(['ret = ret_',nn,';']);
    eval(['clear ret_',nn]);

    eval(['load temp/T_',nn,'.mat']);
    eval(['T = T_',nn,';']);
    eval(['clear T_',nn]);

    eval(['load temp/s_',nn,'.mat']);
    eval(['s = s_',nn,';']);
    eval(['clear s_',nn]);

    % get deseasonalized residuals
    z = ret(:,2).*exp((-T-s)/2);

    % estimate iid and garch-like models
    f = @(x) -gedloglik(z,0,exp(x(1)),1+exp(x(2)));
    [param1]=fminunc(f,[log(var(z)),0]);
    eval(['param1_',nn,' = [exp(param1(1)), 1+exp(param1(2))];']);
    eval(['[param2_',nn,',~,h2_',nn,'] = eGarch(z,1,1,1,''GED'');']);
    eval(['[param3_',nn,',~,h3_',nn,'] = tarch(z,1,0,1,''GED'');']);

    % save results    
    eval(['z_',nn,' = z;']);
    eval(['save temp/z_',nn,'.mat z_',nn]);
    eval(['save temp/param1_',nn,'.mat param1_',nn]);
    eval(['save temp/param2_',nn,'.mat param2_',nn]);
    eval(['save temp/param3_',nn,'.mat param3_',nn]);
    toc
end

if display_results == 1
    m = l(1);
    figure(1); 
    for i =1:m
        nn = pair(i,:);
        subplot(2,4,2*(i-1)+1)
        eval(['plot(autocorr(abs(z_',nn,'./sqrt(h2_',nn,')),options.fs*5))']);
        hold on
        eval(['plot(autocorr(abs(z_',nn,'./sqrt(h2_',nn,')),options.fs*5),''-r'')']);
        title([pair(i,:),' acf|z/h|']);
        hold off

        subplot(2,4,2*i)
        eval(['plot(sqrt(h2_',nn,'(1:options.fs*5)))']);
        hold on
        eval(['plot(sqrt(h3_',nn,'(1:options.fs*5)),''-r'')']);
        hold off
        title([pair(i,:),' h']);
        axis tight
    end
end