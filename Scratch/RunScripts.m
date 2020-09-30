clear variables
close all


fold = dir('Input Data/Test 09182020');
k = 1;
for i = 1:length(fold)
    if not(fold(i).isdir)
        files{k} = fold(i).name(1:end-4);
        k = k+1;
    end
end


for file_loop = 1:length(files)
    
    file_in = files{file_loop}
    FullSystem_RealDataPANUAS_Prototype
    
    SaveFigures(file_in, 'Figures/FixedIntegration2_12usDrop', '.png');
    SaveFigures(file_in, 'Figures/FixedIntegration2_12usDrop', '.fig');
    
    close all;
end