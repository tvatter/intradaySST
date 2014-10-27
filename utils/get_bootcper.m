function ci = get_bootcper(stat,bstat,alpha)
% corrected percentile bootstrap CI
% B. Efron (1982), "The jackknife, the bootstrap and other resampling
% plans", SIAM.
 
% stat is transformed to a normal random variable z0.
% z0 = invnormCDF[ECDF(stat)]
z_0 = fz0(bstat,stat);
z_alpha = norminv(alpha/2); % normal confidence point
 
% transform z0 back using the invECDF[normCDF(2z0-za)] and
% invECDF[normCDF(2z0+za)] 
pct1 = 100*normcdf(2*z_0-z_alpha); 
pct2 = 100*normcdf(2*z_0+z_alpha);

% inverse ECDF
m = numel(stat);
lower = zeros(m,1);
upper = zeros(m,1);
for i=1:m
    lower(i) = prctile(bstat(i,:),pct2(i),2);
    upper(i) = prctile(bstat(i,:),pct1(i),2);
end

% return
ci = [lower,upper];
end % bootcper() 

% -------------------------
function z0=fz0(bstat,stat)
% Compute bias-correction constant z0
z0 = norminv(mean(bsxfun(@lt,bstat,stat),2) + mean(bsxfun(@eq,bstat,stat),2)/2);
end   % fz0()