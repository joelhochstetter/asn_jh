function deriv =  partialVpartialG(jnCon, Connectivity, electrodes)
    %Calculates the function partialVpartialG for each junction
    %Enter electrodes as electrodes = [src, drn]
    %deriv(i,j) = partialV_i/partialG_j
    
    deriv = zeros(Connectivity.NumberOfEdges);
    dG = min(jnCon)*1e-3;
    oneVec = ones(Connectivity.NumberOfEdges,1);
    
    for i = 1:Connectivity.NumberOfEdges
        jnV1 = solveKirchoff(jnCon + oneVec(i)*dG*0.5, electrodes, Connectivity.EdgeList, Connectivity.NumberOfNodes, 1.0);
        jnV2 = solveKirchoff(jnCon - oneVec(i)*dG*0.5, electrodes, Connectivity.EdgeList, Connectivity.NumberOfNodes, 1.0);
        deriv(:,i) = (abs(jnV1) - abs(jnV2))/dG;
    end
end