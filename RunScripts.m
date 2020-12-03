clear variables
close all


fold = dir('Input Data/drone_5');
k = 1;
for i = 1:length(fold)
    if not(fold(i).isdir)
        files{k} = fold(i).name(1:end-4);
        k = k+1;
    end
end

% files = {'reflector_about_40Meters_1125_152509'};

for file_loop = 1:length(files)
    
    
    
    file_in = files{file_loop}
    FullSystem_RealDataPANUAS
    
    %%
    
    max_range = 300;
    r_max_ind = find(scenario.cube.range_axis > max_range, 1);
    
    %{
    figure('Name', 'Range-Doppler Surface Coherent Integration');
    surf(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.co_cube), ...
        'EdgeColor', 'none')
    title('Range-Doppler Surface Coherent Integration')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
    ylim([0 max_range]);
    zlim([0 200]);
    
    figure('Name', 'Range-Doppler Surface Incoherent Integration');
    surf(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.inco_cube), ...
        'EdgeColor', 'none')
    title('Range-Doppler Surface Incoherent Integration')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
    ylim([0 max_range]);
    zlim([0 200]);
    
    figure('Name', 'Range-Doppler SurfaceSingle Channel');
    surf(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.single_cube), ...
        'EdgeColor', 'none')
    title('Range-Doppler Surface Single Channel')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
    ylim([0 max_range]);
    zlim([0 200]);
    %}
    
    %%
    %{
    % Phase plot for 11/3
    figure('Name', 'Phase Across Chirps');
    phases = rad2deg(angle(scenario.cube.range_cube(283,:,:,:)));
    phase_mean = mean(mean(phases, 3), 4);
    plot(phase_mean);
    title('Phase Across Chirps');
    xlabel('Chirp #','FontWeight','bold');
    ylabel('Phase [degrees]','FontWeight','bold');
    xlim([0 512]);
    ylim([-60 60]);
    grid on;
    grid minor;
    %}
    
    %%
    figure('Name', 'Range-Doppler Heat Map Broadside');
    imagesc(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.co_cube))
    title('Range-Doppler Heat Map')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    ylim([0 max_range]);
    set(gca, 'xtick', -60:10:60);
    

    figure('Name', 'Range-Doppler Surface Broadside');
    surf(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.co_cube), ...
        'EdgeColor', 'none')
    title('Range-Doppler Surface')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
    grid on;
    grid minor;
    ylim([0 max_range]);
    zlim([60 160]);
    set(gca, 'xtick', -60:10:60);
    
    figure('Name', 'Zero Doppler Range Plot Broadside');
    plot(scenario.cube.range_axis, 10*log10(scenario.cube.co_cube(:, ceil(end/2))));
    xlabel('Range [m]','FontWeight','bold');
    ylabel('FFT Log Intensity [dB]','FontWeight','bold');
    grid on;
    grid minor;
    xlim([0 max_range])
    ylim([80 160]);
    
    figure('Name', 'Non-Zero Doppler Swath Plot Broadside');
    plot(scenario.cube.range_axis, 10*log10(mean(scenario.cube.co_cube(:, [126:249, 266:389]), 2)));
    xlabel('Range [m]','FontWeight','bold');
    ylabel('FFT Log Intensity [dB]','FontWeight','bold');
    grid on;
    grid minor;
    xlim([0 max_range])
    ylim([60 140]);
    %}
    
    %{
    az_bins = 5:13;
    az_angles = {'-30deg', '-22deg', '-15deg', '7deg', '0deg', '7deg', '15deg', '22deg', '30deg'};
    el_bins = 5:9;
    el_angles = {'30deg', '22deg', '15deg', '7deg', '0deg'};
    
    for az_num = 1:length(az_bins)
        for el_num = 1:length(el_bins)
            
            str = ['Range-Doppler Heat Map Elevation ', el_angles{el_num}, ' Azimuth ', az_angles{az_num}];
            figure('Name', str);
            imagesc(scenario.cube.vel_axis, ...
                scenario.cube.range_axis, ...
                10*log10(scenario.cube.avg_cube(:,:, az_bins(az_num), el_bins(el_num))))
            title(str)
            set(gca,'YDir','normal')
            xlabel('Velocity [m/s]','FontWeight','bold')
            ylabel('Range [m]','FontWeight','bold')
            ylim([0 max_range]);
            
            str = ['Zero Doppler Range Plot Elevation ', el_angles{el_num}, ' Azimuth ', az_angles{az_num}];
            figure('Name', str);
            plot(scenario.cube.range_axis, 10*log10(scenario.cube.avg_cube(:, ceil(end/2), az_bins(az_num), el_bins(el_num))));
            xlabel('Range [m]','FontWeight','bold');
            ylabel('FFT Log Intensity [dB]','FontWeight','bold');
            grid on;
            xlim([0 max_range])
            ylim([80 160])
            
        end
    end
    %}
    
    %
    scenario.cube.co_cube(:,(ceil(end/2)-3):(ceil(end/2)+3)) = median(scenario.cube.co_cube, 'all');
    
    figure('Name', 'Range-Doppler Heat Map Zero Doppler Removed');
    imagesc(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.co_cube))
    title('Range-Doppler Heat Map - Zero Doppler Removed')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    ylim([0 max_range]);
    set(gca, 'xtick', -60:10:60);
    
    figure('Name', 'Range-Doppler Surface Zero Doppler Removed');
    surf(scenario.cube.vel_axis, ...
        scenario.cube.range_axis, ...
        10*log10(scenario.cube.co_cube), ...
        'EdgeColor', 'none')
    title('Range-Doppler Surface - Zero Doppler Removed')
    set(gca,'YDir','normal')
    xlabel('Velocity [m/s]','FontWeight','bold')
    ylabel('Range [m]','FontWeight','bold')
    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
    grid on;
    grid minor;
    ylim([0 max_range]);
    zlim([60 160]);
    set(gca, 'xtick', -60:10:60);
    %}

    %%
    str = ['Figures/drone_5/', file_in, '/' ];
    SaveFigures(file_in, str, '.png');
    
    close all;
    fclose all;
end