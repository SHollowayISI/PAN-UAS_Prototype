function [detection] = DetectionSingle_PANUAS(scenario)
%DETECTIONSINGLE_PANUAS Performs target detection for PANUAS project
%   Takes scenario object as input, provides scenario.detection object as
%   output, containing information about detected targets.

%% Unpack Variables

detection = scenario.detection;
radarsetup = scenario.radarsetup;
cube = scenario.cube;

%% Perform Detection

% Estimate noise power
detection.noise_pow = pow2db(median(mean(cube.pow_cube, 1), 'all'));

% Generate detection cube
detection.detect_cube = zeros(size(cube.pow_cube));

% Determine angle slices to sweep
az_list = intersect(find(scenario.cube.azimuth_axis >= radarsetup.az_limit(1)), find(scenario.cube.azimuth_axis <= radarsetup.az_limit(2)));
el_list = intersect(find(scenario.cube.elevation_axis >= radarsetup.el_limit(1)), find(scenario.cube.elevation_axis <= radarsetup.el_limit(2)));


% Loop across angle slices
for az_slice = az_list
    for el_slice = el_list
        
        rd_cube = cube.pow_cube(:,:,az_slice,el_slice);
        
        switch radarsetup.detect_type
            case 'threshold'
                %% Perform Threshold Detection
                
                % Calculate threshold in absolute
                abs_thresh = db2pow(radarsetup.thresh + detection.noise_pow);
                
                % Perform detection
                detection.detect_cube = (cube.pow_cube > abs_thresh);
                
            case 'CFAR'
                %% Perform CFAR Detection
                
                % Set up index map
                rng_ax = intersect(find(cube.range_axis >= radarsetup.rng_limit(1)), ...
                    find(cube.range_axis <= radarsetup.rng_limit(2)));
                rng_ax = rng_ax(rng_ax >  (radarsetup.num_guard(1) + radarsetup.num_train(1)));
                dop_ax = intersect(find(abs(cube.vel_axis) >= radarsetup.vel_limit(1)), ...
                    find(abs(cube.vel_axis) <= radarsetup.vel_limit(2)));
                
                idx = [];
                idx(1,:) = repmat(rng_ax, 1, length(dop_ax));
                idx(2,:) = reshape(repmat(dop_ax, length(rng_ax), 1), 1, []);
                
                % Perform CFAR detection
                cfar_out = scenario.sim.CFAR(rd_cube, idx);
                cfar_out = reshape(cfar_out, length(rng_ax), length(dop_ax));
                
                % Perform image dilation
                if radarsetup.dilate
                    se = strel('line', 3, 90);
                    cfar_out = imdilate(cfar_out, se);
                end
                
                % Save detection cube
                detection.detect_cube(rng_ax,dop_ax,az_slice,el_slice) = cfar_out;
                
        end
    end
end

% Wrap ends of angle FFT
detection.detect_cube(:,:,size(cube.pow_cube, 3),:) = detection.detect_cube(:,:,1,:);
detection.detect_cube(:,:,:,size(cube.pow_cube, 4)) = detection.detect_cube(:,:,:,1);

%% Update Multiple CPI List

% Initialize multi-frame arrays if not created
if isempty(detection.detect_cube_multi)
    detection.detect_cube_multi = zeros(size(detection.detect_cube));
    detection.pow_cube_multi = zeros(size(cube.pow_cube));
end

% Add to number of detections per cell
detection.detect_cube_multi = detection.detect_cube_multi + detection.detect_cube;

% Add to power cube
detection.pow_cube_multi = detection.pow_cube_multi + cube.pow_cube .* detection.detect_cube;

end



