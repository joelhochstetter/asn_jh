function [Connectivity, ContactNodes] = addRectElectrode(Connectivity, fraction)
        src = find(Connectivity.VertexPosition(:,2) >= Connectivity.GridSize(2)*(1-fraction));
        drn = find(Connectivity.VertexPosition(:,2) <=  Connectivity.GridSize(2)*fraction);
        Connectivity.addNodes = {src, drn};
        ContactNodes =double(Connectivity.NumberOfNodes) + [1:2]; %add new nodes
        Connectivity          = getConnectivity(Connectivity);
end