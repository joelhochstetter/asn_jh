function perturbV1(initStates, netC, spE, params, E)  

    if nargin < 5
        E                          = 261;  
    end
        
    initLamda                  = initStates;

    
    %% Run sim
    
    parfor i = 1:(numel(spE) + 1)
        if i == (numel(spE) + 1)
            p = params;
            p.Comp.filamentState = initLamda;
            p.SimOpt.nameComment = strcat('_i0', '_netC', num2str(netC,'%.3e'));
            p.SimOpt.saveFolder      = strcat(p.SimOpt.saveFolder, '/switch0');
            mkdir(p.SimOpt.saveFolder)
            multiRun(p)
        else
            for eps = [-1e-3, 1e-3] 
                id = eye(E)*eps; 
                p  = params;
                p.Comp.filamentState = initLamda + id(:,spE(i));
                p.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(i,'%03.f'), '_netC', num2str(netC,'%.3e'));
                p.SimOpt.saveFolder      = strcat(p.SimOpt.saveFolder, '/switch', num2str(spE(i)));
                mkdir(p.SimOpt.saveFolder)
                multiRun(p);  
            end
        end
    end

    
end
    