function lamN = junctionNoise(noiseType, noiseBeta, noiseLevel, E)
%{    
    Noise can be added to all junctions by the function junctionNoise.m
    Fields are:
        noiseType = 'powerLaw' (1/f^beta noise), 'gaussian'         
        noiseBeta: power law exponent for power law noise.
        noiseLevel: positive number according to size of noise. 
        This is the std of the noise

    E: number of junctions


    lamN (Ex1) is the noise in lambda
%}
switch noiseType 
    case 'powerLaw'        
        noise = dsp.ColoredNoise(noiseBeta, 1, E);
        lamN  = noise()*noiseLevel;     
        lamN = lamN';
    case 'gaussian'
        lamN = wgn(E, 1, noiseLevel^2, 'linear') ;      
end
