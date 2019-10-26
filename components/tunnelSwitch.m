function [con] = tunnelSwitch(V, d, phi, a, Coff)
    %In low d limit is valid for V < phi and V <3*phi
    C0 = 2.115e-3; %should be 1.5e-4 from formula. Set to give conductance quanta at d = 0.4
    %Coff  = 1e-8;
    A1=10.2;
    A2 = A1/sqrt(2);
    %1e-8 avoids overflow errors
    %con = 7.77e-5*exp(-10.2*(d-0.4)) +Coff;
    
    V1 = abs(V) + 1e-10;
    
    b = 1 - V1.^2/96./(phi-V1/2).^2;

    con = 1e-9*ones(size(V));
    c1 = Coff+C0./b.^2./d.^2.*((phi./V1-1/2).*exp(-A1.*d.*b.*(phi-V1./2).^0.5)-(phi./V1+1/2).*exp(-A1.*b.*d.*(phi+V1/2).^0.5));
    c2 = Coff+V1/phi*C0./(23/24)^2./d.^2./2.*(exp(-A2.*d*(23/24)*phi^1.5./V1)-(1+2.*V1./phi).*exp(-A2*(23/24).*d.*phi.^1.5./V1.*(1+2.*V1/phi).^0.5));
    
    con(V1 < phi)  = c1(V1 < phi);
    con(V1 >= phi) = c2(V1 >= phi);


end

