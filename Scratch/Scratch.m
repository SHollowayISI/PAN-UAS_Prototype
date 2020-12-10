
tracking = struct( ...
    ...
    ... % Tracking properties
    'min_vel',      1, ...              
    'dist_thresh',  10, ...            % Mahanalobis distance association threshold
    'miss_max',     1, ...             % Number of misses required to inactivate track
    'max_hits_fa',  2, ...              % Maximum number of hits for track to still be false alarm
    'EKF',          true, ...           % T/F use extended Kalman filter
    'sigma_v',      [4.5 4.5 4.5], ...        % XYZ target motion uncertainty
    'sigma_z',      [0.5 0.5 0.5 0.1]);         % XYZnull or RAEV measurement uncertainty

scenario.radarsetup.tracking = tracking;

scenario.multi.track_list = {};
scenario.multi.active_tracks = [];

for fr = 1:8
    
    scenario.multi = Tracking_PANUAS(scenario, fr);
    
    track_list = scenario.multi.track_list;
    close all;
    
    % Plot current frame detections
%     figure;
%     for n = 1:length(track_list)
%         % Scatter plot if false alarm
%         if track_list{n}.false_alarm
%             scatter(track_list{n}.det_list(2,:), ...
%                 track_list{n}.det_list(1,:), ...
%                 '.', 'r');
%             hold on;
%             % Line of track if not
%         else
%             scatter(track_list{n}.det_list(2,:), ...
%                 track_list{n}.det_list(1,:), ...
%                 '.', 'k');
%             hold on;
%             scatter(track_list{n}.est_list(3,:), ...
%                 track_list{n}.est_list(1,:), ...
%                 '.', 'b');
%             hold on;
%             plot([track_list{n}.det_list(2,end); track_list{n}.kin_pre(3,:)], ...
%                 [track_list{n}.det_list(1,end); track_list{n}.kin_pre(1,:)], ...
%                 'r');
%         end
%     end
%     grid on;
%     xlim([-50 50])
%     ylim([0 250])
    
end
%% This
close all;
trackingOverlay(scenario, 'Resources/Google Maps/Street.png', false, true, true);






