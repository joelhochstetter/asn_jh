function dist = junctionDistance(i, j, Connectivity)
%{
    Connectivity must contain Connectivity.EdgeList, Connectivity.wireShortPaths
    i and j are the corresponding junction numbers

%}
    iV = Connectivity.EdgeList(:,i);
    jV = Connectivity.EdgeList(:,j);
    dist = round(mean([Connectivity.wireShortPaths(iV(1), jV(1)), ... 
        Connectivity.wireShortPaths(iV(2), jV(1)), ... 
        Connectivity.wireShortPaths(iV(1), jV(2)), ...
        Connectivity.wireShortPaths(iV(2), jV(2))])-0.1);
end