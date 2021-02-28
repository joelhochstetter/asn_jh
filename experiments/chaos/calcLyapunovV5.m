function li = calcLyapunovV5(useParFor, idx, attractorFolder, Attractor, lyFolder, useNp)
% Run Lyapunov Simulations  and saves to file Ly.mat, Ly.h5
% Inputs
%   Enter the attractor file and folder from which the simulations starts
%       from. These are strings
%   Parfor = 0 => do not run in parallel
%   Parfor = n => use parallel processing
% Ouputs:
%   li is the junction lyapunov exponents (1xE array)
%   Ly.mat stores junction Lyapunov exponents and mean exponent
%   Ly.h5 stores exponential diverges at each time step and running
%       lyapunov exponents at the end of each period to check for convergence
% idx < 0 loops through all things
% Written by Joel Hochsteter




    %% quit if file exists
    if numel(idx) == 1 && idx >= 1
        files = dir(strcat(lyFolder, '/', Attractor, '/*_i', num2str(idx, '%03.f'), '.mat'));
        if numel(files) > 0 
            disp(strcat('idx ', num2str(idx), ' already exists for attractor ', Attractor));
            return
        end
    end



	%% Params
	params = struct();

	% Set Simulation Options
	params.SimOpt.useWorkspace    = true;
	params.SimOpt.saveSim         = true;
	params.SimOpt.takingSnapshots = false;
	params.SimOpt.onlyGraphics    = true; %does not plot anything
	params.SimOpt.compilingMovie  = false;
	params.SimOpt.useParallel     = false;
	params.SimOpt.hdfSave         = true;
	params.SimOpt.lyapunovSim     = false;
    params.SimOpt.NodalAnal       = true;
    params.SimOpt.reserveFilename = true;
    params.SimOpt.stopIfDupName = true;
    
	%params.SimOpt.saveFolder      = '/import/silo2/joelh/Chaos/Lyapunov';
	params.SimOpt.dt               = 5e-4;
	params.SimOpt.nameComment      = '';
    params.SimOpt.saveFolder       = strcat(lyFolder, '/', Attractor, '/');%strcat('/headnode2/joelh/bin/longAC_topo/Lyapunov/up/', Attractor, '/');
    mkdir(params.SimOpt.saveFolder)
    
    
    %Initialise paramaters from attractor file
    sim = multiImport(struct('SimOpt', struct('saveFolder', attractorFolder), 'importByName', Attractor, 'importStateOnly', true));
    params.Stim.BiasType = sim{1}.Stim.BiasType;
    params.Stim.Amplitude = sim{1}.Stim.Amplitude;    
    params.Stim.Frequency = sim{1}.Stim.Frequency;   
    params.Comp.setVoltage = sim{1}.Comp.setV;
    params.Comp.resetVoltage = sim{1}.Comp.resetV;
    params.Comp.criticalFlux = sim{1}.Comp.critFlux;
    params.Comp.maxFlux = sim{1}.Comp.maxFlux;
    params.Comp.boost = sim{1}.Comp.boost;
    params.Comp.penalty = sim{1}.Comp.pen;
    params.Comp.onConductance = sim{1}.Comp.onR;
    params.Comp.offConductance = sim{1}.Comp.offR;
    
    params.Comp.nonpolar = useNp;
    
	
	params.SimOpt.ContactMode      = 'preSet';
	params.SimOpt.ContactNodes  = sim{1}.ContactNodes;


    if isfield(sim{1},  'ConnectFile')
        conFile = load(sim{1}.ConnectFile);
        E = conFile.number_of_junctions;
        params.Conn.filename = sim{1}.ConnectFile;
    elseif isfield(sim{1},  'adjMat')
            E = (sum(sum(sim{1}.adjMat))/2); %261    
            params.Conn.WhichMatrix = 'adjMat';
            params.Conn.weights = sim{1}.adjMat;        
    end
    
    
	if idx > E
		return
    end

    switch(sim{1}.Comp.swType)
        case 'a' 
            swType =  'atomicSwitch' ; 
        case 'm'
            swType = 'memristor';
        case 't'
            swType = 'tunnelSwitch';
        case 'q'
            swType = 'quantCSwitch';
        case 't2'
            swType = 'tunnelSwitch2';    
        case 'tl'
            swType = 'tunnelSwitchL';            
        case 'l'
            swType = 'linearSwitch';            
        case 'b'
            swType = 'brownModel';       
    end

    params.Comp.ComponentType = swType; %'tunnelSwitchL'; %'tunnelSwitch2';
	params.SimOpt.T                = 150;%10/params.Stim.Frequency;

    %swLam =  ';%h5read(strcat(Folder, '/', Attractor, '.h5'), '/swLam');
    
    if isfield(sim{1}, 'swLam')
        initLamda                  = sim{1}.swLam(end,1:E)';
    elseif isfield(sim{1}, 'finalStates')
        initLamda                  = sim{1}.finalStates';
    else
        disp('FAILED');
        return;
    end
        
    params.Comp.filamentState = initLamda;
	eps                        = 5e-4;%1e-5; %1e-5 / 1e-6 / 1e-7 / 1
    clear('swLam', 'sim')

    %% Run unperturbed simulation
    files = dir(strcat(params.SimOpt.saveFolder, '/*unperturbed.mat'));
    params.SimOpt.saveFilStateOnly = true;
    if numel(files)
        params.importByName = files(1).name;
         params.importStateOnly = true;
        u = multiImport(params);
        params.SimOpt.unpertFilState = u{1}.swLam(:,1:E);
        NumTSteps                    = numel(u{1}.Stim.TimeAxis);
        clear('u');            
        params = rmfield(params, 'importByName');
    else
        params.SimOpt.nameComment = strcat('_unperturbed');	
        u = multiRun(params);
        params.SimOpt.unpertFilState = u{1}.Output.lambda(:,1:E); 
        NumTSteps                    = numel(u{1}.Stimulus.TimeAxis);
        clear('u');        
    end
    params.SimOpt.saveFilStateOnly = false;
    
    %% Initialise perturbed simulations
    params.SimOpt.lyapunovSim     = true;
    params.SimOpt.LyEps           = eps;    
    params.misc.LyEps             = eps;
    params.SimOpt.saveSwitches    = false;
    params.SimOpt.hdfSave         = false;
	id                            = eye(E)*eps; %identity matrix
    params.importSwitch           = false; %so we don't worry about single switch details
    params.SimOpt.NodalAnal       = false;
	
	R = E; %number to run for %default R = E. and run switches 1:R
    gij = zeros(NumTSteps, R);
    


        %% Run perturbed simulations or import
    if useParFor > 0
        delete(gcp('nocreate'))
        pool=parpool(useParFor);
        parfor i = 1:R
            p = params;
            p.Comp.filamentState = initLamda + id(:,i);
            p.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(i,'%03.f'));
            p.misc.perturbID     = i;
            files = dir(strcat(p.SimOpt.saveFolder, '/*', p.SimOpt.nameComment, '.mat'));
            if numel(files) == 0 
                sprintf('Run, %d\n', i)
                t =  multiRun(p);
                gij(:,i) = t{1}.Output.LyapunovMax;%/params.SimOpt.dt;
            else
                %sprintf('Import, %d\n', i)
                t =  multiImport(p);
                gij(:,i) = t{1}.LyapunovMax;%/params.SimOpt.dt;

            end                
        end
    elseif idx > 0
        for i =  idx %1:R
            params.Comp.filamentState = initLamda + id(:,i);
            params.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(i,'%03.f'));
            params.misc.perturbID     = i;
            files = dir(strcat(params.SimOpt.saveFolder, '/*', params.SimOpt.nameComment, '.mat'));
            if numel(files) == 0 
                t =  multiRun(params);
                gij(:,i) = t{1}.Output.LyapunovMax;%/params.SimOpt.dt;
                clear('t');
            else
                %sprintf('Import, %d\n', i)                      
                t = multiImport(params);
                gij(:,i) = t{1}.LyapunovMax;%/params.SimOpt.dt; 
                clear('t')
            end                                
        end

    elseif idx < 0
        for i = 1:R
            params.Comp.filamentState = initLamda + id(:,i);
            params.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(i,'%03.f'));
            params.misc.perturbID     = i;
            files = dir(strcat(params.SimOpt.saveFolder, '/*', params.SimOpt.nameComment, '.mat'));
            if numel(files) == 0 || isempty(who('-file', strcat(files(1).folder, '/', files(1).name), 'sim')) %checks if contains sim
                if numel(files) > 0 && isempty(who('-file', strcat(files(1).folder, '/', files(1).name), 'sim')) %if doesnt contain sim delete sim
                    delete(strcat(files(1).folder, '/', files(1).name))
                end                
                t =  multiRun(params);
                gij(:,i) = t{1}.Output.LyapunovMax;%/params.SimOpt.dt;
                clear('t');
            else
                sprintf('Import, %d\n', i)                      
                t = multiImport(params);
                gij(:,i) = t{1}.LyapunovMax;%/params.SimOpt.dt; 
                clear('t')
            end                                
        end        
        
    end
    
    
