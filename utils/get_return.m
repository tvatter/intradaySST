function ret = get_return(data)
    
    ret = NaN(length(data)-1,2);
    ret(:,1) = data(2:end,1);
    ret(:,2) = diff(data(:,2));

    dst = tag_dst(ret(:,1));
    ret(dst==0,1) = ret(dst==0,1) - 1/24;

    ret(:,1) = ret(:,1)+3/24;%-5/(24*60);
    ret = remove_holidays(ret); 
    ret(:,1) = ret(:,1)-3/24;%+5/(24*60);
    
    %m = 288;
    %yy = ret(:,1);
    %test = reshape(yy,m,length(yy)/m)';
    %datestr(test(:,1));
    %datestr(test(:,m));

end