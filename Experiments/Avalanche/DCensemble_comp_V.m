%%
files = dir('V*');
critResults = cell(numel(files), 1);
events = cell(numel(files), 1);
N = numel(files);
for i = 1:numel(files)
    critResults{i} = load(strcat(files(i).name, '/critResults.mat'));
    critResults{i} = critResults{i}.critResults;
    events{i} = load(strcat(files(i).name, '/events.mat'));    
    events{i} = events{i}.events;
end


%%
meanG = zeros(N,1);
V = zeros(N,1);
PSDbeta = zeros(N,1);
PSDdbet = zeros(N,1);
numEvents = zeros(N,1);
meanIEI = zeros(N,1);
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

for i = 1:N
    meanG(i) = critResults{i}.net.meanG;
    V(i) = mean(critResults{i}.net.V);
    PSDbeta(i) = critResults{i}.PSD.beta;
    PSDdbet(i) = critResults{i}.PSD.dbeta;    
    numEvents(i) = critResults{i}.events.numEvents;
    meanIEI(i) = critResults{i}.IEI.meanIEI;
    dGalpha(i) = critResults{i}.dG.alpha;
    dGdalph(i) = critResults{i}.dG.alpha;
    Stau(i) = critResults{i}.avalanche.sizeFit.tau;
    Sdta(i) = critResults{i}.avalanche.sizeFit.dTau;
    Slct(i) = critResults{i}.avalanche.sizeFit.lc;
    Suct(i) = critResults{i}.avalanche.sizeFit.uc;
    Talp(i) = critResults{i}.avalanche.timeFit.alpha;
    Tdal(i) = critResults{i}.avalanche.timeFit.dAlpha;
    Tlct(i) = critResults{i}.avalanche.timeFit.lc;
    Tuct(i) = critResults{i}.avalanche.timeFit.uc;
    x1 (i) = critResults{i}.avalanche.gamma.x1;
    dx1(i) = critResults{i}.avalanche.gamma.dx1;
    x2 (i) = critResults{i}.avalanche.gamma.x2;
    dx2(i) = critResults{i}.avalanche.gamma.dx2;
    x3 (i) = critResults{i}.avalanche.gamma.x3;
    dx3(i) = critResults{i}.avalanche.gamma.dx3;
end


%% dG
figure;
errorbar(V, dGalpha, dGdalph);
xlabel('V (V)')
ylabel('\alpha')
yyaxis right;
plot(V, meanG);
ylabel('<G>')
title('\Delta G exponent')

%% PSD
figure;
errorbar(V, PSDbeta, PSDdbet);
xlabel('V (V)')
ylabel('\beta')
title('PSD exponent')



%% IEI
figure;
semilogy(V, meanIEI, 'o-');
xlabel('V (V)')
ylabel('<IEI>')
title('Inter-event interval')


%% Size
figure;
errorbar(V, Stau, Sdta);
xlabel('V (V)')
ylabel('\tau')
title('Avalanche size')
yyaxis right;
plot(V, Slct);
hold on;
plot(V, Suct);
ylabel('cut-off')
legend('\alpha', 'lc', 'uc')



%% Lifetime
figure;
errorbar(V, Talp, Tdal);
xlabel('V (V)')
ylabel('\tau')
title('Avalanche size')
yyaxis right;
plot(V, Tlct);
hold on;
plot(V, Tuct);
ylabel('cut-off')
legend('\alpha', 'lc', 'uc')


%% Gamma
figure;
errorbar(V,x1, dx1);
hold on;
errorbar(V,x2, dx2);
errorbar(V,x3, dx3);
xlabel('V (V)')
ylabel('1/\sigma\tau\nu')
title('Crackling relationship')