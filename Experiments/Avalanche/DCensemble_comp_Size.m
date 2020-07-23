%%
close all;
% baseFolder = '/home/joelh/Documents/NeuroNanoAI/Avalanche/FixedWires/';
% baseFolder = '~/Documents/NeuroNanoAI/Avalanche/FixedDensity/';
baseFolder = '/home/joelh/Documents/NeuroNanoAI/Avalanche/ChangePLength/';
cd(baseFolder)
saveFolder = strcat(baseFolder, '/AvCompare/');
mkdir(saveFolder)
binSize = -1; %[-1, 10, 50, 100];

% Lvals = [40:10:80]';
Lvals = [5:10:45]';
N = numel(Lvals);

critResults = cell(N, 1);

for i = 1:numel(Lvals)
%     critResults{i} = load(strcat2({baseFolder, 'Length', num2str(Lvals(i), '%04.f'), '/bs', binSize, '/critResults.mat'}));
%     critResults{i} = load(strcat2({baseFolder, 'Length', num2str(Lvals(i)), '/bs', binSize, '/critResults.mat'}));    
    critResults{i} = load(strcat2({baseFolder, 'ChangePLength', num2str(Lvals(i)), '/bs', binSize, '/critResults.mat'}));    
    critResults{i} = critResults{i}.critResults;
end


%%
meanG = zeros(N,1);
V = zeros(N,1);
PSDbeta = zeros(N,1);
PSDdbet = zeros(N,1);
numEvents = zeros(N,1);
meanIEI = zeros(N,1);
IEItau = zeros(N,1);
IEIdta = zeros(N,1);
dGalpha = zeros(N,1);
dGdalph = zeros(N,1);
Stau = zeros(N,1);
Sdta = zeros(N,1);
Slct = zeros(N,1);
Suct = zeros(N,1);
Talp = zeros(N,1);
Tdal = zeros(N,1);
Tlct = zeros(N,1);
Tuct = zeros(N,1);
x1  = zeros(N,1);
dx1 = zeros(N,1);
x2  = zeros(N,1);
dx2 = zeros(N,1);
x3  = zeros(N,1);
dx3 = zeros(N,1);
IEIbins = cell(N,1);
IEIprob = cell(N,1);
dGbins  = cell(N,1);
dGprob  = cell(N,1);
Szbins  = cell(N,1);
Szprob  = cell(N,1);
Tmbins  = cell(N,1);
Tmprob  = cell(N,1);
ASlife  = cell(N,1);
ASsize  = cell(N,1);


for i = 1:N
    meanG(i) = critResults{i}.net.meanG;
    V(i) = mean(critResults{i}.net.V);
    PSDbeta(i) = critResults{i}.PSD.beta;
    PSDdbet(i) = critResults{i}.PSD.dbeta;    
    numEvents(i) = critResults{i}.events.numEvents;
    meanIEI(i) = critResults{i}.IEI.meanIEI;
    IEItau(i) = critResults{i}.IEI.tau;
    IEIdta(i) = critResults{i}.IEI.sigmaTau;
    IEIbins{i} = critResults{i}.IEI.bins;
    IEIprob{i} = critResults{i}.IEI.prob;
    dGalpha(i) = critResults{i}.dG.alpha;
    dGdalph(i) = critResults{i}.dG.dalph;
    dGbins{i} = critResults{i}.dG.bins;
    dGprob{i} = critResults{i}.dG.prob;
    Stau(i) = critResults{i}.avalanche.sizeFit.tau;
    Sdta(i) = critResults{i}.avalanche.sizeFit.dTau;
    Slct(i) = critResults{i}.avalanche.sizeFit.lc;
    Suct(i) = critResults{i}.avalanche.sizeFit.uc;
    Szbins{i} = critResults{i}.avalanche.sizeFit.bins;
    Szprob{i} = critResults{i}.avalanche.sizeFit.prob;    
    Talp(i) = critResults{i}.avalanche.timeFit.alpha;
    Tdal(i) = critResults{i}.avalanche.timeFit.dAlpha;
    Tlct(i) = critResults{i}.avalanche.timeFit.lc;
    Tuct(i) = critResults{i}.avalanche.timeFit.uc;
    Tmbins{i} = critResults{i}.avalanche.timeFit.bins;
    Tmprob{i} = critResults{i}.avalanche.timeFit.prob;        
    ASlife{i} = critResults{i}.avalanche.avSizeFit.mLife;
    ASsize{i} = critResults{i}.avalanche.avSizeFit.mSize;         
    x1 (i) = critResults{i}.avalanche.gamma.x1;
    dx1(i) = critResults{i}.avalanche.gamma.dx1;
    x2 (i) = critResults{i}.avalanche.gamma.x2;
    dx2(i) = critResults{i}.avalanche.gamma.dx2;
    x3 (i) = critResults{i}.avalanche.gamma.x3;
    dx3(i) = critResults{i}.avalanche.gamma.dx3;
