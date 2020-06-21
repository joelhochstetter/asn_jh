function adjMat = genScaleFree(N, m0, m, seed)
%{
    Generates a scale-free network according to the Barabasi-Albert model
    
    Inputs: 
    N:  Number of nodes
    m0: Number of initial nodes
    m:  Number of edges added for each new node added

    Using the initail process from wikipedia the initial nodes are
    connected
    
    Require that m <= m0
    
    Outputs: 
    adjMat: adjacency matrix of the new graph


    Example usage:
    A=genScaleFree(500, 2, 2, 1);
    k = sum(A):
    histogram(k); %plots degree distribution
    
%}

    %initialise random seed
    rng(seed);

    adjMat = zeros(N); %adjacency matrix
    ki     = zeros(N,1); %Degree per node - constantly updated
    Pi     = zeros(N,1); %connection probability
    
    %Generate connections of initial m0 nodes
    %1<->2 , 2<->3, etc.
    for i = 1:(m0 - 1)
        adjMat(i,i+1) = 1;
        adjMat(i+1,i) = 1;        
    end
    
    %Preferentially add edges
    for i = (m0 + 1):N
        %update degree and connection probability
        ki  = sum(adjMat);
        Pi  = ki./sum(ki);

        %add m edges for new node
        for j = 1:m
            cPi = cumsum(Pi); %cumulative sum of probability

            rnum = rand(); %generate a random number between 0 and 1
            %find index of new edge (edgI)
            %e.g. if cPi = [0.5, 0.6, 1.0] then rnum = 0.55 => edgI = 2
            edgI = find(cPi >= rnum, 1); 
            adjMat(i, edgI) = 1;
            adjMat(edgI, i) = 1;
            
            %remove edgI from possible edges and renormalise probability
            %distribution
            Pi(edgI) = 0;
            Pi = Pi/sum(Pi);
        end
    end

end