%%
addpath(genpath('/import/silo2/joelh/Chaos'));
attractorFolder =     '/import/silo2/joelh/Chaos/AC-attractors/polar1/boost10';
lyFolder = '/import/silo2/joelh/Chaos/AC-Lyapunov/PolarModel/polar-lyapunov-fixed-1';
files = dir(strcat(attractorFolder, '/*.mat'));

%%
for i = 1:numel(files)
    calcLyapunovV5(5, 0, attractorFolder, files(i).name, lyFolder, 1)
end

%%
%files = dir('/import/silo2/joelh/Chaos/AC-Lyapunov/PolarModel/NewLyapunov/t2*');
files = dir('/import/silo2/joelh/Chaos/AC-Lyapunov/PolarModel/polar-lyapunov-fixed-1/t2*');
ml = zeros(numel(files),1);
lij1 = cell(numel(files),1);
gij1 = cell(numel(files),1);
N = numel(files);
li1 = zeros(N,261);
si  = zeros(N,1);
st  = zeros(N,1);
Gl  = zeros(N,1);
Gu = zeros(N,1);


parfor i = 1:numel(files)
    if exist(strcat(files(i).folder, '/', files(i).name,'/LyCalc.mat'), 'file')
        f = load(strcat(files(i).folder, '/', files(i).name,'/LyCalc.mat'));
        li    = f.li;
        lij = h5read(strcat(files(i).folder, '/', files(i).name,'/LyCalc.h5'), '/lij');
        gij = h5read(strcat(files(i).folder, '/', files(i).name,'/LyCalc.h5'), '/gij');
        si(i)  = std(li);
        st(i)  = std(mean(lij(end/2:end), 1));         
        gij1{i} = gij;
        ml(i) = f.ml;
        lij1{i} = lij;
        li1(i,:) = li; 
        files(i).name
    end

end


%%
Amp = zeros(numel(files),1);
Vres = zeros(numel(files),1);
Freq = zeros(numel(files),1);
lMax = zeros(numel(files),1);
boo  = zeros(numel(files),1);
maG = zeros(numel(files),1);
miG = zeros(numel(files),1);
maL = zeros(numel(files),1);
netI       = cell(numel(files), 1);
netV      = cell(numel(files), 1);
netC     = cell(numel(files), 1);
dt = zeros(numel(files),1);

for i = 1:numel(files)
        f1 =    dir(strcat(files(i).folder, '/', files(i).name, '/*unperturbed.mat'));
        if numel(f1) == 0
            continue
        end
        sim = multiImport(struct('importSwitch', false, 'SimOpt', struct('saveFolder', strcat(files(i).folder, '/', files(i).name)), 'importByName', f1(1).name));
        Amp(i) = sim{1}.Stim.Amplitude;    
        Freq(i) = sim{1}.Stim.Frequency;   
        Vres(i) = sim{1}.Comp.resetV;
        lMax(i) = sim{1}.Comp.maxFlux;
        boo(i)  = sim{1}.Comp.boost;  
        maG(i) = max(sim{1}.netC);
        miG(i)  = min(sim{1}.netC);
        maL(i) = 0; %max(max(abs(sim{1}.swLam)));
        dt(i)     = sim{1}.dt;
%         if dt(i) == 0.1
%             continue
%         end
        netV{i}   = sim{1}.Stim.Signal();
        netI{i} = sim{1}.netI();
        netC{i,:} = sim{1}.netC();
        i
end

%% Populate table
ml1 = ml./dt;
si1 = si./dt;
st1 = st./dt;
T = table(ml1, si1, st1, miG, maG, Amp, Vres);
save('results.mat', 'T');

%%
figure;
plot(Amp(Vres == 1e-3), ml1(Vres == 1e-3), 'x--')
hold on;
plot(Amp(Vres == 1e-2), ml1(Vres == 1e-2), 'x--')
xlabel('A (V)')
ylabel('l (1/s)')
title('Maximal lyapunov exponent vs amplitude')
legend('Vr = 1e-3', 'Vr = 1e-2', 'location', 'southeast')

%%
figure;
loglog(ml1(Vres == 1e-3), miG(Vres == 1e-3), 'x--')
hold on;
loglog(ml1(Vres == 1e-3), maG(Vres == 1e-3), 'x--')
loglog(ml1(Vres == 1e-2), miG(Vres == 1e-2), 'x--')
loglog(ml1(Vres == 1e-2), maG(Vres == 1e-2), 'x--')
ylabel('G (S)')
xlabel('l (1/s)')
title('Maximal lyapunov exponent vs conductance')
legend('Gl: Vr = 1e-3', 'Gu: Vr = 1e-3', 'Gl: Vr = 1e-2', 'Gu: Vr = 1e-2', 'location', 'northwest')


%% analyse a particular sim
i = 4;
f1 =    dir(strcat(files(i).folder, '/', files(i).name, '/*unperturbed.mat'));
sim = multiImport(struct('importSwitch', true, 'SimOpt', struct('saveFolder', strcat(files(i).folder, '/', files(i).name)), 'importByName', f1(1).name));
sim = sim{1};

%% Junction lypaunov exponents
figure;
plot(li1(i,:)/sim.dt, min(abs(sim.swV)), 'x');
hold on;
plot(li1(i,:)/sim.dt, mean(abs(sim.swV)), 'x');
plot(li1(i,:)/sim.dt, max(abs(sim.swV)), 'x');
xlabel('junction lyapunov (1/s)')
ylabel('V (V)')
legend('min', 'mean', 'max', 'location', 'northwest')
title(strcat('Junction voltage vs Lyapunov, V_r = ', num2str(Vres(i)), 'V, A = ',  num2str(Amp(i))));

figure;
plot(li1(i,:)/sim.dt, min(abs(sim.swLam)), 'x');
hold on;
plot(li1(i,:)/sim.dt, mean(abs(sim.swLam)), 'x');
plot(li1(i,:)/sim.dt, max(abs(sim.swLam)), 'x');
xlabel('junction lyapunov (1/s)')
ylabel('\lambda (Vs)')
legend('min', 'mean', 'max', 'location', 'northwest')
title(strcat('Junction state vs Lyapunov, V_r = ', num2str(Vres(i)), 'V, A = ',  num2str(Amp(i))));


%% Temporal lypaunov exponents
% i = 4;
% f1 =    dir(strcat(files(i).folder, '/', files(i).name, '/*unperturbed.mat'));
% sim = multiImport(struct('importSwitch', true, 'SimOpt', struct('saveFolder', strcat(files(i).folder, '/', files(i).name)), 'importByName', f1(1).name));
% sim = sim{1};

figure;
plot(sim.Stim.Signal(end/2:end), min(gij1{i}(end/2:end,:), [], 2)/sim.dt);
hold on;
plot(sim.Stim.Signal(end/2:end), mean(gij1{i}(end/2:end,:), 2)/sim.dt);
plot(sim.Stim.Signal(end/2:end), max(gij1{i}(end/2:end,:), [], 2)/sim.dt);
ylabel('l_t (s^{-1})')
yyaxis right;
semilogy(sim.Stim.Signal, abs(sim.netC));
xlim([-sim.Stim.Amplitude,sim.Stim.Amplitude]);
legend('min(l_t)', 'mean(l_t)', 'max(l_t)', 'I', 'location', 'southeast');
xlabel('Stimulus (V)')
ylabel('Conductance (S)')
title(strcat('Stimulus vs temporal lyapunov, V_r = ', num2str(Vres(i)), 'V, A = ',  num2str(Amp(i))));


