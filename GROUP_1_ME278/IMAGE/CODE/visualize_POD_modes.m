function visualize_POD_modes(image_matrix, rows, cols)
    [U, S, V] = svd(image_matrix, 'econ');
    num_modes_to_display = 5;

    figure;
    
    for mode_idx = 1:num_modes_to_display
        pod_mode_image = reshape(U(:, mode_idx), [rows, cols]);
        subplot(1, num_modes_to_display, mode_idx);
        imshow(pod_mode_image, []);  % Display each POD mode as an image
        title(['POD Mode ' num2str(mode_idx)]);
    end

    figure;
    
    %Singular values
    subplot(1, 3, 1); 
    plot(diag(S), 'o-');
    xlabel('Mode index');
    ylabel('Singular value');
    title('Singular Values (Energy Content)');
    
    %Energy Spectrum (singular values squared)
    subplot(1, 3, 2);
    plot(diag(S).^2 / sum(diag(S).^2), 'o-');  % Energy distribution across the modes
    xlabel('Mode index');
    ylabel('Energy Content (Normalized)');
    title('Energy Spectrum of POD Modes');
    
    %Cumulative Energy Content
    subplot(1, 3, 3);  % 1 row, 3 columns, third subplot
    cumulative_energy = cumsum(diag(S).^2) / sum(diag(S).^2);  % Cumulative energy ratio
    plot(cumulative_energy, 'o-');
    xlabel('Mode index');
    ylabel('Cumulative Energy Content');
    title('Cumulative Energy Content per POD Mode');


    %Temporal Evolution of Modes
    num_temporal_modes_to_plot = 5;
    figure;
    for mode_idx = 1:num_temporal_modes_to_plot
        subplot(num_temporal_modes_to_plot, 1, mode_idx);
        plot(V(:, mode_idx));
        xlabel('Image Index (Time)');
        ylabel(['Mode ' num2str(mode_idx)]);
        title(['Temporal Evolution of Mode ' num2str(mode_idx)]);
    end

    figure;
    
    % 2D Scatter plot of the first two POD modes
    subplot(1, 2, 1);  % 1 row, 2 columns, first subplot
    scatter(U(:, 1), U(:, 2), 10, 'filled');
    title('Scatter plot of the first two POD modes');
    xlabel('Mode 1');
    ylabel('Mode 2');
    colorbar;
    
    % 3D Scatter plot of the first three POD modes
    subplot(1, 2, 2);
    scatter3(U(:, 1), U(:, 2), U(:, 3), 10, 'filled');
    title('3D Scatter plot of the first three POD modes');
    xlabel('Mode 1');
    ylabel('Mode 2');
    zlabel('Mode 3');
    colorbar;

end
