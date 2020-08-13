function li = simToLyapunov(useParFor, simFolder, simFile, lyFolder, numJnLy, initLamda)
% Run Lyapunov Simulations  and saves to file Ly.mat, Ly.h5
%{
Takes in a simulation file simFile in simulation folder simFolder

Performs Lyapunov analysis with initial state initLamda with numJnLy
junction Lyapunvs calculated:

- Take filament state time-series
  - Exclude junctions with std(lambda) = 0
    - These are junctions that are not affected by the stimulus
  - Sort mean(|lambda|) from minimum to maximum
  - If 1 datapoint take the median and perform Lyapunov analysis
  - If 2 datapoint take the min and max and perform Lyapunov analysis
  - For > 3 datapoints evenly  space starting with the min and max
- Perform Lyapunov analysis with all else equal on this time-series.


%}
%
% Written by Joel Hochsteter

    if nargin < 6
        initLamda = 0;
    end
    
    disp('Importing simulation for Lyapunov') 
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
    
    %Initialise paramaters from attractor file
    sim = multiImport(struct('SimOpt', struct('saveFolder', simFolder), 'importByName', simFile, 'importStateOnly', true));
    
	params.SimOpt.dt               = sim{1}.dt;
	params.SimOpt.T                = sim{1}.T;
    NumTSteps = round(sim{1}.T/sim{1}.dt); 

	params.SimOpt.nameComment      = '';
    params.SimOpt.saveFolder       = strcat(lyFolder, '/', simFile, '/');
    mkdir(params.SimOpt.saveFolder)
    

    params.Stim.BiasType = sim{1}.Stim.BiasType;
    params.Stim.Amplitude = sim{1}.Stim.Amplitude;    
    params.Stim.Frequency = sim{1}.Stim.Frequency;   
    params.Comp.setVoltage = sim{1}.Comp.setV;
    params.Comp.resetVoltage = sim{1}.Comp.resetV;
    params.Comp.criticalFlux = sim{1}.Comp.critFlux;
    params.Comp.maxFlux = sim{1}.Comp.maxFlux;
    params.Comp.boost = sim{1}.Comp.boost;
    params.Comp.penalty = sim{1}.Comp.pen;
    params.Comp.nonpolar = false;
    	
	params.SimOpt.ContactMode      = 'preSet';
	params.SimOpt.ContactNodes  = sim{1}.ContactNodes;


    if isfield(sim{1},  'ConnectFile')
        conFile = load(sim{1}.ConnectFile);
        E = double(conFile.number_of_junctions);
        params.Conn.filename = sim{1}.ConnectFile;
    elseif isfield(sim{1},  'adjMat')
            E = (sum(sum(sim{1}.adjMat))/2); %261    
            params.Conn.WhichMatrix = 'adjMat';
            params.Conn.weights = sim{1}.adjMat;        
    end
   
    params.Comp.ComponentType = 'tunnelSwitchL';
    
    params.Comp.filamentState = initLamda;
	eps                        = 5e-4;%1e-5; %1e-5 / 1e-6 / 1e-7 / 1
    
    if (sim{1}.dt*params.Comp.boost*params.Comp.resetVoltage > eps) || (sim{1}.dt*(params.Stim.Amplitude - params.Comp.setVoltage) > eps)
        eps = max([sim{1}.dt*params.Comp.boost*params.Comp.resetVoltage, sim{1}.dt*(params.Stim.Amplitude - params.Comp.setVoltage)])*1.05;
        disp(strcat('Using eps = ', num2str(eps)));
    end
    
    params.SimOpt.saveFilStateOnly = false;
    swLam = sim{1}.swLam(:,1:E);
    clear('sim')
    
    %% Initialise perturbed simulations
    params.SimOpt.lyapunovSim     = true;
    params.SimOpt.LyEps           = eps;    
    params.misc.LyEps             = eps;
    params.SimOpt.saveSwitches    = false;
    params.SimOpt.hdfSave         = false;
	id                            = eye(E)*eps; %identity matrix
    params.importSwitch           = false; %so we don't worry about single switch details
    params.SimOpt.NodalAnal       = false;
	
    rngLam = max(swLam,1) - min(swLam,1); %range over time
    aveLam = mean(abs(swLam),1);
    [srtALam, idxLam] = sort(aveLam);
    srtRLam = rngLam(idxLam);
    
    rangeTol = params.Comp.criticalFlux/10; %tolerance for range of lambda
    % this is so we exclude junctions which do not change during simulation
    
    minIdx = find(srtRLam >= rangeTol, 1);
    maxIdx = E;
    
    if numJnLy == 1
        jnList = round(maxIdx - minIdx)/2;
    elseif numJnLy == 2
        jnList = idxLam([minIdx, maxIdx]);
    else
        jnList = idxLam(round(linspace(minIdx, maxIdx, numJnLy)));
    end
    
    params.SimOpt.unpertFilState = swLam;
    clear('swLam');
    gij = zeros(NumTSteps, numJnLy);
    
    disp(strcat('Running junction Lyapunov for junction(s): ', num2str(jnList)))

        %% Run perturbed simulations or import
    if useParFor > 0
        delete(gcp('nocreate'))
        pool=parpool(useParFor);
        parfor i = 1:numJnLy
            p = params;
            jidx = jnList(i);            
            p.Comp.filamentState = initLamda + id(:,jidx);
            p.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(jidx,'%04.f'));
            p.misc.perturbID     = jidx;
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
    else
        for i =  1:numJnLy
            jidx = jnList(i);
            params.Comp.filamentState = initLamda + id(:,i);
            params.SimOpt.nameComment = strcat('_eps', num2str(eps), '_i', num2str(i,'%04.f'));
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

    end
    
    
   %% Calculate lyapunov and save
    skipFraction = 0.2; %Skip for calculating mean
    numTStep = round(params.SimOpt.T/ params.SimOpt.dt*(1-skipFraction));
    numT = round(params.SimOpt.T * params.Stim.Frequency*(1-skipFraction));
%     lambda = zeros(E,1);
    lij    = zeros(numT, numJnLy);
%     netC   = zeros(numTStep, numJnLy);
    gij1   = gij(round(skipFraction*numT)+1:end,:);


    if useParFor == true		
        parfor j = 1:numT
            lij(j,:) = mean(gij1(1:floor(numTStep/numT)*j,:));
        end
    else
        for j = 1:numT
            lij(j,:) = mean(gij1(1:floor(numTStep/numT)*j,:));
        end
    end


    li = lij(end,:);
    ml = mean(li);

    hdfFile = strcat(params.SimOpt.saveFolder, '/LyCalc.h5');
    %delete(hdfFile)
    if ~exist(hdfFile, 'file')
        h5create(hdfFile,'/lij', size(lij)) 
        h5create(hdfFile,'/gij', size(gij))
    end

    h5write(hdfFile, '/lij', lij)
    h5write(hdfFile, '/gij',  gij)                 

    save(strcat(params.SimOpt.saveFolder, '/LyCalc.mat'), 'hdfFile', 'ml', 'li');
    if useParFor > 0
        delete(pool);
    end
    
    
    
    
end


