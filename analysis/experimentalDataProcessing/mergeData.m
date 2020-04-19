function mergeVec = mergeData(dataCell, isTime, useNaN)
%{
    Takes time-series data as a cell and returns as one long vector.
    useNaN (boolean) pads a NaN at the end of the dataset
%}
    
    if nargin < 3
       useNaN = false;
       if nargin < 2
           isTime = false;
       end
    end
    
    mergeVec = [];

    for i = 1:numel(dataCell)
        if isTime && i > 1
            T = mergeVec(end);
            mergeVec = [mergeVec, T + dataCell{i}];
        else
            mergeVec = [mergeVec, dataCell{i}];
        end
        if useNaN
           mergeVec = [mergeVec, nan]; 
        end  
    end

end