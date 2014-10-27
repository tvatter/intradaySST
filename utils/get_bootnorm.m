function [ci,bias] = get_bootnorm(stat,bstat,alpha)
% normal approximation interval
% A.C. Davison and D.V. Hinkley (1996), p198-200

se = std(bstat,0,2);   % standard deviation estimate
bias = mean(bsxfun(@minus,bstat,stat),2);
za = norminv(alpha/2);   % normal confidence point
lower = stat - bias + se*za; % lower bound
upper = stat - bias - se*za;  % upper bound

% return
ci = [lower,upper];        
end   % bootnorm() 