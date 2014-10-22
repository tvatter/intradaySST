clear all
close all

addpath(genpath('mfetoolbox'))
addpath(genpath('mex'))
addpath(genpath('sst'))
addpath(genpath('utils'))
display_results = 0;

pair = ['USDCHF';'EURUSD';'GBPUSD';'USDJPY'];
l = size(pair);
options = get_sstoptions();

for j = 1:l(1)
    nn = pair(j,:);
    disp(['Read and prepare data: ',nn])
    tic
    eval(['ask = read_price(''data/',nn,'_UTC_5 Mins_Ask_2009.12.31_2014.01.01.csv'');']);
    eval(['bid = read_price(''data/',nn,'_UTC_5 Mins_Bid_2009.12.31_2014.01.01.csv'');']);
    eval(['price = [ask(:,1),(log(bid(:,2))+log(ask(:,2)))/2];']);
    if(strcmp(nn(1:3),'USD'))
        nn(1:3) = nn(4:6);
        nn(4:6) = 'USD';
        pair(j,:) = nn;
        eval(['ret_',nn,' = get_return(price);']);
        eval(['ret_',nn,'(:,2) = -ret_',nn,'(:,2);']);
    else
       eval(['ret_',nn,' = get_return(price);']); 
    end
    eval(['vol_',nn,' = get_logvol(ret_',nn,');']); 
    eval(['save temp/ret_',nn,'.mat ret_',nn]);
    toc
end

clear ask bid price

m = options.fs;
for j = 1:l(1)
    nn = pair(j,:);
    disp(['RV, BV and FFF: ',nn])
    tic
    eval(['[rv_',nn,', bv_',nn,'] = get_rvbv(ret_',nn,');']);
    eval(['mu = mean(ret_',nn,'(:,2));']);
    eval(['vol2_',nn,' = log(((ret_',nn,'(:,2)-mu).^2)./[repmat(bv_',nn,'(1),m-1,1);bv_',nn,']);']);
    eval(['[fff_',nn,', paramfff_',nn,'] = get_fff(vol2_',nn,', m, options.season.sst.ncomp);']);
   
    eval(['save temp/rv_',nn,'.mat rv_',nn]);
    eval(['save temp/bv_',nn,'.mat bv_',nn]);
    eval(['save temp/fff_',nn,'.mat fff_',nn]);
    eval(['save temp/paramfff_',nn,'.mat paramfff_',nn]);
    toc
end

for j = 1:l(1)
    nn = pair(j,:);
    disp(['SST with reconstruction: ',nn])
    tic
    eval(['[T_',nn,', s_',nn,', am_',nn,', ph_',nn,'] = get_sstrecon(vol_',nn,', options);']);
    toc
end

for j = 1:l(1)
    nn = pair(j,:);
    disp(['ACF, residuals and optimal block length ',nn])
    tic
    eval(['[a1_',nn, ', a2_',nn, ', a3_', nn,'] = get_acf(vol_',nn,',T_',nn,',s_',nn,',5*options.fs);']);
    eval(['res_', nn,' = vol_',nn,' - T_',nn,' - s_',nn,';']);
    eval(['b_', nn,' = opt_block_length(res_',nn,');']);
    eval(['save temp/b_',nn,'.mat b_',nn]);
    eval(['save temp/T_',nn,'.mat T_',nn]);
    eval(['save temp/s_',nn,'.mat s_',nn]);
    eval(['save temp/res_',nn,'.mat res_',nn]);
    toc
end

if display_results == 1
    m = l(1);
    figure(1); 
    for i =1:m
        subplot(2,2,i)
        eval(['tt = T_',pair(i,:),';']);
        plot(tt);
        title(pair(i,:));
        axis tight
    end


    figure(2);
    for i =1:m
        for j = 1:m
            subplot(m,m,m*(i-1)+j)
            eval(['tt = am_',pair(i,:),';']);
            plot(tt(:,i));       
            if(i == 1)
                title(pair(j,:)) 
            end
            if(j == 1)
            ylabel(['Comp' num2str(j)])
            end
            axis tight
        end
    end

    cc=hsv(3);
    figure(3);
    for i =1:m
        subplot(m,1,i)
        hold on
        for j = 1:3
            eval(['tt = a',num2str(j),'_',pair(i,:),';']);
            plot([2:5*options.fs]/options.fs,tt(2:end), 'color',cc(j,:));       
        end
        title(pair(i,:)) 
        axis tight
    end
    keyboard()
    figure(4);
    for i =1:m
        nn = pair(i,:);
        subplot(m,2,2*(i-1)+1)
        eval(['plot(s_',nn,'(1:288*5))']);
        hold on
        eval(['plot(fff_',nn,'(1:288*5)-paramfff_',nn,'(1), ''-r'')']);
        legend('sst','fff')
        title(pair(i,:)) 
        axis tight
        
        subplot(m,2,2*i)
        eval(['plot(vol_',nn,'(1:288*5))']);   
        hold on
        eval(['plot(vol2_',nn,'(1:288*5), ''-g'')']);
        eval(['plot(vol_',nn,'(1:288*5)-T_',nn,'(1:288*5),''-c'')']);
        eval(['plot(vol2_',nn,'(1:288*5)-paramfff_',nn,'(1), ''-y'')']);
        eval(['plot(T_',nn,'(1:288*5), ''-r'')']);
        legend('logvol', 'log(r^2/bv)','logvol-T', 'log(r^2/bv)-s0','T')
        title(pair(i,:)) 
        axis tight
    end
end