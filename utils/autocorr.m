function [a l] = autocorr(x, maxlag)

    %# autocorrelation
    nfft = 2^nextpow2(2*length(x)-1);
    xx = fft(x-mean(x),nfft);
    r = ifft( xx .* conj(xx) );

    %# keep values corresponding to lags 1:maxlag
    a = r(2:maxlag+1)/r(1);
    l = [1:maxlag];

end

