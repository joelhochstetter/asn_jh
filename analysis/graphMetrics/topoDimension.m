function [td, dtd,Nr, rvals] = topoDimension(adj_matrix)
% %{
%     Calculates the topological dimension as defined in DOI: 10.1038/ncomms3521
%     i.e. N ~ R^D. Number of neighbours visited
% %}

    sp = graphallshortestpaths(sparse(double(adj_matrix)));
    sp = triu(sp);
    sp = sp(:);
    sp = sp(sp > 0);
    rmax = max(sp);
    rvals = 1:rmax;
    Nr     = sum(sp <= rvals);
    intmed = round(0.1*rmax):round(0.9*rmax);
    [td, dtd] = fitPowerLawLinearLogLog(rvals(intmed), Nr(intmed));
    td = -td;
end