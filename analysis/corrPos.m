function Corr = corrPos(x)
    nSteps = size(x,1);
    nds    = size(x,2);
    Corr = zeros(nds, nds);
    %calculate
    for i = 1:nds
        for j = 1:nds
            Corr(i,j) = mean(x(:,i).*x(:,j)) - mean(x(:,i))*mean(x(:,j));
        end
    end

    %normalise
     for i = 1:nds
        for j = 1:nds
            Corr(i,j) = Corr(i,j)/sqrt(Corr(i,i)*Corr(j,j));
        end
    end   
    
end