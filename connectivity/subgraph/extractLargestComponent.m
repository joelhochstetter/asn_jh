function [SimulationOptions, Connectivity] = extractLargestComponent(SimulationOptions, Connectivity)
    %{
        If disconnected then extracts largest connected component

        If we go from N->M nodes then we map node indices down from 1:N to
        1:M

        Assumes that contacts lie on largest component and tests this with
        assertion

        To do later:
            - generalise this so is valid for any sub-graph (not just the
                giant component). Mostly a cut and paste job but need to
                check some assertions 
    %}

    if ~Connectivity.SingleComponent 
        %% get largest component and new indices
        g =graph(Connectivity.weights);
        ccs = conncomp(g);
        compsizes = sum(ccs' ==  [1:max(ccs)]);
        [~, GCCidx] = max(compsizes); %component index of giant component
        GCnds = find(ccs == GCCidx); %node indices of nodes in giant component
        GCinv = invertArray(GCnds); %maps old indices to new indices
        
        %% updating contact indices
        assert(all(ccs(SimulationOptions.ContactNodes) == GCCidx)); %checks all contacts lie on giant components
        SimulationOptions.ContactNodes = GCinv(SimulationOptions.ContactNodes);
%         SimulationOptions.Source       = GCinv(SimulationOptions.Source); % not fields in current implemenation
%         SimulationOptions.Drain        = GCinv(SimulationOptions.Drain);
        
        %% updating components
        Connectivity.NumberOfNodes  = compsizes(GCCidx);        
        Connectivity.weights        = Connectivity.weights(GCnds, GCnds);
        assert(Connectivity.NumberOfNodes == size(Connectivity.weights,1));
        
        if strcmp(Connectivity.WhichMatrix,'nanoWires')
            Connectivity.wireDistances  = Connectivity.wireDistances(GCnds,GCnds);
            Connectivity.VertexPosition = Connectivity.VertexPosition(GCnds,1:2);
            Connectivity.WireEnds       = Connectivity.WireEnds(GCnds, 1:4);
        end
        
        if numel(Connectivity.NewNodes) > 0
            assert(all(ccs(Connectivity.NewNodes) == GCCidx)); %checks all new nodes lie on giant components        
            Connectivity.NewNodes = GCinv(Connectivity.NewNodes);
        end
        Connectivity.NodeStr  = string(1:Connectivity.NumberOfNodes);
        
        %% get edge list: 
        [NewEdgeList, EdgeMapping] = subgraphEdgeList(GCnds, Connectivity.EdgeList, Connectivity.weights);
        Connectivity.EdgeList = NewEdgeList;
        Connectivity.NumberOfEdges = size(Connectivity.EdgeList, 2);
        
        if strcmp(Connectivity.WhichMatrix,'nanoWires')
            Connectivity.EdgePosition   = Connectivity.EdgePosition(EdgeMapping, 1:2);
        end
        
        %% output
        disp(strcat2({'Extracted giant component with N = ', Connectivity.NumberOfNodes, ', E = ', Connectivity.NumberOfEdges}))
    end
end