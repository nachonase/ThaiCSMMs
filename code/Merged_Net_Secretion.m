clc; clear; close all;

% Get list of folders that start with "Results_"
folderList = dir('Results_p*');
numFolders = length(folderList);

% Initialize an empty table
mergedTable = [];

% Loop through each folder
for i = 1:numFolders
    folderName = folderList(i).name;
    filePath = fullfile(folderName, 'inputDiet_net_uptake_fluxes.csv');
    
    % Check if file exists in the folder
    if exist(filePath, 'file')
        % Read the table from the CSV file
        try
            dataTable = readtable(filePath, 'PreserveVariableNames', true);
            
            % Ensure "Net secretion" is present
            if any(strcmp(dataTable.Properties.VariableNames, 'Net secretion'))
                % Merge tables using "Net secretion" as the key
                if isempty(mergedTable)
                    mergedTable = dataTable;
                else
                    mergedTable = outerjoin(mergedTable, dataTable, 'Keys', 'Net secretion', ...
                        'MergeKeys', true, 'Type', 'full');
                end
            else
                fprintf('Skipping file (no "Net secretion" column): %s\n', filePath);
            end
        catch ME
            fprintf('Error reading %s: %s\n', filePath, ME.message);
        end
    else
        fprintf('File not found in %s\n', folderName);
    end
end

% Save the merged table as a CSV file
if ~isempty(mergedTable)
    outputFileName = 'Merged_Net_Secretion-prebiotic.csv';
    writetable(mergedTable, outputFileName);
    fprintf('Merged table saved as %s\n', outputFileName);
else
    fprintf('No valid tables found for merging.\n');
end
