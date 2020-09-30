
%% Setup

% Bookkeeping
% clear variables
close all

% Initialization
scenario = RadarScenario_RealDataPANUAS;

% Set up simulation parameters
SetupSimulation_RealDataPANUAS

% Set up transceiver and channel parameters
SetupRadarScenario_RealDataPANUAS

% Parse Data
scenario.simsetup.file_in = 'Input Data/Test 09182020/test_0918_115303_60m';
scenario = DataParsing_RealDataPANUAS(scenario);
data_60m = squeeze(scenario.parsed_data(:,1,:,:));

scenario.simsetup.file_in = 'Input Data/Test 09182020/test_0918_115551_40m';
scenario = DataParsing_RealDataPANUAS(scenario);
data_40m = squeeze(scenario.parsed_data(:,1,:,:));

scenario.simsetup.file_in = 'Input Data/Test 09182020/test_0918_115843_25m';
scenario = DataParsing_RealDataPANUAS(scenario);
data_25m = squeeze(scenario.parsed_data(:,1,:,:));

scenario.simsetup.file_in = 'Input Data/Test 09172020/test_0917_114913_active_2';
scenario = DataParsing_RealDataPANUAS(scenario);
data_0917_active = squeeze(scenario.parsed_data(:,1,:,:));

scenario.simsetup.file_in = 'Input Data/Test 09172020/test_0917_115310_A1_terminated';
scenario = DataParsing_RealDataPANUAS(scenario);
data_0917_term = squeeze(scenario.parsed_data(:,1,:,:));


%% Time Domain Debug
%

outlier_data = data_60m;
num_out = zeros(4,16);
for t = 1:4
    for r = 1:16
        
        ab_diff = abs(diff(outlier_data(:,t,r)));
        num_out(t,r) = nnz(isoutlier(ab_diff));
        
    end
end

figure;
plot(num_out')
title(scenario.simsetup.file_in((end-2):end))
legend('Tx1', 'Tx2', 'Tx3', 'Tx4')
xlabel('Rx channel')
ylabel('Number of outliers')
%}

%% Compare channels across different data

t = 4;
r = 16;

figure;

plot(data_25m(:,t,r));
hold on;
plot(data_40m(:,t,r));
hold on;
plot(data_60m(:,t,r));
% hold on;
% plot(data_0917_term(:,t,r));
% hold on;
% plot(data_0917_active(:,t,r));








