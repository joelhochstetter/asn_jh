function onSwitchMatrix = getOnSubGraph(adjMat, edgeList, onOrOff)
% Given an adjacency matrix and vector of which switches are onOrOff calculates
% the adjacency matrix of the subgraph of switches that are On
% Also pass in the edge list but can modify so this is not essential

    badPairs = edgeList(:, ~onOrOff);
        % Reminder: EdgeList is a 2XE matrix of vertex indices, where each 
        % column represents an edge. The index of an edge is defined as the 
        % index of the corresponding column in this list.

    % Get the original adjacency matrix:
    onSwitchMatrix = adjMat;

    % Remove the edges which correspond to OFF switches:
    onSwitchMatrix(sub2ind(size(onSwitchMatrix),badPairs(1,:),badPairs(2,:))) = 0;
    onSwitchMatrix(sub2ind(size(onSwitchMatrix),badPairs(2,:),badPairs(1,:))) = 0;