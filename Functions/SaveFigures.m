function [] = SaveFigures(save_name, fig_path, format)
%SAVEFIGURES Saves all open figures
%   Saves all open figures to fig_path directory, with name save_name plus
%   title of figure.

if ~exist(fig_path, 'dir')
    mkdir(fig_path)
end

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle, 'Name');
    if save_name == ""
        saveas(FigHandle, fullfile(fig_path, [FigName, format]));
    else
        saveas(FigHandle, fullfile(fig_path, [save_name, '_', FigName, format]));
    end
end

% Display update to command window
disp([format, ' Figures saved in ', fig_path]);

end

