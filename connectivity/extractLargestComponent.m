function [SimulationOptions, Connectivity] = extractLargestComponent(SimulationOptions, Connectivity)
    %{
        If disconnected then extracts largest connected component
    %}

    if ~Connectivity.SingleComponent 
        ccs = conncomp(g);
        compsizes = sum(ccs' ==  [1:max(ccs)]);
        [~, GCCidx] = max(compsizes); %component index of giant component
        GCnds = find(ccs == GCCidx); %node indices of nodes in giant component
        
    end
end