%% PANUAS Radar System - Example Processing Initialization File
%{

    Sean Holloway
    PANUAS Processing Init File
    
    This file specifies processing parameters for PANUAS simulation.

    Use script 'FullSystem_RealDataPANUAS.m' to run scenarios.
    
%}

%% Simulation Parameter Setup

% save_format.list = {'.png','.fig'};
save_format.list = {'.png'};

% Radar simulation and processing setup
scenario.simsetup = struct( ...
    ... % Data Processing Options
    'file_in',      '10m_high_going_away_200M_0413_105545', ...         % Input data filename
    'in_path',      'Input Data\noise_tests_3\', ...    % Input filepath
    'file_out',     'noise_tests_3_50M', ...                % Output figure filename
    'skip_detection', true, ...                         % T/F skip detection, only get radar cube
    ...
    ... % Calibration Options
    'calibrate',    false, ...                      % Perform calibration T/F
    'cal_bin',      18, ...                        % Range bin containing corner reflector
    'cal_phase',    true, ...                       % Calibrate phase only
    'cal_file',     'nocal', ...    % Name of calibration file to read/write
    ...
    ... % Simulation Properties
    'par_cfar',     false, ...                   % Parallelize CFAR detection
    ...
    'num_frames',   1, ...                      % Number of radar frames to simulate
    'readout',      true, ...                   % Read out target data T/F
    ...
    'clear_cube',   false, ...
    'send_alert',   false, ...                  % Send email alert T/F
    'attach_zip',   false, ...
    'alert_address', 'sholloway@intellisenseinc.com', ...
    ...                                         % Email address for status updates
    'save_format',  save_format, ...            % File types to save figures
    'save_figs',    true, ...                  % Save figures T/F
    'save_date',    false, ...                  % Include date in file savename
    'save_mat',     false, ...                  % Save mat file T/F
    'reduce_mat',   false);                     % Reduce mat file for saving

%% Start Parallel Pool

if scenario.simsetup.par_cfar
    if(isempty(gcp('nocreate')))
        parpool;
    end
end




