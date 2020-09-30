%% PANUAS Radar System - Calibration Script
%{

    Sean Holloway
    PANUAS Calibration Script
    
    This file runs data parsing, performs signal processing, and generates
    calibration data for the input file.

    Use script 'FullSystem_RealDataPANUAS.m' to run scenarios.
    
%}

%% Data Parsing

% Return rx signal in format fast time x slow time x tx-ch x rx-ch
scenario = DataParsing_RealDataPANUAS(scenario);

%% Signal Processing

% Perform signal processing on received signal
scenario.cube = SignalProcessing_Calibration_RealDataPANUAS(scenario);

% Generate calibration cube
scenario.cal = GenerateCalibration_RealDataPANUAS(scenario);

%% Visualization

% Plot uncalibrated power over range bins
viewCalRange(scenario)

% Plot calibration magnitude and phase
viewCalCube(scenario)










