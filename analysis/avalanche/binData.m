function binned = binData(data, tStep)
%{
    Puts data into bins according with the tStep an integer corresponding
    to how many time-points per bin

    binned is sum of the data that goes in that bin
%}

    len   = numel(data);
    nStep = ceil(len/tStep);
    
    binned = zeros(nStep, 1);
    
    for i = 1:(nStep - 1)
        binned(i) = sum(data((1 + (i - 1)*tStep):i*tStep));
    end
    
    binned(nStep) = sum(data((1 + (nStep - 1)*tStep):end));


end