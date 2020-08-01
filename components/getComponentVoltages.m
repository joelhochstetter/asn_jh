function voltages = getComponentVoltages(componentConductance, edgeList, electrodes, Signals, ii, V, E, numOfElectrodes)
%Updates voltages for conductance at a given time point given

    LHS =  zeros(V+numOfElectrodes, V+numOfElectrodes);
    RHS = zeros(V+numOfElectrodes,1);

    % Get LHS (matrix) and RHS (vector) of equation:
    Gmat = zeros(V,V);

    for i = 1:E
        Gmat(edgeList(1,i),edgeList(2,i)) = componentConductance(i);
        Gmat(edgeList(2,i),edgeList(1,i)) = componentConductance(i);
    end

    Gmat = diag(sum(Gmat, 1)) - Gmat;

    LHS(1:V,1:V) = Gmat;

    for i = 1:numOfElectrodes
        this_elec           = electrodes(i);
        LHS(V+i,this_elec)  = 1;
        LHS(this_elec,V+i)  = 1;
        RHS(V+i)            = Signals{i}(ii);
    end

    % Solve equation:
    sol = LHS\RHS;

    tempWireV = sol(1:V);
    voltages = tempWireV(edgeList(1,:)) - tempWireV(edgeList(2,:)); %junction voltage

end