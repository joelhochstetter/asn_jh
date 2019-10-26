function [ resistance ] = joelResistance(Components, compType, swLambda, swV)

    Components.offResistance = Components.offR;
    Components.criticalFlux  = Components.critFlux;
    Components.onResistance  = Components.onR(1)*ones(size(swLambda));
    Components.OnOrOff       = ones(size(swLambda)); 
    Components.identity      = ones(size(swLambda)); 
    Components.resistance    = zeros(size(swLambda)); 
    Components.type          = compType;
    Components.voltage       = swV;
    
    
    
    %Get switch resistances
    compPtr = ComponentsPtr(Components);
    compPtr.comp.filamentState = swLambda;
    [~, resistance] = updateComponentResistance(compPtr);
    
end