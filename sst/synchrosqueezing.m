function [rslt] = synchrosqueezing(sst);
%
% Synchrosqueezing transform ver 0.2 (2011-09-10)
% Try example_sst.m to see example
% You can find more information in 
%	http://www.math.princeton.edu/~hauwu
%
% TODO: rescale for the STFT version
%
% INPUT:
%   sst.TFRtype	  = STFT or CWT
%   sst.x         = signal
%   sst.t         = time
%   sst.wavelet   = parameters used in continuous wavelet transform
%   sst.stft      = parameters used in short time Fourier transform
%   sst.quantile_gamma     = if the threshold used in squeezing is determined by the quantile, this is the quantile value. Set it to 0 if you want to use absolute value as the threshold
%   sst.freqrange = the frequency range displayed in the time frequency plane
%   sst.display   = parameters used to control the final displayed figures
%   sst.extractcurv   = extract curves from the TF plane
% (OPTIONS)
%   sst.symmetry   = turn on symmetrization to reduce the boundary effect
%   sst.cleanup	   = close all existing figures
%   sst.parallel   = use parallel computataion
%   sst.compact    = compact support kernel
%   sst.debug      = debug message
%
% OUTPUT:
%   rslt	   = the structure contains the following results
%   rslt.stfd	   = the SST time-frequency domain result
%   rslt.freq	   = the frequency axis
%   rslt.c	   = the extracted curve 
%   rslt.h{i}	   = the handle of the i-th subplot. Use it to draw more.
%
% DEPENDENCY:
%   Wavelab (modifed and saved as ContWavelet.m), ContWavelet.m, STFourier.m, sqzTFD.m, extractcurv.m
%
% by Hau-tieng Wu v0.1 2011-06-20 (hauwu@math.princeton.edu)
%		  v0.2 2011-09-10
%		  v0.3 2012-03-03
%
% TODO: curve extraction and component reconstruction for STFT and linear-CWT
if sst.cleanup; clc; close all; end


if ~strcmp(sst.TFRtype,'CWT') & ~strcmp(sst.TFRtype,'STFT') ;
    error('Only CWT or STFT based Synchrosqueezing is provided...');
end

if strcmp(sst.TFRtype,'CWT') & (sst.TFR.rescale > 1) ;
    error('TFR.rescale is only used for STFT');
end

if sst.debug
    if strcmp(sst.TFRtype,'CWT')

    	fprintf('Synchrosqueezing transform based on CWT, ');

    	if sst.TFR.linear
	    fprintf('linear scale version\n');
    	else
	    fprintf('log scale version\n');
    	end

    else

 	fprintf('Synchrosqueezing transform based on STFT.\n');

    end
