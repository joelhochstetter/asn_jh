function jnV = solveKirchoff(jnCon, electrodes, edgeList, V, Vs)
    
    E = numel(jnCon);
    numOfElectrodes = numel(electrodes);
    Signals = [Vs, 0];
    RHS             = zeros(V+numOfElectrodes,1); % the first E entries in the RHS vector.
    LHSinit         = zeros(V+numOfElectrodes, V+numOfElectrodes);
    Gmat = zeros(V,V);    
    for i = 1:E
        Gmat(edgeList(1,i),edgeList(2,i)) = jnCon(i);
        Gmat(edgeList(2,i),edgeList(1,i)) = jnCon(i);
    end

    Gmat = diag(sum(Gmat, 1)) - Gmat;
    LHS          = LHSinit;
    LHS(1:V,1:V) = Gmat;


    
    for i = 1:numel(electrodes)
        this_elec           = electrodes(i);
        LHS(V+i,this_elec)  = 1;
        LHS(this_elec,V+i)  = 1;
        RHS(V+i)            = Signals(i);
    end

    % Solve equation:
    sol = LHS\RHS;

    tempWireV = sol(1:V);
    jnV = tempWireV(edgeList(1,:)) - tempWireV(edgeList(2,:));
    
end