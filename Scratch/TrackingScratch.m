
load('MAT Files/circle.mat');
% ylimits = [30 45];
% name = 'Zoom_Circle';
% ylimits = [0 50];
% name = 'Full_Circle';
scenario.multi = multi;

load('MAT Files/going50.mat');
% ylimits = [50 70];
% name = 'Zoom_50m';
% ylimits = [0 70];
% name = 'Full_50m';
for n = 1:8
    scenario.multi.detect_list{n}.range = [scenario.multi.detect_list{n}.range, multi.detect_list{n}.range];
    scenario.multi.detect_list{n}.vel = [scenario.multi.detect_list{n}.vel, multi.detect_list{n}.vel];
    scenario.multi.detect_list{n}.az = [scenario.multi.detect_list{n}.az, multi.detect_list{n}.az];
    scenario.multi.detect_list{n}.el = [scenario.multi.detect_list{n}.el, multi.detect_list{n}.el];
    scenario.multi.detect_list{n}.cart = [scenario.multi.detect_list{n}.cart, multi.detect_list{n}.cart];
    scenario.multi.detect_list{n}.SNR = [scenario.multi.detect_list{n}.SNR, multi.detect_list{n}.SNR];
    scenario.multi.detect_list{n}.num_detect = scenario.multi.detect_list{n}.num_detect + 1;
end

load('MAT Files/going100.mat');
% ylimits = [100 120];
% name = 'Zoom_100m';
% ylimits = [0 120];
% name = 'Full_100m';
for n = 1:8
    scenario.multi.detect_list{n}.range = [scenario.multi.detect_list{n}.range, multi.detect_list{n}.range];
    scenario.multi.detect_list{n}.vel = [scenario.multi.detect_list{n}.vel, multi.detect_list{n}.vel];
    scenario.multi.detect_list{n}.az = [scenario.multi.detect_list{n}.az, multi.detect_list{n}.az];
    scenario.multi.detect_list{n}.el = [scenario.multi.detect_list{n}.el, multi.detect_list{n}.el];
    scenario.multi.detect_list{n}.cart = [scenario.multi.detect_list{n}.cart, multi.detect_list{n}.cart];
    scenario.multi.detect_list{n}.SNR = [scenario.multi.detect_list{n}.SNR, multi.detect_list{n}.SNR];
    scenario.multi.detect_list{n}.num_detect = scenario.multi.detect_list{n}.num_detect + 1;
end

load('MAT Files/going150.mat');
% ylimits = [150 170];
% name = 'Zoom_150m';
% ylimits = [0 170];
% name = 'Full_150m';
for n = 1:8
    scenario.multi.detect_list{n}.range = [scenario.multi.detect_list{n}.range, multi.detect_list{n}.range];
    scenario.multi.detect_list{n}.vel = [scenario.multi.detect_list{n}.vel, multi.detect_list{n}.vel];
    scenario.multi.detect_list{n}.az = [scenario.multi.detect_list{n}.az, multi.detect_list{n}.az];
    scenario.multi.detect_list{n}.el = [scenario.multi.detect_list{n}.el, multi.detect_list{n}.el];
    scenario.multi.detect_list{n}.cart = [scenario.multi.detect_list{n}.cart, multi.detect_list{n}.cart];
    scenario.multi.detect_list{n}.SNR = [scenario.multi.detect_list{n}.SNR, multi.detect_list{n}.SNR];
    scenario.multi.detect_list{n}.num_detect = scenario.multi.detect_list{n}.num_detect + 1;
end

load('MAT Files/going200.mat');
% ylimits = [180 260];
% name = 'Zoom_200m';
% ylimits = [0 250];
% name = 'Full_200m';


multi.detect_list{3}.range = [];
multi.detect_list{3}.vel = [];
multi.detect_list{3}.az = [];
multi.detect_list{3}.el = [];
multi.detect_list{3}.cart = [];
multi.detect_list{3}.SNR = [];
multi.detect_list{3}.num_detect = 0;


for n = 1:8
    if multi.detect_list{n}.num_detect > 0
        scenario.multi.detect_list{n}.range = [scenario.multi.detect_list{n}.range, multi.detect_list{n}.range];
        scenario.multi.detect_list{n}.vel = [scenario.multi.detect_list{n}.vel, multi.detect_list{n}.vel];
        scenario.multi.detect_list{n}.az = [scenario.multi.detect_list{n}.az, multi.detect_list{n}.az];
        scenario.multi.detect_list{n}.el = [scenario.multi.detect_list{n}.el, multi.detect_list{n}.el];
        scenario.multi.detect_list{n}.cart = [scenario.multi.detect_list{n}.cart, multi.detect_list{n}.cart];
        scenario.multi.detect_list{n}.SNR = [scenario.multi.detect_list{n}.SNR, multi.detect_list{n}.SNR];
        scenario.multi.detect_list{n}.num_detect = scenario.multi.detect_list{n}.num_detect + 1;
    end
end

ylimits = [0 250];
name = 'Full_Combined';

% scenario.multi = multi;

tracking = struct( ...
    ...
    ... % Tracking properties
    'min_vel',      1, ...
    'dist_thresh',  50, ...            % Mahanalobis distance association threshold
    'miss_max',     2, ...             % Number of misses required to inactivate track
    'max_hits_fa',  2, ...              % Maximum number of hits for track to still be false alarm
    'EKF',          true, ...           % T/F use extended Kalman filter
    'sigma_v',      [10 10 1], ...        % XYZ target motion uncertainty
    'sigma_z',      [0.95 deg2rad(7.5) deg2rad(7.5) 0.25], ...         % XYZnull or RAEV measurement uncertainty
    'RDCoupling',   0.0029);
