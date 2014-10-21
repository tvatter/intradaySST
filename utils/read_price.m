function [data] = read_price(filename)

    fid=fopen(filename);
    C=textscan(fid,'%s %*f %*f %*f %f %f','delimiter',',', 'Headerlines', 1);
    fclose(fid);

    data = NaN(length(C{2}),3);
    data(:,2) = C{2};
    data(:,3) = C{3};
    
    times = cell2mat(C{1});
    data(:,1) = datenum(times(:,1:19),'yyyy.mm.dd HH:MM:SS'); %.FFF to add millisecond precision

end