function [] = sst_figure(ret, name, path)

    mu = mean(ret(:,2));
    vol = log((ret(:,2)-mu).^2);
    
    n = length(ret);
    fs = round(1/(ret(2,1)-ret(1,1)));
    pad = 50*fs;

    sst = setup_param;
    sst.usemex = 1;
    sst.TFRtype = 'STFT';
    sst.freqrange.high = 4.5;
    sst.freqrange.low = 0.5;
    sst.TFR.MAXFREQ = sst.freqrange.high;
    sst.TFR.MINFREQ = sst.freqrange.low;
    sst.TFR.alpha = 0.01;
    sst.TFR.FWHM = 0.05;
    sst.reconstruction = 1;
    sst.extractcurv.no = 4;
    sst.extractcurv.range = 1+2*(ceil(sst.TFR.FWHM/sst.TFR.alpha)+2);
    sst.extraction = 0;
    sst.extractcurv.iff1 = 1;
    sst.extractcurv.iff2 = 2;
    sst.extractcurv.iff3 = 3;
    sst.extractcurv.iff4 = 4;
    sst.display.all = 0;
    sst.display.fontsize = 20;
    sst.display.reconband = 1;
    
    sst.t = [1:(n+2*pad)]/fs; 
    sst.x = [fliplr(vol(1:pad)); vol; fliplr(vol(end-pad+1:end))];
    rslt = synchrosqueezing(sst);
    
    [~, I] = arrayfun(@(Year) min(abs(datenum(Year,1,3)-ret(:,1))), 2010:2013);
    xtick = [I', ret(I,1)];   
    
    scrsz = get(0,'ScreenSize');
    fig = figure(1);
    set(fig,'position',scrsz);
    display_SST(sst,rslt,n,pad,name,xtick)
    export_fig(strcat(path,'/',name,'_sst.jpg'), '-transparent', '-r300') 
    close all
end
