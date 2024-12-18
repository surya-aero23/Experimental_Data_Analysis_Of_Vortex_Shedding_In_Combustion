function [flame_height, peak_frequency] = calculate_height_and_frequency(image_matrix, rows, cols)
    [U, S, V] = svd(image_matrix, 'econ');
    approximation_image_1 = U(:, 1) * S(1, 1) * V(:, 1)';
    approximation_image_5 = U(:, 1:5) * S(1:5, 1:5) * V(:, 1:5)';

    frames = size(approximation_image_1, 2);

    reshaped_1 = reshape(approximation_image_1, [rows, cols, frames]);
    reshaped_5 = reshape(approximation_image_5, [rows, cols, frames]);

    time_series_all_pixels = reshape(reshaped_5, [], frames);

    mean_time_series = mean(time_series_all_pixels, 1);

    mean_time_series = mean_time_series - mean(mean_time_series);

    sampling_rate = 1000;
    n = length(mean_time_series);

    Y = fft(mean_time_series);
    f = (0:n-1)*(sampling_rate/n);

    magnitude = abs(Y);

    [~, peak_idx] = max(magnitude(2:end));
    peak_frequency = f(peak_idx + 1);

    disp(['Flickering frequency: ', num2str(peak_frequency), ' Hz']);

    figure;
    plot(f(1:n/2), magnitude(1:n/2));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('FFT Frequency Spectrum of the Time-Series (DC removed)');
    grid on;

    threshold_level = 0.85;
    binarized_image = imbinarize(reshaped_1(:,:,1), threshold_level);

    figure;
    imshow(binarized_image);
    title('Binarized Image');

    [flame_rows, ~] = find(binarized_image);

    if ~isempty(flame_rows)
        flame_height = max(flame_rows) - min(flame_rows);
        disp(['Flame Height: ', num2str(flame_height), ' pixels']);
    else
        disp('No flame detected in the image.');
    end
end
