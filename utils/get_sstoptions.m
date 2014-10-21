function [options] = get_sstoptions()

    % General options
    options.fs = 288; % Number of daily observations 
    options.pad = options.fs*50; % Length of the left/right padding

    % Generic SST parameters
    [options.trend.sst] = setup_param;
    options.trend.sst.display.all = 0;
    options.trend.sst.TFRtype = 'STFT';
    options.trend.sst.TFR.motherwavelet = 'Cinfc'; 
    options.trend.sst.usemex = 1;
    [options.season.sst] = options.trend.sst;
    
    % SST trend parameters
    options.trend.sst.freqrange.high = 30;
    options.trend.sst.freqrange.low = 0;
    options.trend.sst.TFR.MAXFREQ = options.trend.sst.freqrange.high;
    options.trend.sst.TFR.MINFREQ = options.trend.sst.freqrange.low;
    options.trend.sst.TFR.alpha = 0.1;
    options.trend.sst.TFR.FWHM = 0.5;
    options.trend.sst.extraction = 0;
    options.trend.sst.reconstruction = 0;

    % SST season parameters
    options.season.sst.TFR.alpha = 0.004; %0.05
    options.season.sst.TFR.FWHM = 0.02; %0.05
    options.season.sst.TFR.quantile_gamma = 0.1;
    options.season.sst.extraction = 0; 
    options.season.sst.reconstruction = 1;
    options.season.sst.extractcurv.no = 1;
    options.season.sst.compband = 0.2; % band around IF for STFT/CWT/SST
    options.season.sst.ncomp = 4; % Number of components to extract

    % Smoothing parameters
    options.trend.smoothspan = options.fs;
    options.trend.smoothtype = 'moving';
    options.season.ph.smoothspan = 1;
    options.season.smoothtype = 'moving';
    options.season.am.smoothspan = options.fs*20;
    options.season.am.smoothtype = 'moving';
    
end


