function [Connectivity, ContactNodes, SDpath] = addRectElectrode(Connectivity, fraction)
%{
    Inputs:
        Connectivity, SimulationOptions
        SDpath: is the number of junctions between source and drain not. If
        treading electrode as RS then add 2 to this number
%}
        src = find(Connectivity.VertexPosition(:,2) >= Connectivity.GridSize(2)*(1-fraction));
        drn = find(Connectivity.VertexPosition(:,2) <=  Connectivity.GridSize(2)*fraction);
        Connectivity.addNodes = {src, drn};
        ContactNodes =double(Connectivity.NumberOfNodes) + [1:2]; %add new nodes
        Connectivity          = getConnectivity(Connectivity);
        sp = graphallshortestpaths(sparse(double(Connectivity.weights)));
        SDpath  = sp(ContactNodes(1), ContactNodes(2)) - 2;
end