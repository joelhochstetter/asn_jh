function betas = runningBeta(t, x, dt)
%{
    Calculates the fourier transform exponent beta across different parts
    of the time-series
    
    Inputs:
        t:  time-vector
        x:  time-series data, normally conductance
        dt: number of time-points which we group together
    
    Output:
        betas: the running exponents for each time-point. Start and end
        time-points use first dt time-steps.
%}
    %% Initialise outputs
    betas = zeros(size(x));    
    N  = numel(x);
    dt1 = floor((dt - 1)/2); %lower range
    dt2 = dt - dt1 - 1;      %upper range
    
    %% Initial datapoints
    betas(1) = getBeta(t(1:dt), x(1:dt), -1, -1);
    for i = 2:dt1
        betas(i) = betas(1);
    end   
    
    %% Central datapoints
    for i = (dt1 + 1):(N-dt2)
        betas(i) = getBeta(t(i - dt1:i + dt2), x(i - dt1:i + dt2), -1, -1);
    end
    
    %% End datapoints
    betas(N) = getBeta(t(end - dt + 1:end), x(end - dt + 1:end), -1, -1);

    for i = (N - dt2 + 1):(N - 1)
        betas(i) = betas(N);
    end     


end