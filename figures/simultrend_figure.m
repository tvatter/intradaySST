function [] = simultrend_figure(pair, path)

   nn = pair;
   eval(['load temp/ret_',nn,'.mat']);
   eval(['ret = ret_',nn,';']);
   eval(['clear ret_',nn]);
  
   eval(['load temp/rv_',nn,'.mat']);
   eval(['rv = rv_',nn,';']);
   eval(['clear rv_',nn]);
   
   eval(['load temp/bv_',nn,'.mat']);
   eval(['bv = bv_',nn,';']);
   eval(['clear bv_',nn]);
   
   eval(['load temp/paramfff_',nn,'.mat']);
   eval(['paramfff = paramfff_',nn,';']);
   eval(['clear paramfff_',nn]);
    
   eval(['load temp/T_',nn,'.mat']);
   eval(['T = T_',nn,';']);
   eval(['clear T_',nn]);
   keyboard()
   for k = 1:3
        eval(['load temp/Tsimul_',nn,'_sst',num2str(k),'.mat']);
        %eval(['load temp/Tsimul_',nn,'fff',num2str(k),'.mat']);
        eval(['Tb',num2str(k),' = Tsimul_',nn,'_sst',num2str(k),';']);
        eval(['clear Tsimul_',nn,'_sst',num2str(k)]);  
        %eval(['clear Tsimul_',nn,'fff',num2str(k)]); 
        
        [Tci,Tbias] = get_bootnorm(T,Tb,0.05);
   end
   
   
   Tc = exp(T)*exp(-paramfff(1)) - Tbias; 

   n = length(ret);
   d1 = datenum(2011,07,04);
   d2 = datenum(2011,09,02);
   %week = 76;
   %nweeks = 8;
   %n1 = week*5*288;
   %n2 = n1+nweeks*5*288;  
   
   n1 = find(ret(:,1) >= d1, 1, 'first');
   n2 = find(ret(:,1) <= d2, 1, 'last');
   rr = ret(n1:n2,1);   
   mm = arrayfun(@(Year) datenum(Year,1,1,21,0,0),2010:2013);
   for k = 2:12
       mm = [mm,arrayfun(@(Year) datenum(Year,k,1,21,0,0),2010:2013)];
   end
   mm = sort(mm);
   mm = mm(find(mm <= rr(1),1,'last'):find(mm <= rr(end),1,'last'));
   xx = NaN(1,length(mm));
   for k = 1:length(mm)
       [~,xx(k)] = min(abs(rr-mm(k)));
   end
   yy = [2,4,6,8].*10^-4;
   
