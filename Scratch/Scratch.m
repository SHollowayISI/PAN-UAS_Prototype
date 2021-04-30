
close all

for n = 1:8
    save_cube_reduced{n} = save_cube{n}(:,:,9,9);
    region{n} = save_cube_reduced{n}(11:33, 46:90);
end

for n = 1:8
    
    [m(n), I] = max(region{n}, [], 'all', 'linear');
    [r, v(n)] = ind2sub(size(region{n}), I);
    
    range(n) = scenario.cube.range_axis(r + 10);
    vel(n) = scenario.cube.vel_axis(v(n) + 45);
    
end


sum_region = zeros(size(region{1}));
sum_cube = zeros(size(save_cube_reduced{1}, 1), size(save_cube_reduced{1}, 2)-10);
for n = 1:2:7
    
%     shift_bins = v(n+1) - v(n);
    shift_bins = 0;
    shifted_region{n} = region{n};
    shifted_region{n+1} = save_cube_reduced{n+1}(11:33, (46:90) + shift_bins);
    
    shifted_cube{n} = save_cube_reduced{n}(:, (6:(end-5)));
    shifted_cube{n+1} = save_cube_reduced{n+1}(:, (6:(end-5)) + shift_bins);
    
    diff_region{n} = abs(shifted_region{n} - shifted_region{n+1});
    sum_region = sum_region + (diff_region{n}/4);
    
    diff_cube{n} = abs(shifted_cube{n} - shifted_cube{n+1});
    sum_cube = sum_cube + (diff_cube{n}/4);
end


str = sprintf('Non-Zero Doppler Swath Plot %dm Max', 300);
figure('Name', str);
dopplerMinMax = [3 30];
dop_ind = intersect(find(abs(scenario.cube.vel_axis) >= dopplerMinMax(1)), ...
    find(abs(scenario.cube.vel_axis) <= dopplerMinMax(2)));
plot(scenario.cube.range_axis, 10*log10(mean(sum_cube(:, dop_ind), 2)));
grid on;
grid minor;
xlim([0 300]);
ylim([60 140]);
xlabel('Range [m]','FontWeight','bold');
ylabel('FFT Log Intensity [dB]','FontWeight','bold');

str = sprintf('Non-Zero Doppler Swath Plot %dm Max', 1500);
figure('Name', str);
dopplerMinMax = [3 30];
dop_ind = intersect(find(abs(scenario.cube.vel_axis) >= dopplerMinMax(1)), ...
    find(abs(scenario.cube.vel_axis) <= dopplerMinMax(2)));
plot(scenario.cube.range_axis, 10*log10(mean(sum_cube(:, dop_ind), 2)));
grid on;
grid minor;
xlim([0 1500]);
ylim([60 140]);
xlabel('Range [m]','FontWeight','bold');
ylabel('FFT Log Intensity [dB]','FontWeight','bold');

str = sprintf('Zero Doppler Range Plot %dm Max', 300);
figure('Name', str);
plot(scenario.cube.range_axis, 10*log10(sum_cube(:, ceil(end/2))));
xlabel('Range [m]','FontWeight','bold');
ylabel('FFT Log Intensity [dB]','FontWeight','bold');
grid on;
grid minor;
xlim([0 300])
ylim([110 190]);

str = sprintf('Zero Doppler Range Plot %dm Max', 1500);
figure('Name', str);
plot(scenario.cube.range_axis, 10*log10(sum_cube(:, ceil(end/2))));
xlabel('Range [m]','FontWeight','bold');
ylabel('FFT Log Intensity [dB]','FontWeight','bold');
grid on;
grid minor;
xlim([0 1500])
ylim([70 190]);

figure('Name', 'Range-Doppler Heat Map');
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    10*log10(sum_cube))
title('Range-Doppler Heat Map')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 300])

data = 10*log10(sum_cube);
data(:, floor((end/2)-3):ceil((end/2)+3)) = median(data, 'all');
figure('Name', 'Non-Zero Doppler Heat Map');
imagesc(scenario.cube.vel_axis, ...
    scenario.cube.range_axis, ...
    data)
title('Range-Doppler Heat Map')
set(gca,'YDir','normal')
xlabel('Velocity [m/s]','FontWeight','bold')
ylabel('Range [m]','FontWeight','bold')
ylim([0 300])


SaveFigures("", 'Figures/new_calibration/without_shift/', '.png');

% figure;
% for n = 1:8
%     subplot(8, 1, n);
%     surfc(10*log10(shifted_region{n}));
%     view(0,0);
% end


