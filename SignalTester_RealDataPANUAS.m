%% Bookkeeping

clear variables
close all
tic
addpath(genpath(pwd));

%% Set Variables

warmup_s = 10000;

n_s = 1250;
drop_s = 125;

off_s = 137.5;

num_channels = 16;
data_type = 'int16';

num_chirps = 100;


%% Load .bin file

read_filename = 'Input Data/Test 10132020/drone2_corner_reflect_1013_111521.bin';

sample_max = floor(4 * num_chirps * (n_s + off_s) + warmup_s);

fileID = fopen(read_filename,'r');
outbuff = fread(fileID, [num_channels, sample_max], 'int16');

%% Bitwise operations on channels

% Channel A1
sync_start = bitget(outbuff(1,:), 2, data_type);
sync_stop = bitget(outbuff(1,:), 1, data_type);

% Channel B1 & C1
Tx(1,:) = bitget(outbuff(2,:), 2, data_type);
Tx(2,:) = bitget(outbuff(2,:), 1, data_type);
Tx(3,:) = bitget(outbuff(3,:), 2, data_type);
Tx(4,:) = bitget(outbuff(3,:), 1, data_type);

% Clear LSB data
outbuff = bitset(outbuff, 1, 0, data_type);
outbuff = bitset(outbuff, 2, 0, data_type);
outbuff = outbuff/4;

%% Process results

% Find beginning and end of chirps
start_ind = find(diff(sync_start) > 0);
stop_ind = find(diff(sync_stop) > 0);

% Throw out beginning of index list
start_ind = start_ind(start_ind > warmup_s);
stop_ind = stop_ind(stop_ind > start_ind(1));
start_ind = start_ind(start_ind < stop_ind(end));

% Throw out indices until starting on first Tx channel
while true
    if Tx(1, start_ind(1) + ceil(n_s/2)) == 1
        start_ind(1) = [];
        stop_ind(1) = [];
    else
        break
    end
end

% Throw out indices that don't complete Tx cycle
start_ind = start_ind(1:(4*floor(length(start_ind)/4)));

% Initialize data container
parsed_data = zeros(n_s - drop_s, length(start_ind), num_channels);

% Create index list
ind = start_ind + (drop_s:(n_s-1))';
ind = ind(:);

% Obtain data from buffer
parsed_data = reshape(outbuff(:,ind), num_channels, n_s - drop_s, []);
parsed_data = reshape(parsed_data, num_channels, ...
    n_s - drop_s, 4, []);
parsed_data = permute(parsed_data, [2 4 3 1]);

% Clear output buffer to save size
outbuff = [];

toc

%% Plotting

close all;

% Time domain visual check
plot_ind = 1;
for n = 1:4
    
    figure;
    
    for m  = 1:16
        
        subplot(4,4,m)
        plot(parsed_data(:,plot_ind,n,m));
        ylim([-8000 8000])
        
        str_title = sprintf('Rx%d', m);
        title(str_title)
        
    end
    
    str_title = sprintf('Tx%d', n);
    sgtitle(str_title)
end

% Outlier check
diff_data = diff(parsed_data);
outs = isoutlier(diff_data);
plot_data = squeeze(sum(sum(outs,1),2));

figure;
plot(plot_data');
grid on;
ylabel('Number of Outliers')
xlabel('Rx Channel')
legend('Tx1', 'Tx2', 'Tx3', 'Tx4')

























