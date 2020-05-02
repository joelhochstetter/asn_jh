function [con] = tunnelSwitch2(V, s, phi, A, Coff, Con)
%Calculates the tunnelling conductance (con)
%Inputs:
%   V (Voltage across junction in V)
%   s (filament gap distance in nm)
%   phi (filament barrier height in V)
%   A (area of filament tip in nm^2)
%   Coff (conductance of off state in S) usually 1e-8
%   Con (conductance of off state in S) usually G_0=7.7e-5
%Outputs:
%   con (conductance of junction in S)
%Written by Joel Hochstetter

    %Initialise free paraeters
    C0 = 10.19;
    C2 = 23/24/sqrt(2)*C0;
    J0 = 6.16438e-6;
    J1 = 0.0000471307;
    J2 = 2.65686e-6;
    V = abs(V);
    J0 = J0*A;
    J1 = J1*A;
    J2 = J2*A;

    %Low Voltage formula
    tunL = 2*s/phi^0.5.*exp(C0.*s*phi^2)/J1;
    b = 1 - V.^2/96./(phi-V/2).^2;
    
    %Intermediate voltage formula
 	tunI = 1./b.^2.*((phi-V/2).*exp(-C0.*(s+1).*b.*(phi-V/2).^0.5)-(phi+V/2).*exp(-C0.*b.*(s+1).*(phi+V/2).^0.5))*exp(C0*(phi)^0.5);
    tunI = V.*s.^2./tunI/J0;
    
    %High voltage formula
    tunU = 1/phi.*(exp(-C2.*(s + 1)*phi^1.5./V)-(1+2.*V./phi).*exp(-C2.*(s +1).*phi.^1.5./V.*(1+2.*V/phi).^0.5))*exp(C0*(phi)^0.5); 
    tunU = s.^2./tunU/J2;
    
    tun = tunL;
    tun(V > phi/2) = tunI(V > phi/2);
    tun(V >= phi)   = tunU(V >= phi);
    
    con = 1./(tun+1./Con) + Coff;
    
end