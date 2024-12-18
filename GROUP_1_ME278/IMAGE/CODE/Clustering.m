Phi = [4, 5, 5, 7.5, 7.5, 7.5, 10, 10, 10, 18, 18, 18, 28, 28, 38, 38, 57];
Re = [4.29e5, 3.68e5, 7.67e5, 3.067e5, 5.82e5, 8.895e5, 2.45e5, 5.21e5, 7.66e5, ...
      2.14e5, 3.98e5, 6.13e5, 3.68e5, 5.21e5, 3.37e5, 4.9e5, 4.6e5];
fmax = [2.5, 2.5, 2.222, 12.5, 1.428, 1.5385, 13.333, 14.667, 2.5, 14, 14.2847, ...
        12.6582, 12.1212, 12.8571, 12.5, 12.5, 13.334];
h = [34.8, 34.6, 71.6, 33, 68.6, 103, 34.8, 65.8, 105.4, 34.6, 66.4, 82.6, ...
     58.6, 89.8, 60, 91.2, 91.8];

figure;

subplot(1, 2, 1);
title('Independent Variables: Phi vs Re');
xlabel('Phi');
ylabel('Re');
grid on;

subplot(1, 2, 2);
title('Dependent Variables: fmax vs h');
xlabel('fmax');
ylabel('h');
grid on;

colors = lines(length(Phi));

for i = 1:length(Phi)
    subplot(1, 2, 1);
    hold on;
    scatter(Phi(i), Re(i), 50, 'filled', 'MarkerFaceColor', colors(i,:));
    xlim([min(Phi)-1, max(Phi)+1]);
    ylim([min(Re)-1, max(Re)+1]);

    subplot(1, 2, 2);
    hold on;
    scatter(fmax(i), h(i), 50, 'filled', 'MarkerFaceColor', colors(i,:));
    xlim([min(fmax)-1, max(fmax)+1]);
    ylim([min(h)-1, max(h)+1]);
end

data = [fmax', h'];
gmm = fitgmdist(data, 2);

clusterIdx = cluster(gmm, data);

subplot(1, 2, 2);
hold on;
for i = 1:length(clusterIdx)
    if clusterIdx(i) == 1
        scatter(fmax(i), h(i), 50, 'r', 'filled');
    else
        scatter(fmax(i), h(i), 50, 'g', 'filled');
    end
end

mu = gmm.mu;
plot(mu(:, 1), mu(:, 2), 'kx', 'MarkerSize', 10, 'LineWidth', 2);

subplot(1, 2, 1);
hold on;
for i = 1:length(clusterIdx)
    if clusterIdx(i) == 1
        scatter(Phi(i), Re(i), 50, 'r', 'filled');
    else
        scatter(Phi(i), Re(i), 50, 'g', 'filled');
    end
end

h1 = scatter(NaN, NaN, 50, 'r', 'filled');
h2 = scatter(NaN, NaN, 50, 'g', 'filled');

legend([h1, h2], {'Flickering Absent (Red)', 'Flickering Present (Green)'}, 'Location', 'best');

figure;
silhouette(data, clusterIdx);
title('Silhouette Plot for GMM Clustering');
xlabel('Silhouette Value');
ylabel('Data Point Index');

trueLabels = ones(size(clusterIdx));
trueLabels(clusterIdx == 2) = 2;

confMat = confusionmat(trueLabels, clusterIdx);

figure;
h = heatmap(confMat, 'Title', 'Confusion Matrix', 'XLabel', 'Predicted', 'YLabel', 'True');
h.FontSize = 24;
