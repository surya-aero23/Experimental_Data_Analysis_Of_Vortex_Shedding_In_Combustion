clear all;
close all;

fileName = 'P_0kV_ShockJetFlame_HeatRelease_Data.xlsx';
numSheets = 16;
sheetwise_2_d = zeros(numSheets, 1);
fft_dom_freq = zeros(numSheets, 2);

for sheetIdx = 2
    data = readcell(fileName, 'Sheet', sheetIdx, 'Range', 'D:Y');
    selectedData = data(6:end-1, 1:22);
    columnsToRemove = [2, 17];
    selectedData(:, columnsToRemove) = [];
    time = cell2mat(selectedData(2:end, 1));
    flame_tip_location = cell2mat(selectedData(2:end, 18));
    norm_HR = cell2mat(selectedData(2:end, 16));

    best_window = 0;
    best_SNR = -Inf;
    best_sigma = 0;

    h = time(2) - time(1);
    threshold_multiplier = 1;

    for window = 9:2:101
         P = floor(window / 2);
         padded_signal = [repmat(flame_tip_location(1), P, 1); flame_tip_location; repmat(flame_tip_location(end), P, 1)];
           
        for sigma = 1:5
            x = -floor(window/2):floor(window/2);
            gaussian_kernel = exp(-x.^2 / (2*sigma^2));
            gaussian_kernel = gaussian_kernel / sum(gaussian_kernel);
            smoothed_signal_Gaussian = conv(padded_signal, gaussian_kernel, 'same');
            smoothed_signal_Gaussian = smoothed_signal_Gaussian(P+1:end-P);
            second_derivative = (smoothed_signal_Gaussian(3:end) - 2*smoothed_signal_Gaussian(2:end-1) + smoothed_signal_Gaussian(1:end-2)) / h^2;
            threshold = threshold_multiplier * std(smoothed_signal_Gaussian);
            exceeds_threshold = any(abs(second_derivative) > threshold);
            noise = flame_tip_location - smoothed_signal_Gaussian;
            signal_power = mean(smoothed_signal_Gaussian.^2);
            noise_power = mean(noise.^2);
            SNR_dB = 10 * log10(signal_power / noise_power);

            if SNR_dB > best_SNR && ~exceeds_threshold
                best_SNR = SNR_dB;
                best_window = window;
                best_sigma = sigma;
            end
        end
    end

    x = -floor(best_window/2):floor(best_window/2);
    gaussian_kernel = exp(-x.^2 / (2*best_sigma^2));
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel);
    P = floor(best_window / 2);
    padded_signal = [repmat(flame_tip_location(1), P, 1); flame_tip_location; repmat(flame_tip_location(end), P, 1)];
    smoothed_signal_Gaussian = conv(padded_signal, gaussian_kernel, 'same');
    smoothed_signal_flame_tip = smoothed_signal_Gaussian(P+1:end-P); 
    
    best_window = 0;
    best_SNR = -Inf;
    best_sigma = 0;
    
    for window = 9:2:101
         P = floor(window / 2);
         padded_signal = [repmat(norm_HR(1), P, 1); norm_HR; repmat(norm_HR(end), P, 1)];
           
        for sigma = 1:5
            x = -floor(window/2):floor(window/2);
            gaussian_kernel = exp(-x.^2 / (2*sigma^2));
            gaussian_kernel = gaussian_kernel / sum(gaussian_kernel);
            smoothed_signal_Gaussian = conv(padded_signal, gaussian_kernel, 'same');
            smoothed_signal_Gaussian = smoothed_signal_Gaussian(P+1:end-P);
            second_derivative = (smoothed_signal_Gaussian(3:end) - 2*smoothed_signal_Gaussian(2:end-1) + smoothed_signal_Gaussian(1:end-2)) / h^2;
            threshold = threshold_multiplier * std(smoothed_signal_Gaussian);
            exceeds_threshold = any(abs(second_derivative) > threshold);
            noise = norm_HR - smoothed_signal_Gaussian;
            signal_power = mean(smoothed_signal_Gaussian.^2);
            noise_power = mean(noise.^2);
            SNR_dB = 10 * log10(signal_power / noise_power);

            if SNR_dB > best_SNR && ~exceeds_threshold
                best_SNR = SNR_dB;
                best_window = window;
                best_sigma = sigma;
            end
        end
    end

    x = -floor(best_window/2):floor(best_window/2);
    gaussian_kernel = exp(-x.^2 / (2*best_sigma^2));
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel);
    P = floor(best_window / 2);
    disp(best_window)
    padded_signal = [repmat(norm_HR(1), P, 1); norm_HR; repmat(norm_HR(end), P, 1)];
    smoothed_signal_Gaussian = conv(padded_signal, gaussian_kernel, 'same');
    smoothed_signal_norm_HR = smoothed_signal_Gaussian(P+1:end-P); 
    
end

[cross_corr, lags] = xcorr(smoothed_signal_norm_HR, normalize(smoothed_signal_flame_tip), 'coeff');
correlation_after = corr(smoothed_signal_norm_HR, smoothed_signal_flame_tip);
correlation_before = corr(norm_HR, flame_tip_location);

figure;
stem(lags, cross_corr);
title('Cross-Correlation between Time Series (sheet 2)');
xlabel('Lag');
ylabel('Cross-Correlation');
grid on;

t = time;
signal0 = normalize(flame_tip_location);
signal1 = normalize(norm_HR);
signal3 = normalize(smoothed_signal_flame_tip);
signal4 = normalize(smoothed_signal_norm_HR);

plotTitles = {'OH & Flame Tip Location (Noisy)', 'OH & Flame Tip Location (Gaussian)'};
lineColors = {'blue', 'red'};
lineWidth = 1.5;

titleFontSize = 20;
labelFontSize = 16;
legendFontSize = 16;

figure;

subplot(2, 1, 1);
plot(t, signal0, 'LineWidth', lineWidth, 'Color', lineColors{2});
hold on;
plot(t, signal1, 'LineWidth', lineWidth + 0.5, 'Color', lineColors{1});
title(plotTitles{1}, 'FontSize', titleFontSize, 'FontWeight', 'bold');
xlabel('Time (ms)', 'FontSize', labelFontSize);
ylabel('Magnitude', 'FontSize', labelFontSize);
legend('Normalized Flame Tip Location', 'Normalized OH Chemiluminescence', 'Fontsize', legendFontSize);
grid on;
set(gca, 'FontSize', legendFontSize, 'Box', 'on');
hold off;

subplot(2, 1, 2);
plot(t, signal3, 'LineWidth', lineWidth, 'Color', lineColors{2});
hold on;
plot(t, signal4, 'LineWidth', lineWidth + 0.5, 'Color', lineColors{1})
hold off;
title(plotTitles{2}, 'FontSize', titleFontSize, 'FontWeight', 'bold');
xlabel('Time (ms)', 'FontSize', labelFontSize);
ylabel('Magnitude', 'FontSize', labelFontSize);
legend('Normalized Flame Tip Location', 'Normalized OH Chemiluminescence', 'Fontsize', legendFontSize);
grid on;
set(gca, 'FontSize', legendFontSize, 'Box', 'on');

sgt = sgtitle('        Case 2: No flickering', 'FontSize', titleFontSize + 2, 'FontWeight', 'bold');
