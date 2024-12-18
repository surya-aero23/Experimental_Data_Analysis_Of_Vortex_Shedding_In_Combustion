function plot_POD_modes(image_matrix, rows, cols)
    [U, S, V] = svd(image_matrix, 'econ');

    approximation_image_1 = U(:, 1) * S(1, 1) * V(:, 1)';  
    approximation_image_2 = U(:, 1:2) * S(1:2, 1:2) * V(:, 1:2)';  
    approximation_image_3 = U(:, 1:3) * S(1:3, 1:3) * V(:, 1:3)';  
    approximation_image_4 = U(:, 1:4) * S(1:4, 1:4) * V(:, 1:4)';  
    approximation_image_5 = U(:, 1:5) * S(1:5, 1:5) * V(:, 1:5)';  

    frames = size(approximation_image_1, 2);

    figure('Color', [0.1, 0.1, 0.1]);

    reshaped_1 = reshape(approximation_image_1, [rows, cols, frames]);
    reshaped_2 = reshape(approximation_image_2, [rows, cols, frames]);
    reshaped_3 = reshape(approximation_image_3, [rows, cols, frames]);
    reshaped_4 = reshape(approximation_image_4, [rows, cols, frames]);
    reshaped_5 = reshape(approximation_image_5, [rows, cols, frames]);

    subplot(1, 5, 1);  
    h1 = imshow(reshaped_1(:, :, 1), []);  
    set(gca, 'Color', [0.1, 0.1, 0.1]);  
    title('Rank-1 Approximation', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');  

    subplot(1, 5, 2);  
    h2 = imshow(reshaped_2(:, :, 1), []);  
    set(gca, 'Color', [0.1, 0.1, 0.1]);  
    title('Rank-2 Approximation', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');  

    subplot(1, 5, 3);  
    h3 = imshow(reshaped_3(:, :, 1), []);  
    set(gca, 'Color', [0.1, 0.1, 0.1]);  
    title('Rank-3 Approximation', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');  

    subplot(1, 5, 4);  
    h4 = imshow(reshaped_4(:, :, 1), []);  
    set(gca, 'Color', [0.1, 0.1, 0.1]);  
    title('Rank-4 Approximation', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');  

    subplot(1, 5, 5);  
    h5 = imshow(reshaped_5(:, :, 1), []);  
    set(gca, 'Color', [0.1, 0.1, 0.1]);  
    title('Rank-5 Approximation', 'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');  

    speed_factor = 2;  

    frame_time = 1 / (30 * speed_factor);  

    for i = 1:frames
        h1.CData = reshaped_1(:, :, i);  
        h2.CData = reshaped_2(:, :, i);  
        h3.CData = reshaped_3(:, :, i);  
        h4.CData = reshaped_4(:, :, i);  
        h5.CData = reshaped_5(:, :, i);  

        axis tight;  
        set(gca, 'XLim', [1, cols]);
        set(gca, 'YLim', [1, rows]);

        drawnow;  

        pause(frame_time);  
    end

    videoWriter = VideoWriter('C:\Data - Premixed Flame Shedding Characteristics\Videos\RankApproxVid_Case16.mp4', 'MPEG-4');
    videoWriter.FrameRate = 30 * speed_factor;  
    open(videoWriter);

    set(gcf, 'Position', [100, 100, 1920, 926]);  

    for i = 1:frames
        h1.CData = reshaped_1(:, :, i);
        h2.CData = reshaped_2(:, :, i);
        h3.CData = reshaped_3(:, :, i);
        h4.CData = reshaped_4(:, :, i);
        h5.CData = reshaped_5(:, :, i);

        drawnow;  

        frame = getframe(gcf);  
        writeVideo(videoWriter, frame);  
    end

    close(videoWriter);
end
