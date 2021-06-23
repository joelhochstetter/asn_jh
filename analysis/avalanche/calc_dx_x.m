function dx_x = calc_dx_x(x)
%{
    For function x(t) the expression x'(t)/x(t) has an
        ambiguous definition for discrete time-steps. 
        When using for event definition (dx./x > threshold)
        where dx(t) = x(t+1) - x(t).   depending on wether is 
        forward or reverse event different threshold counted.
        
        This is rectified by defining 
            dx(t)/x(t) = (x(t+1) - x(t))/min(x(t+1), x(t)
%}

    x = reshape(x, [numel(x), 1]);
    
    dx_x = (x(2:end) - x(1:end - 1))./min(x(1:end - 1), x(2:end));

    dx_x  = [dx_x; 0];
    
    
end