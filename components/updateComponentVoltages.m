function sol = updateComponentVoltages(compPtr, edgeList, electrodes, Signals, LHS, RHS, ii, V, E, numOfElectrodes)
%Updates voltages for components in Ruomin's version of the code


        componentConductance = compPtr.comp.resistance;
        
        % Get LHS (matrix) and RHS (vector) of equation:
        Gmat = zeros(V,V);
        
%          Gmat(edgeList(:,1),edgeList(:,2)) = componentConductance;
%          Gmat(edgeList(:,2),edgeList(:,1)) = componentConductance;
        
        for i = 1:E
            Gmat(edgeList(i,1),edgeList(i,2)) = componentConductance(i);
            Gmat(edgeList(i,2),edgeList(i,1)) = componentConductance(i);
        end
        
        Gmat = diag(sum(Gmat, 1)) - Gmat;
        
        
        
        %LHS          = LHSinit;
        
        LHS(1:V,1:V) = Gmat;
        
        for i = 1:numOfElectrodes
            this_elec           = electrodes(i);
            LHS(V+i,this_elec)  = 1;
            LHS(this_elec,V+i)  = 1;
            RHS(V+i)            = Signals{i,1}(ii);
        end
        
        
        
        
        % Solve equation:
        sol = LHS\RHS;

        tempWireV = sol(1:V);
        compPtr.comp.voltage = tempWireV(edgeList(:,1)) - tempWireV(edgeList(:,2));



end