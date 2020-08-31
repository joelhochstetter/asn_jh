function [netC2, netC1, dV, Con1, Con2, V1, V2] = switchFlip(flip, getSnap, drain, VDC, OnOrOff)
    %random Switch flip
    
    %% inputs
    % Input Voltage
    % Initial switch configurations as filament states %This shouldn't matter
    % provided we have the on and off states
    % Network



    %filament states
    %flip = 1;
%     E = 261;
    E = 11469;
    
    if nargin < 5
        OnOrOff = false(E,1);
    end
    if nargin < 4
        VDC = 1.0;
    end

    %Voltage
    V = VDC;    
    
    OnOrOff1 = OnOrOff;
    OnOrOff2 = OnOrOff;
    OnOrOff2(flip) = not(OnOrOff2(flip));
    OnC  = 1.0e-4;
    OffC = 1e-7;


    %Connectivity
    Connectivity.filename = '2016-09-08-153543_asn_nw_02048_nj_11469_seed_042_avl_28.00_disp_10.00.mat'; %100nw
    %Connectivity.filename = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat'; %100nw
    if drain < 0
        drain = 30; %corresponding junction is 131
    end
    
    contacts = [73, drain];

    %% simulation
    Connectivity.WhichMatrix       = 'nanoWires';    % 'nanoWires' \ 'randAdjMat'
    Connectivity = getConnectivity(Connectivity);
    V               = Connectivity.NumberOfNodes;
    edgeList        = Connectivity.EdgeList.';
    
    SimulationOptions.ContactMode  = 'preSet';    % 'farthest' \ 'specifiedDistance' \ 'random' (the only one relevant for 'randAdjMat' (no spatial meaning)) \ 'preSet'
    SimulationOptions.ContactNodes = [73, drain]; % only really required for preSet, other modes will overwrite this
    SimulationOptions = selectContacts(Connectivity, SimulationOptions);
    
    Con1 = (OnC-OffC)*OnOrOff1 + OffC;
    Con2 = (OnC-OffC)*OnOrOff2 + OffC;
    numOfElectrodes = 2;
    RHS             = zeros(V+numOfElectrodes,1); % the first E entries in the RHS vector.
    LHSinit         = zeros(V+numOfElectrodes, V+numOfElectrodes);
    Gmat = zeros(V,V);
    netC1 = 0;
%          Gmat(edgeList(:,1),edgeList(:,2)) = componentConductance;
%          Gmat(edgeList(:,2),edgeList(:,1)) = componentConductance;

    for i = 1:E
        Gmat(edgeList(i,1),edgeList(i,2)) = Con1(i);
        Gmat(edgeList(i,2),edgeList(i,1)) = Con1(i);
    end

    Gmat = diag(sum(Gmat, 1)) - Gmat;



    LHS          = LHSinit;

    LHS(1:V,1:V) = Gmat;

    for i = 1:numOfElectrodes
        this_elec           = contacts(i);
        LHS(V+i,this_elec)  = 1;
        LHS(this_elec,V+i)  = 1;
        RHS(V+i)            = VDC;
    end

    %condition(ii) = cond(LHS);


    % Solve equation:
    sol = LHS\RHS;

    tempWireV = sol(1:V);
    V1 = tempWireV(edgeList(:,1)) - tempWireV(edgeList(:,2));

    netC2 = Con1(end)/(V / V(end) - 1);
    
    Gmat = zeros(V,V);

%          Gmat(edgeList(:,1),edgeList(:,2)) = componentConductance;
%          Gmat(edgeList(:,2),edgeList(:,1)) = componentConductance;

    for i = 1:E
        Gmat(edgeList(i,1),edgeList(i,2)) = Con2(i);
        Gmat(edgeList(i,2),edgeList(i,1)) = Con2(i);
    end

    Gmat = diag(sum(Gmat, 1)) - Gmat;



    LHS          = LHSinit;

    LHS(1:V,1:V) = Gmat;

    for i = 1:numOfElectrodes
        this_elec           = contacts(i);
        LHS(V+i,this_elec)  = 1;
        LHS(this_elec,V+i)  = 1;
        RHS(V+i)            = VDC;
    end

    %condition(ii) = cond(LHS);


    % Solve equation:
    sol = LHS\RHS;

    tempWireV = sol(1:V);
    V2 = tempWireV(edgeList(:,1)) - tempWireV(edgeList(:,2));
    
    
    dV = abs(V2) - abs(V1);

    %% Output variables
    %Voltage across each switch -> changes dlambda/dt
    %Changes to entire network conductance
    %Snapshot of the network
    if getSnap 
        snapshot = struct();
        snapshot.Timestamp = 0.0;
        snapshot.Voltage = V2;
        snapshot.dV = dV;
        snapshot.Conductance = Con2;
        snapshot.OnOrOff = OnOrOff2;
        snapshot.filamentState = zeros(E,1);
        snapshot.netV = V;
        snapshot.netC = netC2;
        snapshot.netI = netC2*V;
        axesLimits.DissipationCbar = [0,5]; % (1pW*10^0 : 1pW*10^5)
        axesLimits.CurrentArrowScaling = 0.25;
        axesLimits.VoltageCbar = [0,V];

        whatToPlot = struct(...
                            'Nanowires',    true, ...
                            'Contacts',     true, ...
                            'Dissipation',  false, ...
                            'Lambda',       false, ... #can either plot lambda or dissipation or Vdrop
                            'Currents',     true, ...
                            'Voltages',     true,  ...
                            'Labels',       false, ...
                            'VDrop',        true, ...
                            'GraphRep',     true ... 
                            );


        snapshotToFigure(snapshot, SimulationOptions.ContactNodes, Connectivity, whatToPlot, axesLimits);
        set(gcf, 'visible','on');
    end
%     dV   = dV(1:end - 1);
%     Con1 = Con1(1:end - 1);
%     Con2 = Con2(1:end - 1);
%     V1   = V1(1:end - 1); 
%     V2   = V2(1:end - 1);
end