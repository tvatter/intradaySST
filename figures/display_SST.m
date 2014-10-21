function [] = display_SST(sst,rslt,n,pad, name,xtick)

    if(mod(n,2) == 1)
        fig.image = abs(rslt.stfd(pad+2:end-pad,:)); 
        fig.t 	= sst.t(pad+2:end-pad);
    else
        fig.image = abs(rslt.stfd(pad+1:end-pad,:));
        fig.t 	= sst.t(pad+1:end-pad);
    end 

    fig.freq 	= rslt.freq;
    fig.alpha 	= rslt.alpha;
    fig.TFRtype = sst.TFRtype;
    fig.TFR     = sst.TFR;
    fig.display = sst.display;
    fig.figtype = 'SST';
    
    [nn, nscale] = size(fig.image);
    fig.image   = fig.image(:,fliplr(1:1:nscale));
    fig.freq    = fig.freq(fliplr(1:1:nscale));

    %xtic = [1:nn];
    xtic = [1:nn]*(fig.t(2)-fig.t(1));
    ytic = 1:nscale; 

    QQ = quantile(fig.image(:), fig.display.quantile);
    fig.image(find(fig.image>QQ)) = QQ; clear QQ;

    imagesc(xtic, ytic, fig.image'); axis('ij');

    if strcmp(fig.TFRtype, 'CWT') & fig.TFR.linear
        set(gca,'YTick',[1:nscale/((range(fig.freq)+fig.alpha)/0.5):nscale nscale]);
    elseif strcmp(fig.TFRtype, 'CWT') & ~fig.TFR.linear
    	set(gca,'YTick',1:2*fig.TFR.nvoice:nscale);
    elseif strcmp(fig.TFRtype, 'STFT')
        set(gca,'Ytick',[1+nscale/((range(fig.freq)+fig.alpha)/0.5):nscale/((range(fig.freq)+fig.alpha)):nscale]);
    end

    set(gca,'YTickLabel',round(fig.freq(get(gca,'YTick'))*10)/10);
    set(gca,'fontsize',fig.display.fontsize);

    set(gca,'Xtick', xtic(xtick(:,1)))
    set(gca,'Xticklabel', datestr(xtick(:,2), 'yyyy'))
    ylabel('Frequency (1/day)');
    title(name, 'fontsize',fig.display.fontsize+10);

    str = sprintf('colormap(1-%s(256))',fig.display.color);
    eval(str)
    
    if sst.display.reconband & sst.reconstruction    
        hold on; 
        for qq = 1 : sst.extractcurv.no 
            calc_band;  
            eval(['temp1 = nscale-rslt.c',num2str(qq),'+1+Z1;']);
            eval(['temp2 = nscale-rslt.c',num2str(qq),'+1-Z2;']);
            
            if(mod(n,2) == 1)
                plot(xtic,temp1(pad+2:end-pad), 'r--','linewidth',0.5);
                plot(xtic,temp2(pad+2:end-pad), 'r--','linewidth',0.5);
            else
                plot(xtic,temp1(pad+1:end-pad), 'r--','linewidth',0.5);
                plot(xtic,temp2(pad+1:end-pad), 'r--','linewidth',0.5);
            end 
        end
     end

end