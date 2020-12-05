function [cal] = GenerateCalibration_RealDataPANUAS(scenario)
%GENERATECALIBRATION_REALDATAPANUAS Generates calibration cube from
%range-doppler cube
%   Takes scenario object as input, returns .cal field and saves to mat
%   file. Uses magnitude and phase at simsetup.cal_bin.

%% Generate Calibration Cube

% Pull magnitude and phase data
cal = scenario.cube.rd_cube(scenario.simsetup.cal_bin, ceil(end/2), :, :);

% Calculate mean magnitude
ref_mag = mean(abs(cal(:)));

% Calculate phase offset
ref_ang = cal(1)/abs(cal(1));

% Normalize relative to channel (1,1)
cal = cal/(ref_mag*ref_ang);

% Remove amplitude information
if scenario.simsetup.cal_phase
    cal = cal./abs(cal);
end

%% Save to .mat file
save(['MAT Files\Calibration\', scenario.simsetup.cal_file], 'cal');

end

