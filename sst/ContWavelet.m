function [cwtcoeff, ftd_ytic, Rpsi] = ContWavelet(cwt)
%
% Continuous wavelet transform ver 0.1
% Modified from wavelab 85
%
% INPUT:
%   cwt.xhat     : signal
%   cwt.t        : time
%   cwt.oct	 : the initial octave
%   cwt.scale	 : the log scale
%   cwt.nvoice	 : the number of equally spaced bins in each log scale
%   cwt.motehrwavelet   : the mother wavelet used in CWT
%   cwt.minus_i_partial_b : evaluate -i\partial_bW_f(a,b)
%   cwt.CENTER	 : the center of the Gaussian function if the motherwavelet is Gaussian
%   cwt.FWHM  	 : the FWHM of the Gaussian fucntion if the motherwavelet is Gaussian
% (OPTIONS)
%   cwt.parallel : use parallel computataion
%   cwt.debug    : debug message
%
% OUTPUT:
%   cwtcoeff	 : Continuous wavelet transform on log scale
%
% DEPENDENCY:
%
% by Hau-tieng Wu 2011-06-20 (hauwu@math.princeton.edu)
%


xhat = cwt.xhat; 
t = cwt.t;
dt = t(2)-t(1);
n = length(xhat);


if cwt.debug; fprintf('working on CWT\n'); end

    %% assume the original signal is on [0,L].
    %% assume the signal is on [0,1]. Frequencies are rescaled to \xi/L
xi = [(0:(n/2)) (((-n/2)+1):-1)];

noctave = floor(log2(n)) - cwt.oct;
cwtcoeff = zeros(n, cwt.nvoice .* noctave);

kscale = 1;
scale = cwt.scale;

ftd_ytic = zeros(1, cwt.nvoice .* noctave);
for jj = 1 : cwt.nvoice .* noctave
    ftd_ytic(jj) = scale .* (2^(jj/cwt.nvoice));
end

    for jo = 1:noctave	% # of scales
        for jv = 1:cwt.nvoice
            qscale = scale .* (2^(jv/cwt.nvoice));
            omega =  xi ./ qscale ;            

        if strcmp(cwt.motherwavelet, 'morlet'); 	%% Morlet

                window = 4*sqrt(pi)*exp(-4*(omega-0.69*pi).^2)-4.89098d-4*4*sqrt(pi)*exp(-4*omega.^2);  

        elseif strcmp(cwt.motherwavelet, 'gaussian');	%% Gaussian (not really wavelet)

            if ~isfield(cwt,'CENTER') | ~isfield(cwt,'FWHM')
            error('You should assign CENTER and FWHM if you want to use Gaussian function as the mother wavelet');
            end

            psihat = @(f) exp( -log(2)*( 2*(f-cwt.CENTER)./cwt.FWHM ).^2 );
            window = psihat(omega);

            elseif strcmp(cwt.motherwavelet, 'antigaussian');   %% Gaussian (not really wavelet)

                if ~isfield(cwt,'CENTER') | ~isfield(cwt,'FWHM')
                    error('You should assign CENTER and FWHM if you want to use Gaussian function as the mother wavelet');
                end

                psihat = @(f) exp( -log(2)*( 2*(f-cwt.CENTER)./cwt.FWHM ).^2 ) .* (f-1) * (-8*log(2)/cwt.FWHM.^2);
                window = psihat(omega);

        elseif strcmp(cwt.motherwavelet, 'Cinfc');	

            tmp0 = (omega-cwt.CENTER)./cwt.FWHM;	    
            tmp1 = (tmp0).^2-1;

            window = exp( 1./tmp1 ); 
            window( omega >= (cwt.CENTER+cwt.FWHM) ) = 0;
            window( omega <= (cwt.CENTER-cwt.FWHM) ) = 0;

            elseif strcmp(cwt.motherwavelet, 'antiCinfc');

                tmp0 = (omega-cwt.CENTER)./cwt.FWHM;
                tmp1 = (tmp0).^2-1;

                window = i * exp( 1./tmp1 ) .* (-2/cwt.FWHM) .* (1./tmp1.^2) .* tmp0;
                window( find( omega >= (cwt.CENTER+cwt.FWHM) ) ) = 0;
                window( find( omega <= (cwt.CENTER-cwt.FWHM) ) ) = 0;

        elseif strcmp(cwt.motherwavelet, 'meyer');	%% Meyer

                window = zeros(size(omega));
                int1 = find((omega>=5./8*0.69*pi)&(omega<0.69*pi));
                int2 = find((omega>=0.69*pi)&(omega<7./4*0.69*pi));
                window(int1) = sin(pi/2*meyeraux((omega(int1)-5./8*0.69*pi)/(3./8*0.69*pi), 2));
                window(int2) = cos(pi/2*meyeraux((omega(int2)-0.69*pi)/(3./4*0.69*pi), 2));

        elseif strcmp(cwt.motherwavelet, 'BL3');	%% B-L 3

                phihat = (2*pi)^(-0.5)*(sin(omega/4)./(omega/4)).^4; phihat(1) = (2*pi)^(-0.5);
                aux1 = 151./315 + 397./840*cos(omega/2) + 1./21*cos(omega) + 1./2520*cos(3*omega/2);
                phisharphat = phihat.*(aux1.^(-0.5));

                aux2 = 151./315 - 397./840*cos(omega/2) + 1./21*cos(omega) - 1./2520*cos(3*omega/2);
                aux3 = 151./315 + 397./840*cos(omega) + 1./21*cos(2*omega) + 1./2520*cos(3*omega);
                msharphat = sin(omega/4).^4.*(aux2.^(0.5)).*(aux3.^(-0.5));
                window = phisharphat.*msharphat.*exp(i*omega/2).*(omega>=0);

        else

            error('Choose a supported motherwave'); 

        end

            window = window ./ sqrt(qscale);

        if cwt.minus_i_partial_b
                what = (xi./(n*dt)) .* window .* xhat;
        else
                what = window .* xhat;
        end

            w = ifft(what);
            %keyboard()
            cwtcoeff(:,kscale) = transpose(w);
            kscale = kscale+1;

        end

        scale = scale .* 2;

    end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %% calculate the constant for reconstruction
    %% TODO: calculate Rpsi for other mother wavelets
