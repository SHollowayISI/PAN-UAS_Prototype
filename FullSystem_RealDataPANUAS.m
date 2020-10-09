%% PAN-UAS Radar System
%{

    Sean Holloway
    PAN-UAS (Portable Anti-UAS System) - Prototype
    MATLAB Data Parsing & Processing

    This shell file runs successive scripts and gauges progress.

    TODO: 
        - Signal Processing Path:
            + Implement frame-level loop
            + Throw warning if no calibration data found
            + Save cube each CPI
            + Updates
            + Read/scan through
            + Comment
            + Move MIMO arrangement to setup
        - Full System
            + End of processing tasks
        - Full System Auto
            + Implement loop
        - Human readible interface

%}

%% Housekeeping

clear variables
close all
addpath(genpath(pwd));
tic

%% Initialize Scenario Object

% Initialization
scenario = RadarScenario_RealDataPANUAS;

%% Setup Structures for Simulation

% Set up processing parameters
SetupProcessing_RealDataPANUAS

% Set up transceiver and waveform parameters
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














