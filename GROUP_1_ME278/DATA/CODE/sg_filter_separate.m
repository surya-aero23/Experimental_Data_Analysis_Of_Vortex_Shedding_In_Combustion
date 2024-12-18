clear all;
close all;

fileName = 'P_0kV_ShockJetFlame_HeatRelease_Data.xlsx';

numSheets = 17;
sheetwise_2_d=zeros(numSheets,1);
fft_dom_freq=zeros(numSheets,2);

for sheetIdx = 2
    data = readcell(fileName, 'Sheet', sheetIdx, 'Range', 'D:Y');
    selectedData = data(6:end-1, 1:22);
    columnsToRemove = [2, 17];
    selectedData(:, columnsToRemove) = [];
    time = cell2mat(selectedData(2:end, 1));  
    flame_tip_location = cell2mat(selectedData(2:end, 18)); 
    base_area = cell2mat(selectedData(2:end, 4)); 
    norm_HR = cell2mat(selectedData(2:end, 16)); 

    best_window = 0;
    best_order = 0;
    best_SNR = -Inf;

    h = time(2) - time(1);

    threshold_multiplier = 1; 

    for window = 9:2:101
        for order = 2:window-1
            smoothed_signal = sgolayfilt(flame_tip_location, order, window);
            second_derivative = (smoothed_signal(3:end) - 2*smoothed_signal(2:end-1) + smoothed_signal(1:end-2)) / h^2;
            threshold = threshold_multiplier * std(smoothed_signal);
            exceeds_threshold = any(abs(second_derivative) > threshold);
            noise = flame_tip_location - smoothed_signal;
            signal_power = mean(smoothed_signal.^2);
            noise_power = mean(noise.^2);
            SNR_dB = 10 * log10(signal_power / noise_power);
            if SNR_dB > best_SNR && ~exceeds_threshold
                best_SNR = SNR_dB;
                best_window = window;
                best_order = order;
            end
        end
    end

    smoothed_signal = sgolayfilt(flame_tip_location, best_order, best_window);
    sheetwise_2_d(sheetIdx) = max(abs(smoothed_signal));

    if sheetIdx <= numSheets / 2
        figure(1); 
        subplot(4, 2, sheetIdx); 
    else
        figure(2); 
        subplot(5, 2, sheetIdx - floor(numSheets / 2)); 
    end

    plot(time, flame_tip_location, 'r'); 
    hold on;
    plot(time, smoothed_signal, 'b', 'LineWidth', 2); 
    title(['Sheet ', num2str(sheetIdx)]);
    xlabel('Time');
    ylabel('Signal');
    legend('Original', 'Smoothed');
    grid on;

    fprintf('Sheet %d: Optimal Window Size: %d, Optimal Order: %d, Best SNR (dB): %.2f, Max second derivative: %.2f\n', ...
        sheetIdx, best_window, best_order, best_SNR,sheetwise_2_d(sheetIdx));

    for window = 9:2:101
        for order = 2:window-1
            smoothed_normHR = sgolayfilt(norm_HR, order, window);
            second_derivative = (smoothed_normHR(3:end) - 2*smoothed_normHR(2:end-1) + smoothed_normHR(1:end-2)) / h^2;
            threshold = threshold_multiplier * std(smoothed_normHR);
            exceeds_threshold = any(abs(second_derivative) > threshold);
            noise = norm_HR - smoothed_normHR;
            signal_power = mean(smoothed_normHR.^2);
            noise_power = mean(noise.^2);
            SNR_dB = 10 * log10(signal_power / noise_power);
            if SNR_dB > best_SNR && ~exceeds_threshold
                best_SNR = SNR_dB;
                best_window = window;
                best_order = order;
            end
        end
    end

    smoothed_normHR = sgolayfilt(norm_HR, best_order, best_window);
    sheetwise_2_d(sheetIdx) = max(abs(smoothed_normHR));

    if sheetIdx <= numSheets / 2
        figure(3); 
        subplot(4, 2, sheetIdx); 
    else
        figure(4); 
        subplot(5, 2, sheetIdx - floor(numSheets / 2)); 
    end

    plot(time, norm_HR, 'r'); 
    hold on;
    plot(time, smoothed_normHR, 'b', 'LineWidth', 2); 
    title(['Sheet ', num2str(sheetIdx)]);
    xlabel('Time');
    ylabel('Signal');
    legend('Original norm_HR', 'Smoothed');
    grid on;

    fprintf('Sheet %d: Optimal Window Size: %d, Optimal Order: %d, Best SNR (dB): %.2f, Max second derivative: %.2f\n', ...
        sheetIdx, best_window, best_order, best_SNR,sheetwise_2_d(sheetIdx));
end

[cross_corr, lags] = xcorr(smoothed_normHR, smoothed_signal, 'coeff');  
correlation_coefficient = corr(norm_HR, flame_tip_location)
correlation_coefficient = corr(smoothed_normHR, smoothed_signal)

figure;
stem(lags, cross_corr);
title('Cross-Correlation between Time Series (sheet 2)');
xlabel('Lag');
ylabel('Cross-Correlation');
grid on;

figure;
plot(time, normalize(smoothed_normHR), 'red');
hold on;
plot(time, normalize(smoothed_signal), 'blue');
legend('normalize(norm HR)', 'normalize(flame tip loc)')
title('Smoothened norm HR and flame tip location vs time (sheet 2)')
hold off;

smoothed_normHR = smoothed_normHR - mean(smoothed_normHR);

N = length(smoothed_normHR);

F = fftshift(fft(smoothed_normHR));

Fs = 1/(time(2)-time(1)); 
k = (-N/2:N/2-1); 
frequencies = k * (Fs / N); 

magnitude = abs(F);

[~, peakIdx] = max(magnitude);

dominantFrequency = frequencies(peakIdx);

fft_dom_freq(sheetIdx,1) = sheetIdx;
fft_dom_freq(sheetIdx,2) = dominantFrequency;
end

figure(1);
sgtitle('Original and Smoothed Data (Sheets 1 to 8)');
figure(2);
sgtitle('Original and Smoothed Data (Sheets 9 to 17)');
disp("Sheet Number and FFT Dominant Frequency");
disp(fft_dom_freq);
