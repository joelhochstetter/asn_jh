lambda = 0:1e-3:0.15;
V = ones(size(lambda))*0;
d = (0.1-abs(lambda))*50;
d(d<0) = 0;
tunnel = tunnelSwitch2(V,d,0.5, 0.4^2 ,1e-8, 7.7738e-05);
tunnel1 = tunnelSwitch2(V,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel2 = tunnelSwitch2(V,d,1.5, 0.4^2 ,1e-8, 7.7738e-05);
atomic = atomicSwitch(lambda, 0.1, 7.7738e-05+1e-8, 1e-8);
% lambda(lambda >= 0.1) = 0.1;
% atomic = linearSwitch(lambda, 0.1, 1e-8, 7.7738e-05+1e-8);
%%% Conductance Voltage

figure;
semilogy(lambda, tunnel, '-')
hold on;
semilogy(lambda, tunnel1, '-')
semilogy(lambda, tunnel2, '-')
semilogy(lambda, atomic, '--')

title('Conductance model comparison')
xlabel('|\lambda| (Vs)');
ylabel('Conductance (S)');

yyaxis right;
plot(lambda, d, '-');
ylabel('s (nm)')
legend('Tun: \phi = 0.5 eV', 'Tun: \phi = 0.81 eV', 'Tun: \phi = 1.5 eV', 'Binary', 's', 'location','southwest');
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/TunAtmCmp.png')


%% Area comparison
lambda = 0:1e-3:0.15;
V = ones(size(lambda))*0;
d = (0.1-abs(lambda))*50;
d(d<0) = 0;
tunnel = tunnelSwitch2(V,d,0.81, 0.2^2 ,1e-8, 7.7738e-05);
tunnel1 = tunnelSwitch2(V,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel2 = tunnelSwitch2(V,d,0.81, 0.8^2 ,1e-8, 7.7738e-05);
atomic = atomicSwitch(lambda, 0.1, 7.7738e-05+1e-8, 1e-8);

%%% Conductance Voltage

figure;
semilogy(lambda, tunnel, '-')
hold on;
semilogy(lambda, tunnel1, '-')
semilogy(lambda, tunnel2, '-')
semilogy(lambda, atomic, '--')

title('Conductance model comparison')
xlabel('|\lambda| (Vs)');
ylabel('Conductance (S)');

yyaxis right;
plot(lambda, d, '-');
ylabel('s (nm)')
legend('Tun: A = 0.04 nm^2', 'Tun: A = 0.17 nm^2', 'Tun: A = 0.64 nm^2', 'Binary', 's', 'location','southwest');
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/AreaTunAtmCmp.png')


%% Non-linearity

V = ones(size(lambda));
tunnel  = tunnelSwitch2(V*0,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel1 = tunnelSwitch2(V*0.9*0.81,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel2 = tunnelSwitch2(V*1.1*0.81,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
atomic = atomicSwitch(lambda, 0.1, 7.7738e-05+1e-8, 1e-8);

%%% Conductance Voltage

figure;
semilogy(lambda, tunnel, '-')
hold on;
semilogy(lambda, tunnel1, '-')
semilogy(lambda, tunnel2, '-')
semilogy(lambda, atomic, '--')

title('Conductance model comparison')
xlabel('|\lambda| (Vs)');
ylabel('Conductance (S)');

yyaxis right;
plot(lambda, d, '-');
ylabel('s (nm)')
legend('Tun: V = 0.0 \phi_0', 'Tun: V = 0.9 \phi_0', 'Tun: V = 1.1\phi_0', 'Binary', 's', 'location','southwest');
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/NonlinVTunAtmCmp.png')


%% Calculation of residual tunnelling barrier
phi = 0.81;
d   = 4;
B   = 10.19;
A   = 100;
res = 2/A*d/phi^0.5.*exp(B*d*phi^2);


%% DC
t = 0:1e-5:2;
Vset = 1e-2;
V = 0.1;

lambda = (V - Vset)*t;
d = (0.1-abs(lambda))*50;
d(d<0) = 0;

tunnel = tunnelSwitch2(V,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel1 = tunnelSwitch2(V,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
tunnel2 = tunnelSwitch2(V,d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
atomic = atomicSwitch(lambda, 0.1, 7.7738e-05+1e-8, 1e-8);
% lambda(lambda >= 0.1) = 0.1;
% atomic = linearSwitch(lambda, 0.1, 1e-8, 7.7738e-05+1e-8);
%%% Conductance Voltage

figure;
semilogy(t, tunnel, '-');
hold on;
semilogy(t, atomic, '--');

title('0.1V DC Activation Comparison')
xlabel('t (s)');
ylabel('Conductance (S)');

yyaxis right;
plot(t, V*ones(size(t)));
ylabel('Stimulus Voltage (V)')
ylim([0,0.2])

legend('Tun', 'Binary', 'location','southwest');
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/DCact.png')



%% DC and wait

Vset = 1e-2;
Vres = 1e-3;
b    = 10;
Ron  = 7.77e-5;
Roff = 1e-8;
cLam = 0.1;


AmplitudeOn   = 0.1;
AmplitudeOff  = 1e-5;
T = 10.0;
dt = 1e-3;
OffTime = 2;
t = 0:dt:T;
tvec = t';
conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));
Signal = max(AmplitudeOff,AmplitudeOn*square(1*pi*tvec/OffTime));
Signal(tvec > OffTime) = AmplitudeOff;

close all;
for i = 1: numel(tvec)
    d = (0.1-abs(lam(i)))*50;
    if d < 0.0
        d = 0.0;
    end
    
    conT(i) = tunnelSwitch2(Signal(i),d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
    conA(i) = (abs(lam(i)) > cLam)*Ron + (abs(lam(i)) <= cLam)*Roff;
    
    if i < numel(tvec)
        lam(i+1) = lam(i) + (abs(Signal(i))-Vset)*dt*(abs(Signal(i)) > Vset)*sign(Signal(i)) + b*(abs(Signal(i))-Vres)*dt*(abs(Signal(i)) < Vres)*sign(lam(i));
        if abs(lam(i+1)) >= 0.15 
            lam(i+1) = sign(lam(i+1))*0.15;
        end
    end
    

end

figure;
semilogy(t, conT, '-');
hold on;
semilogy(t, conA, '--');


title('0.1V 2s DC Square Pulse Activation Comparison')
xlabel('t (s)');
ylabel('Conductance (S)');

yyaxis right;
plot(t, Signal);
ylabel('Stimulus Voltage (V)')
ylim([0,0.2])

legend('Tun', 'Binary', 'location','northeast');
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/DCsquare.png')









%% IV Curve
Vset = 1e-2;
Vres = 1e-3;
b    = 10.0;
Ron  = 7.77e-5;
Roff = 1e-8;
cLam = 0.1;
Amp = 0.1;
freq = 0.1;
T = 10.0;
dt = 1e-3;

t = 0:dt:T;
tvec = t';
conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));



AC = Amp*sawtooth(2*pi*freq*(tvec-0.75/freq), 0.5); %AC
conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));

Signal = AC;

close all;
for i = 1: numel(tvec)
    d = (0.1-abs(lam(i)))*50;
    if d < 0.0
        d = 0.0;
    end
    
    conT(i) = tunnelSwitch2(Signal(i),d,0.81, 0.4^2 ,1e-8, 7.7738e-05);
    conA(i) = (abs(lam(i)) > cLam)*Ron + (abs(lam(i)) <= cLam)*Roff;
    
    if i < numel(tvec)
        lam(i+1) = lam(i) + (abs(Signal(i))-Vset)*dt*(abs(Signal(i)) > Vset)*sign(Signal(i)) + b*(abs(Signal(i))-Vres)*dt*(abs(Signal(i)) < Vres)*sign(lam(i));
        if abs(lam(i+1)) >= 0.15 
            lam(i+1) = sign(lam(i+1))*0.15;
        end
    end
    

end

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1);
%phasePlot(Signal, lam, tvec, 1, 1, 'x')
hold on;
yy = -0.15:1e-5:0.15;
plot(ones(size(yy))*Vset, yy , 'r');
plot(-ones(size(yy))*Vset, yy, 'r');
plot(ones(size(yy))*Vres, yy , 'y');
plot(-ones(size(yy))*Vres, yy, 'y');
plot(Signal,lam);
xx = -Amp:1e-5:Amp;
plot(xx,  ones(size(xx))*cLam, 'g');
plot(xx, -ones(size(xx))*cLam, 'g');
plot(Signal,lam, 'b');


subplot(2,1,2);
plot(Signal,(Signal.*conT));
hold on;
plot(Signal,(Signal.*conA), '--');



%set(findall(gca, 'Type', 'Line'),'LineWidth',2);





%%
figure('units', 'centimeters', 'OuterPosition', [5 5 25 15]);
subplot(1,2,1);
plot(Signal,(Signal.*conT/1e-6), 'Color', [0 0.4470 0.7410],'LineWidth',2);
hold on;
plot(Signal,(Signal.*conA/1e-6), '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth',2);
legend('Tun', 'Binary', 'location', 'northwest');
xlabel 'V (V)'
ylabel 'I (\mu A)'
title 'I-V Characteristics'
xlim([-0.11,0.11])

subplot(1,2,2);
hold on;
yy = -0.16:1e-4:0.16;
xx = -Amp*1.1:1e-4:Amp*1.1;


plot(-ones(size(yy))*Vset, yy,  'r','LineWidth', 1.2);
plot( ones(size(yy))*Vset, yy,  'r','LineWidth', 1.2,'HandleVisibility','off');
plot(-ones(size(yy))*Vres, yy, 'color', [1, 0.5, 0],'LineWidth', 1.2);
plot( ones(size(yy))*Vres, yy, 'color', [1, 0.5, 0],'LineWidth', 1.2, 'HandleVisibility','off');
plot(xx,  ones(size(xx))*cLam, 'g','LineWidth', 1.2);
plot(xx, -ones(size(xx))*cLam, 'g','LineWidth', 1.2, 'HandleVisibility','off');
plot(Signal,lam, 'Color', [0 0.4470 0.7410], 'LineWidth',2);
title '(V,\lambda) Characteristics'
ylabel('\lambda (Vs)')
xlabel('V (V)')
ylim([-0.16,0.16])
xlim([-0.11,0.11])

legend('\pm V_{set}', '\pm V_{reset}', '\pm \lambda_{crit}', '(V, \lambda)', 'location', 'southeast')


saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/ExampleIVCurve.png')
