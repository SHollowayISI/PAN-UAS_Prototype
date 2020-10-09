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
    'file_in',      'test_0918_115303_60m', ...         % Input data filename
    'in_path',      'Input Data\Test 09182020\', ...    % Input filepath
    'file_out',     'Test_09302020', ...                % Output figure filename
    ...
    ... % Calibration Options
    'calibrate',    false, ...                              % Perform calibration T/F
    'cal_bin',      61, ...                                 % Range bin containing corner reflector
    'cal_file',     'test_0918_115843_25m_wall.mat', ...    % Name of calibration file to read/write
    ...
    ... % Simulation Properties
    'num_frames',   1, ...                      % Number of radar frames to simulate
    'readout',      true, ...                   % Read out target data T/F
    ...
    'clear_cube',   false, ...
    'send_alert',   false, ...                  % Send email alert T/F
    'attach_zip',   false, ...
    'alert_address', 'sholloway@intellisenseinc.com', ...
    ...                                         % Email address for status updates
    'save_format',  save_format, ...            % File types to save figures
    'save_figs',    false, ...                  % Save figures T/F
    'save_mat',     false, ...                  % Save mat file T/F
    'reduce_mat',   false);                     % Reduce mat file for saving