% KF:  [1 1 1]
% EKF: [1 7.5 7.5 0.25]

for n = 1:length(scenario.multi.detect_list)
    for m = 1:length(scenario.multi.detect_list{n})
        scenario.multi.detect_list{n}(m).el = scenario.multi.detect_list{n}(m).el + deg2rad(11.319);
    end
end

scenario.radarsetup.tracking = tracking;
scenario.multi.track_list = {};
scenario.multi.active_tracks = [];

for fr = 1:8
    
    scenario.multi = Tracking_PANUAS(scenario, fr);
    
    track_list = scenario.multi.track_list;
    close all;
    
    % Plot current frame detections
    figure;
    for n = 1:length(track_list)
        % Scatter plot if false alarm
        if track_list{n}.false_alarm
            scatter(track_list{n}.det_list(2,:), ...
                track_list{n}.det_list(1,:), ...
                '.', 'r');
            hold on;
            % Line of track if not
        else
            scatter(track_list{n}.det_list(2,:), ...
                track_list{n}.det_list(1,:), ...
                '.', 'k');
            hold on;
            scatter(track_list{n}.est_list(3,2:end), ...
                track_list{n}.est_list(1,2:end), ...
                '.', 'b');
            hold on;
            plot([track_list{n}.det_list(2,end); track_list{n}.kin_pre(3,:)], ...
                [track_list{n}.det_list(1,end); track_list{n}.kin_pre(1,:)], ...
                'r');
        end
    end
    grid on;
    xlim([-diff(ylimits)/2, diff(ylimits)/2])
    ylim(ylimits)
    
end
%% This
close all;
% trackingOverlay(scenario, 'Resources/Google Maps/Street.png', false, true, true);
% viewTracking(scenario, 'scatter', true, true)


%% Tracking


% Pass in variables
track_list  = scenario.multi.track_list;

% Generate plot
figure('Name', 'Horizontal Tracking');
% Add tracks to plot
for n = 1:length(track_list)
    
    % Scatter for detection
    scatter(track_list{n}.det_list(2,:), ...
        track_list{n}.det_list(1,:), ...
        30, 'r', '+');
    hold on;
    
    % Scatter for tracks
    scatter(track_list{n}.est_list(3,:), ...
        track_list{n}.est_list(1,:), ...
        30, 'k', '.');
    hold on;
    
    % Lines for tracks
    plot(track_list{n}.est_list(3,:), ...
        track_list{n}.est_list(1,:), 'b');
    hold on;
end
% Add radar location to plot
scatter(0, 0, 'filled', 'r', 'v');

% Correct plot limits
ylim(ylimits)
ax = gca;
ax.XLim = [-diff(ax.YLim)/2, diff(ax.YLim)/2];
pbaspect([1 1 1])
grid on;

% Add labels
ylabel('Altitude [m]', 'FontWeight', 'bold')
xlabel('Down Range Distance [m]', 'FontWeight', 'bold')

figure('Name', 'Vertical Tracking');
% Add tracks to plot
for n = 1:length(track_list)
    
    % Scatter for detection
    scatter(track_list{n}.det_list(1,:), ...
        track_list{n}.det_list(3,:), ...
        30, 'r', '+');
    hold on;
    
    % Scatter for tracks
    scatter(track_list{n}.est_list(1,:), ...
        track_list{n}.est_list(5,:), ...
        30, 'k', '.');
    hold on;
    
    % Lines for tracks
    plot(track_list{n}.est_list(1,:), ...
        track_list{n}.est_list(5,:), 'b');
    hold on;
end
% Add radar location to plot
scatter(0, 0, 'filled', 'r', 'v');

% Correct plot limits
xlim(ylimits)
ax = gca;
ax.YLim = [0, 20];
pbaspect([diff(ylimits) diff(ax.YLim) 1])
grid on;

% Add labels
ylabel('Down Range Distance [m]', 'FontWeight', 'bold')
xlabel('Cross Range Distance [m]', 'FontWeight', 'bold')

%% Tracking google maps overlay

%
% Pass in variables
track_list  = scenario.multi.track_list;
static_list = scenario.multi.static_list;
% Generate plot
figure('Name', 'Tracking Results Map Overlay', ...
        'units', 'normalized', 'outerposition', [0 0 1 1]);
    
% Show image
img = imread('Resources/Google Maps/Street.png');
image('CData', img, 'XData', [-190 180], 'YData', [270 -19], ...
    'AlphaData', 0.75);
hold on;
% Add tracks to plot
for n = 1:length(track_list)
    
    % Scatter for detection
    scatter(track_list{n}.det_list(2,:), ...
        track_list{n}.det_list(1,:), ...
        30, 'r', '+');
    hold on;
    
    % Scatter for tracks
    scatter(track_list{n}.est_list(3,:), ...
        track_list{n}.est_list(1,:), ...
        30, 'k', '.');
    hold on;
    
    % Lines for tracks
    plot(track_list{n}.est_list(3,:), ...
        track_list{n}.est_list(1,:), 'b');
    hold on;
end

% Add radar location to plot
scatter(0, 0, 'filled', 'r', 'v');

% Correct plot limits
ylim([-25 275])
xlim([-150 150])
pbaspect([1 1 1])
grid on;
% Add labels
ylabel('Down Range Distance [m]', 'FontWeight', 'bold')
xlabel('Cross Range Distance [m]', 'FontWeight', 'bold')
%}

SaveFigures(name, 'Figures/tracking_fixed_with200m', '.png')
% close all;










