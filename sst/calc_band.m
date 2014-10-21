% called by synchrosqueezing.m and finalreport.m

eval(['tmpc = rslt.c',num2str(qq), ';']);

    if strcmp(sst.TFRtype,'CWT') & ~sst.TFR.linear
        Z1 = -floor(log2(curv.range*curv.iff)) + floor(sst.TFR.nvoice);
        Z2 = -floor(log2(curv.range*curv.iff)) + floor(sst.TFR.nvoice);
    else
        Z1 = ceil(sst.TFR.FWHM/sst.TFR.alpha)+2;	%% 0.1 Hz up
        Z2 = ceil(sst.TFR.FWHM/sst.TFR.alpha)+2;	%% 0.1 Hz down
        %Z2 = ceil((1+sst.TFR.FWHM)./(alpha*tmpc)*2);
        %Z1 = Z2;
    end
    
    tmpc1 = tmpc - Z1;
    tmpc2 = tmpc + Z2;

    %eval(['tmpc1 = rslt.c',num2str(qq),'-Z1;']);
    %eval(['tmpc2 = rslt.c',num2str(qq),'+Z2;']);
    if min(tmpc1) < 1; Z1 = Z1 + min(tmpc1) - 1; end
    if max(tmpc2) > round((sst.TFR.MAXFREQ-sst.TFR.MINFREQ)/sst.TFR.alpha); Z2 = Z2 - (max(tmpc2) - round((sst.TFR.MAXFREQ-sst.TFR.MINFREQ)/sst.TFR.alpha)); end


