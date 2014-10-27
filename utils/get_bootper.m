function ci = get_bootper(bstat,alpha)
% percentile bootstrap CI
 
pct1 = 100*alpha/2;
pct2 = 100-pct1;
lower = prctile(bstat,pct1,2); 
upper = prctile(bstat,pct2,2);

% return
ci =[lower,upper];
end % bootper() 