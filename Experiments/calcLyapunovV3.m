function li = calcLyapunovV3(useParFor, Folder, Attractor)
    
    %{
        swV = h5read('t2_T1000_ACsaw2V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p1_unperturbed.h5', '/swV');
        figure;plot(abs(swV(1,:)),li,'x');
        gij = h5read('LyCalc.h5', '/gij');
        load('t2_T1000_ACsaw2V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p1_unperturbed.mat');
        figure; subplot(2,1,1); plot(sim.Stim.Signal, sum(gij,2)); subplot(2,1,2); plot(sim.Stim.Signal, sim.netI);

        This guy starts on an attractor states. Then the Maximal Lyapunov
        Exponent is calculated

     %}
	

	%runCalc = 1 => runs sim,   runCalc = 0 => analyse sim, runCalc = 2 => gets mean data

    
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

	%params.SimOpt.saveFolder      = '/import/silo2/joelh/Chaos/Lyapunov';
	params.SimOpt.dt               = 1e-3;
	params.SimOpt.nameComment      = '';
    params.SimOpt.saveFolder       = strcat('/import/silo2/joelh/Chaos/Lyapunov/NewLyapunov1/', Attractor, '/');
    mkdir(params.SimOpt.saveFolder)

	%Set Stimulus
    E = 261;
    
    sim = multiImport(struct('importByName', strcat(Folder, '/', Attractor)));
    params.Stim.BiasType = sim{1}.Stim.BiasType;
    params.Stim.Amplitude = sim{1}.Stim.Amplitude;    
    params.Stim.Frequency = sim{1}.Stim.Frequency;   
    params.Comp.setVoltage = sim{1}.Comp.setV;
    params.Comp.resetVoltage = sim{1}.Comp.resetV;
    params.Comp.criticalFlux = sim{1}.Comp.critFlux;
    params.Comp.maxFlux = sim{1}.Comp.maxFlux;
    params.Comp.boost = sim{1}.Comp.boost;
    params.Comp.penalty = sim{1}.Comp.pen;

    params.Comp.ComponentType = 'tunnelSwitch2';
	params.SimOpt.T                = 100/params.Stim.Frequency;

    swLam = h5read(strcat(Folder, '/', Attractor, '.h5'), '/swLam');
    
    
	initLamda                  = swLam(end,:)';
	eps                        = 1e-6;%1e-5; %1e-5 / 1e-6 / 1e-7 / 1
    clear('swLam', 'sim')

    %% Run unperturbed simulation
    files = dir(strcat(params.SimOpt.saveFolder, '/*unperturbed.mat'));
    if numel(files)
        params.importByName = files(1).name;
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

    
    %% Initialise perturbed simulations
    params.SimOpt.lyapunovSim     = true;
    params.SimOpt.LyEps           = eps;    
    params.misc.LyEps             = eps;
    params.SimOpt.saveSwitches    = false;
    params.SimOpt.hdfSave         = false;
	id                            = eye(E)*eps; %identity matrix
    params.importSwitch           = false; %so we don't worry about single switch details
    params.SimOpt.NodalAnal       = false;

    gij = zeros(NumTSteps, E);
    
        %% Run perturbed simulations or import
    if useParFor > 0
        delete(gcp('nocreate'))
        pool=parpool(useParFor);
        parfor i = 1:E
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
    else
        for i = 1:E
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

    end
    
    
    
    %% Calculate lyapunov and save
    skipFraction = 0.0; %Skip for calculating mean
    numTStep = round(params.SimOpt.T/ params.SimOpt.dt*(1-skipFraction));
    numT = round(params.SimOpt.T * params.Stim.Frequency*(1-skipFraction));
    lambda = zeros(E,1);
    lij    = zeros(numT, E);
    netC   = zeros(numTStep, E);
    gij1   = gij(round(skipFraction*numT)+1:end,:);

    
    if useParFor == true		
        parfor j = 1:numT
            lij(j,:) = mean(gij1(1:round(numTStep/numT)*j,:));
        end
    else
        for j = 1:numT
            lij(j,:) = mean(gij1(1:round(numTStep/numT)*j,:));
        end
    end
    

    li = lij(end,:);
    ml = mean(li);
    
    hdfFile = strcat(params.SimOpt.saveFolder, '/LyCalc.h5');
    
    if ~exist(hdfFile, 'file')
        h5create(hdfFile,'/lij', size(lij)) 
        h5create(hdfFile,'/gij', size(gij))
    end

    h5write(hdfFile, '/lij', lij)
    h5write(hdfFile, '/gij',  gij)                 
    
    save(strcat(params.SimOpt.saveFolder, '/LyCalc.mat'), 'hdfFile', 'ml', 'params', 'li');

    
        
    %% Ideally I won't save the states on a regular Lyapunov test to save memory
    
    
    if useParFor == true
		delete(pool);
    end


end
