clear all;
close all;

fileName = 'P_0kV_ShockJetFlame_HeatRelease_Data.xlsx';

sheet_number = 16;
data = readcell(fileName, 'Sheet', sheet_number, 'Range', 'D:Y');

selectedData = data(6:end-1, 1:22);

columnsToRemove = [2, 17];

selectedData(:, columnsToRemove) = [];

time = cell2mat(selectedData(2:end, 1));  
flame_tip_location = cell2mat(selectedData(2:end, 18));  
base_area = cell2mat(selectedData(2:end, 4)); 
norm_HR = cell2mat(selectedData(2:end, 16)); 

figure;
linewidth = 1.25;
subplot(2, 1, 2);
plot(time, norm_HR, 'red', LineWidth=linewidth);

subplot(2, 1, 1);
plot(time, flame_tip_location, 'blue', LineWidth=linewidth);

[cross_corr, lags] = xcorr(norm_HR, flame_tip_location, 'coeff');
correlation_coefficient = corr(norm_HR, flame_tip_location);

figure;
stem(lags, cross_corr);
title('Cross-Correlation between Time Series');
xlabel('Lag');
ylabel('Cross-Correlation');
grid on;

fs = 1000;  
t = time;  
signal = flame_tip_location;  

signal_no_dc = signal - mean(signal);

N = length(signal_no_dc);  
fft_signal = fft(signal_no_dc);  
freq = (0:N-1)*(fs/N);  

figure;
plot(freq(1:N/2), abs(fft_signal(1:N/2)));  
title('Magnitude Spectrum of Time Series (DC Removed)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

signal1 = flame_tip_location;
signal2 = norm_HR;

plotTitles = {'Flame Tip Location', 'OH Chemiluminescence'};
lineColors = {'blue', 'red'};  
lineWidth = 1.5;  

titleFontSize = 20;
labelFontSize = 16;
legendFontSize = 16;

figure;

subplot(2, 1, 1);  
plot(t, signal1, 'LineWidth', lineWidth, 'Color', lineColors{1});  
title(plotTitles{1}, 'FontSize', titleFontSize, 'FontWeight', 'bold');
xlabel('Time (ms)', 'FontSize', labelFontSize);
ylabel('Amplitude (mm)', 'FontSize', labelFontSize);
grid on;
set(gca, 'FontSize', legendFontSize, 'Box', 'on');  

subplot(2, 1, 2);  
plot(t, signal2, 'LineWidth', lineWidth, 'Color', lineColors{2});  
plot(freq(1:N/2), abs(signal2(1:N/2)), 'LineWidth', lineWidth, 'Color', lineColors{2});  
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title(plotTitles{2}, 'FontSize', titleFontSize, 'FontWeight', 'bold');
xlabel('Time (ms)', 'FontSize', labelFontSize);
ylabel('Amplitude', 'FontSize', labelFontSize);
grid on;
set(gca, 'FontSize', legendFontSize, 'Box', 'on');  

sgt = sgtitle('        Case 2: No flickering', 'FontSize', titleFontSize + 2, 'FontWeight', 'bold');
%sgt = sgtitle('        Case 1: With flickering', 'FontSize', titleFontSize + 2, 'FontWeight', 'bold');