end

%% Comparison by parameter
%% dG
figure;
errorbar(Lvals, dGalpha, dGdalph, '--o');
xlabel('L')
ylabel('\alpha')
yyaxis right;
semilogy(Lvals, meanG, '-o');
ylabel('<G>')
title('\Delta G exponent')
print(gcf,strcat(saveFolder, '/dGComp.png'), '-dpng', '-r300', '-painters')



%% PSD
figure;
errorbar(Lvals, PSDbeta, PSDdbet, '--o');
xlabel('L')
ylabel('\beta')
title('PSD exponent')
print(gcf,strcat(saveFolder, '/PSDComp.png'), '-dpng', '-r300', '-painters')



%% IEI
figure;
errorbar(Lvals, IEItau, IEIdta, '--o');
xlabel('L')
ylabel('\alpha')
yyaxis right;
semilogy(Lvals, meanIEI, 'o-');
ylabel('<IEI>')
title('Inter-event interval')
print(gcf,strcat(saveFolder, '/IEIComp.png'), '-dpng', '-r300', '-painters')


%% Size
figure;
errorbar(Lvals, Stau, Sdta);
xlabel('L')
ylabel('\tau')
title('Avalanche size')
yyaxis right;
plot(Lvals, Slct, ':');
hold on;
plot(Lvals, Suct, 'k--');
ylabel('cut-off')
legend('\alpha', 'lc', 'uc')
print(gcf,strcat(saveFolder, '/SizeComp.png'), '-dpng', '-r300', '-painters')



%% Lifetime
figure;
errorbar(Lvals, Talp, Tdal);
xlabel('L')
ylabel('\alpha')
title('Avalanche life-time')
yyaxis right;
plot(Lvals, Tlct, ':');
hold on;
plot(Lvals, Tuct, 'k--');
ylabel('cut-off')
legend('\alpha', 'lc', 'uc')
print(gcf,strcat(saveFolder, '/LifeComp.png'), '-dpng', '-r300', '-painters')


%% Gamma
figure;
errorbar(Lvals,x1, dx1);
hold on;
errorbar(Lvals,x2, dx2);
errorbar(Lvals,x3, dx3);
xlabel('L')
ylabel('1/\sigma\tau\nu')
legend('S,T', '<S>(T)', 'Shape', 'location', 'best')
title('Crackling relationship')
print(gcf,strcat(saveFolder, '/CrackComp.png'), '-dpng', '-r300', '-painters')


%% Distributions
%% IEI
figure;
for i = 1:N 
    loglog(IEIbins{i}, IEIprob{i});
    hold on;
end
xlabel('T')
ylabel('P(T)')
title('IEI')
leg = legend(num2str(Lvals), 'location', 'best');
title(leg,'L')
print(gcf,strcat(saveFolder, '/IEIPlot.png'), '-dpng', '-r300', '-painters')


%% dG
figure;
for i = 1:N 
    loglog(dGbins{i}, dGprob{i});
    hold on;
end
xlabel('\Delta G')
ylabel('P(\Delta G)')
title('\Delta G')
leg = legend(num2str(Lvals), 'location', 'best');
title(leg,'L')
print(gcf,strcat(saveFolder, '/dGPlot.png'), '-dpng', '-r300', '-painters')



%% Size
figure;
for i = 1:N 
    loglog(Szbins{i}, Szprob{i});
    hold on;
end
xlabel('S')
ylabel('P(S)')
title('Avalanche size')
leg = legend(num2str(Lvals), 'location', 'best');
title(leg,'L')
print(gcf,strcat(saveFolder, '/SizePlot.png'), '-dpng', '-r300', '-painters')


%% Life
figure;
for i = 1:N 
    loglog(Tmbins{i}, Tmprob{i});
    hold on;
end
xlabel('T')
ylabel('P(T)')
title('Avalanche life-time')
leg = legend(num2str(Lvals), 'location', 'best');
title(leg,'L')
print(gcf,strcat(saveFolder, '/LifePlot.png'), '-dpng', '-r300', '-painters')



%% Average Size
figure;
for i = 1:N 
    loglog(ASlife{i}, ASsize{i});
    hold on;
end
xlabel('T')
ylabel('<S>')
title('Avalanche average size')
leg = legend(num2str(Lvals), 'location', 'best');
title(leg,'L')
print(gcf,strcat(saveFolder, '/AvSzPlot.png'), '-dpng', '-r300', '-painters')
