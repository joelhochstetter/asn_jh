function beta = getBeta(timeVector, signal,fl, fu)
%{
    calculates beta, the power law exponent of the conductance time-series
    fl and fu are the cut-offs (lower and upper frequencies used in fit).
    A negative cut-off uses maximum range in that direction.
%}
    
    signal = reshape(signal, size(timeVector));

    signal(isnan(signal)) = 0;
    [t_freq, conductance_freq] = fourier_analysis(timeVector, signal);
    
    if fl < 0
        fl = min(t_freq(t_freq > 0))*5;
    end
    
    if fu < 0 
        fu = max(t_freq)/5;
    end
    conductance_freq = reshape(conductance_freq, size(t_freq));
    
    fitCoef = polyfit(log10(t_freq(t_freq>fl & t_freq<=fu)), log10(conductance_freq(t_freq>fl & t_freq<=fu)), 1);
    beta = -fitCoef(1);
    if isnan(beta)
        'fuck'
    end
end