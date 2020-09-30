function [cal] = GenerateCalibration_RealDataPANUAS(scenario)
%GENERATECALIBRATION_REALDATAPANUAS Summary of this function goes here
%   Detailed explanation goes here

%% Generate Calibration Cube

% Pull magnitude and phase data
cal = scenario.cube.rd_cube(scenario.simsetup.cal_bin, ceil(end/2), :, :);

% Calculate mean magnitude
ref_mag = mean(abs(cal(:)));

% Calculate phase offset
ref_ang = cal(1)/abs(cal(1));

% Normalize relative to channel (1,1)
cal = cal/(ref_mag*ref_ang);


%% Save to .mat file
save(scenario.simsetup.cal_file, 'cal');

end

