%% PANUAS Radar System - Example Radar Initialization File
%{

    Sean Holloway
    PANUAS Radar Init File
    
    This file specifies radar parameters for PANUAS processing.

    Use script 'FullSystem_RealDataPANUAS.m' to run scenarios.
    
%}

%% Radar Parameter Setup

% Radar simulation and processing setup
scenario.radarsetup = struct( ...
    ...
    ... % Waveform Properties
    'f_c',          5.8e9, ...              % Operating frequency in Hz
    'f_s',          50e6, ...               % ADC sample frequency in Hz
    't_ch',         50e-6, ...              % Chirp duration in seconds
    'pri',          55.5e-6, ...            % Interval between successive chirps
    'bw',           100e6, ...              % Chirp bandwidth in Hz
    'n_p',          512, ...               % Number of (MIMO) chirps per CPI
    'drop_s',       250, ...                % Number of samples to drop
    'cpi_fr',       1, ...                  % Number of CPI per frame
    'warmup_s',     10000, ...              % Number of samples to drop at beginning of file
    'data_type',    'int16', ...            % Input value data type
    'mimo_type',    'TDM', ...              % Set 'TDM' or 'CDM'
    'angle_method', 'set', ...              % Set 'fit' or 'set'
    'n_el',         16, ...                 % Size of elevation FFT for 'set' case
    'n_az',         16, ...                 % Size of azimuth FFT for 'set' case
    ...
    ... % Antenna Array Properties
    'n_tx_y',       2, ...              % Number of horizontal elements in Tx array
    'n_tx_z',       2, ...              % Number of vertical elements in Tx array
    'd_tx',         2, ...              % Distance between Tx elements in wavelengths
    'n_rx_y',       4, ...              % Number of horizontal elements in Rx array
    'n_rx_z',       4, ...              % Number of vertical elements in Rx array
    'd_rx',         0.5, ...            % Distance between Rx elements in wavelengths
    ...
    ... % Processing Properties
    'r_win',        'hanning', ...          % Window for range processing
    'd_win',        'blackmanharris', ...   % Window for doppler processing
    'az_win',       'hanning', ...          % Window for azimuth processing
    'el_win',       'hanning', ...          % Window for elevation processing
    'v_az_coeff',   0, ...            % Velocity-azimuth coupling coefficient
    'v_el_coeff',   -0.01871, ...           % Velocity-elevation coupling coefficient
    ...
    ... % Detection Properties
    'detect_type',  'CFAR', ...         % Choose 'CFAR' or 'threshold'
    'thresh',       20, ...             % Threshold detection threshold in dB
    'CFAR_Pfa',     1e-4, ...           % CFAR false alarm probability
    'num_guard',    [3 3], ...          % Number of R-D guard cells for CFAR detection
    'num_train',    [15 15], ...        % Number of R-D training cells for CFAR detection
    'rng_limit',    [210 230], ...        % Minimum/maximum range to search
    'vel_limit',    [5, 15], ...         % Minimum/maximum absolute value of velocity
    'az_limit',     [-20 20], ...       % Maximum angle to search in azimuth
    'el_limit',     [-30.1 30.1], ...       % Maximum angle to search in elevation
    'snr_min',      15, ...             % Minimum SNR to keep detection
    'dilate',       false, ...          % T/F dilate raw CFAR result to avoid duplicates 
    'dil_bins',     5, ...              % Length of CFAR dilation
    'det_m',        1);                 % M for m-of-n binary integration

tracking = struct( ...
    ...
    ... % Tracking properties
    'min_vel',      1, ...              % Minimum velocity required to track target
    'dist_thresh',  Inf, ...            % Mahanalobis distance association threshold
    'miss_max',     1, ...             % Number of misses required to inactivate track
    'max_hits_fa',  1, ...              % Maximum number of hits for track to still be false alarm
    'EKF',          true, ...           % T/F use extended Kalman filter
    'sigma_v',      [10 10 1], ...        % XYZ target motion uncertainty
    'sigma_z',      [0.9 deg2rad(7.5) deg2rad(7.5) 1]);         % XYZnull or RAEV measurement uncertainty

scenario.radarsetup.tracking = tracking;

%% Perform Calculations

% Ensure integer number of samples per chirp
scenario.radarsetup.f_s = ...
    floor(scenario.radarsetup.t_ch*scenario.radarsetup.f_s)/scenario.radarsetup.t_ch;

% Calculate number of samples per chirp
scenario.radarsetup.n_s = ...
    scenario.radarsetup.f_s*scenario.radarsetup.t_ch;

% Calculate frame time
scenario.radarsetup.t_fr = ...
    scenario.radarsetup.t_ch * scenario.radarsetup.n_p * ...
    scenario.radarsetup.n_tx_y * scenario.radarsetup.n_tx_z;

% Calculate range-doppler coupling for tracking filter
scenario.radarsetup.tracking.RDCoupling = ...
    scenario.radarsetup.f_c * scenario.radarsetup.t_ch / scenario.radarsetup.bw;

%% Set up PAT objects

% Set up CFAR detector
scenario.sim.CFAR = phased.CFARDetector2D( ...
    'Method',                   'CA', ...
	'ProbabilityFalseAlarm',    scenario.radarsetup.CFAR_Pfa, ...
    'ThresholdFactor',          'Auto', ...
    'GuardBandSize',            scenario.radarsetup.num_guard, ...
    'TrainingBandSize',         scenario.radarsetup.num_train);

% Set up virtual array for beamformer AoA
n_y = scenario.radarsetup.n_tx_y * scenario.radarsetup.n_rx_y;
n_z = scenario.radarsetup.n_tx_z * scenario.radarsetup.n_rx_z;

scenario.sim.virtual_array = phased.URA( ...
    'Size',                     [n_z, n_y], ...
    'ElementSpacing',           scenario.radarsetup.d_rx);

% Set up 2D beamformer
scenario.sim.AoA = phased.BeamscanEstimator2D( ...
    'SensorArray',              scenario.sim.virtual_array, ...
    'OperatingFrequency',       scenario.radarsetup.f_c, ...
    'AzimuthScanAngles',        -90:1:90, ...
    'ElevationScanAngles',      -90:1:90, ...
    'DOAOutputPort',            true);





