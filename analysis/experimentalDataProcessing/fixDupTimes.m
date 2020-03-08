function [t1, x1] = fixDupTimes(t, x)
%{
    Measurements taken from the Keithley instrument have some duplicates in
    measurements at a given time-point. This averages at this time-point
    and outputs a new time vector (t) and time-varying vector (x)
%}
    
    j = 1; %index for storing in new time-vector
    
    k = 0; %k stores number of consecutive that are the same
    
    for i = 1:(numel(t) - 1)
        if k > 0 
            k = k - 1;
            continue
        end
        
        if t(i) == t(i + 1)
            k = 0;
            while t(i) == t(i + k + 1)
                k = k + 1;
                if i + k + 1 > numel(t)
                    break
                end
            end
            t1(j) = t(i);
            x1(j) = mean(x(i:i+k));
        else
            t1(j) = t(i); 
            x1(j) = x(i);
        end
        j = j + 1;
    end


end