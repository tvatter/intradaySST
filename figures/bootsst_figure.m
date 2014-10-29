function [] = bootsst_figure(pair, path, options)

   nn = pair;
   eval(['load temp/ret_',nn,'.mat']);
   eval(['ret = ret_',nn,';']);
   eval(['clear ret_',nn]);
   
   eval(['load temp/bv_',nn,'.mat']);
   eval(['bv = bv_',nn,';']);
   eval(['clear bv_',nn]);
   
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
   X = NaN(n,2*K);
   time = repmat(((1:m)/m)',n/m,1);
 
   for jj = 1:K
       %disp(num2str(jj))
        eval(['load temp/am',num2str(jj),'boot_',nn,'.mat']);
        eval(['am',num2str(jj),'b = am',num2str(jj),'boot_',nn,';']);
        eval(['clear am',num2str(jj),'boot_',nn,'']); 
        eval(['load temp/ph',num2str(jj),'boot_',nn,'.mat']);
        eval(['ph',num2str(jj),'b = ph',num2str(jj),'boot_',nn,';']);
        eval(['clear ph',num2str(jj),'boot_',nn,'']);
        eval(['s',num2str(jj),'b = am',num2str(jj),'b.*cos(ph',num2str(jj),'b);']); 
        eval(['clear ph',num2str(jj),'b']);
        eval(['clear am',num2str(jj),'b']);
        X(:,[jj jj+K]) = [cos(2*pi*jj*time) sin(2*pi*jj*time)];
   end 

   sb = s1b;
   %clear s1b
   for jj = 2:K
      eval(['sb = sb+s',num2str(jj),'b;']); 
      %eval(['clear sb',num2str(jj),'b']);
   end
    
   [sci,sbias] = get_bootnorm(s,sb,0.05);
   sc = s-sbias; 
   
   %keyboard()
   wsize = 4*5*m;
   mu = mean(ret(:,2));
   vol = log(((ret(:,2)-mu).^2./bv));
   paramrfff=rollregress(X,vol,wsize);  
   rfff = sum(X(round(wsize/2):n-round(wsize/2),:).*paramrfff(:,2:end),2);

%    week = 1;
%    nweeks = 1;
%    n1 = 1+(week-1)*5*288;
%    n2 = n1+nweeks*5*288-1;  
%    rr = ret(n1:n2,1);
%    sel = unique(datenum(datestr(rr,'yyyy-mm-dd'),'yyyy-mm-dd'));
%    xx = NaN(length(sel)-1,1);
%    for k = 1:length(sel)-1
%        [~,xx(k)] = min(abs(rr-sel(k+1)));
%    end

   dd = datenum(2011,07,10,21,0,0);
   n1 = find(ret(:,1) >= dd, 1, 'first');
   n2 = n1+288*5-1;
   rr = ret(n1:n2,1);
   sel = unique(datenum(datestr(rr,'yyyy-mm-dd'),'yyyy-mm-dd'));
   xx = NaN(length(sel)-1,1);
   for k = 1:length(sel)-1
       [~,xx(k)] = min(abs(rr-sel(k+1)));
   end
  
   scrsz = get(0,'ScreenSize');
   fig = figure(1);
   set(fig,'position',scrsz);
   erl = sc(n1:n2)-sci(n1:n2,1);
   eru = sci(n1:n2,2)-sc(n1:n2);     
   boundedline(1:(n2-n1+1), sc(n1:n2), [erl,eru], '-k');
   hold on
   h2 = plot(1:(n2-n1+1), fff(n1:n2)-paramfff(1),  '-b','linewidth',2);
   l = plot(1:(n2-n1+1), sc(n1:n2),  '-k','linewidth',2);
   h1 = plot(1:(n2-n1+1), rfff((n1-round(wsize/2)):(n2-round(wsize/2))),  '-r','linewidth',2);
   legend([l h1 h2],{'SST','rFFF','FFF'}','linewidth',2)
   axis tight
   set(gca,'ylim',[-2 2])
   set(gca,'ytick',-1.5:0.5:1.5)
   set(gca,'xtick',xx)
   set(gca, 'xticklabel', datestr(rr(xx), 'yy-mm-dd'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Seasonality', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_season1.pdf'),'-transparent') 
   
   dd = datenum(2011,08,07,21,0,0);
   n1 = find(ret(:,1) >= dd, 1, 'first');
   n2 = n1+288*5-1;
   rr = ret(n1:n2,1);
   sel = unique(datenum(datestr(rr,'yyyy-mm-dd'),'yyyy-mm-dd'));
   xx = NaN(length(sel)-1,1);
   for k = 1:length(sel)-1
       [~,xx(k)] = min(abs(rr-sel(k+1)));
   end
     
   scrsz = get(0,'ScreenSize');
   fig = figure(2);
   set(fig,'position',scrsz);
   erl = sc(n1:n2)-sci(n1:n2,1);
   eru = sci(n1:n2,2)-sc(n1:n2);     
   boundedline(1:(n2-n1+1), sc(n1:n2), [erl,eru], '-k');
   hold on
   h2 = plot(1:(n2-n1+1), fff(n1:n2)-paramfff(1),  '-b','linewidth',2);
   l = plot(1:(n2-n1+1), sc(n1:n2),  '-k','linewidth',2);
   h1 = plot(1:(n2-n1+1), rfff((n1-round(wsize/2)):(n2-round(wsize/2))),  '-r','linewidth',2);
   legend([l h1 h2],{'SST','rFFF','FFF'}','linewidth',2)
   axis tight
   set(gca,'ylim',[-2 2])
   set(gca,'ytick',-1.5:0.5:1.5)
   set(gca,'xtick',xx)
   set(gca, 'xticklabel', datestr(rr(xx), 'yy-mm-dd'))
   set(gca, 'fontsize', 40)
   title(pair, 'fontsize', 50)
   ylabel('Seasonality', 'fontsize', 40)
   export_fig(strcat(path,'/',pair,'_season2.pdf'),'-transparent') 
   close all
end
