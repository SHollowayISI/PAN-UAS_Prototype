%% PANUAS Radar System - Main Simulation Loop
%{

    Sean Holloway
    PANUAS Main Simulation Loop
    
    This file specifies performs simulation, signal processing, detection,
    data processing, and results collection for PANUAS system.

    Use script 'FullSystem_PANUAS.m' to run scenarios.
    
%}

%% Data Parsing

% Return rx signal in format fast time x slow time x rx-channel
scenario = DataParsing_RealDataPANUAS(scenario);

%% Signal Processing

% Perform signal processing on received signal
scenario.cube = SignalProcessing_Calibration_RealDataPANUAS(scenario);

% Generate calibration cube
scenario.cal = GenerateCalibration_RealDataPANUAS(scenario);


%% DEBUG: PLOT
figure;
plot(10*log10(sum(sum(abs(scenario.cube.range_cube(:,ceil(end/2),:,:)), 3), 4)))
title(scenario.simsetup.file_in((end-2):end))

% Plot calibration magnitude and phase
figure
subplot(2, 1, 1)
plot(20*log10(squeeze(abs(scenario.cal))'))
title('Calibration Amplitude')
legend('Tx1', 'Tx2', 'Tx3', 'Tx4')
xlabel('Rx channel')
ylabel('Relative Amplitude [dB]')
grid on

subplot(2, 1, 2)
plot(squeeze((180/pi)*angle(scenario.cal))')
title('Calibration Phase')
legend('Tx1', 'Tx2', 'Tx3', 'Tx4')
xlabel('Rx channel')
ylabel('Relative Phase Angle [deg]')
grid on

%% DEBUG: GLITCH PLOTS

% Plot magnitude with glitch designator
figure
plot(20*log10(squeeze(abs(scenario.cal))'))
title('Calibration Amplitude')
xlabel('Rx channel')
ylabel('Relative Amplitude [dB]')
grid on
hold on

% minor_list = [3 4 6 10 13 20 24 30 43 51 52 53 54 59];
minor_list = [31 36];

% major_list = [7 8 11 14 15 16 17 18 19 22 23 31 36 38 39 40 50 55 56 57 61 62 63 64];
major_list = [7 8 11 14 15 16 17 18 19 22 23 38 39 40 50 57 62 63 64];

ys = 20*log10(abs(squeeze(scenario.cal)'));

minor_y = ys(minor_list);
major_y = ys(major_list);

scatter(mod(minor_list-1, 16)+1, minor_y, 'filled', 'MarkerFaceColor', [0.9290 0.6940 0.1250]);
scatter(mod(major_list-1, 16)+1, major_y, 'r', 'filled');

legend('Tx1', 'Tx2', 'Tx3', 'Tx4', 'Minor Glitch', 'Major Glitch')

% Figure out good values without major glitches
goodcal_list = setdiff(find(abs(ys) <= 2), major_list)














