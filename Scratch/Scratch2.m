
close all;

% Average/sum over cube

avg_cube = zeros(size(debug_cube{1}));

for n = 1:(length(debug_cube)-1)
    
    avg_cube = avg_cube + debug_cube{n}/(length(debug_cube)-1);
        
end

% User Options
r_max = 200;
max_bin = find(scenario.cube.range_axis > r_max, 1);

% v_bin = 466;
v_bin = 513;

%% Heat maps
%
% RD Plot
figure('Name', 'Range-Doppler Heat Map'); 
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(avg_cube(:,:,ceil(end/2), ceil(end/2))))
title('Range-Doppler Heat Map')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%}

%% RD Surf
%
figure('Name', 'Range-Doppler Heat Map'); 
surf(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(abs(avg_cube(:,:,ceil(end/2), ceil(end/2)))), 'EdgeColor', 'none')
title('Range-Doppler Heat Map')
% set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 r_max])
%}

%% RA Plot
%
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

figure('Name', 'Azimuth-Elevation Heat Map'); 
imagesc(scenario.cube.azimuth_axis, ...
    scenario.cube.elevation_axis, ...
    10*log10(squeeze(sum(avg_cube(:, v_bin, :, :),1))))
title('Azimuth-Elevation Heat Map')
set(gca,'YDir','normal')
xlabel('Azimuth Angle [degree]','FontWeight','bold')
ylabel('Elevation Angle [degree]','FontWeight','bold')

%% PPI
%
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
















