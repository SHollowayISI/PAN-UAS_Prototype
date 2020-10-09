%% PANUAS Radar System - Main Processing Loop
%{

    Sean Holloway
    PANUAS Main Simulation Loop
    
    This file specifies performs data parsing, signal processing, detection,
    data processing, and results collection for PANUAS system.

    Use script 'FullSystem_RealDataPANUAS.m' to run scenarios.
    
%}

%% Data Parsing

% Return rx signal in format fast time x slow time x rx-channel
scenario = DataParsing_RealDataPANUAS(scenario);

%% Main Loop

% Set up timing system
timeStart(scenario);

% If data remains, enter loop
while not(scenario.flags.out_of_data)
    %% Set up loop
    
    % Increment CPI number
    scenario.flags.cpi = scenario.flags.cpi + 1;
    
    %% Allocate parsed data into single CPI
    
    % Split scenario.parsed_data into scenario.rx_sig for single CPI
    scenario.rx_sig = AllocateCPI_RealDataPANUAS(scenario);
    
    %% Signal Processing
    
    % Perform signal processing on received signal
    scenario.cube = SignalProcessing_RealDataPANUAS(scenario);
    
    %% End of loop processing
    
    % Readout loop update
    
    
    % Break loop if final CPI
    if scenario.flags.cpi == scenario.radarsetup.cpi_fr
        break
    end
    
    
end






