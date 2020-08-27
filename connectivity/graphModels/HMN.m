function adjMat = HMN(HMtype, M0, b, alpha, p, numLevels, seed)
%{
    Constucts Hierierchical modular networks by process outlined by
    Moretti + Munoz Nature Comms 2013 (https://doi.org/10.1038/ncomms3521)

    Inputs:
        HMtype (integer): Whether to construct HMN-1 (HMtype = 1) which has
            inter-modular connections determined by level-dependendent
            probability p, or HMN-2 (HMtype = 2) which has inter-moduli
            connections that have a deterministic number of level dependent
            connections
        M0     (integer): Number of nodes in fully connected modules
         b     (integer): Number of modules in set of higher level blocks
     numLevels (integer): Number of levels in network hierarchy
          seed (integer): If >=0 then random seed of number generated. If < 0 then use
        rng('shuffle') which is seed based on clock times
        

    Outputs: 
        adjMat: adjacency matrix of hierirachical modular network

    Written by Joel Hochstetter (27/08/20)

%}
    if seed >= 0 
        rng(seed);
    else
        rng('shuffle')
    end

    %% generate module
    block = ones(M0) - eye(M0); 
    

end