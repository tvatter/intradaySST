function [s, ams, phs] = get_SSTcomp(recon, options)

    am = abs(recon);
    [n m] = size(am);
    ph = NaN(n,m);
    phs = ph;
    ams = ph;

    for i = 1:m
        ph(:,i) = phase(recon(:,i));
        phs(:,i) = smooth(ph(:,i),options.sst.ph.smoothspan,options.sst.ph.smoothtype);
        ams(:,i) = smooth(am(:,i),options.sst.am.smoothspan,options.sst.ph.smoothtype);
    end
    
    s = sum(ams.*cos(ph),2);
    
end