function [NewEdgeList, EdgeMapping] = subgraphEdgeList(sgNds, oldEdgeList, newAdjMat)
%{
    Inputs:
              sgNds: list of sub-graph nodes using old indexing
        oldEdgeList: edge-list before
          newAdjMat: (OPTIONAL). Checks that edge-list extracted is correct
    Old EdgeList and list of sub-graph nodes
    
    Optional: 
        sgNds

%}

    oldNumEdges = size(oldEdgeList, 2);
    NewLongList = oldEdgeList;
    sgInv = invertArray(sgNds); %maps old indices to new indices
    
    %Extracts sub-graph indices
    for i = 1:2
        for j = 1:oldNumEdges       
            NewLongList(i,j) = sgInv(oldEdgeList(i,j));
        end
    end        
    EdgeMapping = find(and(NewLongList(1,:) > 0, NewLongList(2,:) > 0));
    NewEdgeList = NewLongList(1:2, EdgeMapping);
    
        
    %% Checking consistency
    % check new edge list produced is consistent with new adjacency matrix 
    if nargin >= 3 %only if new adjacency matrix is provided
        [ii, jj] = find(tril(newAdjMat)); 
        altNewEdgeList = [jj ii]'; %alternative method for new edge list
        assert(all(size(altNewEdgeList) == size(NewEdgeList)));
        assert(all(altNewEdgeList(:) == NewEdgeList(:)));
    end

end