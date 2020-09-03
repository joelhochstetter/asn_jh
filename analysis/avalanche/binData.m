% function [binned, centres, nnzero] = binData(data, tStep)
function binned = binData(data, tStep)
%{
    Puts data into bins according with the tStep an integer corresponding
    to how many time-points per bin

    binned is sum of the data that goes in that bin

    nnzero: number of non-zero events in a given time-bin

    Indices of centre of bins in terms of number of tsteps


%}

    len   = numel(data);
    nStep = ceil(len/tStep);
    
    binned = zeros(nStep, 1);
%     nnzero = zeros(nStep, 1);
    
    for i = 1:(nStep - 1)
        binned(i) = sum(data((1 + (i - 1)*tStep):i*tStep));
%         nnzero(i) = sum(data((1 + (i - 1)*tStep):i*tStep) > 0); 
    end
    
    binned(nStep) = sum(data((1 + (nStep - 1)*tStep):end));
%     nnzero(nStep) = sum(data((1 + (nStep - 1)*tStep):end) > 0);

%     centres = floor((tStep+1)/2):tStep:numel(data);
    
%     assert(numel(binned) == numel(centres));
    
end