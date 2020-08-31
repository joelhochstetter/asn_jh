%Constants
Components.criticalFlux  = 1e-1;
Components.maxFlux       = 0.15;
Components.offConductance = 1e-9;
Components.onConductance  = 7.77e-5;
Components.resetVoltage  = 1e-3;
Components.setVoltage    = 1e-2;
Components.boost         = 10;
Components.penalty       = 1;
Components.type          = 'atomicSwitch';

%Inputs
Amp = 0.2;

T = 2.0;
dt = 1e-3;
tvec = (dt:dt:T)';
DC = Amp*ones(size(tvec));% + normrnd(0,0.2,size(Stimulus.TimeAxis)); % DC 
freq = 1;
AC =  Amp*sawtooth(2*pi*freq*(tvec-0.75/freq) , 0.5);
%AC = Amp*sin(2*pi*freq*tvec);
AOff = 0;
OffT = 1;
DCaW = max(AOff,Amp*square(1*pi*tvec));
DCaW(tvec > OffT) = AOff;
sw1 = tV{1}.swV(:,131);
Signal = sw1;


%Sim Paramaters
Components.filamentState = 0.0;
Components.OnOrOff       =   0;
phi = 2;

%Storage
con = zeros(size(tvec));
co1 = zeros(size(tvec));
lam = zeros(size(tvec));
la1 = zeros(size(tvec));

%create pointer
compPtr       = ComponentsPtr(Components);
compPt1       = ComponentsPtr(Components);

for i = 1:size(tvec)
    compPtr.comp.voltage = Signal(i); 
    updateComponentState(compPtr, dt);
    compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;

    compPt1.comp.voltage = Signal(i); 
    updateComponentState(compPt1, dt);
    compPt1.comp.OnOrOff = abs(compPt1.comp.filamentState) >= compPt1.comp.criticalFlux;    
    
    compPt1.comp.conductance = (~compPt1.comp.OnOrOff) * compPt1.comp.offConductance + (compPt1.comp.OnOrOff) .* compPt1.comp.onConductance;
    co1(i) = compPt1.comp.conductance;
    la1(i) = compPt1.comp.filamentState;
    
    lam(i) = compPtr.comp.filamentState;
    d = (Components.criticalFlux-abs(lam(i)))*30+0.4;
    d(d<0.4) = 0.4;
    con(i) = tunnelSwitch(Signal(i),d,phi,0.4);
    compPr.comp.conductance = con(i);
    
end

%{
figure;
plot(Signal,con);
hold on
plot(
xlabel 'V'
ylabel 'G (S)'
%}


figure;
plot(tvec,co1)
hold on 
plot(tvec,con)
xlabel 't'
ylabel 'con'
legend('old','tunnel')
yyaxis right
plot(tvec,Signal)
ylabel('V')
ylim([min(Signal)*0.75,max(Signal)*1.25])
title 'AC 1Hz, 0.4V'

