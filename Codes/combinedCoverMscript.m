% Folder containing Excel files
folderPath = 'path_to_your_folder';
folderPath = 'C:\Users\Lenovo\Documents\GitHub\myMiBiOME\abunPath\coverM\seperate_coverM'
% Get list of Excel files in the folder
fileList = dir(fullfile(folderPath, '*.tabular'));

% Initialize the combined table
combinedTable = table();

% Loop through each file and merge tables
for i = 1:length(fileList)
    % Read the current TSV file into a table
    currentFile = fullfile(folderPath, fileList(i).name);
    currentTable = readtable(currentFile, 'FileType', 'text', 'Delimiter', '\t');
    
    % If this is the first file, initialize the combined table
    if i == 1
        combinedTable = currentTable;
    else
        % Join the current table with the combined table based on 'Contig'
        combinedTable = join(combinedTable, currentTable, 'Keys', 'Contig');
    end
end

% Write the combined table to a new Excel file
writetable(combinedTable, 'combinedCoverM.xlsx');

% Display a message to confirm task completion
disp('All tables successfully combined and saved to combinedTable.xlsx');
