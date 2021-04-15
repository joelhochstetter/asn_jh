function adjMat =  DilutedLattice(sizex, sizey, BondProb, RewireProb, seed)
    
    rng(seed)
    
    N = sizex*sizey;
    adjMat = spalloc(N, N, 2*N);


    if BondProb == 1
        %We index nodes so first row 1-sizex, 2nd row sizex+1-2sizex,etc.
        %nodeIdx = sizex * (j - 1) + i
        %Connect adjacent nodes in x direction
        for i = 1:(sizex - 1)
            for j = 1:sizey
                adjMat(sizex * (j - 1) + i,     sizex * (j - 1) + i + 1) = 1;
                adjMat(sizex * (j - 1) + i + 1, sizex * (j - 1) + i)     = 1;            
            end
        end

        %Connect adjacent nodes in y direction
        for i = 1:sizex
            for j = 1:(sizey - 1)
                adjMat(sizex * (j - 1) + i, sizex * j + i)       = 1;
                adjMat(sizex * j + i,       sizex * (j - 1) + i) = 1;                
            end
        end            
    else %percolation model with bond proabibility p

        %We index nodes so first row 1-sizex, 2nd row sizex+1-2sizex,etc.
        %nodeIdx = sizex * (j - 1) + i
        %Connect adjacent nodes in x direction
        for i = 1:(sizex - 1)
            for j = 1:sizey
                p = rand(1) < BondProb;                         
                adjMat(sizex * (j - 1) + i,     sizex * (j - 1) + i + 1) = p;
                adjMat(sizex * (j - 1) + i + 1, sizex * (j - 1) + i)     = p;                
            end
        end

        %Connect adjacent nodes in y direction
        for i = 1:sizex
            for j = 1:(sizey - 1)
                p = rand(1) < BondProb;                        
                adjMat(sizex * (j - 1) + i, sizex * j + i)       = p;
                adjMat(sizex * j + i,       sizex * (j - 1) + i) = p;                
            end
        end                  
    end       

    if RewireProb ~= 0

    end

    nds = 0:(N - 1);
    Connectivity.VertexPosition = 1 +  [floor(nds/sizex); mod(nds, sizex)].';      
end