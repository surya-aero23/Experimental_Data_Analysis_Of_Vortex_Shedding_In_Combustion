clear all, close all, clc

folderPath = 'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_7p5\P_0kV_7p25mps';
totalImageFiles = dir(fullfile(folderPath, '*.tif'));

numImages = numel(1:10:numel(totalImageFiles)); 

Images = cell(1, numImages);  
binarized_images = cell(1, numImages);  
cropped_images = cell(1, numImages);  

level = 0.001;
j = 1;  
for i = 1:10:numel(totalImageFiles)
    imagePath = fullfile(folderPath, totalImageFiles(i).name);
    Images{j} = imread(imagePath);  
    binarized_images{j} = imbinarize(Images{j},level);  
    j = j + 1;  
end

[rows, cols, ~] = size(binarized_images{1});  

crop_height = 700;  
crop_width = 192;   

for k = 1:numImages
    if rows >= crop_height && cols >= crop_width
        cropped_images{k} = binarized_images{k}(end-crop_height+1:end, round(cols-crop_width)+1:end, :);
    else
        warning('Image size is smaller than expected. Skipping cropping for image %d.', k);
        cropped_images{k} = binarized_images{k};  
    end
end

matrix_cropped_images = cell(1, numImages);  
for k = 1:numImages
    matrix_cropped_images{k} = im2double(cropped_images{k});  
end

disp(size(matrix_cropped_images))

[rows, cols, ~] = size(cropped_images{1});  

disp([rows,cols])

image_matrix = zeros(rows * cols, numImages);  

for k = 1:numImages
    flattened_image = im2double(cropped_images{k});  
    image_matrix(:, k) = flattened_image(:);  
end

disp(size(image_matrix));  

X1 = image_matrix(:, 1:end-1);  
X2 = image_matrix(:, 2:end);    

[U, S, V] = svd(X1, 'econ');

r = 100;  
U_r = U(:,1:r);
S_r = S(1:r,1:r);
V_r = V(:,1:r);

Atilde = U_r' * X2 * V_r / S_r;
[W, eigs] = eig(Atilde);

Phi = X2 * V_r / S_r * W;

X2_approx = Phi * (W \ (S_r \ (U_r' * X1)));

residual_norm = norm(X2 - X2_approx, 'fro');
fprintf('Residual Norm for DMD approximation: %.4f\n', residual_norm);

num_modes_to_display = 5;  

figure;

for mode_idx = 1:num_modes_to_display
    dmd_mode_image = reshape(Phi(:, mode_idx), [rows, cols]);
    
    subplot(1, num_modes_to_display, mode_idx);
    imshow(dmd_mode_image, []);  
    title(['DMD Mode ' num2str(mode_idx)]);
end

figure;
plot(abs(diag(eigs)), 'o-');
xlabel('Mode Index');
ylabel('Magnitude of Eigenvalue (Energy)');
title('Eigenvalue Spectrum (Energy of Modes)');

num_modes_to_use = 1; 
delta_t = 1;  

predicted_image = zeros(rows * cols, 1);

for mode_idx = 1:num_modes_to_use
    predicted_temporal_coeff = exp(eigs(mode_idx) * delta_t) * V_r(end, mode_idx);
    predicted_image = predicted_image + predicted_temporal_coeff * Phi(:, mode_idx);
end

predicted_image_2d = reshape(predicted_image, [rows, cols]);

figure;
imshow(predicted_image_2d, []);
title('Predicted Next Image Using First 2 Dominant DMD Modes');