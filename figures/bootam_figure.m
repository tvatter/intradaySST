function [] = bootam_figure(pair, path, options)

   nn = pair;
   eval(['load temp/ret_',nn,'.mat']);
   eval(['ret = ret_',nn,';']);
   eval(['clear ret_',nn]);
   
   eval(['load temp/bv_',nn,'.mat']);
   eval(['bv = bv_',nn,';']);
   eval(['clear bv_',nn]);
   
   eval(['load temp/paramfff_',nn,'.mat']);
   eval(['paramfff = paramfff_',nn,';']);
   eval(['clear paramfff_',nn]);
   
   eval(['load temp/fff_',nn,'.mat']);
   eval(['fff = fff_',nn,';']);
   eval(['clear fff_',nn]);
   
   eval(['load temp/am_',nn,'.mat']);
   eval(['am = am_',nn,';']);
   eval(['clear am_',nn]);

   K = options.season.sst.ncomp;
   m = options.fs;
   n = length(fff);
   X = NaN(n,2*K);
   time = repmat(((1:m)/m)',n/m,1);
   
   for jj = 1:K
        eval(['load temp/am',num2str(jj),'boot_',nn,'.mat']);
        eval(['am',num2str(jj),'b = am',num2str(jj),'boot_',nn,';']);
        eval(['clear am',num2str(jj),'boot_',nn,'']);             
        %eval(['am',num2str(jj),'b = am',num2str(jj),'b(1:287424,:);']);        
        eval(['[am',num2str(jj),'ci,am',num2str(jj),'bias] = get_bootnorm(am(:,',num2str(jj),'),am',num2str(jj),'b,0.05);']);
        eval(['am',num2str(jj),'c = am(:,',num2str(jj),')-am',num2str(jj),'bias;']);        
        X(:,[jj jj+K]) = [cos(2*pi*jj*time) sin(2*pi*jj*time)]; 
   end
   
   wsize = 4*5*m;
   mu = mean(ret(:,2));
   vol = log(((ret(:,2)-mu).^2./bv));
   paramfffr=rollregress(X,vol,wsize);  
   amfff = NaN(length(paramfffr),K);  
   amfff2 = NaN(1,K); 
   for jj = 1:K
        amfff(:,jj) = sqrt(sum(paramfffr(:,[jj+1 jj+5]).^2,2));
        amfff2(jj) = sqrt(sum(paramfff([jj+1 jj+5]).^2));
   end

   [~, I] = arrayfun(@(Year) min(abs(datenum(Year,1,3)-ret(:,1))), 2010:2013);
   xtick = [I', ret(I,1)];   

   for jj = 1:K
       scrsz = get(0,'ScreenSize');
       fig = figure(jj);
       set(fig,'position',scrsz);
       eval(['erl = am',num2str(jj),'c-am',num2str(jj),'ci(:,1);']);
       eval(['eru = am',num2str(jj),'ci(:,2)-am',num2str(jj),'c;']);    
       eval(['boundedline(1:n, am',num2str(jj),'c, [erl,eru], ''-k'');']);
       hold on
       h2 = plot(round(wsize/2):n-round(wsize/2), amfff(:,jj),  '-r','linewidth',2);
       eval(['h1 = plot([1 n],repmat(amfff2(',num2str(jj),'),2,1),''--k'',''linewidth'',2);']);
       eval(['l = plot(1:n, am',num2str(jj),'c,  ''-k'',''linewidth'',2);']);
       legend([l h1 h2],{'SST','FFF','rFFF'})
       axis tight
       set(gca,'ylim',[0 1.5])
       set(gca,'ytick',0.2:0.4:1.4)
       set(gca,'xtick',I)
       set(gca, 'xticklabel', datestr(ret(I,1), 'yyyy'))
       set(gca, 'fontsize', 40)
       title(pair, 'fontsize', 50)
       ylabel(['Amplitude ', num2str(jj)], 'fontsize', 40)
       export_fig(strcat(path,'/',pair,'_am',num2str(jj),'.pdf'),'-transparent')
   end
   close all
end
