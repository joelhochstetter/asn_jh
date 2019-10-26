function changeComponentState(compPtr, dt)
%Is like updateComponentState by no max threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function updates the state field of the input struct (which is passed
% by reference). (for example, the 'charge' fields for memristors or the
% 'filamentState' field for atomic switches.
%
% ARGUMENTS: 
% compPtr - a pointer to a struct containing the properties and current 
%           state of the electrical components of the network.
% dt - length of current timestep.
%
% OUTPUT:
% none
%
% REQUIRES:
% none
%
% Authors:
% Ido Marcus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch compPtr.comp.type
        case {'atomicSwitch', 'tunnelSwitch'}
            
            % compPtr.comp that have voltage bigger than setVoltage 
            % experience  polarity-dependent cation migration (filament can
            % either grow or shrink). The rate of change is determined by
            % the difference V-setV.
            compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                                         (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                                         (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) .* ...
                                         sign(compPtr.comp.voltage) ...
                                         * dt;
            
            % compPtr.comp that have voltage smaller than resetVoltage
            % experience polarity-independent filament dissolution
            % (filaments always shrink). The rate of change is determined 
            % by the difference resetV-V.
            
            compPtr.comp.filamentState = compPtr.comp.filamentState - ...
                                         (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                         (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
                                         sign(compPtr.comp.filamentState) ...
                                         * dt .* compPtr.comp.boost;
            % maxFlux is an upper limit on filamentState:
            
        case {'quantCSwitch', 'hybridSwitch'}
            
            % compPtr.comp that have voltage bigger than setVoltage 
            % experience  polarity-dependent cation migration (filament can
            % either grow or shrink). The rate of change is determined by
            % the difference V-setV.
            compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                                         (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                                         (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) .* ...
                                         sign(compPtr.comp.voltage) ...
                                         * dt;
            
            % compPtr.comp that have voltage smaller than resetVoltage
            % experience polarity-independent filament dissolution
            % (filaments always shrink). The rate of change is determined 
            % by the difference resetV-V.
            
            compPtr.comp.filamentState = compPtr.comp.filamentState - ...
                                         (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                         (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
                                         sign(compPtr.comp.filamentState) ...
                                         * dt .* compPtr.comp.boost;
            
                                     

           
            
            %{        
        case 'tunnelSwitch'
            wasOpen = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;
            
            % compPtr.comp that have voltage bigger than setVoltage 
            % experience  polarity-dependent cation migration (filament can
            % either grow or shrink). The rate of change is determined by
            % the difference V-setV.
            compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                                         (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                                         (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) .* ...
                                         sign(compPtr.comp.voltage) ...
                                         * dt;
            
            % compPtr.comp that have voltage smaller than resetVoltage
            % experience polarity-independent filament dissolution
            % (filaments always shrink). The rate of change is determined 
            % by the difference resetV-V.
            boost = 1; %boost when filament is recending
            compPtr.comp.filamentState = compPtr.comp.filamentState - ...
                                         (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                         (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
                                         sign(compPtr.comp.filamentState) ...
                                         * dt * boost;
                                   
            % maxFlux is an upper limit on filamentState:
            compPtr.comp.filamentState (compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);
            compPtr.comp.filamentState (compPtr.comp.filamentState < -compPtr.comp.maxFlux) = -compPtr.comp.maxFlux(compPtr.comp.filamentState < -compPtr.comp.maxFlux);
            
            % Filaments that have just disconnected suffer a blow:
            justClosed = wasOpen & (abs(compPtr.comp.filamentState) < compPtr.comp.criticalFlux);
            pen = 1; %penalty ratio for disconnection
            compPtr.comp.filamentState(justClosed) = compPtr.comp.filamentState(justClosed) / pen;
            
            % local values:
            local_lambda = compPtr.comp.filamentState;
            local_voltage = compPtr.comp.voltage;

%}
    
    end
end