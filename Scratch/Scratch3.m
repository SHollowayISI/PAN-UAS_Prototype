
close all;

% Average/sum over cube

avg_cube = zeros(size(debug_cube{1}));

for n = 1:(length(debug_cube)-1)
    
    avg_cube = avg_cube + debug_cube{n}/(length(debug_cube)-1);
        
end

good_ind = [1 3 4 5 7 11 17 18 19 33 34 35 38 39 40 42 45 46 47 48 50 51 55 59 62 63];
minor_ind = union(good_ind, [9 12 13 14 16 20 21 24 30 37 43 44 49 54]);

% best_ind = [1 3 5 9 13 20 21 25 28 29 30 35 42 43 44 47 48 51 52 59 60];
best_ind = [1 2 3 4 6 9 10 12 20 24 25 27 38 30 31 35 43 44 46 47 48 51 52 54 56 59 60];

cube_ind = zeros(16, 4);
cube_ind(best_ind) = 1;
best_ind = find(best_ind');

good_rdcube = sum(avg_cube(:,:,good_ind), 3);
minor_rdcube = sum(avg_cube(:,:,minor_ind), 3);
all_rdcube = sum(sum(avg_cube, 3), 4);

avg_best_rdcube = zeros(size(debug_cube{1}, 1), size(debug_cube{1}, 2));
for n = 1:(length(debug_cube)-1)
    
    best_rdcube = abs(sum(debug_cube{n}(:,:,best_ind),3)).^2;
    avg_best_rdcube = avg_best_rdcube + best_rdcube/(length(debug_cube)-1);
        
end

nodop = avg_best_rdcube;
nodop(:,(ceil(end/2)-5):(ceil(end/2)+5)) = median(median(nodop));


% User Options
r_max = 200;
max_bin = find(scenario.cube.range_axis > r_max, 1);

% v_bin = 466;
v_bin = 513;

%% Heat maps
%{
% RD Heatmap
figure('Name', 'Range-Doppler Heat Map'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(good_rdcube))
title('Range-Doppler Heat Map - No Glitches')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%
figure('Name', 'Range-Doppler Heat Map'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(minor_rdcube))
title('Range-Doppler Heat Map - Minor Glitches')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

figure('Name', 'Range-Doppler Heat Map'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(all_rdcube))
title('Range-Doppler Heat Map - All Channels')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%}

figure('Name', 'Heatmap_BestChannels'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(avg_best_rdcube))
title('Range-Doppler Heat Map - Best Channels')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

figure('Name', 'Heatmap_NoDoppler'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(nodop))
title('Range-Doppler Heat Map - Best Channels Zero Doppler Removed')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

%% RD Surf
%{
% RD Surface Plot
figure('Name', 'Range-Doppler Heat Map'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(good_rdcube), 'EdgeColor', 'none')
title('Range-Doppler Surface - No Glitches')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

%
figure('Name', 'Range-Doppler Heat Map'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(good_rdcube), 'EdgeColor', 'none')
title('Range-Doppler Surface - Minor Glitches')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

figure('Name', 'Range-Doppler Heat Map'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(all_rdcube), 'EdgeColor', 'none')
title('Range-Doppler Surface - All Channels')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%}

figure('Name', 'Surface'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(avg_best_rdcube), 'EdgeColor', 'none')
title('Range-Doppler Surface - Best Channels')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

figure('Name', 'Surface_NoDoppler'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(nodop), 'EdgeColor', 'none')
title('Range-Doppler Surface - Best Channels Zero Doppler Removed')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])

%% RA Plot
%{
figure('Name', 'Range-Azimuth Heat Map'); 
imagesc(scenario.cube.azimuth_axis, ...
    scenario.cube.range_axis, ...
    10*log10(squeeze(avg_cube(:, v_bin, :, ceil(end/2)))))
title('Range-Azimuth Heat Map')
set(gca,'YDir','normal')
xlabel('Azimuth Angle [degree]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])


%RE Plot

figure('Name', 'Range-Elevation Heat Map'); 
imagesc(scenario.cube.elevation_axis, ...
    scenario.cube.range_axis, ...
    10*log10(squeeze(avg_cube(:, v_bin, ceil(end/2), :))))
title('Range-Elevation Heat Map')
set(gca,'YDir','normal')
xlabel('Elevation Angle [degree]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%}

%AE Plot
%{
figure('Name', 'Azimuth-Elevation Heat Map'); 
imagesc(scenario.cube.azimuth_axis, ...
    scenario.cube.elevation_axis, ...
    10*log10(squeeze(sum(avg_cube(:, v_bin, :, :),1))))
title('Azimuth-Elevation Heat Map')
set(gca,'YDir','normal')
xlabel('Azimuth Angle [degree]','FontWeight','bold')
ylabel('Elevation Angle [degree]','FontWeight','bold')
%}

%% PPI
%{
generateCoordinates(scenario);

%RA PPI

figure('Name', 'Range-Azimuth PPI'); 
surf(scenario.results.x_grid(1:max_bin,:,ceil(end/2)), ...
    scenario.results.y_grid(1:max_bin,:,ceil(end/2)), ...
    10*log10(squeeze(avg_cube(1:max_bin, v_bin, :, ceil(end/2)))), ...
    'EdgeColor', 'none')
title('Range-Azimuth PPI')
ylabel('Cross-Range Distance [m]','FontWeight','bold')
xlabel('Down-Range Distance [m]','FontWeight','bold')
zlabel('FFT Log Intensity [dB]','FontWeight','bold')
view(90, -90)
pbaspect([1 1 1])


%RE PPI

figure('Name', 'Range-Elevation PPI'); 
surf(squeeze(scenario.results.x_grid(1:max_bin,ceil(end/2),:)), ...
    squeeze(scenario.results.z_grid(1:max_bin,ceil(end/2),:)), ...
    10*log10(squeeze(avg_cube(1:max_bin, v_bin, ceil(end/2), :))), ...
    'EdgeColor', 'none')
title('Range-Elevation PPI')
set(gca,'YDir','normal')
ylabel('Elevation [m]','FontWeight','bold')
xlabel('Down-Range Distance [m]','FontWeight','bold')
zlabel('FFT Log Intensity [dB]','FontWeight','bold')
view(0, 90)
pbaspect([1 1 1])
%}

%{
[az_grid, el_grid] = meshgrid(scenario.cube.azimuth_axis(2:(end-1)), scenario.cube.elevation_axis(2:(end-1)));

angle_x_grid = sind(az_grid).*cosd(el_grid);
angle_y_grid = cosd(el_grid).*sind(el_grid);

%AE PPI
figure('Name', 'Azimuth-Elevation PPI'); 
surf(angle_y_grid, ...
    angle_x_grid, ...
    10*log10(squeeze(sum(avg_cube(:, ceil(end/2), 2:(end-1), 2:(end-1)),1))), ...
    'EdgeColor', 'none')
title('Azimuth-Elevation PPI')
set(gca,'YDir','normal')
xlabel('Azimuth Angle [degree]','FontWeight','bold')
ylabel('Elevation Angle [degree]','FontWeight','bold')
%}
















