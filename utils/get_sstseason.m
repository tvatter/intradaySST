function [s, ams, phs] = get_sstseason(vol, options)

   % Prepare left and right padding
    dd = options.pad;
    b1 = vol(1:dd);
    b2 = vol(end-dd+1:end);

    % Correct for odd data
    if(mod(length(vol),2) == 1)        
        data = [1e-12;b1;vol;b2];
    else
       data = [b1;vol;b2];
    end

    % Load options and prepare SST
    ncomp = options.season.sst.ncomp;
    season = NaN(length(data),ncomp);
    sst = options.season.sst;
    sst.x = data;
    sst.t = [1:length(data)]/options.fs;

    % Run SST separately for each component
    for i = 1:ncomp

        sst.freqrange.high = i + sst.compband;
        sst.freqrange.low = i - sst.compband;
        sst.TFR.MAXFREQ = sst.freqrange.high;
        sst.TFR.MINFREQ = sst.freqrange.low;
        sst.extractcurv.iff1 = i;

        rslt = synchrosqueezing(sst);
        season(:,i) = rslt.recon1;

    end
    
    am = abs(season);
    ph = NaN(length(data),ncomp);
    phs = ph;
    ams = ph;

    for i = 1:ncomp
        ph(:,i) = unwrap(angle(season(:,i)));
        phs(:,i) = smooth(ph(:,i),options.season.ph.smoothspan,options.season.smoothtype);
        ams(:,i) = smooth(am(:,i),options.season.am.smoothspan,options.season.smoothtype);
    end

    s = sum(ams.*cos(ph),2);
    
    % Remove padding
    if(mod(length(vol),2) == 1)       
       ams = ams(dd+2:end-dd,:);
       phs = phs(dd+2:end-dd,:);
       s = s(dd+2:end-dd);
    else
       ams = ams(dd+1:end-dd,:);
       phs = phs(dd+1:end-dd,:);
       s = s(dd+1:end-dd);
    end
    
end