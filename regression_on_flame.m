% ------------------------------------------------------
% DATA READING

% Define the file name
fileName = 'P_0kV_ShockJetFlame_HeatRelease_Data.xlsx';

% Read the range from column D to Y in the first sheet as a cell array
data = readcell(fileName, 'Sheet', 5, 'Range', 'D:Y');

% Extract data from columns 1 to 22 and rows starting from row 6 to
% last_row - 1
selectedData = data(6:end-1, 1:22);

% Specify the columns you want to remove (columns 2 and 17)
columnsToRemove = [2, 17];

% Remove the specified columns
selectedData(:, columnsToRemove) = [];

% Use cell2mat to convert cells to plottable matrix
time = cell2mat(selectedData(2:end, 1));  % Convert to numeric values
flame_tip_average = cell2mat(selectedData(2:end, 19));  % Convert to numeric values


% ------------------------------------------------------
% PLOTTING THE DATA

% Plot time vs flame_tip_average as a scatter plot
figure;
plot(time, flame_tip_average);
xlabel('Time');
ylabel('Flame Tip Average');
title('Scatter Plot of Time vs Flame Tip Average');
grid on;
