function [T, s, ams, phs] = get_sstrecon(vol, options)

    T = get_ssttrend(vol, options);
    temp = vol - T;
    [s, ams, phs] = get_sstseason(temp-T, options);

end