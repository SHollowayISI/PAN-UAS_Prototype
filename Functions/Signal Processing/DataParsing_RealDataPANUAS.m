function [scenario] = DataParsing_RealDataPANUAS(scenario)
%DATAPARSING_REALDATAPANUAS Parses data form PAN-UAS Prototype
%   Takes scenario object as input, returns scenario object with
%   .parsed_data field included. Output data is in fast time x slow time x
%   tx channel x rx channel format.

%% Unpack Variables

radarsetup = scenario.radarsetup;
simsetup = scenario.simsetup;

%% Calculate Variables

num_channels = radarsetup.n_rx_y*radarsetup.n_rx_z;

%% Load .bin file

read_filename = [simsetup.file_in, '.bin'];

fileID = fopen(read_filename,'r');
outbuff = fread(fileID, [num_channels, Inf], 'int16');

%% Bitwise operations on channels

% Channel A1
sync_start = bitget(outbuff(1,:), 2, radarsetup.data_type);
sync_stop = bitget(outbuff(1,:), 1, radarsetup.data_type);

% Channel B1 & C1
Tx(1,:) = bitget(outbuff(2,:), 2, radarsetup.data_type);
Tx(2,:) = bitget(outbuff(2,:), 1, radarsetup.data_type);
Tx(3,:) = bitget(outbuff(3,:), 2, radarsetup.data_type);
Tx(4,:) = bitget(outbuff(3,:), 1, radarsetup.data_type);

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
start_ind = start_ind(start_ind < (size(outbuff, 2) - radarsetup.n_s));

% Throw out indices until starting on first Tx channel
while true
    if Tx(1, start_ind(1) + ceil(radarsetup.n_s/2)) == 1
        break
    else
        start_ind(1) = [];
        stop_ind(1) = [];
    end
end

% Throw out indices that don't complete Tx cycle
start_ind = start_ind(1:(4*floor(length(start_ind)/4)));

% Find duplicate stops
donebool = false;

while not(donebool)
    min_len = min(length(stop_ind), length(start_ind));
    diff_ind = stop_ind(1:min_len) - start_ind(1:min_len);
    bad_ind = find(diff_ind < 0, 1);
    
    if isempty(bad_ind)
        donebool = true;
    else
        stop_ind(bad_ind) = [];
    end
end

% Remove duplicates at end
stop_ind = stop_ind(1:min_len);
start_ind = start_ind(1:min_len);
diff_ind = stop_ind - start_ind;

% Find overruns to be set to zero
interp_ind = find(diff_ind < radarsetup.n_s);

% Initialize data container
scenario.parsed_data = zeros(radarsetup.n_s - radarsetup.drop_s, length(start_ind), num_channels);

% Create index list
ind = start_ind + (radarsetup.drop_s:(radarsetup.n_s-1))';
ind = ind(:);

% Obtain data from buffer
scenario.parsed_data = outbuff(:,ind);
scenario.parsed_data = reshape(scenario.parsed_data, num_channels, radarsetup.n_s - radarsetup.drop_s, []);

% Shape data
scenario.parsed_data = reshape(scenario.parsed_data, num_channels, ...
    radarsetup.n_s - radarsetup.drop_s, 4, []);
scenario.parsed_data = permute(scenario.parsed_data, [2 4 3 1]);

%DEBUG: FIX BIT FLIP
% scenario.parsed_data(:,:,:,11) = mod(scenario.parsed_data(:,:,:,11) + 2^11, 2^12) - 2^11;

% Interpolate bad indices
%{
for n = interp_ind
%     scenario.parsed_data(:,(diff_ind(n) - radarsetup.drop_s):end, n) = 0;

    ch_ind = floor((n-1) / 4) + 1;
    tx_ind = mod(n - 1, 4) + 1;
    
    if (ch_ind ~= 1)
        scenario.parsed_data(:,ch_ind,tx_ind,:) = ...
            (scenario.parsed_data(:,ch_ind + 1,tx_ind,:) + scenario.parsed_data(:,ch_ind - 1,tx_ind,:))/2;
    end
    
    
end
%}

% Clear output buffer to save size
outbuff = [];


end

