%% PAN-UAS Radar System
%{

    Sean Holloway
    PAN-UAS (Portable Anti-UAS System) - Prototype
    MATLAB Data Parsing & Processing

    This shell file runs successive scripts and gauges progress.

    TODO:
    - Implement
    - Break Main into loop
    - Comment data format in Parsing script
    - Move inputs from parsing to file
    - Automatically obtain corner reflector range bin
    - Split file name into directory + name
    - Fix MIMO arrangement
    - Calibrate if no calibration data found

    DOCUMENT:
    - Main
    - Data Parsing
%}

%% Housekeeping

clear variables
close all
addpath(genpath(pwd));
tic

%% Obtain input files

fold = dir('Input Data/noise_tests_3_50M');
k = 1;
for i = 1:length(fold)
    if not(fold(i).isdir)
        files{k} = fold(i).name(1:end-4);
        k = k+1;
    end
end

for file_loop = 1:length(files)
    
    %% Initialize Scenario Object
    
    % Initialization
    scenario = RadarScenario_RealDataPANUAS;
    
    %% Setup Structures for Simulation
    
    % Set up simulation parameters
    SetupProcessing_RealDataPANUAS
    
    % Modify filename input
    scenario.simsetup.file_in = files{file_loop};
    
    % Set up transceiver and channel parameters
    SetupRadarScenario_RealDataPANUAS
    
    %% Run Simulation & Signal Processing
    
    if scenario.simsetup.calibrate
        % Return corner reflector calibration information
        Calibrate_RealDataPANUAS
    else
        % Perform main processes of simulation, signal and data processing
        Main_RealDataPANUAS
    end
    
    %% Save and Package Resultant Data
    
    % Run all end-of-simulation tasks
    EndProcess_RealDataPANUAS
    
    disp(files{file_loop})
    
    % Close figures
    close all;
    
end














