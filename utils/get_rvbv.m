function [rv, bv] = get_rvbv(ret)

    n = length(ret);
    m = round(1/(ret(2,1)-ret(1,1)));
    
    mu = mean(ret(:,2));
    vol = (ret(:,2)-mu).^2;
    ii = 2:m;
    bv = NaN(n-m+1,1);
    rv = NaN(n-m+1,1);
    bias = (m-1)/m ;
    
    rv = m*smooth(ret(:,2).^2,m);
    bv = abs(ret(1:(end-1),2)).*abs(ret(2:end,2));
    bv = smooth(bv,m)*pi/2*m/bias;
    bv = [bv;bv(end)];
%     for i = 1:(n-m+1)
%     	temp = (pi/2) * abs(ret(ii-1,2))'*abs(ret(ii,2));
%         bv(i) = temp / bias;
%         rv(i) = sum(ret([ii(1)-1,ii],2).^2);
%         ii = ii + 1;
%     end
end