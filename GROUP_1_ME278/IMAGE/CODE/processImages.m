function [image_matrix, rows, cols] = processImages(folderPath)

    totalImageFiles = dir(fullfile(folderPath, '*.tif'));

    % Every 10th Image Considered from the Image_Set
    numImages = numel(1:10:numel(totalImageFiles)); 
    Images = cell(1, numImages);
    binarized_images = cell(1, numImages);
    cropped_images = cell(1, numImages);

    level = 0.001;  % Contrast adjustment threshold
    
    j = 1; 
    for i = 1:10:numel(totalImageFiles)
        imagePath = fullfile(folderPath, totalImageFiles(i).name);
        Images{j} = imread(imagePath);  
        binarized_images{j} = imbinarize(Images{j}, level); 
        j = j + 1; 
    end

    [rows, cols, ~] = size(binarized_images{1});  % 928 * 576 

    crop_height = 700;  % The number of rows we want to keep
    crop_width = 192;   % The number of columns we want to keep

    % Crop images
    for k = 1:numImages
        if rows >= crop_height && cols >= crop_width
            cropped_images{k} = binarized_images{k}(end-crop_height+1:end, round(cols-crop_width)+1:end, :);
        else
            warning('Image size is smaller than expected. Skipping cropping for image %d.', k);
            cropped_images{k} = binarized_images{k};  % Keep the original image if it's too small
        end
    end

    % Converting cropped_images to 2D matrices based on intensity
    matrix_cropped_images = cell(1, numImages);  
    for k = 1:numImages
        matrix_cropped_images{k} = im2double(cropped_images{k});
    end

    [rows, cols, ~] = size(cropped_images{1});  % 700 x 192

    image_matrix = zeros(rows * cols, numImages);  % Each column corresponds to one image

    % Converting each cropped image to a 1D array and normalize
    for k = 1:numImages
        flattened_image = im2double(cropped_images{k}); 
        image_matrix(:, k) = flattened_image(:);  % Each image as a column in the matrix
    end
end
