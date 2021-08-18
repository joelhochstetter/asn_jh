function [betas, segs]= segBeta(t, x, dt)
%{
    Calculates the fourier transform exponent beta across different parts
    of the time-series split into time-series
    
    Inputs:
        t:  time-vector
        x:  time-series data, normally conductance
        dt: number of time-points which we group together
    
    Output:
        betas: the running exponents for segments
        segs: time-stamp for centre of segment
%}
    %% Initialise outputs
    N =floor(numel(t)/dt);
    tstep = (t(end) - t(1))/(numel(t) - 1);
    segs = ((1:N) - 0.5)*tstep*dt;
    betas = zeros(size(segs));
    
    %%
    for i = 1:N
        trange = ((i - 1)*dt + 1):i*dt;
        betas(i) = getBeta(t(trange), x(trange), -1, -1);
    end

end