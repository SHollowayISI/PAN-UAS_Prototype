function [multi] = Tracking_PANUAS(scenario, frame)
%TRACKING_PANUAS Multi-Target Tracking system for PAN-UAS project
%   Takes scenario object as input, returns modified multi object as child of
%   scenario.


%% Unpack Variables

radarsetup = scenario.radarsetup;
multi = scenario.multi;

%% Target-to-Track Association

% Initialize variables
detect_ind_list = [];
hit_list = [];
multi.static_list{frame} = struct( ...
    'cart',     [], ...
    'SNR',      []);

% Loop through all pre-existing tracks
for tr = multi.active_tracks
    
    % Infinite distance if no detection found
    dist = Inf;
    detect_ind = [];
    
    % Find detections in track uncertainty area
    for de = 1:multi.detect_list{frame}.num_detect
        
        % Calculate Mahanalobis distance
        dist_check = MahanalobisDistance( ...
            multi.detect_list{frame}, de, multi.track_list{tr}, ...
            radarsetup.tracking.EKF, radarsetup.tracking.sigma_z);
        
        % If detection is within bound and closer than previous
        if (dist_check < dist) && (dist_check < radarsetup.tracking.dist_thresh)
            
            % Save new distance
            dist = dist_check;
            detect_ind = de;
            
            % Assign detection coordinates
            multi.track_list{tr}.meas.range = multi.detect_list{frame}.range(de);
            multi.track_list{tr}.meas.az = multi.detect_list{frame}.az(de);
            multi.track_list{tr}.meas.el = multi.detect_list{frame}.el(de);
            multi.track_list{tr}.meas.vel = multi.detect_list{frame}.vel(de);
            multi.track_list{tr}.meas.cart = multi.detect_list{frame}.cart(:,de);
            
        end
    end
    
    % Check if a detection was found
    if isinf(dist)  % Non-detection case
        
        % Increment counter of misses if no detection
        multi.track_list{tr}.misses = multi.track_list{tr}.misses + 1;
        
        % Deactivate track if too many misses
        if multi.track_list{tr}.misses > radarsetup.tracking.miss_max
            
            % Remove from active track
            multi.active_tracks(multi.active_tracks == tr) = [];
            
        end
    else            % Detection case
        
        % Update timestep
        time_step(tr) = multi.track_list{tr}.misses + 1;
        
        % Set counter of misses to zero, increment number of hits
        multi.track_list{tr}.misses = 0;
        multi.track_list{tr}.hits = multi.track_list{tr}.hits + 1;
        
        % Append detection to detection list
        multi.track_list{tr}.det_list(:,end+1) = multi.track_list{tr}.meas.cart;
        
        % Add detection index to list
        detect_ind_list(end+1) = detect_ind;
        
        % Add hit index to list
        hit_list(end+1) = tr;
        
    end
    
    % Set false alarm flag if too few hits
    multi.track_list{tr}.false_alarm = ...
        (multi.track_list{tr}.hits < radarsetup.tracking.max_hits_fa);
    
end

% Create list of non-associated indices
ind = 1:multi.detect_list{frame}.num_detect;
ind(detect_ind_list) = [];

% Loop through non-associated detections
for de = ind
    
    % Track only targets above minimum absolute value velocity
    if (abs(multi.detect_list{frame}.vel(de)) > radarsetup.tracking.min_vel)
        
        % Pass coordinates from detection list
        meas = struct( ...
            'range',      multi.detect_list{frame}.range(de), ...
            'az',         multi.detect_list{frame}.az(de), ...
            'el',         multi.detect_list{frame}.el(de), ...
            'vel',        multi.detect_list{frame}.vel(de), ...
            'cart',       multi.detect_list{frame}.cart(:,de));
        
        % Construct kinematic uncertainty
        kin_pre = [meas.cart(1); meas.vel * cosd(meas.az) * cosd(meas.el); ...
            meas.cart(2); meas.vel * sind(meas.az) * cosd(meas.el); ...
            meas.cart(3); meas.vel * sind(meas.el)];
        kin_pre = kin_pre(:);
        
        % Create track with new detection
        multi.track_list{end+1} = struct( ...
            'hits',               1, ...
            'misses',             0, ...
            'false_alarm',        true, ...
            'kin_pre',            kin_pre, ...
            'unc_pre',            [], ...
            'meas',               meas, ...
            'det_list',           meas.cart, ...
            'est_list',           []);
        
        % Update track lists
        multi.active_tracks(end+1) = length(multi.track_list);
        hit_list(end+1) = length(multi.track_list);
        time_step(length(multi.track_list)) = 1;
        
    else
        
        % Save static target to list
        multi.static_list{frame}.cart(:,end+1) = multi.detect_list{frame}.cart(:,de);
        multi.static_list{frame}.SNR(end+1) = multi.detect_list{frame}.SNR(de);
        
    end
end


%% Kalman Filtering


% Loop through active tracks and update Kalman tracking
for tr = hit_list
    
    % Unpack current track
    curr_tr = multi.track_list{tr};
    
    % Calculate timestep
    kalman_Tm = radarsetup.t_fr * time_step(tr);
    
    % Run single step of Kalman predictor-corrector algorithm
    [kin_est, kin_pre, unc_pre] = KalmanFilter_Step( ...
        curr_tr.meas, curr_tr.kin_pre, curr_tr.unc_pre, kalman_Tm, ...
        radarsetup.tracking.sigma_v, radarsetup.tracking.sigma_z, ...
        radarsetup.tracking.EKF);
    
    % Re-pack to current track
    curr_tr.est_list(:,end+1) = kin_est;
    curr_tr.kin_pre = kin_pre;
    curr_tr.unc_pre = unc_pre;
    multi.track_list{tr} = curr_tr;
    
    
end


end

