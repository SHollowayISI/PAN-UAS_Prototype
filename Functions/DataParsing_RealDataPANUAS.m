function [scenario] = DataParsing_RealDataPANUAS(scenario)
%DATAPARSING_REALDATAPANUAS Parses data form PAN-UAS Prototype
%   Detailed explanation goes here

%% Unpack Variables

radarsetup = scenario.radarsetup;
simsetup = scenario.simsetup;

%% Calculate Variables

num_channels = radarsetup.n_rx_y*radarsetup.n_rx_z;

%% Load .bin file

read_filename = [simsetup.file_in, '.bin'];

fileID = fopen(read_filename,'r');
outbuff = fread(fileID, [num_channels, Inf], 'int16');
% outbuff = fread(fileID, [num_channels, Inf], radarsetup.data_type);

%% Bitwise operations on channels

% Channel A1
sync_start = bitget(outbuff(1,:), 2, radarsetup.data_type);
sync_stop = bitget(outbuff(1,:), 1, radarsetup.data_type);

% Channel B1 & C1
Tx(1,:) = bitget(outbuff(2,:), 2, radarsetup.data_type);
Tx(2,:) = bitget(outbuff(2,:), 1, radarsetup.data_type);
Tx(3,:) = bitget(outbuff(3,:), 2, radarsetup.data_type);
Tx(4,:) = bitget(outbuff(3,:), 1, radarsetup.data_type);
% Tx_total = bi2de(Tx', 'left-msb');

% Clear LSB data
outbuff = bitset(outbuff, 1, 0, radarsetup.data_type);
outbuff = bitset(outbuff, 2, 0, radarsetup.data_type);
outbuff = outbuff/4;

%% Process results

% Find beginning and end of chirps
start_ind = find(diff(sync_start) > 0);
stop_ind = find(diff(sync_stop) > 0);

% Throw out beginning of index list
start_ind = start_ind(start_ind > radarsetup.warmup_s);
stop_ind = stop_ind(stop_ind > start_ind(1));
start_ind = start_ind(start_ind < stop_ind(end));

% Throw out indices until starting on first Tx channel
while true
    if Tx(1, start_ind(1) + ceil(radarsetup.n_s/2)) == 1
        start_ind(1) = [];
        stop_ind(1) = [];
    else
        break
    end
end

% Throw out indices that don't complete Tx cycle
start_ind = start_ind(1:(4*floor(length(start_ind)/4)));
% stop_ind = stop_ind(1:(4*floor(length(stop_ind)/4)));

% Initialize data container
scenario.parsed_data = zeros(radarsetup.n_s - radarsetup.drop_s, length(start_ind), num_channels);

% Create index list
ind = start_ind + (radarsetup.drop_s:(radarsetup.n_s-1))';
ind = ind(:);

% Obtain data from buffer
scenario.parsed_data = reshape(outbuff(:,ind), num_channels, radarsetup.n_s - radarsetup.drop_s, []);
scenario.parsed_data = reshape(scenario.parsed_data, num_channels, ...
    radarsetup.n_s-radarsetup.drop_s, 4, []);
scenario.parsed_data = permute(scenario.parsed_data, [2 4 3 1]);

% Clear output buffer to save size
outbuff = [];


end

