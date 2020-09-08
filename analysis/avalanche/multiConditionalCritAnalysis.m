function multiConditionalCritAnalysis(conditions, baseFolder, saveFolder, vals, subtype, binSize, joinperiod, fitML, fmt, dt)
%{
    For a set of simulations (note use jointCritAnalysis /
    multiCritAnalysis for experiments).

%}
    
    %% defaults
    if nargin < 7
        joinperiod = 30*1000;
    end
    
    if nargin < 8
        fitML = false;
    end
    
    if nargin < 9
        fmt = '%g';
    end

    if nargin < 10
        dt = 1e-3;
    end
    
    vals       = reshape(vals,       [1, numel(vals)]);
    binSize = reshape(binSize, [1, numel(binSize)]);    
    
    %%
    for v = vals
        for bs = binSize
            disp(v)
            load(strcat(baseFolder, '/', subtype, num2str(v, fmt), '/events.mat'), 'events')
            load(strcat(baseFolder, '/', subtype, num2str(v, fmt), '/netC.mat'), 'netC')            
            saveFolder1 = strcat(baseFolder, '/', saveFolder, '/', subtype, num2str(v, fmt), '/bs', num2str(bs));            
            time = dt*(1:numel(events));
            conditionalCritAnalysis(conditions, events, dt, netC, time, v, '', saveFolder1, fitML, binSize, joinperiod);
        end
    end
end