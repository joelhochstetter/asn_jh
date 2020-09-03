function [means, counts] = seqMeanCounts(seq)
%{
    For a cell array containing sequence of variables at
    each time point. Calculate the mean of the variable 
    and a count of this variable
%}

    means = zeros(size(seq));
    counts = zeros(size(seq));

    for i = 1:numel(seq)
        counts = numel(seq);
        means = mean(seq);
    end
    
    means(isnan(means)) = 0;

end