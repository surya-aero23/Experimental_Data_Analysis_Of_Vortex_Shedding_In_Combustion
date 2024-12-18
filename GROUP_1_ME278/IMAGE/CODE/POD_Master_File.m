folderPaths = {
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_4\P_0kV_3p5mps', 
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_5\P_0kV_3mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_5\P_0kV_6p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_7p5\P_0kV_2p5mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_7p5\P_0kV_4p75mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_7p5\P_0kV_7p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_10\P_0kV_2mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_10\P_0kV_4p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_10\P_0kV_6p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_18\P_0kV_1p75mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_18\P_0kV_3p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_18\P_0kV_5mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_28\P_0kV_3mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_28\P_0kV_4p25mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_38\P_0kV_2p75mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_38\P_0kV_4mps',
    'C:\Data - Premixed Flame Shedding Characteristics\0kV\Phi_57\P_0kV_3p75mps'
};

folderNum = input('Select a folder (1 to 17): ');

if folderNum < 1 || folderNum > 17
    disp('Invalid folder number. Please select a number between 1 and 17.');
    return;
end

folderPath = folderPaths{folderNum};

[image_matrix, rows, cols] = processImages(folderPath);

[flame_height, peak_frequency] = calculate_height_and_frequency(image_matrix, rows, cols);

visualize_POD_modes(image_matrix, rows, cols);

plot_POD_modes(image_matrix, rows, cols);

