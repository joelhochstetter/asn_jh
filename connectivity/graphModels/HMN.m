function adjMat = HMN(HMtype, M0, b, alpha, numLevels, p, seed)
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
             p  (double): probability 0<p<1
          seed (integer): If >=0 then random seed of number generated. If < 0 then use
        rng('shuffle') which is seed based on clock times
        

    Outputs: 
        adjMat: adjacency matrix of hierirachical modular network


    To do: update HMN1 so it ensures a fully connected network

    Example usage: adjMat = HMN(2, 2, 2, 2, 10, 0, 1);

    Written by Joel Hochstetter (27/08/20)

%}
    if seed >= 0 
        rng(seed);
    else
        rng('shuffle')
    end

    
    %% Defining important variables
    Nd      = M0*b^numLevels; %number of nodes
    nBlock0 = b^numLevels; %number of blocks at the base level 
    adjMat  = zeros(Nd);
    baseMod = ones(M0) - eye(M0);  %adjMat of fully connected module size M0
    bComb   = combnk([1:b],2); %is the possible combinations of blocks
    nbComb  = size(bComb,1); %number of combination of blocks
    
    %% Generate level 0 modules
    for i = 1:nBlock0
       adjMat((i-1)*M0 + 1:i*M0, (i-1)*M0 + 1:i*M0) = baseMod;
    end
    
    
    %% connect modules
    if HMtype == 1
        for l = 1:numLevels
            NdBlockl = M0*b^(l-1); %number of nodes per block
            nBlockl  =  b^(numLevels - l); %number of blocks at l-th level
            probi = alpha*p^l;
            for i = 1:nBlockl
                %[b,Ndx,Ndy] is a 3D array (size b x NdBlockl x NdBlockl)
                %of all possible edge choices
                %randomly sample these edges according to probability for
                %each level
                %re-map to indices within block and add edges to adjMat
                probs = binornd(1, probi, [nbComb,NdBlockl,NdBlockl]);
                [bidx,Ndx,Ndy] = ind2sub(size(probs),find(probs));             
                Ex = Ndx + (b*(i - 1) + bComb(bidx,1) - 1)*NdBlockl; 
                Ey = Ndy + (b*(i - 1) + bComb(bidx,2) - 1)*NdBlockl; 
                adjMat(Ex, Ey) = 1;
                adjMat(Ey, Ex) = 1;
            end
        end 
    elseif HMtype == 2
        for l = 1:numLevels
            NdBlockl = M0*b^(l-1); %number of nodes per block
            nBlockl  =  b^(numLevels - l); %number of blocks at l-th level
            for i = 1:nBlockl
                %NdBlockl^2*C(b,2) edge choices (C(n,k) is combination)                    
                %[b,Ndx,Ndy] is a 3D array (size b x NdBlockl x NdBlockl)
                %of all possible edge choices
                % we randomly generate unique integers corresponding to
                % possible edge choices and re-map them to 3d indices.
                Edgs = randperm(nbComb*NdBlockl^2, alpha);
                [bidx, Ndx, Ndy] = ind2sub([nbComb,NdBlockl,NdBlockl],Edgs);                
                Ex = Ndx + (b*(i - 1) + bComb(bidx,1) - 1)*NdBlockl; 
                Ey = Ndy + (b*(i - 1) + bComb(bidx,2) - 1)*NdBlockl; 
                adjMat(Ex, Ey) = 1;
                adjMat(Ey, Ex) = 1;
            end
        end        
    end
    
    
    

end