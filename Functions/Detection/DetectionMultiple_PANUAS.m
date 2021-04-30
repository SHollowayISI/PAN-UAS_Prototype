function [detection] = DetectionMultiple_PANUAS(scenario)
%DETECTIONMULTIPLE_PANUAS Summary of this function goes here
%   Detailed explanation goes here

%% Unpack Variables

detection = scenario.detection;
radarsetup = scenario.radarsetup;
cube = scenario.cube;
sim = scenario.sim;

% Load angular offset
load_in = load('Resources\AngleDopplerOffset.mat');
offset_angle = load_in.offset_smooth;
offset_vel = load_in.vel_axis;

%% Perform Binary Integration

% Find over-threshold detections
bw_cube = (detection.detect_cube_multi >= radarsetup.det_m);

% Average power for multiple-detection indices
avg_cube = bw_cube .* (detection.pow_cube_multi ./ detection.detect_cube_multi);
avg_cube(isnan(avg_cube)) = 0;

%% Determine Individual Object Coordinates

% Find connected objects in R-D cube
cc = bwconncomp(bw_cube);
regions = regionprops(cc, avg_cube, 'WeightedCentroid');

% Generate list of detection coordinates
detection.detect_list.range = [];
detection.detect_list.vel = [];
detection.detect_list.az = [];
detection.detect_list.el = [];
detection.detect_list.cart = [];
detection.detect_list.SNR = [];
detection.detect_list.num_detect = length(regions);

% Determine Centroid of azimuth-elevation slice
for n = 1:length(regions)
    
    % Shorten variable for ease of typing
    ind = regions(n).WeightedCentroid;
    
    % Store direct coordinates
    detection.detect_list.range(end+1) = interp1(cube.range_axis, ind(2));
    detection.detect_list.vel(end+1) = interp1(cube.vel_axis, ind(1));
    
    % Store SNR
    detection.detect_list.SNR(end+1) = 10*log10(max(avg_cube(cc.PixelIdxList{n}), [], 'all')) ...
        - detection.noise_pow;
    
    % Find angle of attack using AoA estimator
%     ant_slice = squeeze(cube.mimo_cube(round(ind(2)), round(ind(1)), :))';
%     [~, ang] = sim.AoA(ant_slice);

    % Find angle of attack using centroid estimator
    ang_slice = squeeze(cube.pow_cube(round(ind(2)), round(ind(1)), :, :));
    ang(1) = sum(ang_slice .* cube.azimuth_axis', 'all') / sum(ang_slice, 'all');
    ang(2) = sum(ang_slice .* cube.elevation_axis, 'all') / sum(ang_slice, 'all');
    
    % Correct TDM angle-doppler association
    if strcmp(radarsetup.mimo_type, 'TDM')
%         detection.detect_list.az(end+1) = ang(1) - ...
%             interp1(offset_vel, offset_angle(:,1), detection.detect_list.vel(end), 'linear', 'extrap');
%         detection.detect_list.el(end+1) = ang(2) - ...
%             interp1(offset_vel, offset_angle(:,2), detection.detect_list.vel(end), 'linear', 'extrap');
        ang_mod(1) = ang(1) - radarsetup.v_az_coeff * detection.detect_list.vel(end);
        ang_mod(2) = ang(2) - radarsetup.v_el_coeff * detection.detect_list.vel(end);
        detection.detect_list.az(end+1) = ang_mod(1);
        detection.detect_list.el(end+1) = ang_mod(2);
    else
        detection.detect_list.az(end+1) = ang(1);
        detection.detect_list.el(end+1) = ang(2);
    end
    
    % Remove detections out of search area
    if (ang_mod(1) < radarsetup.az_limit(1)) || ...
            (ang_mod(1) > radarsetup.az_limit(2)) || ...
            (ang_mod(2) < radarsetup.el_limit(1)) || ...
            (ang_mod(2) > radarsetup.el_limit(2)) || ...
            (detection.detect_list.SNR(end) < radarsetup.snr_min)
        detection.detect_list.az(end) = [];
        detection.detect_list.el(end) = [];
        detection.detect_list.range(end) = [];
        detection.detect_list.vel(end) = [];
        detection.detect_list.SNR(end) = [];
        detection.detect_list.num_detect = detection.detect_list.num_detect - 1;
        
    else
    
        % Store derived coordinates
        detection.detect_list.cart(:,end+1) = detection.detect_list.range(end) * ...
            [cosd(detection.detect_list.el(end)) * cosd(detection.detect_list.az(end)); ...
            cosd(detection.detect_list.el(end)) * sind(detection.detect_list.az(end));
            sind(detection.detect_list.el(end))];
    end
    
end



end

