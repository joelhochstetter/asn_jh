function result = onOrOff(AdjacencyMatrix, OnOrOff, contact)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determines whether the network is in a collective ON or in a collective
% OFF state. The network's collective state is defined to be "ON" iff there 
% exists a path between the two contacts which passes only through "ON" 
% switches.
%
% ARGUMENTS: 
% AdjacencyMatrix - Matrix of the connectivity of the network. 1 if edges
%                   exists between the i-th and j-th wires and 0 otherwise
%             This is 'connectivity.weights' when running 'getConnectivity'
% OnOrOff - a row vector (1xn) of which switches are on (1) or off (0). Such 
%           as in Snapshots.OnOrOff or similar. If you enter a matrix then
%           each row (1st index) corresponds to a different time vector 
%           and each column (2nd index) to a different switch
%           
% Contact - indices of the nanowires (vertices) to which the 
%           external voltage is connected. 
%
% OUTPUT:
% result - true if a conductive path exists between the source and drain. 
%          false otherwise.
%
% REQUIRES:
% none
%
% Author:
% Ido Marcus
% Joel Hochsteter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the edges which correspond to OFF switches:
badPairs = Connectivity.EdgeList(~Snapshot.OnOrOff);
    % Reminder: EdgeList is a 2XE matrix of vertex indices, where each 
    % column represents an edge. The index of an edge is defined as the 
    % index of the corresponding column in this list.

% Get the original adjacency matrix:
adjacencyMatrix = Connectivity.weights;

% Remove the edges which correspond to OFF switches:
adjacencyMatrix(sub2ind(size(adjacencyMatrix),badPairs(1,:),badPairs(2,:))) = 0;
adjacencyMatrix(sub2ind(size(adjacencyMatrix),badPairs(2,:),badPairs(1,:))) = 0;

% Check whether in the modified adjacency matrix the two contacts are in 
% the same connected component:
result = doesPathExist(adjacencyMatrix, contact(1), contact(2));