% Specify the folder where the images are located
folderPath = 'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_38\P_0kV_2p75mps';  % Path to the images

% List all the image files in the folder (assuming .tif files)
totalImageFiles = dir(fullfile(folderPath, '*.tif'));  % Use the correct extension for your images

% Calculate how many images you will process (every 10th image)
numImages = numel(1:10:numel(totalImageFiles)); 

% Initialize cell arrays to store the images
Images = cell(1, numImages);  % Pre-allocate the cell array for Images
binarized_images = cell(1, numImages);  % To store contrasted images
cropped_images = cell(1, numImages);  % To store cropped images

level = 0.001;
% Loop through every 10th image
j = 1;  % Use a new index for the cell array
for i = 1:10:numel(totalImageFiles)
    % Full path of the image
    imagePath = fullfile(folderPath, totalImageFiles(i).name);
    Images{j} = imread(imagePath);  % Store the image in the Images cell array
    binarized_images{j} = imbinarize(Images{j},level);  % Apply contrast adjustment
    j = j + 1;  % Increment index for the next image
end

% Get the image dimensions (assuming all images are the same size)
[rows, cols, ~] = size(binarized_images{1});  % 928 * 576 for your case

% Ensure cropped images don't go out of bounds
crop_height = 600;  % The number of rows we want to keep
crop_width = 192;   % The number of columns we want to keep

% Crop images
for k = 1:numImages
    % Check if the image has enough size to be cropped
    if rows >= crop_height && cols >= crop_width
        % Perform the cropping (starting from the last 600 rows and last 192 columns)
        cropped_images{k} = binarized_images{k}(end-crop_height+1:end, round(cols-crop_width)+1:end, :);
    else
        warning('Image size is smaller than expected. Skipping cropping for image %d.', k);
        cropped_images{k} = binarized_images{k};  % Keep the original image if it's too small
    end
end

% Convert cropped_images to 2D matrices based on intensity
matrix_cropped_images = cell(1, numImages);  % Initialize a new cell array to store 2D matrices
for k = 1:numImages
    matrix_cropped_images{k} = im2double(cropped_images{k});  % Convert to 2D matrix of intensities
end

disp(size(matrix_cropped_images))

% Get the dimensions of a cropped image (assuming all cropped images have the same size)
[rows, cols, ~] = size(cropped_images{1});  % For example, 600 x 192

disp([rows,cols])

% Pre-allocate the matrix with the correct size (flattened image size)
image_matrix = zeros(rows * cols, numImages);  % Each column corresponds to one image

% Convert each cropped image to a 1D array and normalize
for k = 1:numImages
    % Flatten the cropped image into a 1D array and normalize the intensity
    flattened_image = im2double(cropped_images{k});  % Normalize to [0, 1]
    
    % Reshape the image into a column vector and assign it to the matrix
    image_matrix(:, k) = flattened_image(:);  % Each image as a column in the matrix
end

% Display the size of the resulting 2D matrix
disp(size(image_matrix));  % Should be (rows * cols) x numImages

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform SVD on X1 and X2
[U_X1, Sigma_X1, V_X1] = svd(X1, 'econ');  % SVD of X1
[U_X2, Sigma_X2, V_X2] = svd(X2, 'econ');  % SVD of X2

% Compute the reduced system matrix Atilde using the SVD components
Atilde = U_X2' * X1 * pinv(U_X1);  % Corrected: Using pseudo-inverse of U_X1

% Perform SVD of the reduced system matrix Atilde
[U_dmd, Sigma_dmd, V_dmd] = svd(Atilde, 'econ');  % Singular value decomposition of Atilde

% Compute DMD modes (Phi) (spatial modes)
Phi = X1 * U_dmd * pinv(Sigma_dmd);  % DMD modes (spatial patterns)

% Eigenvalues (Lambda) of the system
Lambda = diag(Sigma_dmd);  % Eigenvalues are the diagonal elements of Sigma_dmd

% Temporal modes (omega) are derived from the eigenvalues
omega = log(abs(Lambda)) / (1);  % Logarithm of the absolute value of eigenvalues

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Visualization

% Plot the first few temporal modes (omega)
figure;
for i = 1:5  % First 5 modes
    subplot(5,1,i);
    plot(real(omega(i,:)), 'b-', 'LineWidth', 2); % Real part of the temporal modes
    hold on;
    plot(imag(omega(i,:)), 'r--', 'LineWidth', 2); % Imaginary part of the temporal modes
    title(['Temporal Mode ' num2str(i)]);
    xlabel('Time');
    ylabel('Mode Value');
end

% Plot the singular values (energy content)
figure;
plot(diag(Sigma_dmd), 'o-', 'LineWidth', 2);
xlabel('Mode Index');
ylabel('Singular Value');
title('Singular Values (Energy Content)');

% Plot the eigenvalues (Lambda)
figure;
plot(real(Lambda), imag(Lambda), 'o');
xlabel('Real Part');
ylabel('Imaginary Part');
title('Eigenvalue Spectrum');
grid on;