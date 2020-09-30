function [rx_sig] = AllocateCPI_RealDataPANUAS(scenario)
%ALLOCATECPI_REALDATAPANUAS Summary of this function goes here
%   Detailed explanation goes here

%% Pull data from single CPI to be processed

% Calculate slow time indexes to pull
ch_start = (scenario.flags.cpi-1)*scenario.radarsetup.n_p + 1;
ch_ind = ch_start:(ch_start + scenario.radarsetup.n_p - 1);

% Determine if end of data is reached
if ch_ind(end) > size(scenario.parsed_data, 2)
    
    % Set flags
    scenario.flags.out_of_data = true;
    
    % Shorten index list
    ch_ind = ch_ind(1):size(scenario.parsed_data,2);
    
    % Pull data to rx_sig
    rx_sig = scenario.parsed_data(:,ch_ind,:,:);
    
    % Pad incomplete data with trailing zeroes.
    rx_sig(:,(length(ch_ind)+1):scenario.radarsetup.n_p, :, :) = 0;
    
    
else
    
    % Pull data to rx_sig
    rx_sig = scenario.parsed_data(:,ch_ind,:,:);
    
end

end

