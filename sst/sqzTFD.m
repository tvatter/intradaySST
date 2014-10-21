function [stfd, freq, alpha] = sqzTFD(squeezing)
%
% Synchro- and -squeezing the time-frequency domain ver 0.2
% called by synchrosqueezing.m
%
% INPUT:
%   squeezing.tftype	= CWT or STFT
%   squeezing.tfd       = time frequency domain, CWT or STFT
%   squeezing.squeezing.w         = instantaneous freuquency information function
%   squeezing.TFR   = parameters used in continuous squeezing.wavelet transform
%   squeezing.stft      = parameters used in short time Fourier transform
%   squeezing.freqrange = the frequency range displayed in the time frequency plane
% (OPTIONS)
%   squeezing.debug      = debug message
%
% OUTPUT:
%
% DEPENDENCY:
%   squeezing.wavelab (included), Contsqueezing.wavelet.m
%
% by Hau-tieng squeezing.wu 2011-06-20 (hausqueezing.wu@math.princeton.edu)
% by Hau-tieng squeezing.wu 2012-03-03 (hausqueezing.wu@math.princeton.edu)
%


if squeezing.debug; fprintf('(DEBUG:synchrosqueezing) squeezing.working on SS...'); end

[n, nscale] = size(squeezing.tfd);


%=====================================================================
	%% CWT-based SST
if strcmp(squeezing.TFRtype, 'CWT')
    if squeezing.TFR.linear

        alpha = squeezing.TFR.alpha;
        nalpha = floor((squeezing.freqrange.high-squeezing.freqrange.low)./alpha);
        stfd = zeros(n,nalpha);
        freq = ([1:1:nalpha])*alpha+squeezing.freqrange.low;
        nfreq = length(freq);
	
	if squeezing.debug;
    	    fprintf(['linear freq resolution is ',num2str(alpha),'\n']);   
	end

    else	%% log scale

	nfreq = nscale;
        stfd = zeros(size(squeezing.tfd));
        freq = zeros(1, nfreq);
        freq(1) = squeezing.freqrange.low;;
        alpha = 2.^((log2(squeezing.freqrange.high/squeezing.freqrange.low))./(nscale-1));
        for k = 2: nscale; freq(k) = freq(k-1)*alpha; end

	if squeezing.debug;
    	    fprintf(['log2 freq resolution is ',num2str(alpha),'\n']);   
	end
	    %% (2^alpha)^{freq resolution} = 2;

    end
 
    if(~squeezing.usemex)

        for b = 1:n             %% Synchro-
            if squeezing.debug; if mod(b,floor(n/10))==0; fprintf('*'); end; end;

            for kscale = 1: nscale       %% -Squeezing

                qscale = squeezing.TFR.scale .* (2^(kscale/squeezing.TFR.nvoice));

            if squeezing.TFR.linear	%% linear scale

                    if (isfinite(squeezing.w(b, kscale)) && (squeezing.w(b, kscale)>0))
                        k = floor( ( squeezing.w(b,kscale)-squeezing.freqrange.low )./ alpha )+1;

                        if (isfinite(k) && (k > 0) && (k < nfreq-1))
                            ha = freq(k+1)-freq(k);
                            stfd(b,k) = stfd(b,k) + log(2)*squeezing.tfd(b,kscale)*sqrt(qscale)./ha/squeezing.TFR.nvoice;
                        end
                    end

            else  %% log scale

                    if (isfinite(squeezing.w(b, kscale)) && (squeezing.w(b, kscale)>0))
                        k = floor(( log2( squeezing.w(b,kscale)/squeezing.freqrange.low ) )./ log2(alpha))+1;
                        if (isfinite(k) && (k > 0) && (k < nfreq))
                ha = freq(k+1)-freq(k);
                            stfd(b,k) = stfd(b,k) + log(2)*squeezing.tfd(b,kscale)*sqrt(qscale)./ha/squeezing.TFR.nvoice;
                        end
                    end

            end
            end
            
        end

    else
        
        squeezing.w(~isfinite(squeezing.w))=1e9;
        stfd = sqzTFD_CWTlin(squeezing.w', freq, squeezing.tfd', n, nscale, nalpha, squeezing.TFR.scale, squeezing.TFR.nvoice, squeezing.freqrange.low, alpha)';

    end

end   




%=====================================================================
        %% STFT-based SST
if strcmp(squeezing.TFRtype, 'STFT')

    alpha = squeezing.TFR.alpha;
    nalpha = floor((squeezing.freqrange.high-squeezing.freqrange.low)./alpha);   
    stfd = zeros(n,nalpha);
    freq = ([1:1:nalpha])*alpha+squeezing.freqrange.low;

    if(~squeezing.usemex)

        for b = 1:n		%% Synchro-
            if squeezing.debug; if mod(b,floor(n/10))==0; fprintf('*'); end; end;

            for jj = 1:nscale		%% -Squeezing
                if isfinite(squeezing.w(b,jj))
                    k = floor((squeezing.w(b,jj)-squeezing.freqrange.low)./alpha);
                    %k = floor((+squeezing.tfd_ytic(jj) -squeezing.w(b,jj)-squeezing.freqrange.low)./alpha);
                    if (k>0) && (k<=nalpha);
                        if squeezing.TFR.measure
                                    stfd(b,k) = stfd(b,k)+1;
                        else
                                    stfd(b,k) = stfd(b,k)+squeezing.tfd(b,jj);
                        end
                    end
                end
            end
        end

    else
        
        squeezing.w(~isfinite(squeezing.w))=1e9;
        stfd = sqzTFD_STFT(squeezing.w', squeezing.tfd', n, nscale, nalpha, squeezing.TFR.measure, squeezing.freqrange.low, alpha)';
        %keyboard()
    end
    
end
    

if squeezing.debug; fprintf('DONE!!\n'); end

