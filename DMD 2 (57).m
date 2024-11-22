% Specify the folder where the images are located
folderPath = 'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_57\P_0kV_3p75mps';  % Path to the images

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
% Create X1 and X2 from the image_matrix
X1 = image_matrix(:, 1:end-1);  % All rows, columns 1 to n-1
X2 = image_matrix(:, 2:end);    % All rows, columns 2 to n

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of spatial modes to display
num_modes_to_display = 3;

for mode_idx = 1:num_modes_to_display
    % Reshape the spatial mode vector from Phi back into 2D image format (600 x 192)
    dmd_mode_image = reshape(Phi(:, mode_idx), [600, 192]);
    
    % Normalize the mode to the range [0, 1] without flipping the sign
    dmd_mode_image = (dmd_mode_image - min(dmd_mode_image(:))) / (max(dmd_mode_image(:)) - min(dmd_mode_image(:)));
    
    % Display the normalized DMD mode as a grayscale image
    figure;
    imshow(dmd_mode_image, []);  % The empty array [] auto-scales the intensity
    colormap('gray');  % Use a grayscale colormap for the images
    colorbar;  % Add colorbar to indicate the intensity scale
    title(['DMD Spatial Mode ' num2str(mode_idx)]);  % Add title for clarity
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the magnitudes of the eigenvalues (like singular values in POD) with clear decay
figure;
% Sort the absolute values of the eigenvalues in descending order
sorted_eigenvalues = sort(abs(Lambda), 'descend');

% Plot using semilogy to show the decay clearly on a logarithmic scale
semilogy(sorted_eigenvalues, 'o-', 'MarkerFaceColor', 'b', 'LineWidth', 2);

% Label the axes and title the plot
xlabel('Mode Index');
ylabel('Magnitude of Eigenvalues');
title('Magnitude of Eigenvalues of the Reduced System Matrix \Atilde');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Eigenvalues of the reduced system matrix Atilde
Lambda = diag(Sigma_dmd);  % Eigenvalues are the diagonal elements of Sigma_dmd

% Display the eigenvalues
disp('Eigenvalues (Lambda):');
disp(Lambda);

% Define a tolerance for small imaginary parts
tolerance = 1e-6;  % Tolerance for considering an imaginary part significant

% Initialize an array to store flickering frequencies (in Hz)
flickering_frequencies = [];

% Check for significant imaginary parts and compute flickering frequency
for i = 1:length(Lambda)
    if abs(imag(Lambda(i))) > tolerance
        % Calculate the flickering frequency (imaginary part of the eigenvalue)
        flickering_frequency = imag(Lambda(i)) / (2 * pi);  % Frequency in Hz
        flickering_frequencies = [flickering_frequencies, flickering_frequency];
        
        % Display the flickering frequency for each mode
        disp(['Flickering Frequency (Mode ' num2str(i) ') in Hz: ' num2str(flickering_frequency)]);
    else
        % If the eigenvalue is purely real, indicate no oscillation
        disp(['No significant oscillatory mode detected for Mode ' num2str(i) ' (purely real eigenvalue).']);
    end
end

% Optionally, plot the flickering frequencies
figure;
plot(flickering_frequencies, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Mode Number');
ylabel('Flickering Frequency (Hz)');
title('Flickering Frequencies of DMD Modes');
grid on;

