function b=rollregress(x,y,m)
    % b = estimated parameters

    [nr,nc]=size(x);
    x=[ones(nr,1) x];
    nc=nc+1;
    p=m+1:nr+1;q=1:nr-m+1;

    % get the rolling sum of y'*x
    sxy=[zeros(1,nc); cumsum(x.*y(:,ones(nc,1)),1)]; sxy=sxy(p,:)-sxy(q,:);
    % get the rolling sum of x'*x
    % --- also this loop is not bad, because typically nc is small
    sx2=NaN(nc,nr-m+1,nc);
    for j=1:nc
        sx2r=[zeros(1,nc); cumsum(x.*x(:,j*ones(nc,1)),1)];
        sx2r=sx2r(p,:)-sx2r(q,:);
        sx2(j,:,:)=sx2r;
    end

    % --- solve linear system
    b = MultiSolver(permute(sx2,[3 1 2]), sxy')';

end
