function [filename] = saveSim(Stimulus,SimulationOptions,Output,Components, Connectivity)
    %saves dataset to a file as a struct
    %assumes that component parameters are the same at all switches

    sim.Stim = Stimulus;
    %sim.Stim = rmfield(sim.Stim,'TimeAxis'); %does not same timevector as this would be double stored
    sim.netI = Output.networkCurrent;
    sim.netC = Output.networkResistance;
    
    switch(Components.ComponentType)
        case 'atomicSwitch' 
            swType = 'a'; 
        case 'memristor'
            swType = 'm';
        case 'tunnelSwitch'
            swType = 't';
        case 'quantCSwitch'
            swType = 'q';
        case 'tunnelSwitch2'
            swType = 't2';            
    end
    
    sim.T = SimulationOptions.T;
    sim.dt = SimulationOptions.dt;
    sim.seed = SimulationOptions.seed;
    if strcmp(Connectivity.WhichMatrix, 'nanoWires')
        sim.ConnectFile = Connectivity.filename;
    else
        sim.adjMat = Connectivity.weights;
    end
    
    %Save maximal Lyapunov exponent
    if isfield(Output, 'LyapunovMax')
        sim.LyapunovMax = Output.LyapunovMax;
    end
        

    sim.ContactNodes = SimulationOptions.ContactNodes;
    sim.Comp.setV = Components.setVoltage(1);
    sim.Comp.resetV = Components.resetVoltage(1);
    sim.Comp.pen = Components.penalty;
    sim.Comp.boost = Components.boost;
    sim.Comp.critFlux = Components.criticalFlux(1);
    sim.Comp.maxFlux = Components.maxFlux(1);
    sim.Comp.onR = Components.onResistance(1);
    sim.Comp.offR = Components.offResistance(1);
    sim.Comp.swType = swType;
    
    %Save extra parameters if need be
    if isfield(SimulationOptions, 'misc')
        sim.misc = SimulationOptions.misc;
    end
    
%     filename =  strcat(SimulationOptions.saveFolder, '/', swType,'_T',num2str(sim.T),'_',sim.Stim.stimName,'_s', ...
%         num2str(sim.Comp.setV,3), '_r', num2str(sim.Comp.resetV,3),'_c', ...
%         num2str(sim.Comp.critFlux,3), '_m', num2str(sim.Comp.maxFlux,3), '_b', ...
%         num2str(sim.Comp.boost,3),'_p',num2str(sim.Comp.pen,3),SimulationOptions.nameComment);
    
    
    filename =  strcat(SimulationOptions.saveFolder, '/', swType,'_T',num2str(sim.T),'_',sim.Stim.stimName,'_s', ...
    num2str(sim.Comp.setV,3), '_r', num2str(sim.Comp.resetV,3),'_c', ...
    num2str(sim.Comp.critFlux,3), '_m', num2str(sim.Comp.maxFlux,3), '_b', ...
    num2str(sim.Comp.boost,3),'_p',num2str(sim.Comp.pen,3),SimulationOptions.nameComment);
    

    %check if the filename exists already and updates the name 
    if exist(strcat(filename,'.mat'), 'file') 
        num = 1;
        while exist(strcat(filename, '_#', num2str(num), '.mat'), 'file') > 0
            %filename = strcat(filename, num2str(num));
            num = num + 1;
        end
        filename = strcat(filename, '_#', num2str(num));
    end 
    
    if isfield(Output, 'EndTime')
    	sim.EndTime = Output.EndTime;
    end
    
    
    if isfield(Output, 'MaxG')
        sim.MaxG    = Output.MaxG;
    end
    
    %Save switches unless specified not to
    if ~isfield(SimulationOptions, 'saveSwitches') || (isfield(SimulationOptions, 'saveSwitches') && SimulationOptions.saveSwitches)
        if isfield(SimulationOptions, 'hdfSave') && SimulationOptions.hdfSave
            sim.hdfFile = strcat(filename, '.h5');
            
            %https://au.mathworks.com/help/matlab/ref/h5write.html
            %https://au.mathworks.com/help/matlab/ref/h5create.html
            
            if ~exist(sim.hdfFile, 'file')
                h5create(sim.hdfFile,'/swLam', size(Output.lambda)) 
                h5create(sim.hdfFile,'/swV', size(Output.storevoltage))
                h5create(sim.hdfFile,'/swC', size(Output.storeCon))
            end
            

            h5write(sim.hdfFile, '/swLam', Output.lambda)
            h5write(sim.hdfFile, '/swV', Output.storevoltage)        
            h5write(sim.hdfFile, '/swC', Output.storeCon)            
            
        else
            sim.swLam = Output.lambda;
            sim.swV   = Output.storevoltage;
            sim.swC   = Output.storeCon;    
        end
    else
        sim.finalStates = Output.lambda(end,:);
    end    

    sim.filename = filename;
    
    filename = strcat(filename,'.mat');        
    save(filename ,'sim');
    
    
    
end
