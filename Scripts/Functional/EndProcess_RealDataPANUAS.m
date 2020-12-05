%% PANUAS Radar System - End of Process Tasks
%{

    Sean Holloway
    PANUAS End-of-Process Tasks

    Container script which saves output files from PANUAS processing, and
    sends alert email.

    For use in FullSystem_RealDataPANUAS without automated simulation.
    
%}

%% Announce Elapsed Time

toc

%% Save Files and Figures

% Establish file name
save_name = scenario.simsetup.file_in;
if scenario.simsetup.save_date
    save_name = [save_name, '_', datestr(now, 'mmddyy_HHMM')];
end

% Establish filepaths for saving
mat_path = 'MAT Files\Scenario Objects\';
fig_path = ['Figures\', scenario.simsetup.file_out, '\' save_name, '\'];

% Save scenario object if chosen
if scenario.simsetup.save_mat
    SaveScenario(scenario, save_name, mat_path);
end

% Save open figures if chosen
if scenario.simsetup.save_figs
    
    if ~exist(fig_path, 'dir')
        mkdir(fig_path)
    end
    
    for ftype = 1:length(scenario.simsetup.save_format.list)
        SaveFigures("", fig_path, scenario.simsetup.save_format.list{ftype});
    end
end


%% Send Email Alert

% Send email alert with attachment if chosen
if scenario.simsetup.send_alert
    
    % Set up email process
    EmailSetup();
    
    % Send email
    EmailAlert( ...
        scenario.simsetup.alert_address, ...
        save_name, ...
        scenario.simsetup.attach_zip);
end








