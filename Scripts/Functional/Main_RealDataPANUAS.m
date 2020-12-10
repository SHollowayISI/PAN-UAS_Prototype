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

%DEBUG: Initialize cube for saving
save_cube = {};

% Set up timing system
timeStart(scenario);

% If data remains, enter frame loop
while not(scenario.flags.out_of_data)
    
    % Increment frame number
    scenario.flags.frame = scenario.flags.frame + 1;
    scenario.flags.cpi = 0;
    
    % Enter CPI loop
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
        
        %% Single CPI Data Processing
        
        % Perform single-frame radar detection
        if (scenario.simsetup.par_cfar && strcmp(scenario.radarsetup.detect_type, 'CFAR'))
            scenario.detection = DetectionSingle_Parallel_PANUAS(scenario);
        else
            scenario.detection = DetectionSingle_PANUAS(scenario);
        end
        
        %% Loop Update Procedures
        
        % Read out CPI update
        CPIUpdate(scenario);
        
        % Read out estimated time of completion
        timeUpdate(scenario, 1, 'loops')
        
        % Debug
        loop = scenario.radarsetup.cpi_fr * (scenario.flags.frame-1) + scenario.flags.cpi;
        save_cube{loop} = scenario.cube.pow_cube;
        
        %% End of loop processing
        
        % Break loop if final CPI
        if scenario.flags.cpi == scenario.radarsetup.cpi_fr
            break
        end
    end
    
    %% Multiple CPI Data Processing
        
    % Perform binary integration and coordinate determination
    scenario.detection = DetectionMultiple_PANUAS(scenario);
    
    % Read out detection data
    if scenario.simsetup.readout
        readOut(scenario);
    end
    
    % Save detection data
    saveMulti(scenario);
    
    % Update multi-target tracking system
    scenario.multi = Tracking_PANUAS(scenario, scenario.flags.frame);
    
    % Break loop if final frame
    if scenario.flags.frame == scenario.simsetup.num_frames
        break
    end
    
end

%% Visualization

% Plot range-doppler heatmap
% viewIncoherentCube(scenario, 'heatmap', 300);

% Plot doppler swaths
% viewDopplerSwath(scenario, [3 30], 300);

% Plot tracked targets
% viewTracking(scenario, 'PPI', false, false);

% Plot tracked targets overlayed on map
% trackingOverlay(scenario, 'Resources/Google Maps/Street.png', false, true, true)
% trackingOverlay(scenario, 'Resources/Google Maps/Street.png', false, true, false)





