function binarise

folderPath = 'D:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_57\P_0kV_3p75mps'; %folder path

imageFiles = dir(fullfile(folderPath, '*.tif'));

outputFolder = fullfile(folderPath, 'Binarized_Images');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end


level = 0.001;  %threshold value


for i = 1:length(imageFiles)
    
    imagePath = fullfile(folderPath, imageFiles(i).name);
    
    img = imread(imagePath);

    binaryImage = imbinarize(img, level);

    [~, name, ~] = fileparts(imageFiles(i).name);
    outputFileName = fullfile(outputFolder, [name, '_Binarized.png']);
    imwrite(binaryImage, outputFileName);
end

disp('Batch processing complete. All binarized images are saved in the output folder.');

end