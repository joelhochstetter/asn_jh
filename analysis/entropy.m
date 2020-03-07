
swV = Output.storevoltage;
swG = Output.storeCon;
swL = Output.lambda;
swI = Output.storeCon.*Output.storevoltage;
entV = -sum(abs(swV).*log(abs(swV)),2);
netI = Output.networkCurrent;
entI = -sum(abs(swI).*log(abs(swI)),2);
enti = -sum(abs(swI./netI).*log(abs(swI./netI)),2);
entG = -sum(abs(swG).*log(abs(swG)),2);

figure
semilogy(Stimulus.TimeAxis,enti)