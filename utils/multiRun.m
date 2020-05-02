function [sims] = multiRun(params)
%Takes in parameters struct classified into following categories:
%SimOpt: SimulationOptions
%Stim:   Stimulus
%Comp:   Components
%Conn:   Connectivity
%Then maps all possible elements to column vectors
%Names of these are stored as a row vector 
%Combinations of all possible parameter sets are then taken
%Simulations are run for each combination
%Generalise so works for generic Struct names
%Write exceptions such as setting initial filamentState, etc.

%Parallisation:
%

    %Generate save name before we run
        

    %M = 10;
    runs = multify(params);
    if ~isfield(params.SimOpt, 'runIndex') || (params.SimOpt.runIndex < 0)
        sims = cell(1,numel(runs));
        if (isfield(params.SimOpt,'useParallel') == 0) || (params.SimOpt.useParallel == false)
            for i = 1:numel(runs)
               sims{i} = runSim(runs{i}.SimOpt, runs{i}.Stim, runs{i}.Comp, runs{i}.Conn);
            end
        else
            parfor i = 1:numel(runs)
               sims{i} = runSim(runs{i}.SimOpt, runs{i}.Stim, runs{i}.Comp, runs{i}.Conn);
            end
        end
    else
        sims = cell(1);
        i = params.SimOpt.runIndex;
        sims{1} = runSim(runs{i}.SimOpt, runs{i}.Stim, runs{i}.Comp, runs{i}.Conn);
    end
    
end