function inEq = checkDCEquilibrium(tol, conductance, swLambda)
%Inputs:
%tol (double) - the tolerance in difference to change. The sum of
%differences must be <= this number
%conductance (Nx1 vector, N number of timesteps) - time series
%swL (Nx(E+1) matrix) - time series
%Outputs:
%inEq true if in equilibrium and false otherwise
%For best use give lambda. A guess can be used based off conductance
    inEq = false;
  
    if nargin < 3
        if abs(conductance(end - 1) - conductance(end)) <= tol
            inEq = true;
        end
    else
        if sum(abs(swLambda(end,1:end-1) - swLambda(end - 1 ,1:end-1))) <= tol
            inEq = true;
        end
    end

end