%    %% Calculate lyapunov and save
%     if useParFor > 0 || numel(idx) > 1
%         skipFraction = 0.3; %Skip for calculating mean
%         numTStep = round(params.SimOpt.T/ params.SimOpt.dt*(1-skipFraction));
%         numT = round(params.SimOpt.T * params.Stim.Frequency*(1-skipFraction));
%         lambda = zeros(E,1);
%         lij    = zeros(numT, E);
%         netC   = zeros(numTStep, E);
%         gij1   = gij(round(skipFraction*numT)+1:end,:);
% 
% 
%         if useParFor == true		
%             parfor j = 1:numT
%                 lij(j,:) = mean(gij1(1:floor(numTStep/numT)*j,:));
%             end
%         else
%             for j = 1:numT
%                 lij(j,:) = mean(gij1(1:floor(numTStep/numT)*j,:));
%             end
%         end
% 
% 
%         li = lij(end,:);
%         ml = mean(li);
% 
%         hdfFile = strcat(params.SimOpt.saveFolder, '/LyCalc.h5');
%         %delete(hdfFile)
%         if ~exist(hdfFile, 'file')
%             h5create(hdfFile,'/lij', size(lij)) 
%             h5create(hdfFile,'/gij', size(gij))
%         end
% 
%         h5write(hdfFile, '/lij', lij)
%         h5write(hdfFile, '/gij',  gij)                 
% 
%         save(strcat(params.SimOpt.saveFolder, '/LyCalc.mat'), 'hdfFile', 'ml', 'params', 'li');
%         if useParFor > 0
%             delete(pool);
%         end
%     end


end