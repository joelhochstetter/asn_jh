function [ resistance ] = joelResistance(Components, compType, lambda)
    numEdges = numel(lambda) - 1;
    Components.ComponentType = compType;
    Components = initializeComponents(numEdges,Components);
    %Get switch resistances
    compPtr = ComponentsPtr(Components);
    compPtr.comp.filamentState = swLambda;
    [~, resistance] = updateComponentResistance(compPtr);
end

