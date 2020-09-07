function mins = seqMinCounts(seq)
%{
    For a cell array containing sequence of variables at
    each time point. Calculate the min of the variable 
%}

    mins = zeros(size(seq));

    for i = 1:numel(seq)
        mins(i) = min([seq{i},0]);
    end
    
    mins(isnan(mins)) = 0;

end