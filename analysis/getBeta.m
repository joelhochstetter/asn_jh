function beta = getBeta (timeVector, signal,fl, fu)
    if fl < 0
        fl = 0;
    end
    signal(isnan(signal)) = 0;
    [t_freq, conductance_freq] = fourier_analysis(timeVector, signal);
    if fu < 0 
        fu = max(t_freq);
    end
    fitCoef = polyfit(log10(t_freq(t_freq>fl & t_freq<fu)), log10(conductance_freq(t_freq>fl & t_freq<fu)), 1);
    beta = -fitCoef(1);
end