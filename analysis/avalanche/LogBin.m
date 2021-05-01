function [bins, probs, edges] = LogBin(x, nbins)
%{
    E.g:
        x = [1,1,1,1,1,5,10,12];
        LogBin(x, 2)
%}

    x = reshape(x, [numel(x), 1]);
    c = 1;
    %bins begin floor(c*R^j)
    R = round(max(x)^(1/nbins)/c);
%     R = 2;
    edges = floor(c*R.^[0:(nbins + 1)]);
    bins  = floor(c*R.^[0.5:(nbins + 0.5)]);
    bsize = edges(2:end) - edges(1:end -1);
    probs = sum((x < edges(2:end)) & (x >= edges(1:end-1)))./bsize;


end