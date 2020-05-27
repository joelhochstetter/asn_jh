function [filename, alreadyExists] = genSaveName(SimulationOptions, Components, Stimulus)
    alreadyExists  = false;
    
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
        case 'tunnelSwitchL'
            swType = 'tl';            
        case 'linearSwitch'
            swType = 'l';               
    end


    filename =  strcat(SimulationOptions.saveFolder, '/', swType,'_T',num2str(Stimulus.T),'_',Stimulus.stimName,'_s', ...
        num2str(Components.setVoltage(1),3), '_r', num2str(Components.resetVoltage(1),3),'_c', ...
        num2str(Components.criticalFlux(1),3), '_m', num2str(Components.maxFlux(1),3), '_b', ...
        num2str(Components.boost,3),'_p',num2str(Components.penalty,3),SimulationOptions.nameComment);
   
    %check if the filename exists already and updates the name 
    if exist(strcat(filename,'.mat'), 'file') 
        alreadyExists = true;
        num = 1;
        if SimulationOptions.stopIfDupName == false
            while exist(strcat(filename, '_#', num2str(num), '.mat'), 'file') > 0
                %filename = strcat(filename, num2str(num));
                num = num + 1;
            end
            
            filename = strcat(filename, '_#', num2str(num));
        end
    end 
    
end