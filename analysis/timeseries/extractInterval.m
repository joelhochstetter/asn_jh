function I =  extractInterval(x, lc, uc)
%{
    Extracts the first interval that occurs in a given time-series vector
    x based on a lower and upper cut-off 

    Inputs:
        x    (array): time-series vector
       lc (double): lower cut-off of variable x
      uc (double): upper cut-off of variable x

    Outputs:
        I        (array): Interval containing the specified timepoints
        cuts (1x2 array): First and last index of time point 
%}

    onInt    = x >= lc && x <= uc;
    assert(sum(onInt) > 0); %checks interval is non-empty
    cuts(1) = find(x >= lc && x <= uc, 1);
    onInt = onInt(cuts(1):end);
    
    I = cuts(1):cuts(2);
    
end