%% Get files
load('2016-09-08-153543_asn_nw_02048_nj_11469_seed_042_avl_28.00_disp_10.00.mat', 'adj_matrix')
degrees = sum(adj_matrix);
save('2048topo.mat', 'adj_matrix', 'degrees');


load('2016-09-08-155044_asn_nw_00700_nj_14533_seed_042_avl_100.00_disp_10.00.mat', 'adj_matrix')
degrees = sum(adj_matrix);
save('700topo.mat', 'adj_matrix', 'degrees');

load('2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat')
degrees = sum(adj_matrix);
save('100topo.mat', 'adj_matrix', 'degrees');

nw100 = load('100topo.mat');
nw700 = load('700topo.mat');
nw2000 = load('2048topo.mat');


%% Plot distribution
close all;
figure;

subplot(1,2,1);
histogram(nw100.degrees, 'Normalization','probability')
title('100 nanowire / 261 junction network')
xlabel('Vertex Degree')
ylabel('Proportion')
hold on;
yy = 0:1e-4:0.2;
yx = sum(nw100.degrees)*ones(size(yy))/numel(nw100.degrees);
plot(yx, yy, 'r--');
legend('P(n_j|d)', 'junction density', 'location', 'northeast')

subplot(1,2,2);
histogram(nw700.degrees, 'Normalization','probability')
title('700 nanowire / 14533 junction network')
xlabel('Vertex Degree')
ylabel('Proportion')
hold on;
yy = 0:1e-4:0.2;
yx = sum(nw700.degrees)*ones(size(yy))/numel(nw700.degrees);
plot(yx, yy, 'r--');
legend('P(n_j|d)', 'junction density', 'location', 'northeast')


set(gcf, 'Position',  [100, 100, 1000, 400])

% saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter3/DegreeDistribution.png');
%Plot mean density on the plot for comparison


%% Plot graph representation
g100 = graph(nw100.adj_matrix);
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(1,2,1);
plot(g100, 'NodeLabel',{}, 'NodeColor', 'r');
set(gca,'visible','off')
set(gca,'xtick',[])
set(gca,'ytick',[])

g700 = graph(nw700.adj_matrix);
subplot(1,2,2);
plot(g700, 'NodeLabel',{}, 'NodeColor', 'r');
set(gca,'visible','off')
set(gca,'xtick',[])
set(gca,'ytick',[])



%% Plot both
close all;
figure('color','w', 'units', 'centimeters', 'OuterPosition', [5 5 22.5 17.5]);

subplot(2,2,1);
histogram(nw100.degrees, 'Normalization','probability')
title('100 nanowire / 261 junction network')
xlabel('Vertex Degree')
ylabel('Proportion')
hold on;
yy = 0:1e-4:0.2;
yx = sum(nw100.degrees)*ones(size(yy))/numel(nw100.degrees);
plot(yx, yy, 'r--');
legend('P(n_j|d)', 'jn density', 'location', 'northwest')
text(8.7, 0.175, '(a)', 'FontSize',18)


subplot(2,2,2);
histogram(nw700.degrees, 'Normalization','probability')
title('700 nanowire / 14533 junction network')
xlabel('Vertex Degree')
ylabel('Proportion')
hold on;
yy = 0:1e-4:0.2;
yx = sum(nw700.degrees)*ones(size(yy))/numel(nw700.degrees);
plot(yx, yy, 'r--');
legend('P(n_j|d)', 'jn density', 'location', 'northwest')
text(70, 0.175, '(b)', 'FontSize',18)


g100 = graph(nw100.adj_matrix);

subplot(2,2,3);
plot(g100, 'NodeLabel',{}, 'NodeColor', 'r', 'EdgeColor', 'b');
% set(gca,'visible','off')
set(gca,'xtick',[])
set(gca,'ytick',[])
xlim([-3.7,4]);
ylim([-3.5,4.5]);

g700 = graph(nw700.adj_matrix);
subplot(2,2,4);
plot(g700, 'NodeLabel',{}, 'NodeColor', 'r', 'EdgeColor', 'b');
set(gca,'xtick',[])
set(gca,'ytick',[])
xlim([-6,6])
ylim([-6,6]);

saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter3/DegreeDistribution.png');

