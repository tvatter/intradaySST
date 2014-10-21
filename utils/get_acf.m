function [a1, a2, a3, l] = get_acf(vol,T,s,l)

    [a1, ~] = autocorr(vol, l);
    [a2, ~] = autocorr(vol-T, l);
    [a3, l] = autocorr(vol-T-s, l);

end