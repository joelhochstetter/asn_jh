function mergeVec = mergeData(dataCell, useNaN)
%{
    Takes time-series data as a cell and returns as one long vector.
    useNaN (boolean) pads a NaN at the end of the dataset
%}
    
    if nargin == 1
       useNaN = false;
    end
    
    mergeVec = [];

    for i = 1:numel(dataCell)
        mergeVec = [mergeVec, dataCell{i}];
        if useNaN
           mergeVec = [mergeVec, nan]; 
        end  
    end

end