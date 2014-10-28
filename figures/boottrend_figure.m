function [] = boottrend_figure(pair, path)

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
     
   eval(['load temp/Tboot_',nn,'.mat']);
   eval(['Tb = Tboot_',nn,';']);
   eval(['clear Tboot_',nn,'']);   

   [Tci,Tbias] = get_bootnorm(exp(T)*exp(-paramfff(1)),exp(Tb)*exp(-paramfff(1)),0.05);
   Tc = exp(T)*exp(-paramfff(1)) - Tbias; 

   week = 74;
   nweeks = 8;
   n1 = 1+week*5*288;
   n2 = n1+nweeks*5*288;  
   
   rr = ret(n1:n2);
   days = unique(datenum(datestr(rr,'dd-mm-yyyy'),'dd-mm-yyyy'));
   tmp = arrayfun(@(x) strcmp(datestr(x,'ddd'),'Mon'), days);
   days = days(tmp);
   xx = NaN(1,length(days));
   for k = 1:length(days)
       [~,xx(k)] = min(abs(rr-days(k)));
   end
     
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
   legend([l h1 h2],{'exp(T)','RV','BV'})
   axis tight
   set(gca,'xtick',xx)
   set(gca, 'xticklabel', datestr(rr(xx), 'mm/dd'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Trend', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_trend.pdf'),'-transparent') 
   close all
end

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
