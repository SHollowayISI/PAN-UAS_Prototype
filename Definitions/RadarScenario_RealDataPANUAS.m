% ClassDef File for PANUAS Radar Scenario

classdef RadarScenario_RealDataPANUAS < handle
    properties
        target_list
        simsetup
        radarsetup
        sim
        parsed_data
        rx_sig
        cube
        detection
        flags
        timing
        results
        multi
        cal
    end
    
    methods
        
        function RadarScenario = RadarScenario_RealDataPANUAS()
            % Initialize structure of target list
            RadarScenario.multi.detect_list = {};
            
            RadarScenario.multi.static_list = {};
            
            RadarScenario.multi.track_list = {};
            
            RadarScenario.multi.active_tracks = [];
            
            RadarScenario.detection.detect_cube_multi = [];
            
            % Initialize flags
            RadarScenario.flags = struct( ...
                'cpi',                  0, ...
                'frame',                0, ...
                'out_of_data',          false);
        end
        
        function generateCoordinates(RadarScenario)
            %Generate Input Coordinate Grid
            [range_grid, azimuth_grid, elevation_grid] = meshgrid( ...
                RadarScenario.cube.range_axis, ...
                RadarScenario.cube.azimuth_axis, ...
                RadarScenario.cube.elevation_axis);
            %Generate Output Coordinate Grid
            RadarScenario.results.x_grid = ...
                permute( ...
                range_grid .* cosd(azimuth_grid) .* cosd(elevation_grid), ...
                [2 1 3]);
            RadarScenario.results.y_grid = ...
                permute( ...
                range_grid .* sind(azimuth_grid) .* cosd(elevation_grid), ...
                [2 1 3]);
            RadarScenario.results.z_grid = ...
                permute( ...
                range_grid .* sind(elevation_grid), ...
                [2 1 3]);
        end
        
        function timeStart(RadarScenario)
            % Begin timing for progress readout
            RadarScenario.timing.timing_logical = true;
            RadarScenario.timing.startTime = tic;
            RadarScenario.timing.TimeDate = now;
            RadarScenario.timing.numLoops = ...
                RadarScenario.simsetup.num_frames * ...
                RadarScenario.radarsetup.cpi_fr;
            RadarScenario.timing.timeGate = 0;
        end
        
        function timeUpdate(RadarScenario, repetition, rep_method)
            
            if ~RadarScenario.timing.timing_logical
                error('Must use method timeStart() before timeUpdate()');
            end
            
            % Calculate progress through simulation
            loops_complete = (RadarScenario.flags.frame-1)*RadarScenario.radarsetup.cpi_fr + ...
                RadarScenario.flags.cpi;
            percent_complete = 100*loops_complete/RadarScenario.timing.numLoops;
            
            % Calculate remaining time in simulation
            nowTimeDate = now;
            elapsedTime = nowTimeDate - RadarScenario.timing.TimeDate;
            estComplete = nowTimeDate + ((100/percent_complete)-1)*elapsedTime;
            
            % Form message to display in command window
            message_l = sprintf('%d Loops complete out of %d', loops_complete, RadarScenario.timing.numLoops);
            message_p = [sprintf('Percent complete: %0.0f', percent_complete), '%'];
            message_t = ['Estimated time of completion: ', datestr(estComplete)];
            
            % Display current progress
            switch rep_method
                case 'loops'
                    if (mod(loops_complete, repetition) == 1) || (repetition == 1)
                        disp(message_l);
                        disp(message_p);
                        disp(message_t);
                        disp('');
                    end
                    
                case 'time'
                    if ((RadarScenario.timing.timeGate == 0) || ...
                            (toc > repetition + RadarScenario.timing.timeGate))
                        disp(message_p);
                        disp(message_t);
                        disp('');
                        RadarScenario.timing.timeGate = toc;
                    end
                    
            end
        end
        
        function CPIUpdate(RadarScenario)
            message = sprintf('CPI %d complete out of %d per frame.', ...
                RadarScenario.flags.cpi, ...
                RadarScenario.radarsetup.cpi_fr);
            disp(message);
        end
        
        function readOut(RadarScenario)
            %             fprintf('\nMaximum SNR: %0.1f [dB]\n', ...
            %                 RadarScenario.detection.max_SNR);
            
            num_detect = RadarScenario.detection.detect_list.num_detect;
            
            if num_detect > 0
                if num_detect > 1
                    fprintf('\n%d Targets Detected:\n\n', num_detect);
                else
                    fprintf('\n%d Target Detected:\n\n', num_detect);
                end
                
                for n = 1:num_detect
                    fprintf('Target #%d Coordinates:\n', n);
                    fprintf('Range: %0.1f [m]\n', ...
                        RadarScenario.detection.detect_list.range(n));
                    fprintf('Velocity: %0.1f [m/s]\n', ...
                        RadarScenario.detection.detect_list.vel(n));
                    fprintf('Azimuth Angle: %0.1f [deg]\n', ...
                        RadarScenario.detection.detect_list.az(n));
                    fprintf('Elevation Angle: %0.1f [deg]\n', ...
                        RadarScenario.detection.detect_list.el(n));
                    fprintf('SNR: %0.1f [dB]\n\n', ...
                        RadarScenario.detection.detect_list.SNR(n));
                end
            else
                disp('No Targets Detected');
                disp('');
            end
        end
        
        function saveMulti(RadarScenario)
            
            RadarScenario.multi.detect_list{RadarScenario.flags.frame} = ...
                RadarScenario.detection.detect_list;
            
        end
        
        function viewCalRange(RadarScenario)
            figure('Name', 'Uncalibrated Power vs Range')
            plot(RadarScenario.cube.range_axis, ...
                10*log10(squeeze(sum(abs(RadarScenario.cube.rd_cube(:,ceil(end/2),:,:)).^2, 3))));
            grid on;
            title('Uncalibrated Power vs Range')
            grid on
            xlabel('Range [m]')
            ylabel('Power [dB]')
            
            figure('Name', 'Uncalibrated Power vs Range - Combined Channels')
            plot(RadarScenario.cube.range_axis, ...
                10*log10(sum(sum(abs(RadarScenario.cube.rd_cube(:,ceil(end/2),:,:)).^2, 3),4)));
            grid on;
            title('Uncalibrated Power vs Range - Combined Channels')
            grid on
            xlabel('Range [m]')
            ylabel('Power [dB]')
            
        end
        
        function viewCalCube(RadarScenario)
            figure('Name', 'Calibration Data')
            subplot(2, 1, 1)
            plot(20*log10(squeeze(abs(RadarScenario.cal))'))
            title('Calibration Amplitude')
            legend('Tx1', 'Tx2', 'Tx3', 'Tx4')
            xlabel('Rx channel')
            ylabel('Relative Amplitude [dB]')
            grid on
            
            subplot(2, 1, 2)
            plot(squeeze((180/pi)*angle(RadarScenario.cal))')
            title('Calibration Phase')
            legend('Tx1', 'Tx2', 'Tx3', 'Tx4')
            xlabel('Rx channel')
            ylabel('Relative Phase Angle [deg]')
            grid on
        end
        
        function viewRDCube(RadarScenario, graphType)
            switch graphType
                case 'heatmap'
                    figure('Name', 'Range-Doppler Heat Map');
                    imagesc(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(RadarScenario.cube.pow_cube(:,:,ceil(end/2), ceil(end/2))))
                    title('Range-Doppler Heat Map')
                    set(gca,'YDir','normal')
                    xlabel('Velocity [m/s]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                case 'surface'
                    figure('Name', 'Range-Doppler Surface');
                    surf(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(RadarScenario.cube.pow_cube(:,:,ceil(end/2), ceil(end/2))), ...
                        'EdgeColor', 'none')
                    title('Range-Doppler Surface')
                    set(gca,'YDir','normal')
                    xlabel('Velocity [m/s]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
                case 'cal'
                    figure('Name', 'Range-Doppler Heat Map');
                    for n = 1:size(RadarScenario.cube.pow_cube,3)
                        subplot(RadarScenario.radarsetup.n_rx_y, ...
                            RadarScenario.radarsetup.n_rx_z, n);
                        imagesc(RadarScenario.cube.vel_axis, ...
                            RadarScenario.cube.range_axis, ...
                            10*log10(RadarScenario.cube.pow_cube(:,:,n)))
                        title('Range-Doppler Heat Map')
                        set(gca,'YDir','normal')
                        xlabel('Velocity [m/s]','FontWeight','bold')
                        ylabel('Range [m]','FontWeight','bold')
                    end
            end
        end
        
        function viewIncoherentCube(RadarScenario, graphType, maxRange)
            switch graphType
                case 'heatmap'
                    figure('Name', 'Range-Doppler Heat Map');
                    imagesc(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(RadarScenario.cube.incoherent_cube(:,:,ceil(end/2), ceil(end/2))))
                    title('Range-Doppler Heat Map')
                    set(gca,'YDir','normal')
                    xlabel('Velocity [m/s]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                    ylim([0 maxRange])
                case 'nonzerodoppler'
                    data = 10*log10(RadarScenario.cube.incoherent_cube(:,:,ceil(end/2),ceil(end/2)));
                    data(:, floor((end/2)-3):ceil((end/2)+3)) = median(data, 'all');
                    figure('Name', 'Non-Zero Doppler Heat Map');
                    imagesc(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        data)
                    title('Range-Doppler Heat Map')
                    set(gca,'YDir','normal')
                    xlabel('Velocity [m/s]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                    ylim([0 maxRange])
                case 'surface'
                    figure('Name', 'Range-Doppler Surface');
                    surf(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(RadarScenario.cube.incoherent_cube(:,:,ceil(end/2), ceil(end/2))), ...
                        'EdgeColor', 'none')
                    title('Range-Doppler Surface')
                    set(gca,'YDir','normal')
                    xlabel('Velocity [m/s]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                    ylim([0 maxRange])
                    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
                case 'cal'
                    figure('Name', 'Range-Doppler Heat Map');
                    for n = 1:size(RadarScenario.cube.incoherent_cube,3)
                        subplot(RadarScenario.radarsetup.n_rx_y, ...
                            RadarScenario.radarsetup.n_rx_z, n);
                        imagesc(RadarScenario.cube.vel_axis, ...
                            RadarScenario.cube.range_axis, ...
                            10*log10(RadarScenario.cube.incoherent_cube(:,:,n)))
                        title('Range-Doppler Heat Map')
                        set(gca,'YDir','normal')
                        xlabel('Velocity [m/s]','FontWeight','bold')
                        ylabel('Range [m]','FontWeight','bold')
                        ylim([0 maxRange])
                    end
            end
        end
        
        function viewDopplerSwath(scenario, dopplerMinMax, maxRange, yLimits)
            str = sprintf('Zero Doppler Range Plot %dm Max', maxRange);
            figure('Name', str);
            plot(scenario.cube.range_axis, 10*log10(scenario.cube.incoherent_cube(:, ceil(end/2), ceil(end/2), ceil(end/2))));
            xlabel('Range [m]','FontWeight','bold');
            ylabel('FFT Log Intensity [dB]','FontWeight','bold');
            grid on;
            grid minor;
            xlim([0 maxRange])
            ylim(yLimits);
            
            dop_ind = intersect(find(abs(scenario.cube.vel_axis) >= dopplerMinMax(1)), ...
                find(abs(scenario.cube.vel_axis) <= dopplerMinMax(2)));
            
            str = sprintf('Non-Zero Doppler Swath Plot %dm Max', maxRange);
            figure('Name', str);
            plot(scenario.cube.range_axis, 10*log10(mean(scenario.cube.incoherent_cube(:, dop_ind, ceil(end/2), ceil(end/2)), 2)));
            xlabel('Range [m]','FontWeight','bold');
            ylabel('FFT Log Intensity [dB]','FontWeight','bold');
            grid on;
            grid minor;
            xlim([0 maxRange])
            ylim([60 140]);
        end
        
        function viewRACube(RadarScenario, graphType)
            switch graphType
                case 'heatmap'
                    figure('Name', 'Range-Azimuth Heat Map');
                    imagesc(RadarScenario.cube.azimuth_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(squeeze(RadarScenario.cube.pow_cube(:,ceil(end/2),:, ceil(end/2)))))
                    title('Range-Azimuth Heat Map')
                    set(gca,'YDir','normal')
                    xlabel('Azimuth Angle [degree]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                case 'surface'
                    figure('Name', 'Range-Azimuth Surface');
                    surf(RadarScenario.cube.azimuth_axis, ...
                        RadarScenario.cube.range_axis, ...
                        10*log10(squeeze(RadarScenario.cube.pow_cube(:,ceil(end/2),:, ceil(end/2)))), ...
                        'EdgeColor', 'none')
                    title('Range-Azimuth Surface')
                    xlabel('Azimuth Angle [degree]','FontWeight','bold')
                    ylabel('Range [m]','FontWeight','bold')
                    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
                case 'PPI'
                    figure('Name', 'Range-Azimuth PPI');
                    surf(RadarScenario.results.x_grid(:,:,ceil(end/2)), ...
                        RadarScenario.results.y_grid(:,:,ceil(end/2)), ...
                        10*log10(squeeze(RadarScenario.cube.pow_cube(:,ceil(end/2),:, ceil(end/2)))), ...
                        'EdgeColor', 'none')
                    title('Range-Azimuth PPI')
                    xlabel('Cross-Range Distance [m]','FontWeight','bold')
                    ylabel('Down-Range Distance [m]','FontWeight','bold')
                    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
            end
            
        end
        
        function viewDetections(RadarScenario, graphType)
            switch graphType
                case 'heatmap'
                    figure('Name', 'Detection Heatmap')
                    imagesc(RadarScenario.cube.vel_axis, ...
                        RadarScenario.cube.range_axis, ...
                        RadarScenario.detection.detect_cube( ...
                        :, :, ceil(end/2), ceil(end/2)))
                    set(gca, 'YDir', 'Normal')
                    xlabel('Velocity [m/s]', 'FontWeight', 'bold')
                    ylabel('Ragne [m]', 'FontWeight', 'bold')
                case 'PPI'
                    figure('Name', 'Detection PPI');
                    surf(RadarScenario.cube.x_grid, ...
                        RadarScenario.cube.y_grid, ...
                        RadarScenario.detection.detect_cube_nodop( ...
                        :, :, RadarScenario.flags.slice), ...
                        'EdgeColor', 'none')
                    view(270,90)
                    title('Range-Azimuth PPI')
                    xlabel('Cross-Range Distance [m]','FontWeight','bold')
                    ylabel('Down-Range Distance [m]','FontWeight','bold')
                    zlabel('FFT Log Intensity [dB]','FontWeight','bold')
            end
        end
        
        function viewDetections3D(RadarScenario)
            % Pass in variable
            detect_list = RadarScenario.multi.detect_list;
            % Show 3-D scatter plot of detections
            figure('Name', 'Detections 3D Scatter Plot')
            for n = 1:length(detect_list)
                scatter3(detect_list{n}.cart(1,:), ...
                    detect_list{n}.cart(2,:), ...
                    detect_list{n}.cart(3,:), ...
                    'k', '+');
                hold on;
            end
            title('Detections 3D Scatter Plot')
            xlabel('Down-Range Distance [m]', 'FontWeight', 'bold')
            ylabel('Cross-Range Distance [m]', 'FontWeight', 'bold')
            zlabel('Elevation [m]', 'FontWeight', 'bold')
            
        end
        
        function viewTracking(RadarScenario, graphType, showFalseAlarms, showTracks)
            switch graphType
                case 'scatter'
                    % Pass in variables
                    track_list  = RadarScenario.multi.track_list;
                    % Generate plot
                    figure('Name', 'Tracking Results Scatter Plot');
                    % Add tracks to plot
                    for n = 1:length(track_list)
                        % Scatter plot if false alarm
                        if (track_list{n}.false_alarm && showFalseAlarms)
                            scatter3(track_list{n}.det_list(1,:), ...
                                track_list{n}.det_list(2,:), ...
                                track_list{n}.det_list(3,:), ...
                                30, 'r', '.');
                            hold on;
                            % Line of track if not
                        else
                            scatter3(track_list{n}.det_list(1,:), ...
                                track_list{n}.det_list(2,:), ...
                                track_list{n}.det_list(3,:), ...
                                30, 'k', '.');
                            hold on;
                            if showTracks
                                plot3(track_list{n}.est_list(1,:), ...
                                    track_list{n}.est_list(3,:), ...
                                    track_list{n}.est_list(5,:), ...
                                    'g');
                                hold on;
                            end
                        end
                    end
                    % Add radar location to plot
                    scatter3(0, 0, 0, 'filled', 'r');
                    % Correct plot limits
                    ax = gca;
                    ax.YLim = [-ax.XLim(2)/2, ax.XLim(2)/2];
                    ax.ZLim = [-ax.XLim(2)/2, ax.XLim(2)/2];
                    % Add labels
                    xlabel('Down Range Distance [m]', 'FontWeight', 'bold')
                    ylabel('Cross Range Distance [m]', 'FontWeight', 'bold')
                    zlabel('Altitude [m]', 'FontWeight', 'bold')
                case 'PPI'
                    % Pass in variables
                    track_list  = RadarScenario.multi.track_list;
                    % Generate plot
                    figure('Name', 'Tracking Results PPI Scatter Plot');
                    % Add tracks to plot
                    for n = 1:length(track_list)
                        % Scatter plot if false alarm
                        if (track_list{n}.false_alarm && showFalseAlarms)
                            scatter(track_list{n}.det_list(2,:), ...
                                track_list{n}.det_list(1,:), ...
                                30, 'r', '+');
                            hold on;
                            % Line of track if not
                        else
                            scatter(track_list{n}.det_list(2,:), ...
                                track_list{n}.det_list(1,:), ...
                                30, track_list{n}.det_list(3,:)', '.');
                            hold on;
                            if showTracks
                                plot(track_list{n}.est_list(3,:), ...
                                    track_list{n}.est_list(1,:), 'g');
                                hold on;
                            end
                        end
                    end
                    % Add radar location to plot
                    scatter(0, 0, 'filled', 'r', 'v');
                    % Correct plot limits
                    ax = gca;
                    ax.XLim = [-ax.YLim(2)/2, ax.YLim(2)/2];
                    grid on;
                    c = colorbar;
                    c.Label.String = 'Target Altitude [m]';
                    c.Label.FontWeight = 'bold';
                    % Add labels
                    ylabel('Down Range Distance [m]', 'FontWeight', 'bold')
                    xlabel('Cross Range Distance [m]', 'FontWeight', 'bold')
            end
        end
        
        function trackingOverlay(RadarScenario, imagePath, showFalseAlarms, showTracks, showStatic)
            % Pass in variables
            track_list  = RadarScenario.multi.track_list;
            static_list = RadarScenario.multi.static_list;
            % Generate plot
            if showStatic
                figure('Name', 'Tracking Results Map Overlay with Static Detections', ...
                    'units', 'normalized', 'outerposition', [0 0 1 1]);
            else
                figure('Name', 'Tracking Results Map Overlay', ...
                    'units', 'normalized', 'outerposition', [0 0 1 1]);                
            end
            % Show image
            img = imread(imagePath);
            image('CData', img, 'XData', [-190 180], 'YData', [270 -19], ...
                'AlphaData', 0.75);
            hold on;
            % Add tracks to plot
            for n = 1:length(track_list)
                % Scatter plot if false alarm
                if (track_list{n}.false_alarm && showFalseAlarms)
                    scatter(track_list{n}.det_list(2,:), ...
                        track_list{n}.det_list(1,:), ...
                        50, 'r', '.');
                    hold on;
                    % Line of track if not
                else
                    if (showTracks && (size(track_list{n}.est_list, 2) > 1))
                         plot([track_list{n}.est_list(3,:), track_list{n}.kin_pre(3)], ...
                            [track_list{n}.est_list(1,:), track_list{n}.kin_pre(1)], ...
                            'r', 'LineWidth', 2);
                        hold on;
                        diff_y = track_list{n}.kin_pre(3) - track_list{n}.est_list(3,end);
                        diff_x = track_list{n}.kin_pre(1) - track_list{n}.est_list(1,end);
                        ang = atan2d(-diff_y, -diff_x);
                        len = 1;
                        arrow(1,:) = [track_list{n}.kin_pre(3) + len*sind(ang - 30), ...
                                      track_list{n}.kin_pre(3), ...
                                      track_list{n}.kin_pre(3) + len*sind(ang + 30)];
                        arrow(2,:) = [track_list{n}.kin_pre(1) + len*cosd(ang - 30), ...
                                      track_list{n}.kin_pre(1), ...
                                      track_list{n}.kin_pre(1) + len*cosd(ang + 30)];
                        plot(arrow(1,:), arrow(2,:), 'r', 'LineWidth', 2);
                        
                    end
                end                
            end
            
            if showStatic
                for n = 1:length(static_list)
                    % Scatter plot for static targets
                    for m = 1:length(static_list{n}.SNR)
                        alpha = max(min((static_list{n}.SNR(m) / 50), 1), 0);
                        scatter(static_list{n}.cart(2,m), ...
                            static_list{n}.cart(1,m), ...
                            10, static_list{n}.cart(3,m)', ...
                            'filled', 'MarkerFaceAlpha', alpha, 'MarkerEdgeAlpha', alpha);
                        hold on;
                    end
                end
            end
            
            % Add radar location to plot
            scatter(0, 0, 'filled', 'r', 'v');
            % Correct plot limits
            ylim([-25 275])
            xlim([-150 150])
            pbaspect([1 1 1])
            grid on;
            c = colorbar;
            c.Label.String = 'Target Altitude [m]';
            c.Label.FontWeight = 'bold';
            % Add labels
            ylabel('Down Range Distance [m]', 'FontWeight', 'bold')
            xlabel('Cross Range Distance [m]', 'FontWeight', 'bold')
            
            
        end        
    end
end