xi = [0.05:1/10000:10];

if strcmp(cwt.motherwavelet, 'gaussian');   %% Gaussian (not really wavelet)

    psihat = @(f) exp( -log(2)*( 2*(f-cwt.CENTER)./cwt.FWHM ).^2 );
    window = psihat(xi);
    Rpsi = sum(window./xi)/10000;

elseif strcmp(cwt.motherwavelet, 'antigaussian');   %% Gaussian (not really wavelet)

    psihat = @(f) exp( -log(2)*( 2*(f-cwt.CENTER)./cwt.FWHM ).^2 ) .* (f-1) * (-8*log(2)/cwt.FWHM.^2);
    window = psihat(xi);

    Rpsi = sum(window./xi)/10000;

elseif strcmp(cwt.motherwavelet, 'morlet');

    window = 4*sqrt(pi)*exp(-4*(xi-0.69*pi).^2)-4.89098d-4*4*sqrt(pi)*exp(-4*xi.^2);  
    Rpsi = sum(window./xi)/10000;

elseif strcmp(cwt.motherwavelet, 'Cinfc');

    tmp0 = (xi - cwt.CENTER)./cwt.FWHM;
    tmp1 = (tmp0).^2-1;

    window = exp( 1./tmp1 );
    window( find( xi >= (cwt.CENTER+cwt.FWHM) ) ) = 0;
    window( find( xi <= (cwt.CENTER-cwt.FWHM) ) ) = 0;
    Rpsi = sum(window./xi)/10000;

elseif strcmp(cwt.motherwavelet, 'antiCinfc');

    tmp0 = (xi - cwt.CENTER)./cwt.FWHM;
    tmp1 = (tmp0).^2-1;

    window = i * exp( 1./tmp1 ) .* (-2/cwt.FWHM) .* (1./tmp1.^2) .* tmp0;
    window( find( xi >= (cwt.CENTER+cwt.FWHM) ) ) = 0;
    window( find( xi <= (cwt.CENTER-cwt.FWHM) ) ) = 0;
    Rpsi = abs(sum(window./xi)/10000);
 
elseif strcmp(cwt.motherwavelet, 'meyer');	%% Meyer

            window = zeros(size(xi));
            int1 = find((xi>=5./8*0.69*pi)&(xi<0.69*pi));
            int2 = find((xi>=0.69*pi)&(xi<7./4*0.69*pi));
            window(int1) = sin(pi/2*meyeraux((xi(int1)-5./8*0.69*pi)/(3./8*0.69*pi), 2));
            window(int2) = cos(pi/2*meyeraux((xi(int2)-0.69*pi)/(3./4*0.69*pi), 2));
            
    Rpsi = sum(window./xi)/10000;
    
    
	elseif strcmp(cwt.motherwavelet, 'BL3');	%% B-L 3

            phihat = (2*pi)^(-0.5)*(sin(xi/4)./(xi/4)).^4; phihat(1) = (2*pi)^(-0.5);
            aux1 = 151./315 + 397./840*cos(xi/2) + 1./21*cos(xi) + 1./2520*cos(3*xi/2);
            phisharphat = phihat.*(aux1.^(-0.5));

            aux2 = 151./315 - 397./840*cos(xi/2) + 1./21*cos(xi) - 1./2520*cos(3*xi/2);
            aux3 = 151./315 + 397./840*cos(xi) + 1./21*cos(2*xi) + 1./2520*cos(3*xi);
            msharphat = sin(xi/4).^4.*(aux2.^(0.5)).*(aux3.^(-0.5));
            window = phisharphat.*msharphat.*exp(i*xi/2).*(xi>=0);
            
        Rpsi = sum(window./xi)/10000;
end

cwtcoeff = cwtcoeff ./ Rpsi;


if cwt.debug; fprintf('CWT is done\n\n'); end
end


function nu = meyeraux(xi,deg)
% WindowMeyer -- auxiliary window function for Meyer wavelets.
%  Usage
%    nu = WindowMeyer(xi,deg)
%  Inputs
%    xi     abscissa values for window evaluation
%    deg    degree of the polynomial defining Nu on [0,1]
%           1 <= deg <= 3
%  Outputs
%    nu     polynomial of degree 'deg' if x in [0,1]
%           1 if x > 1 and 0 if x < 0.
%  See Also
%    UnfoldMeyer, FoldMeyer
%
	if deg == 0,
		nu = xi;
	else
	  if deg == 1,
		nu = xi .^2 .* (3 - 2 .*xi) ;
	  else
		 if deg == 2,
			nu = xi .^3 .* (10 - 15 .* xi + 6 .* xi .^2);
		 else
			if deg == 3,
				 nu = xi.^4 .* ( 35 - 84 .* xi + 70 .* xi.^2 - 20 .* xi.^3);
			 end
		end
	  end
	end
	ix0 = find(xi <= 0);
	if length(ix0) > 0,
		%size(ix0),
		nu(ix0) = zeros(1,length(ix0));
	end
	ix1 = find(xi >= 1);
	if length(ix1) > 0,
		nu(ix1) = ones(1,length(ix1));
    end
    
end

%
%  Prepared for the thesis of Eric Kolaczyk, Stanford University, 1994
%  Copyright (c) Eric Kolaczyk, 1994.
%

