ac1=load('ac1.mat');ac2=load('ac2.mat');ac2_1=load('ac2_1.mat');ac2_2=load('ac2_2.mat');ac2_3=load('ac2_3.mat');ac2_4=load('ac2_4.mat');ac2_5=load('ac2_5.mat');
ac2_4.SimulationOptions.dt
ac2_3.SimulationOptions.dt
ac2_2.SimulationOptions.dt
ac2_1.SimulationOptions.dt
ac2_1.SimulationOptions.dt
ac2.SimulationOptions.dt
ac1.SimulationOptions.dt
figure;hold on;
plot(ac2.Stimulus.TimeAxis,ac2.Output.networkResistance);plot(ac2_1.Stimulus.TimeAxis,ac2_1.Output.networkResistance);plot(ac2_2.Stimulus.TimeAxis,ac2_2.Output.networkResistance);plot(ac2_3.Stimulus.TimeAxis,ac2_3.Output.networkResistance);
legend '1e-3' '5e-4' '1e-4' '5e-5'
xlabel 't (s)'
ylabel 'Conductance (S)'
yyaxis right
plot(ac2.Stimulus.TimeAxis,ac2.Stimulus.Signal);
ylabel 'Voltage (V)'
title 'Varying time-step dt'
%subplot(2,1,2);
