function [con] = linearSwitch(lambda, critFlux, Coff, Con)
    R = abs(lambda)/critFlux/Con + (1-abs(lambda)/critFlux)/Coff;
    con = 1./R;
    if min(con) <= 0
        'fuck'
    end
end
