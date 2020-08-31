function [ conductance ] = joelConductance(Components, compType, swLambda, swV)

    Components.offConductance = Components.offR;
    Components.criticalFlux  = Components.critFlux;
    Components.onConductance  = Components.onG(1)*ones(size(swLambda));
    Components.OnOrOff       = ones(size(swLambda)); 
    Components.identity      = ones(size(swLambda)); 
    Components.conductance    = zeros(size(swLambda)); 
    Components.type          = compType;
    Components.voltage       = swV;
    
    
    
    %Get switch conductances
    compPtr = ComponentsPtr(Components);
    compPtr.comp.filamentState = swLambda;
    [~, conductance] = updateComponentConductance(compPtr);
    
end