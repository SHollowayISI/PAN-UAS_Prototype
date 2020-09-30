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

%% Initialize Scenario Object

% Initialization
scenario = RadarScenario_RealDataPANUAS;

%% Setup Structures for Simulation

% Set up simulation parameters
SetupSimulation_RealDataPANUAS

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
EndSimulationSingle_PANUAS

%DEBUG: OUTPUT PLOTS
Scratch2














