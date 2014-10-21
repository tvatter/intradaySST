function [s, param] = get_fff(vol, m, K)
 
    n = length(vol);
   
    % Set up predictors matrix
    X = NaN(n,1+2*K);
    X(:,1) = ones(n,1);
    
    time = repmat(((1:m)/m)',n/m,1);

    for j = 1:K
       X(:,[j+1 j+K+1]) = [cos(2*pi*j*time) sin(2*pi*j*time)];
    end
    
    % Compute OLS estimate
    param = (X'*X)\(X'*vol);
    s = X*param;
    
end