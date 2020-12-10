
close all;

start_ind = [162, 12.5];
end_ind = [173, 12.3];

margin = [5, 10];
bin_margin = [ceil(margin(1) / scenario.cube.range_res), ceil(margin(2) / scenario.cube.vel_res)];

range_centers = linspace(start_ind(1), end_ind(1), 8)';
vel_centers = linspace(start_ind(2), end_ind(2), 8)';

[~, range_center_bins] = min(abs(scenario.cube.range_axis - range_centers), [], 2);
[~, vel_center_bins] = min(abs(scenario.cube.vel_axis - vel_centers), [], 2);

dop_sum = zeros(2*bin_margin + 1);

% figure;
for n = 1:8
    
%     subplot(4, 2, n);
%     imagesc(scenario.cube.vel_axis, scenario.cube.range_axis, ...
%         10*log10(save_cube{n}(:,:,ceil(end/2),ceil(end/2))));
%     set(gca, 'YDir', 'normal')
%     ylim([range_centers(n)-margin(1) range_centers(n)+margin(1)])
%     xlim([vel_centers(n)-margin(2) vel_centers(n)+margin(2)])
    
    dop_only_cube = save_cube{n};
    dop_only_cube(:,(ceil(end/2)-3):(ceil(end/2)+3),:,:) = 0;
    dop_window = dop_only_cube((range_center_bins(n)-bin_margin(1)):(range_center_bins(n)+bin_margin(1)), ...
        (vel_center_bins(n)-bin_margin(2)):(vel_center_bins(n)+bin_margin(2)), ceil(end/2), ceil(end/2));
    dop_sum = dop_sum + dop_window;
    
end

figure('Name', 'MicroDoppler Detail');

r_axis = (-bin_margin(1):bin_margin(1))*scenario.cube.range_res;
v_axis = (-bin_margin(2):bin_margin(2))*scenario.cube.vel_res;

imagesc(v_axis, r_axis, 10*log10(dop_sum));
set(gca, 'YDir', 'normal');
ylabel('Range Offset from Center [m]', 'FontWeight', 'bold')
xlabel('Doppler Offset from Center [m/s]', 'FontWeight', 'bold')

fig_path = ['Figures\', scenario.simsetup.file_out, '\' scenario.simsetup.file_in, '\'];
SaveFigures("", fig_path, ['.png']);













