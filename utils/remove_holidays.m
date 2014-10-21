function out = remove_holidays(data)

    H = holidays('jan 1 2010', 'jan 1 2014');
    H = [H', arrayfun(@(Year) datenum(Year,1,2),2010:2014)];
    H = [H, arrayfun(@(Year) datenum(Year,12,31),2010:2013)];
    H = [H, arrayfun(@(Year) datenum(Year,12,24),2010:2013)];
    H = [H, arrayfun(@(Year) datenum(Year,12,26),2010:2013)];
    H = sort(H);
    %datestr(H,'ddd dd/mm/yy')
    
    Weekend = [1 0 0 0 0 0 1];
    sel = isbusday(data(:,1),H,Weekend);
    out = data(sel,:);
  
end