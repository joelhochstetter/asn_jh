%function resistance = updateComponentResistance(compPtr)
function [switchChange, resistance] = updateComponentResistance(compPtr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function updates the 'resistance' field of the input struct (which is 
% passed by reference).
%
% ARGUMENTS: 
% compPtr - a pointer to a struct containing the properties and current 
%           state of the electrical components of the network.
%
% OUTPUT:
% resistance - resistances of individual switches
% switchChange - true if switches change and false otherwise
%
% REQUIRES:
% none
%
% Authors:
% Ido Marcus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switchChange = true;
    switch compPtr.comp.type
        case 'memristor'
            % Relevant fields: 
                % charge - time integral over current for every component.
                % memristance properties - details of the (... _/-\_/-\ ...) shape.
                  
            % Even function of charge:
            charge = abs(compPtr.comp.charge);
            
            % Periodic function of charge:
            %charge = bsxfun(@mod, charge, Components.period);

            % Create a _/-\_ shaped memristance (each component with its own
            % specific values):
            resistance = (charge <= compPtr.comp.lowThreshold).*compPtr.comp.offResistance;

            resistance = ...
                resistance + (charge > compPtr.comp.lowThreshold & ...
                              charge <= compPtr.comp.highThreshold).* ...
                (  ...
                   compPtr.comp.offResistance + ...
                   ((compPtr.comp.onResistance-compPtr.comp.offResistance)./(compPtr.comp.highThreshold-compPtr.comp.lowThreshold)) .* ...
                   (charge-compPtr.comp.lowThreshold) ...
                );

            resistance = resistance + (charge >  compPtr.comp.highThreshold).*compPtr.comp.onResistance;

        case 'atomicSwitch'
            oldOnOff = compPtr.comp.OnOrOff;                       
            
            compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;
            compPtr.comp.OnOrOff(compPtr.comp.identity == 0) = true; 
            
            if ~sum(abs(oldOnOff - compPtr.comp.OnOrOff))
                switchChange = false;
                resistance = compPtr.comp.resistance;
                return
            end
            
            % passive elements (resistors) are always considered as "open" switches
            
            resistance = (~compPtr.comp.OnOrOff) .* compPtr.comp.offResistance;
            resistance = resistance + ...
                         ( compPtr.comp.OnOrOff) .* compPtr.comp.onResistance;
       
                     
        case 'quantCSwitch'
            oldOnOff = compPtr.comp.OnOrOff;                       
            
            compPtr.comp.OnOrOff = floor(abs(compPtr.comp.filamentState) / compPtr.comp.criticalFlux(1));
            compPtr.comp.OnOrOff(compPtr.comp.identity == 0) = true; 
            
            if ~sum(abs(oldOnOff - compPtr.comp.OnOrOff))
                switchChange = false;
                resistance = compPtr.comp.resistance;
                return
            end
            
            % passive elements (resistors) are always considered as "open" switches
            
            resistance = (~compPtr.comp.OnOrOff) .* compPtr.comp.offResistance;
            resistance = resistance + ...
                         ( compPtr.comp.OnOrOff) .* compPtr.comp.onResistance;
                   
                     
            %adding tunnel resistance
        case 'tunnelSwitch'
            V = compPtr.comp.voltage;
            phi = 2;          
            d = (compPtr.comp.criticalFlux - abs(compPtr.comp.filamentState))*30 + 0.4;
            d(d<0.4)=0.4;
            resistance = tunnelSwitch(V,d,phi,0.4,compPtr.comp.offResistance(1));
            
            if max(abs(V)) > 2.5*phi %Checks conditions for Simmons is valid
                'Results may be inaccurate'
            end    
            compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;

            
        %adding tunnel resistance
        case 'tunnelSwitch2'
            V = compPtr.comp.voltage;
            phi = 0.81;          
            d = (0.1-abs(compPtr.comp.filamentState))*50;
            d(d < 0.0) = 0.0;
            resistance = tunnelSwitch2(V, d, phi, 0.17, compPtr.comp.offResistance(1), compPtr.comp.onResistance(1));
            compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;
            
        case 'tunnelSwitchL'
            phi = 2;          
            d = (0.1-abs(compPtr.comp.filamentState))*50;
            d(d < 0.0) = 0.0;
            resistance = tunnelSwitchL(d, phi, 0.17, compPtr.comp.offResistance(1), compPtr.comp.onResistance(1));
            compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;

        case 'linearSwitch'         
            lambda = abs(compPtr.comp.filamentState);
            lambda(lambda >= compPtr.comp.criticalFlux(1)) = compPtr.comp.criticalFlux(lambda >= compPtr.comp.criticalFlux(1));
            resistance = linearSwitch(lambda, compPtr.comp.criticalFlux(1), compPtr.comp.offResistance(1), compPtr.comp.onResistance(1));
            compPtr.comp.OnOrOff = abs(compPtr.comp.filamentState) >= compPtr.comp.criticalFlux;                                    
            
            
        case 'hybridSwitch'  
            V = compPtr.comp.voltage(1:size(compPtr.comp.filamentState));
            phi = 0.8;          
            d = (0.1-abs(compPtr.comp.filamentState))*30+0.4;
            d(d<0.4)=0.4;
            resistance = tunnelSwitch(V,d,phi,0.4,compPtr.comp.offResistance(1));
            
            if max(abs(V)) > 2.5*phi %Checks conditions for Simmons is valid
                'Results may be inaccurate'
            end
            
            compPtr.comp.OnOrOff = floor(abs(compPtr.comp.filamentState) / compPtr.comp.criticalFlux(1));
            compPtr.comp.OnOrOff(compPtr.comp.identity == 0) = true; 
            
            onRes = tunnelSwitch(V,0.4,phi,0.4,compPtr.comp.offResistance(1));
            
            resistance = resistance + ...
                         ( compPtr.comp.OnOrOff) .* onRes;
                     
        case 'resistor'
                resistance = zeros(size(compPtr.comp.identity)); 
                % That's a place-holder. If resistance is not initialized, the 
                % next statement which takes care of passive elements creates a
                % row rather than a column vector.
                
        case 'nonlinearres'
                resistance =  compPtr.comp.voltage.^2+1e-7;
    end    
    
    % Components that are resistors have resistance 'onResistance',
    % regardless of anything else:
    resistance(compPtr.comp.identity == 0) = compPtr.comp.onResistance(compPtr.comp.identity == 0);
    
    % Modify the input with the updated resistance values:
    compPtr.comp.resistance = resistance;
end