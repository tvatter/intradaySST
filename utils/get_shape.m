function [s, shape] = get_shape(vol, m)

    n = length(vol);
    V = reshape(vol,m,n/m)';
    C = num2cell(V,1);
    shape = cellfun(@mean,C);  
    s = repmat(shape',n/m,1); 

end