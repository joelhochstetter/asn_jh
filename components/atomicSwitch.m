function resistance = atomicSwitch(lambda, lambdaCrit, Ron, Roff)
    resistance = zeros(size(lambda));
    resistance(lambda < lambdaCrit) = Roff; 
    resistance(lambda >= lambdaCrit) = Ron;
    

end