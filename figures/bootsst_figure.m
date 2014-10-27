function [] = bootsst_figure(pair, path, options)

   nn = pair;
   eval(['load temp/ret_',nn,'.mat']);
   eval(['ret = ret_',nn,';']);
   eval(['clear ret_',nn]);
   
   eval(['load temp/fff_',nn,'.mat']);
   eval(['fff = fff_',nn,';']);
   eval(['clear fff_',nn]);
   
   eval(['load temp/paramfff_',nn,'.mat']);
   eval(['paramfff = paramfff_',nn,';']);
   eval(['clear paramfff_',nn]);
   
   eval(['load temp/s_',nn,'.mat']);
   eval(['s = s_',nn,';']);
   eval(['clear s_',nn]);

   K = options.season.sst.ncomp;
   m = options.fs;
   n = length(fff);
 
   for jj = 1:K
       disp(num2str(jj))
        eval(['load temp/am',num2str(jj),'boot_',nn,'.mat']);
        eval(['am',num2str(jj),'b = am',num2str(jj),'boot_',nn,';']);
        eval(['clear am',num2str(jj),'boot_',nn,'']); 
        eval(['load temp/ph',num2str(jj),'boot_',nn,'.mat']);
        eval(['ph',num2str(jj),'b = ph',num2str(jj),'boot_',nn,';']);
        eval(['clear ph',num2str(jj),'boot_',nn,'']);
        eval(['s',num2str(jj),'b = am',num2str(jj),'b.*cos(ph',num2str(jj),'b);']); 
        eval(['clear ph',num2str(jj),'b']);
        eval(['clear am',num2str(jj),'b']);
   end 

   sb = s1b;
   %clear s1b
   for jj = 2:K
      eval(['sb = sb+s',num2str(jj),'b;']); 
      %eval(['clear sb',num2str(jj),'b']);
   end
    
   [sci,sbias] = get_bootnorm(s,sb,0.05);
   sc = s-sbias; 

   week = 1;
   nweeks = 2;
   n1 = 1+week*5*288;
   n2 = n1+nweeks*5*288/2;  
   
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
   erl = sc(n1:n2)-sci(n1:n2,1);
   eru = sci(n1:n2,2)-sc(n1:n2);     
   boundedline(1:(n2-n1+1), sc(n1:n2), [erl,eru], '-k');
   hold on
   l = plot(1:(n2-n1+1), sc(n1:n2),  '-k','linewidth',2);
   h = plot(1:(n2-n1+1), fff(n1:n2)-paramfff(1),  '-r','linewidth',2);
   legend([l h],{'SST','FFF'})
   axis tight
   set(gca,'ylim',[-1.5 1.5])
   set(gca,'ytick',-1:0.5:1)
   set(gca,'xtick',xx)
   set(gca, 'xticklabel', datestr(rr(xx), 'mm/dd'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Seasonality', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_season.pdf'),'-transparent') 
   close all
end
