function T = get_ssttrend(vol, options)

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

    % Load options and run synchrosqueezing
    sst = options.trend.sst;
    sst.x = data;
    sst.t = [1:length(data)]/options.fs;
    rslt = synchrosqueezing(sst);
    
    % Compute and smooth trend
    T = data - 2*rslt.alpha*real(sum(rslt.stfd(:,round(0.95/rslt.alpha):end),2));
    T = smooth(T,options.trend.smoothspan,options.trend.smoothtype);
    
    % Remove padding
    if(mod(length(vol),2) == 1)       
       T = T(dd+2:end-dd);
    else
       T = T(dd+1:end-dd);
    end

    
end