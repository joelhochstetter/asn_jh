function [local_lambda, local_voltage] = updateComponentState(compPtr, dt)
%function updateComponentState(compPtr, dt) % ZK: replaced above for
%retreival of local values
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
    
    fuseCurrent = 5e-5;
    fuseVoltage = 0.5;
    fusePower   = 2.5e-5;
    
    if ~compPtr.comp.nonpolar
        if compPtr.comp.unipolar
                compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                     (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                     (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) * dt ...
                     + (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                     (abs(compPtr.comp.voltage) - compPtr.comp.resetVoltage) * dt ...
                     * compPtr.comp.boost;

                %If lambda < 0 set to 0
                compPtr.comp.filamentState(compPtr.comp.filamentState < 0) = 0;       

                %If lambda > lambda max set to lambdamax
                compPtr.comp.filamentState(compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);
                
                %
                %current = abs(compPtr.comp.voltage).* compPtr.comp.resistance;
                %compPtr.comp.filamentState(current >= fuseCurrent) = compPtr.comp.filamentState(current >= fuseCurrent)/1.1;
                %compPtr.comp.filamentState(abs(compPtr.comp.voltage) >= fuseVoltage) =  compPtr.comp.filamentState(abs(compPtr.comp.voltage) >= fuseVoltage)/1.1;
                power = abs(compPtr.comp.voltage).^2 .* compPtr.comp.resistance;
                compPtr.comp.filamentState(power >= fusePower) = compPtr.comp.filamentState(power >= fusePower)/1.1;
                
                % local values:
                local_lambda = compPtr.comp.filamentState;
                local_voltage = compPtr.comp.voltage;
            return
        end
            
        switch compPtr.comp.type
            case 'memristor'
                compPtr.comp.charge = compPtr.comp.charge + ...
                                      (compPtr.comp.voltage.*compPtr.comp.resistance) ...
                                      *dt;
                local_lambda = compPtr.comp.filamentState; % ZK

            case {'atomicSwitch', 'tunnelSwitch', 'tunnelSwitch2', 'tunnelSwitchL', 'linearSwitch'}
    % 
                wasOpen = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;
    %             
    %             % compPtr.comp that have voltage bigger than setVoltage 
    %             % experience  polarity-dependent cation migration (filament can
    %             % either grow or shrink). The rate of change is determined by
    %             % the difference V-setV.
    %             compPtr.comp.filamentState = compPtr.comp.filamentState + ...
    %                                          (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
    %                                          (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) .* ...
    %                                          sign(compPtr.comp.voltage) ...
    %                                          * dt;
    %             
    %             % compPtr.comp that have voltage smaller than resetVoltage
    %             % experience polarity-independent filament dissolution
    %             % (filaments always shrink). The rate of change is determined 
    %             % by the difference resetV-V.
    %             compPtr.comp.filamentState = compPtr.comp.filamentState - ...
    %                                          (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
    %                                          (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
    %                                          sign(compPtr.comp.filamentState) ...
    %                                          * dt * compPtr.comp.boost;
    %                                    
    %             % maxFlux is an upper limit on filamentState:
    %             compPtr.comp.filamentState (compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);
    %             compPtr.comp.filamentState (compPtr.comp.filamentState < -compPtr.comp.maxFlux) = -compPtr.comp.maxFlux(compPtr.comp.filamentState < -compPtr.comp.maxFlux);

                compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                                             (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                                             (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) .* ...
                                             sign(compPtr.comp.voltage) ...
                                             * dt;
                reset = (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                            (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
                                            sign(compPtr.comp.filamentState) * dt * compPtr.comp.boost;
               %Reset to 0
               resetTo0 = reset >= abs(compPtr.comp.filamentState);
               compPtr.comp.filamentState = compPtr.comp.filamentState - reset;
               compPtr.comp.filamentState(resetTo0) = 0;

               % Filaments that have just disconnected suffer a blow:
               justClosed = wasOpen & (abs(compPtr.comp.filamentState) < compPtr.comp.criticalFlux);

               compPtr.comp.filamentState(justClosed) = compPtr.comp.filamentState(justClosed) / compPtr.comp.penalty(1);

               compPtr.comp.filamentState (compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);
               compPtr.comp.filamentState (compPtr.comp.filamentState < -compPtr.comp.maxFlux) = -compPtr.comp.maxFlux(compPtr.comp.filamentState < -compPtr.comp.maxFlux);


                % local values:
                local_lambda = compPtr.comp.filamentState;
                local_voltage = compPtr.comp.voltage;

            case {'quantCSwitch', 'hybridSwitch'}
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

                compPtr.comp.filamentState = compPtr.comp.filamentState - ...
                                             (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                             (compPtr.comp.resetVoltage - abs(compPtr.comp.voltage)) .* ...
                                             sign(compPtr.comp.filamentState) ...
                                             * dt .* compPtr.comp.boost;


    % 
    %             
    %                                          
    %             % Filaments that have just disconnected suffer a blow:
    %             justClosed = wasOpen & (abs(compPtr.comp.filamentState) < compPtr.comp.criticalFlux);
    %             compPtr.comp.filamentState(justClosed) = compPtr.comp.filamentState(justClosed) ./ compPtr.comp.penalty;
    %             
                % local values:
                local_lambda = compPtr.comp.filamentState;
                local_voltage = compPtr.comp.voltage;


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
        
    else
       switch compPtr.comp.type
           case {'atomicSwitch', 'tunnelSwitch', 'tunnelSwitch2', 'tunnelSwitchL', 'linearSwitch'}
                %update according to modified memristor equation
                compPtr.comp.filamentState = compPtr.comp.filamentState + ...
                                 (abs(compPtr.comp.voltage) > compPtr.comp.setVoltage) .* ...
                                 (abs(compPtr.comp.voltage) - compPtr.comp.setVoltage) * dt ...
                                 + (compPtr.comp.resetVoltage > abs(compPtr.comp.voltage)) .* ...
                                 (abs(compPtr.comp.voltage) - compPtr.comp.resetVoltage) * dt ...
                                 * compPtr.comp.boost;

                %If lambda < 0 set to 0
                compPtr.comp.filamentState(compPtr.comp.filamentState < 0) = 0;       

                %If lambda > lambda max set to lambdamax
                compPtr.comp.filamentState (compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);

                % local values:
                local_lambda = compPtr.comp.filamentState;
                local_voltage = compPtr.comp.voltage;

       end
        
    end

end