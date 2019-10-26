%% Plot t vs conductance and the signal on the same axes

figure
yyaxis left
plot(SimulationOptions.TimeVector, Output.networkResistance)
yyaxis right
plot(SimulationOptions.TimeVector, Stimulus.Signal)



%% Plots average Lambda

figure
plot(max(abs(Output.lambda'))', Output.networkResistance)
xlabel 'ave(abs(lambda))'
ylabel 'Network Conductance'
figure
plot(SimulationOptions.TimeVector,max(abs(Output.lambda'))')
xlabel 'time'
ylabel 'ave(abs(lambda))'

%% Switch voltage analysis

timestep = 300000; %runs from 1 to 300000
dt = SimulationOptions.dt;
simTime = timestep * dt ;

figure;
semilogy(abs(Output.storevoltage(timestep,1:end-1)));
ylabel 'Voltage (V)'
xlabel 'Switch ID'
hold on;
semilogy(Components.setVoltage(1)*ones(261,1));
semilogy(Components.resetVoltage(1)*ones(261,1));
yyaxis right
semilogy(abs(Output.lambda(timestep,1:end-1))/Components.criticalFlux(1));
semilogy(ones(261,1));
ylabel '\lambda (Vs)'
legend('V drop', 'V set', 'V reset', '\lambda switch', '\lambda_{crit}','Location','southeast') 
title(strcat('t = ',num2str(simTime), 's, Switch info'))


%% Which switches change
figure;
%semilogy(abs(Output.lambda(end,1:end-1))./abs(Output.lambda(end-1,1:end-1)));
%semilogy(abs(Output.storevoltage(end,1:end-1))./abs(Output.storevoltage(end-1,1:end-1)));
%semilogy(Stimulus.Signal(2:end)./Stimulus.Signal(1:end-1));
%plot(Stimulus.Signal)
plot(abs(Output.storevoltage(end,1:end-1)))
hold on;
plot(abs(Output.storevoltage(end-1,1:end-1)))
yyaxis right;
plot(changeOn(end,:))

%% Velocity analysis
lamVelPos = abs(Output.storevoltage(:,1:end-1)) > Components.setVoltage(1);
lamVelNeg = abs(Output.storevoltage(:,1:end-1)) < Components.resetVoltage(1);
lamVelSta = ~lamVelPos & ~lamVelNeg;
%lamVelSta = (abs(Output.storevoltage(:,1:end-1)) >= Components.setVoltage(1)) | (abs(Output.storevoltage(:,1:end-1)) <= Components.resetVoltage(1)); 

on        = abs(Output.lambda(:,1:end-1)) > Components.criticalFlux(1);
off       = ~on;
minL      = abs(Output.lambda(:,1:end-1)) < Stimulus.dt*2e-2;

changeOn  = on(2:end,:)-on(1:end - 1,:);

sumDeltV  = sum(abs(Output.storevoltage(2:end,1:end-1) - Output.storevoltage(1:end-1,1:end-1)),2);

figure;
plot(sum(lamVelPos,2))
hold on;
plot(sum(lamVelNeg,2))
legend 'Pos' 'Neg'

figure;
plot(sumDeltV);
yyaxis right
plot(sum(changeOn,2))



%% Change in resistance
figure;
subplot(2,1,1);
plot(Stimulus.TimeAxis(1:end-1),sum((changeOn),2))
ylabel 'Number of switches changing at a given timestep'
yyaxis right
plot(Stimulus.TimeAxis, Output.networkResistance);
xlabel 'Time (s)'
ylabel 'Conductance (S)'
title 'DC 0.1V - Activation - Tunnel'
subplot(2,1,2)
plot(Stimulus.TimeAxis(1:end-1),sum((changeOn),2))
ylabel 'Number of switches changing at a given timestep'
yyaxis right
plot(Stimulus.TimeAxis, Output.networkResistance);
xlabel 'Time (s)'
ylabel 'Conductance (S)'
xlim([0,100])



%% Fourier analysis of switch flipping
figure;
[tf, cf] = fourier_analysis(Stimulus.TimeAxis(1:end-1),sum((changeOn),2));
plot(tf,cf)


%% Calculates Number of switches on at every time step

figure
len = size(snapshots);
len = len(2) - 1;
ns = zeros(len + 1,1);
t2 = 0:SimulationOptions.dt:(SimulationOptions.T-SimulationOptions.dt);
for i = 1:len
    ns(i) =  sum(snapshots{1,i}.OnOrOff);
    %nchange(i) = sum(snapshots{1,i}.OnOrOff);
end 

plot(t2,ns)
title 'Number of switches on at each time step'
xlabel 't'
ylabel 'n_on'



%% Calculates Number of switches changing at every time step

figure
len = size(snapshots);
len = len(2) - 1;
nchange = zeros(len + 1,1);
for i = 1:len
    nchange(i + 1) = sum(abs(snapshots{1,i+1}.OnOrOff - snapshots{1,i}.OnOrOff));
    %nchange(i) = sum(snapshots{1,i}.OnOrOff);
end 

plot(t2,nchange)
title 'Number of switches changing at each time step'
xlabel 't'
ylabel '\Delta |n_{on} - n_{off}|'

figure
n = 10; % average every n values
a = nchange;
b = arrayfun(@(i) sum(a(i:i+n-1)),1:n:length(a)-n+1)'; % the averaged vector


v = 0.1*ones(10,1);
c = conv(nchange,v).';
t = -4*SimulationOptions.dt:SimulationOptions.dt:(SimulationOptions.T+4*SimulationOptions.dt);
plot(t,c)

t = 0:SimulationOptions.dt*10:(SimulationOptions.T-SimulationOptions.dt);
figure
plot(t,b)


title 'Number of switches changing at each time step - averaging over 10 time steps'
xlabel 't'
ylabel '\Delta |n_{on} - n_off|'
%{
%%Plot dC/dt
C = 1./Output.networkResistance;
dCdL = diff(C)/0.001/1.5*100;
t1 = 1.5*SimulationOptions.dt:SimulationOptions.dt:SimulationOptions.T;
t1 = 1.5*t1/100;
figure
plot(t1,dCdL)
title 'Susceptibility'
xlabel '\lambda_{av} (V s) ('
ylabel 'd\sigma/d\lambda (S V^{-1} s^{-1})'
%sig=I/V= Amps/V


figure

len = size(snapshots);
%lchange = zeros(len(2)-1,len(1));
lchastd = zeros(len(2)-1,len(1));
totalrc = zeros(len(2)-1,len(1));
resstuf = zeros(len(2)-1,len(1));
len = len(2) - 1;
t = SimulationOptions.dt*0.5:SimulationOptions.dt:(SimulationOptions.T-1001*SimulationOptions.dt);

for i = 1:len-1000
    size(log10(snapshots{1,i+1}.Resistance ./ snapshots{1,i}.Resistance));
    lchange(i,:) = max(snapshots{1,i+1000}.Resistance ./ snapshots{1,i}.Resistance);
    lchastd(i,:) = std(log10(snapshots{1,i+1}.Resistance ./ snapshots{1,i}.Resistance));
    totalrc(i)   = max(snapshots{1,i+1}.Resistance ./ snapshots{1,i}.Resistance);
    resstuf(i)   = max(snapshots{1,i}.Voltage);
    %nchange(i) = sum(snapshots{1,i}.OnOrOff);
end 

%plot(t,lchange)
yyaxis left
%semilogy(t,totalrc)
plot(t, lchange)
%plot(t, lchastd)
xlabel 'Time (s)'
ylabel 'Maximum switch change ratio per ms'
yyaxis right
semilogy(SimulationOptions.TimeVector,Output.networkResistance)
ylabel 'Conductance (S)'
title '1.5DC Ido Model'

%legend 'Mean, std'




len = size(snapshots);
nchange = zeros(len(2)-1,len(1));
len = len(2) - 1;
t = SimulationOptions.dt*0.5:SimulationOptions.dt:(SimulationOptions.T-SimulationOptions.dt);

for i = 1:len-100
    change = snapshots{1,i+100}.OnOrOff-snapshots{1,i}.OnOrOff;
    change(change > 0) = 0;
	nchange(i) = abs(sum(change));
end 

plot(t,nchange);
%}
%{

len = numel(snapshots);
Vs   = zeros(len,261);
Cs   = zeros(len,261);
Fs   = zeros(len,261);
dVdt = zeros(len-1,261);
dFdt = zeros(len-1,261);
t = SimulationOptions.dt*0.5:SimulationOptions.dt:(SimulationOptions.T);

for i = 1:len
    Vs(i,:) = abs(snapshots{i}.Voltage(1:end-1));
    Cs(i,:) = snapshots{i}.Resistance(1:end-1);
    Fs(i,:) = snapshots{i}.filamentState(1:end-1);
end 

for i = 1:(len-1)
    dVdt(i,:) = (Vs(i+1,:) - Vs(i,:))/SimulationOptions.dt;
    dFdt(i,:) = (Fs(i+1,:) - Fs(i,:))/SimulationOptions.dt;
end

mdVdt = mean(dVdt,2);
sdVdt = std(dVdt')';
HdVdt = max(dVdt')';
LdVdt = min(dVdt')';
%}


%{
plot(mdVdt)
hold on
plot(sdVdt)
plot(LdVdt)
plot(HdVdt)
figure
histogram(dVdt(250,:),[-300:10:300])









%}
