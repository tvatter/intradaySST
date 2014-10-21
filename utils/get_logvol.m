function [vol] = get_logvol(ret)
    
    mu = mean(ret(:,2));
    vol = log((ret(:,2)-mu).^2);

end