end
    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	%% data preparation
    if sst.debug
    	display('data preparation')
        tic
    end
    
    sst.x = transpose(sst.x(:)); sst.t = transpose(sst.t(:)); 
    if mod(length(sst.x),2)
        fprintf('(DEBUG) Use even number points\n'); 
        sst.x=sst.x(1:end-1); sst.t=sst.t(1:end-1);  
    end

    if sst.symmetry; 
        tmp_x = zeros(1, length(sst.x)*2); 
        tmp_x(1:length(sst.x)) = sst.x; 
        tmp_x(end/2+1:end) = tmp_x(end/2:-1:1); 
        sst.x = tmp_x; clear tmp_x; 
        tmp_t = [1:length(sst.t)*2]*(sst.t(2)-sst.t(1));
        %sst.t = tmp_t; clear tmp_t;
    else
        tmp_t = sst.t;
    end;


    t = sst.t/sst.TFR.rescale - sst.t(1)/sst.TFR.rescale;
    t = tmp_t/sst.TFR.rescale - tmp_t(1)/sst.TFR.rescale;
    x = sst.x;
    sst.freqrange.low = sst.freqrange.low * sst.TFR.rescale;
    sst.freqrange.high = sst.freqrange.high * sst.TFR.rescale;
    N2 = 1+sst.symmetry;

    noctave = floor(log2(length(x))) - sst.TFR.oct;
    dt = t(2) - t(1);

    if sst.debug
    	toc
    end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %% Continuous wavelet transform or short time Fourier transform
    if sst.debug
    	display('CWT/STFT')
        tic
    end

    squeezing.TFR   	= sst.TFR;
    tmpdata 		= sst.TFR;
    tmpdata.xhat	= fft(x); 
    tmpdata.t 		= t;
    tmpdata.debug 	= sst.debug;
    tmpdata.minus_i_partial_b = 0;

    if strcmp(sst.TFRtype,'CWT');

        [tfd, tfd_ytic, Rpsi] = ContWavelet(tmpdata);
        %tmpdata.minus_i_partial_b = 1; %[Dtfd, Junk] = ContWavelet(tmpdata);
	    %% TODO: optimize the differentiation step by this parameter
        Dtfd = (-i/2/pi/dt)*[tfd(2:end,:) - tfd(1:end-1,:); tfd(1,:)-tfd(end,:)];

    elseif strcmp(sst.TFRtype,'STFT');

	tmpdata.x = x;
	tmpdata.alpha = tmpdata.alpha * tmpdata.rescale;
        [tfd, tfd_ytic] = STFourier(tmpdata);
        Dtfd = (-i/2/pi/dt)*[tfd(2:end,:) - tfd(1:end-1,:); tfd(1,:)-tfd(end,:)];

    end
    
    if sst.TFR.quantile_gamma > 0;             
	sst.TFR.gamma = quantile(abs(tfd(:)), sst.TFR.quantile_gamma); 
    else
        sst.TFR.gamma = 1e-8;
    end

    clear tmpdata;
    
    if sst.debug
    	toc
    end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %% instantaneous frquency information function
    
    
    Dtfd((abs(tfd) < sst.TFR.gamma)) = NaN;
    omega = Dtfd./tfd;

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %% Synchro-squeezing transform
        
    squeezing.TFRtype   = sst.TFRtype;
    squeezing.tfd       = tfd;
    squeezing.w         = omega;
    squeezing.freqrange = sst.freqrange;
    squeezing.debug     = sst.debug;
    squeezing.dt        = dt;
    squeezing.tfd_ytic  = tfd_ytic;
    squeezing.usemex    = sst.usemex;

    if sst.debug
    	display('SST')
        tic
    end
    [stfd, freq, alpha] = sqzTFD(squeezing);
    clear squeezing;
    if sst.debug
    	toc
    end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	%% take care of the symmetrization
    tfd  = tfd(1:end/N2,:);
    stfd = stfd(1:end/N2,:);
    t    = t(1:end/N2);
    x    = x(1:end/N2);

    if sst.display.TFD
        rslt.tfd   = tfd;
        rslt.tfd_ytic = tfd_ytic;
    end

    rslt.stfd  = stfd;
    %rslt.omega = omega;  
    rslt.freq  = freq./sst.TFR.rescale;
    rslt.alpha = alpha./sst.TFR.rescale;
    rslt.t	   = t;
    rslt.x	   = x;
    clear tfd; clear Dtfd; clear stfd; clear omega;
    
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	%% Curve extraction 
    
    if sst.extractcurv.no & sst.reconstruction

        if sst.debug
            display('Curve extraction')
            tic
        end

        curv.TFRtype = sst.TFRtype;
        curv.stfd    = rslt.stfd; 
        curv.freq    = freq;
        curv.noctave = noctave;
        curv.debug   = sst.debug;
        curv.t       = t;
        curv.lambda  = sst.extractcurv.lambda;
        curv.alpha   = alpha;
        curv.linear  = sst.TFR.linear;

        if isfield(sst.extractcurv,'range')
        curv.range = sst.extractcurv.range;
        else
            if strcmp(sst.TFRtype, 'CWT') & ~sst.TFR.linear
            curv.range = sst.TFR.nvoice; 
            else
                curv.range = floor(1/alpha);
            end
        end

        for idx_qq = 1 : sst.extractcurv.no

            eval(['curv.iff = sst.extractcurv.iff',num2str(idx_qq),';']);

            if strcmp(sst.TFRtype, 'CWT') & ~sst.TFR.linear
                curv.range = -floor(log2(curv.range*curv.iff)./alpha) + curv.range;
            end

            if sst.extraction
                    [c] = extractcurv(curv);
            else
                ll = find(rslt.freq == eval(['sst.extractcurv.iff',num2str(idx_qq)]));
                [c] = ones(length(t),1) * ll;
            end

            if sst.extractcurv.no > 1
                %% setup the regions of the estimated curves to be zero 
                for mm = 1:size(curv.stfd,1)
                    curv.stfd(mm, max(1 , c(mm)-floor(curv.range/2)): min(c(mm)+floor(curv.range/2) , size(curv.stfd,2))) = 0;
                end
            end

            eval(['rslt.c',num2str(idx_qq),' = c;']);

        end

        if sst.debug
            toc
        end
    end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	%% Curve reconstruction

    if sst.reconstruction & sst.extractcurv.no 
        if sst.debug
            display('Curve reconstruction')
            tic
        end

        for qq = 1 : sst.extractcurv.no

        calc_band;

        recon = zeros(1,size(rslt.stfd,1));
            eval(['c = rslt.c', num2str(qq),';']);

        if strcmp(sst.TFRtype,'CWT') & ~sst.TFR.linear
                deltaxi = log2(alpha);

            for kk = 1:size(rslt.stfd,1)
                    stfd2 = log(2)*deltaxi*rslt.stfd(kk,c(kk)-Z1:c(kk)+Z2).*freq(c(kk)-Z1:c(kk)+Z2);
                recon(kk) = 2*sum( stfd2 );
            end

        else

            for kk = 1:size(rslt.stfd,1)
                    stfd2 = alpha*rslt.stfd(kk,c(kk)-Z1:c(kk)+Z2);
                    recon(kk) = 2*sum( stfd2 );
            end

        end

            eval(['rslt.recon',num2str(qq),' = recon;']);

            clear recon; clear stfd2;
        end

        if sst.debug
            toc
        end
    end

finalreport;