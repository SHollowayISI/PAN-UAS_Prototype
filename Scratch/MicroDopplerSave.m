
close all;

r_lim = [163, 172];

r_diff = abs(diff(r_lim));
diff_bins = ceil(r_diff / scenario.cube.range_res);

range_centers = linspace(r_lim(1), r_lim(2), 8)';

[~, range_diff_bins] = min(abs(scenario.cube.range_axis - range_centers), [], 2);
range_diff_bins = range_diff_bins - ceil(r_lim(1) / scenario.cube.range_res);

dop_sum = zeros(size(save_cube{1}, 1) - diff_bins*2, size(save_cube{1},2));

% figure;
for n = 1:8
    
%     subplot(4, 2, n);
%     imagesc(scenario.cube.vel_axis, scenario.cube.range_axis, ...
%         10*log10(save_cube{n}(:,:,ceil(end/2),ceil(end/2))));
%     set(gca, 'YDir', 'normal')
%     ylim([range_centers(n)-margin(1) range_centers(n)+margin(1)])
%     xlim([vel_centers(n)-margin(2) vel_centers(n)+margin(2)])
    
    dop_only_cube = save_cube{n}(:,:,ceil(end/2),ceil(end/2));
    dop_only_cube(:,(ceil(end/2)-3):(ceil(end/2)+3)) = median(dop_only_cube, 'all');
    dop_window = dop_only_cube((diff_bins+range_diff_bins(n)+1):(end-diff_bins+range_diff_bins(n)),:);
    dop_sum = dop_sum + dop_window;
    
end
    
figure('Name', 'MicroDoppler Detail');

r_axis = scenario.cube.range_axis((diff_bins+1):(end-diff_bins));
v_axis = scenario.cube.vel_axis;

imagesc(v_axis, r_axis, 10*log10(dop_sum));
set(gca, 'YDir', 'normal');
ylabel('Range [m]', 'FontWeight', 'bold')
xlabel('Velocity [m/s]', 'FontWeight', 'bold')
xlim([-40 40])
ylim([25 300])


fig_path = ['Figures\', scenario.simsetup.file_out, '\' scenario.simsetup.file_in, '\'];
SaveFigures("", fig_path, ['.png']);













