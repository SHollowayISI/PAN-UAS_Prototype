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
    'file_in',      'drone_150m_dist_movingfast_going_1201_145222', ...         % Input data filename
    'in_path',      'Input Data\drone_5\', ...    % Input filepath
    'file_out',     'drone_5_microdoppler_revised', ...                % Output figure filename
    ...
    ... % Calibration Options
    'calibrate',    false, ...                      % Perform calibration T/F
    'cal_bin',      284, ...                        % Range bin containing corner reflector
    'cal_phase',    false, ...                       % Calibrate phase only
    'cal_file',     'drone5_wall', ...    % Name of calibration file to read/write
    ...
    ... % Simulation Properties
    'par_cfar',     true, ...                   % Parallelize CFAR detection
    ...
    'num_frames',   8, ...                      % Number of radar frames to simulate
    'readout',      true, ...                   % Read out target data T/F
    ...
    'clear_cube',   false, ...
    'send_alert',   false, ...                  % Send email alert T/F
    'attach_zip',   false, ...
    'alert_address', 'sholloway@intellisenseinc.com', ...
    ...                                         % Email address for status updates
    'save_format',  save_format, ...            % File types to save figures
    'save_figs',    false, ...                  % Save figures T/F
    'save_date',    false, ...                  % Include date in file savename
    'save_mat',     false, ...                  % Save mat file T/F
    'reduce_mat',   false);                     % Reduce mat file for saving

%% Start Parallel Pool

if scenario.simsetup.par_cfar
    if(isempty(gcp('nocreate')))
        parpool;
    end
end