%    days = unique(datenum(datestr(rr,'dd-mm-yyyy'),'dd-mm-yyyy'));
%    tmp = arrayfun(@(x) strcmp(datestr(x,'ddd'),'Mon'), days);
%    days = days(tmp);
%    xx = NaN(1,length(days));
%    for k = 1:length(days)
%        [~,xx(k)] = min(abs(rr-days(k)));
%    end
   
   scrsz = get(0,'ScreenSize');
   fig = figure(1);
   set(fig,'position',scrsz);
   erl = Tc(n1:n2)-Tci(n1:n2,1);
   eru = Tci(n1:n2,2)-Tc(n1:n2);     
   boundedline(1:(n2-n1+1), Tc(n1:n2), [erl,eru], '-k');
   hold on
   l = plot(1:(n2-n1+1), Tc(n1:n2),  '-k','linewidth',2);
   h1 = plot(1:(n2-n1+1), rv(n1:n2),  '-b','linewidth',2);
   h2 = plot(1:(n2-n1+1), bv(n1:n2),  '-r','linewidth',2);
   %plot(n1:n2, log(bv(n1:n2))+paramfff(1),  '-b')
   legend([l h1 h2],{'exp(T)','RV','BV'},'linewidth',2)
   axis tight
   set(gca,'ylim',[0 1e-3])
   set(gca,'ytick',yy)
   set(gca,'xtick',xx)
   set(gca, 'xticklabel', datestr(rr(xx), 'mmm yyyy'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Trend', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_trendcrisis.pdf'),'-transparent')
   
   [~, I] = arrayfun(@(Year) min(abs(datenum(Year,1,3)-ret(:,1))), 2010:2013);
   xtick = [I', ret(I,1)]; 
   
   scrsz = get(0,'ScreenSize');
   fig = figure(2);
   set(fig,'position',scrsz);
   h1 = plot(1:n, rv,  '-b','linewidth',2);
   hold on
   h2 = plot(1:n, bv,  '-r','linewidth',2);
   l = plot(1:n, Tc,  '-k','linewidth',2);
   %plot(n1:n2, log(bv(n1:n2))+paramfff(1),  '-b')
   legend([l h1 h2],{'exp(T)','RV','BV'},'linewidth',2)
   axis tight
   set(gca,'ylim',[0 1e-3])
   set(gca,'ytick',yy)
   set(gca,'xtick',I)
   set(gca, 'xticklabel', datestr(ret(I,1), 'yyyy'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Trend', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_trend.pdf'),'-transparent')
   close all
end


%    ci1 = get_bootnorm(T,Tb,0.05);
%    ci2 = get_bootper(Tb,0.05);
%    ci3 = get_bootcper(T,Tb,0.05);
%    
%    jbtest(Tb(50*288,:))
%    lillietest(Tb(50*288,:))
%    adtest(Tb(50*288,:))
%    chi2gof(Tb(50*288,:))

%    n1 = 1+10*288;
%    n2 = n1+20*288;
%    
%    subplot(2,1,1)
%    plot(T(n1:n2), '-b')
%    hold on
%    plot(Tc(n1:n2), '-c')
%    plot(Tm(n1:n2), '-r')
%    plot(ci1(n1:n2,:), '-y')
%    %plot(ci2(n1:n2,:), '-g')
%    plot(ci3(n1:n2,:), '-m')
%    legend('actual', 'corrected','mean','norm1','norm2','cper1','cper2')
%    %legend('actual', 'mean','norm1','norm2','per1','per2','cper1','cper2')
%    hold off
%    subplot(2,1,2)
%    plot(bias(n1:n2))

%    m = round(1/(ret(2,1)-ret(1,1)));
%    vol = get_logvol(ret);
%    mu = mean(ret(:,2));
%    vol2 = log(((ret(:,2)-mu).^2./bv));   

%    erl = Tc(n1:n2)-Tci(n1:n2,1);
%    eru = Tci(n1:n2,2)-Tc(n1:n2);     
%    [l,p] = boundedline(1:(n2-n1+1), Tc(n1:n2), [erl,eru], '-k');
%    hold on
%    h = plot(1:(n2-n1+1), log(rv(n1:n2))+paramfff(1),  '-r');
%    %plot(n1:n2, log(bv(n1:n2))+paramfff(1),  '-b')
%    legend([l h],{'T','log(RV)'})
%    axis tight
%    set(gca,'xtick',xx)
%    set(gca, 'xticklabel', datestr(rr(xx), 'mm-dd-yyyy'))
%    hold off

%    plot(vol(n1:n2), '-k')   
%    hold on   
%    plot(vol2(n1:n2), '-k')
%    plot(T(n1:n2),  'Color',[0 0 0]+0.6, 'Linewidth', 3)
%    plot(T(n1:n2)+s(n1:n2),  'Color',[0 0 0]+0.6, 'Linewidth', 3)
%    plot(paramfff(1),  'Color',[0 0 0]+0.6, 'Linewidth', 3)
%    plot(fff(n1:n2),  'Color',[0 0 0]+0.6, 'Linewidth', 3)
%    
%    plot(vol(n1:n2), '-k')   
%    hold on   
%    plot(vol2(n1:n2), '-k')
%    plot(T(n1:n2),  '-r', 'Linewidth', 3)
%    plot(T(n1:n2)+s(n1:n2),  '-r', 'Linewidth', 3)
%    plot(paramfff(1),  '-r', 'Linewidth', 3)
%    plot(fff(n1:n2),  '-r', 'Linewidth', 3)
%    plot(repmat(paramfff(1),n2-n1),  '-r', 'Linewidth', 3)
%    
%    subplot(2,1,1)
%    plot(ret(n1:n2,2))
%    subplot(2,1,2)
%    
%    plot(vol(1:288*5)-T(1:288*5),'-k')
%    plot(vol2(1:288*5)-paramfff(1),  'Color',[0 0 0]+0.8)
%    
%    
%    legend('logvol', 'log(r^2/bv)','logvol-T', 'log(r^2/bv)-s0','T')
%    title(nn)
%    axis tight
