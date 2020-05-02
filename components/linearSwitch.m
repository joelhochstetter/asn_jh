function [con] = linearSwitch(lambda, maxFlux, Coff, Con)
    R = abs(lambda)/maxFlux/Con + (1-abs(lambda)/maxFlux)/Coff;
    con = 1./R;
    
end
