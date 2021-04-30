
close all;

x_limits = [-30 30];
y_limits = [0 300];

inco_cube = scenario.cube.incoherent_cube(:,:,ceil(end/2),ceil(end/2));
inco_cube(:,(ceil(end/2)-3):(ceil(end/2)+3)) = median(inco_cube, 'all');

figure('Name', 'Moving Target Plot');
imagesc(scenario.cube.vel_axis, scenario.cube.range_axis, 10*log10(inco_cube))
hold on
set(gca, 'YDir', 'normal')
xlim(x_limits)
ylim(y_limits)

% scatter(scenario.detection.detect_list.vel, scenario.detection.detect_list.range, ...
%     'r', 'o');
scatter(scenario.detection.detect_list.vel, scenario.detection.detect_list.range, ...
    'r', '.');

% x_list = (scenario.detection.detect_list.vel - x_limits(1)) / diff(x_limits);
x_list = scenario.detection.detect_list.vel;
% y_list = (scenario.detection.detect_list.range - y_limits(1)) / diff(y_limits);
y_list = scenario.detection.detect_list.range;

x_offset = 0.25;
y_offset = 0;

for n = 1:length(scenario.detection.detect_list.range)
    str = sprintf('Altitude: %0.1fm', scenario.detection.detect_list.cart(3,n));
    text(x_list(n) + x_offset, y_list(n) + y_offset, str);
end
