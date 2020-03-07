%% Switch Parameters
Vset = 1e-2;
Vres = 1e-3;
b    = 1;
Ron  = 7.77e-5;
Roff = 1e-8;
cLam = 0.1;


%% IV AC Paramaters
Amp = 0.4;
T = 4.0;
dt = 1e-3;
tvec = (dt:dt:T)';
DC = Amp*ones(size(tvec));% + normrnd(0,0.2,size(Stimulus.TimeAxis)); % DC 
freq = 0.25;

AC = Amp*sawtooth(2*pi*freq*(tvec-0.75/freq), 0.5); %AC
conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));

Signal = AC;


%% DC paramaters
Amp = 0.4;
T = 4.0;
dt = 1e-3;
tvec = (dt:dt:T)';
DC = Amp*ones(size(tvec));% + normrnd(0,0.2,size(Stimulus.TimeAcd /import/silo2/joelhxis)); % DC 
freq = 0.4;

AC = Amp*sawtooth(2*pi*freq*(tvec-0.75/freq), 0.5); %AC
conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));

Signal = AC;



%% DC and wait paramaters
AmplitudeOn   = 0.1;
AmplitudeOff  = 1e-8;

T = 20.0;
dt = 1e-3;

OffTime = 2;

tvec = (dt:dt:T)';

conT = zeros(size(tvec));
conA = zeros(size(tvec));
lam = zeros(size(tvec));

Signal = max(AmplitudeOff,AmplitudeOn*square(1*pi*tvec/OffTime));
Signal(tvec > OffTime) = AmplitudeOff;



%% Run simulation for single switch to compare
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


%% Plot AC_IV
j = 1;
figure;
subplot(2,1,1);
semilogy(tvec,conA);
hold on;
semilogy(tvec,conT);
xlabel 'Time'
ylabel 'G (S)'
legend 'binary' 'tunnelling'
yyaxis right;
plot(tvec, Signal);
ylabel 'V (V)'

subplot(2,1,2)
plot(Signal,(Signal.*conA));
hold on;
plot(Signal,(Signal.*conT));
legend 'binary' 'tunnelling'
xlabel 'V'
ylabel 'I'



nameStrings = {'nodecay', 'meddecay', 'bigdecay'} ;

%saveas(gcf, strcat('~/Documents/Honours/Project/Figures/Chapter2/AC_dynamics_', nameStrings{j}, '.m'))

%% IV Curve Binary vs Tunnelling
figure;
plot(Signal,(Signal.*conA));
hold on;
plot(Signal,(Signal.*conT));
legend('binary', 'tunnelling', 'location', 'northwest');
xlabel 'V (V)'
ylabel 'I (A)'
title 'IV Curve - Binary vs Tunnelling'


%Lambda plot



%% Plot DC
