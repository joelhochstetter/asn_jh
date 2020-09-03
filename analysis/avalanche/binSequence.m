function seqs = binSequence(x, times, N)
%{
    Inputs:
            x: some variable (such as event, avalanche size, branch)
    times: times when the value x is measured
           N: N is total number of time-points


    Outputs:
        seqs: cell of all elements of x at each time-point

%}

    seqs = cell(N,1);
    for i = 1:numel(x)
        seqs(times) = [seqs(times(i)), x(i)];
    end


end