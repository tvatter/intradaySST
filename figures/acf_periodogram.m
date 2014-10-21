function [] = acf_periodogram(ret, name, path, retlim, vollim, Plim, alim)

    mu = mean(ret(:,2));
    vol = log((ret(:,2)-mu).^2);
    
    L = length(ret);
    Fs = round(1/(ret(2,1)-ret(1,1)));
    NFFT = 2^nextpow2(L); 
    f = Fs/2*linspace(0,1,NFFT/2+1);

    V = fft(vol,NFFT)/L;
    P = 2*abs(V(1:NFFT/2+1));
    [a, l] = autocorr(vol, 5*288);


    n1 = find(cumsum(f > 5));
    n2 = find(cumsum(f > 1));
    n3 = 1;
    n4 = n3+5*Fs-2;

%     retlim = [min(ret(n3:n4,2)) max(ret(n3:n4,2))];
%     vollim = [min(vol(n3:n4)) max(vol(n3:n4))];
%     Plim = [min(P(2:n1(1))) max(P(2:n1(1)))];
%     alim = [min(a(2:end)) max(a(2:end))];
%     
    ee = (retlim(end)-retlim(1))/5;
    rtick = [(retlim(1)+ee/2):ee:(retlim(end)-ee/2)];    
    ee = (vollim(end)-vollim(1))/5;
    vtick = [(vollim(1)+ee):ee:(vollim(end)-ee)];
    ee = (alim(end)-alim(1))/6;
    atick = [(alim(1)+ee):ee:(alim(end)-ee)];
    
    xtick = unique(round(ret(n3:n4,1)))';
    xlabels = datestr(xtick, 'ddd mm-dd');

    scrsz = get(0,'ScreenSize');
    fig = figure(1);
    set(fig,'position',scrsz);
    plot(ret(n3:n4,1), ret(n3:n4,2), '-k')
    axis tight
    title(name, 'fontsize', 50)
    ylabel('Return', 'fontsize', 40)
    %xlabel('date', 'fontsize', 40)
    set(gca, 'ylim', retlim)
    set(gca, 'ytick', rtick)
    set(gca, 'xtick', xtick)
    set(gca, 'xticklabel', xlabels)
    set(gca, 'fontsize', 40)
    export_fig(strcat(path,'/',name,'_oneweek_return.pdf'), '-transparent') 

    scrsz = get(0,'ScreenSize');
    fig = figure(2);
    set(fig,'position',scrsz);
    plot(ret(n3:n4,1), vol(n3:n4), '-k')
    title(name, 'fontsize', 50)
    axis tight
    ylabel('Log-volatility', 'fontsize', 40)
    %xlabel('date', 'fontsize', 40)
    set(gca, 'ylim', vollim)
    set(gca, 'ytick', vtick)
    set(gca, 'xtick', xtick)
    set(gca, 'xticklabel', xlabels)
    set(gca, 'fontsize', 40)
    export_fig(strcat(path,'/',name,'_oneweek_logvol.pdf'), '-transparent') 

    scrsz = get(0,'ScreenSize');
    fig = figure(3);
    set(fig,'position',scrsz);
    plot(l(2:end)/288, a(2:end), '-k')
    %vline(1:5, '--k')
    title(name, 'fontsize', 50)
    axis tight
    set(gca, 'ytick', atick)
    set(gca, 'ylim', alim)
    set(gca,'XTick',0:5)
    xlabel('Lag (day)', 'fontsize', 40)
    ylabel('Autocorrelation', 'fontsize', 40)
    set(gca, 'fontsize', 40)
    export_fig(strcat(path,'/',name,'_acf.pdf'), '-transparent') 

    scrsz = get(0,'ScreenSize');
    fig = figure(4);
    set(fig,'position',scrsz);
    semilogy(f(2:n1(1)), P(2:n1(1)), '-k')
    title(name, 'fontsize', 50)
    axis tight
    set(gca, 'ylim', Plim)
    xlabel('Frequency (1/day)', 'fontsize', 40)
    ylabel('Power spectrum', 'fontsize', 40)
    set(gca, 'fontsize', 40)
    export_fig(strcat(path,'/',name,'_spectrum.pdf'), '-transparent') 

    close all
end
