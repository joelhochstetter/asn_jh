function [sims] = multiImport (params)
%Takes in parameters struct classified into following categories:
%SimOpt: SimulationOptions
%Stim:   Stimulus
%Comp:   Components
%Conn:   Connectivity
%params.importAll is a flag (true / false). false by default
%If true imports all mat files in 'params.SimOpt.saveFolder
%
% To import by name use
%params.importByName = 'String' where string is the name of the file. Do
%not include '.mat'. E.g. params.importByName =
%'t_T1000_AC3V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p10_eps1e-05_i257' 

    if isfield(params, 'SimOpt') == 0
        params.SimOpt = struct();
    end
    if isfield(params, 'Comp') == 0
        params.Comp = struct();
    end    
    if isfield(params, 'Comp') == 0
        params.Comp = struct();
    end    
    if isfield(params, 'Stim') == 0
        params.Stim = struct();
    end                

    if isfield(params.SimOpt, 'saveFolder') == 0
        params.SimOpt.saveFolder = '.';
    end
    
    %Control whether or not to import single switch data
    if ~isfield(params, 'importSwitch')
        params.importSwitch = true;
    end
    
    if (isfield(params, 'importAll') && params.importAll == true) || (isfield(params, 'importByName') && ~isempty(params.importByName))
        if (isfield(params, 'importAll') && params.importAll == true)
            files = dir(strcat(params.SimOpt.saveFolder, '/*.mat'));
            sims = cell(1,numel(files));
            filenames = cell(1,numel(files));

            for i = 1:numel(files)
                filenames{i} = strcat(files(i).folder,'/',files(i).name);
            end

        else %in this case we use importByName
            if contains(params.importByName,'.mat')
                filenames{1} = strcat(params.SimOpt.saveFolder, '/', params.importByName);                
            else
                filenames{1} = strcat(params.SimOpt.saveFolder, '/', params.importByName, '.mat');
            end
        end

        
        if (isfield(params.SimOpt,'useParallel') == 0) || (params.SimOpt.useParallel == false)
            for i = 1:numel(filenames) 
                filenames{i}
            	sims{i} = load(filenames{i});
                if isfield(sims{i}, 'sim')
                    sims{i} = sims{i}.sim;
                end
                if isfield(sims{i}, 'hdfFile') && params.importSwitch
                    sims{i}.hdfFile = strcat(params.SimOpt.saveFolder, '/', sims{i}.hdfFile);   
                    sims{i}.swLam =  h5read(sims{i}.hdfFile, '/swLam');
                    sims{i}.swV   =  h5read(sims{i}.hdfFile, '/swV');    
                    sims{i}.swC   =  h5read(sims{i}.hdfFile, '/swC');  
                end                
            	sims{i}.filename = filenames{i};
            end
        else
            parfor i = 1:numel(filenames)   
                filenames{i}
            	sims{i} = load(filenames{i});
                if isfield(sims{i}, 'sim')
                    sims{i} = sims{i}.sim;
                end
                
                if isfield(sims{i}, 'hdfFile') && params.importSwitch
                    sims{i}.swLam =  h5read(sims{i}.hdfFile, '/swLam');
                    sims{i}.swV   =  h5read(sims{i}.hdfFile, '/swV');    
                    sims{i}.swC   =  h5read(sims{i}.hdfFile, '/swC');  
                end
            	sims{i}.filename = filenames{i};
            end
        end        
        

        
    else
        if isfield(params.SimOpt, 'nameComment') == 0
            params.SimOpt.nameComment = '';
        end

 


        runs = multify(params);
        sims = cell(1,numel(runs));

        if (isfield(params.SimOpt,'useParallel') == 0) || (params.SimOpt.useParallel == false)
            for i = 1:numel(runs) %
                %for i = 1:numel(runs)
               sims{i} = importSim(runs{i}.Comp, runs{i}.Stim, runs{i}.SimOpt.T, ...
               -1, runs{i}.SimOpt.saveFolder, runs{i}.SimOpt.nameComment, params.importSwitch);
            end
        else
            parfor i = 1:numel(runs) %
            %for i = 1:numel(runs)
               sims{i} = importSim(runs{i}.Comp, runs{i}.Stim, runs{i}.SimOpt.T, ...
               -1, runs{i}.SimOpt.saveFolder, runs{i}.SimOpt.nameComment, params.importSwitch);
            end
        end
        
    end
    
end