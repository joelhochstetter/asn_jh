function [ s, tvec, cList ] = analyseSim(sims, field, changeVar)
    %changeVar is ther variable that has been changed between the files
    %field is either 'SimOpt', 'Comp', 'Stim' or 'Conn' 
    onL = 1e-7; %used as lower conductance crossing threshold for switch on
    onU = 1e-5; %used as upper conductance crossing threshold for switch on
    
    %The maximum number of conducting path to look for
    maxConductingPaths = 30;
    
    %Get connectivity of 1st network
    %Only reimports connectivity if a different filename is given
    Conn.WhichMatrix       = 'nanoWires';
    Conn.filename = sims{1}.ConnectFile;
    Conn = getConnectivity(Conn);
    adjMat = Conn.weights;
    SimulationOptions.ContactMode = 'farthest';
    SimulationOptions = selectContacts(Conn, SimulationOptions);
    sdDist = distances(graph(Conn.weights),SimulationOptions.ContactNodes(1),SimulationOptions.ContactNodes(2));
    edgeList = Conn.EdgeList;
    
    
    if isfield(sims{1},'Stim') == 0
        for i = 1:numel(sims)
            sims{i}.Stim = sims{i}.stimulus;
        end
    end


    switch sims{1}.Stim.BiasType
        case {'DC', 'DCandWait'}
            tvec =  sims{1}.dt:sims{1}.dt:sims{1}.T;
            tvec = tvec';
            cList           = zeros(numel(sims),1);   
            s.Max           = zeros(numel(sims),1);
            s.MaxLoc        = zeros(numel(sims),1);
            s.MaxEnd        = zeros(numel(sims),1);
            s.Min           = zeros(numel(sims),1);
            
            %Time at max position
            s.MaxTime       = zeros(numel(sims),1);
            %crossing of threshold onL and onU. First index is decreasing
            %second index is increasing
            s.onStart       = zeros(numel(sims),2);
            s.onEnd         = zeros(numel(sims),2);
            s.onStartNum    = zeros(numel(sims),2);
            s.onEndNum      = zeros(numel(sims),2);
            
            s.numSwOn       = zeros(numel(tvec),numel(sims));
            s.firstSwOn     = zeros(numel(sims),1); %1st time in sim where a switch turns on
            s.lastSwOn      = zeros(numel(sims),1); %last time in the sim with a witch on
            s.firstCPath    = zeros(numel(sims),1); %1st time in sim with a cond. path
            s.lastCPath     = zeros(numel(sims),1); %last time in simulation with a cond. path
            
            s.firstIncrease = zeros(numel(sims),1);
            s.reachMin      = zeros(numel(sims),1);            
            
            %Number of conducting paths at each time step
            s.numCPath      = zeros(numel(tvec),numel(sims));
            s.endGrad       = zeros(numel(sims),1);
            s.c             = zeros(numel(tvec),numel(sims));
            s.I             = zeros(numel(tvec),numel(sims));
            s.V             = zeros(numel(tvec),numel(sims));
            s.avLam         = zeros(numel(tvec),numel(sims));
            s.beta          = zeros(numel(sims),1);
            s.beta_0_10     = zeros(numel(sims),1);
            s.beta_100_500  = zeros(numel(sims),1);

            for i = 1:numel(sims)
                cList(i) = sims{i}.(field).(changeVar);
                c = sims{i}.netC;
                s.c(:,i) = c;
                s.I(:,i) = sims{i}.netI;
                s.V(:,i) = s.I(:,i)./s.c(:,i);
                s.avLam(:,i) = mean(abs(sims{i}.swLam),2);
                [s.Max(i), s.MaxLoc(i)] = max(c);
                s.MaxLoc(i) = tvec(s.MaxLoc(i));
                
                x = find(c==s.Max(i));
                s.MaxEnd(i) = tvec(x(end));                
                s.MaxTime(i) = range(tvec(find(c==s.Max(i)))); %#ok<FNDSB>
                
                y = tvec(find((c - c(1)) > 1e-10, 1));
                if numel(y) == 0
                    y = tvec(end);
                end
                s.firstIncrease(i) = y; 
                
                [s.Min(i) , y] = min(c(x(1):end));
                s.reachMin(i) = tvec(y + x(1) - 1);
                
                C1 = [c(1); c(1:end -1)];
                
                x = c((C1 >= onL) & (c < onL));
                s.onStart(i,1) = numel(x);
                if numel(x) == 0
                    s.onStart(i,1) = NaN;
                else
                    s.onStart(i,1) = tvec(find(c==x(1),1));
                end

                x = c((C1 < onL) & (c >= onL));
                s.onStart(i,2) = numel(x);                
                if numel(x) == 0
                    s.onStart(i,2) = NaN;
                else
                    s.onStart(i,2) = tvec(find(c==x(1),1));
                end                   
                
                x = c((C1 >= onU) & (c < onU));
                s.onEnd(i,1) = size(x,1);
                if numel(x) == 0
                    s.onEnd(i,1) = NaN;
                else
                    s.onEnd(i,1) = tvec(find(c==x(1),1));
                end

                x = c((C1 < onU) & (c >= onU));
                s.onEnd(i,2) = numel(x);                
                if numel(x) == 0
                    s.onEnd(i,2) = NaN;
                else
                    s.onEnd(i,2) = tvec(find(c==x(1),1));
                end                
                
                
                s.endGrad(i) = (c(end)-c(end-1))/sims{i}.dt;
                s.beta(i) = getBeta (tvec, c, -1, -1);
                s.beta(i) = getBeta (tvec, c, 0, 10);        
                s.beta_100_500(i) = getBeta (tvec, c, 100, 500);          
                
                
                critLam   = sims{i}.Comp.critFlux;
                onOrOff   = abs(sims{i}.swLam) >= critLam(1);
                isCurrentPath = zeros(size(sims{i}.swLam,1),1);
                
                contacts = sims{i}.ContactNodes;
                
                %Fast algorithm to find
                for j = 1:1000:size(onOrOff,1) %1:size(onOrOff,1)
                    sg               = getOnSubGraph(adjMat, edgeList, onOrOff(j,:));
                    g                = graph(sg);
                    bins             = conncomp(g);
                    isCurrentPath(j:j+999) = bins(contacts(1)) == bins(contacts(2));    
%                     if isCurrentPath(j)
%                         currentBin       = bins(contacts(1));  
%                         lieOnCurrentP(j,:) = (bins(edgeList(1,:)) == currentBin) & (bins(edgeList(2,:)) == currentBin) & onOrOff(j,:);
%                     end 
                end
                
                y = tvec(find(isCurrentPath, 1));
                if numel(y) == 0
                    y = tvec(end);
                end
                s.firstCPath(i) =y;
                x = find(isCurrentPath);
                if numel(x) == 0
                    x = tvec(end);
                end
                
                s.lastCPath(i)  = tvec(x(end)); 
                
                
                %Calculate which switchs are on at which timestep
%                 OnOrOff         = abs(sims{i}.swLam(:,1:end-1)) > sims{i}.Comp.critFlux;
%                 s.numSwOn(:,i)  = sum(OnOrOff,2); %number of switches on at a given timestep
%                 nonzero         = find(s.numSwOn(:,i)); %returns array of non-zero elements
%                 s.firstSwOn(i)  = tvec(nonzero(1)); %1st time in sim where a switch turns on
%                 s.lastSwOn(i)   = tvec(nonzero(end)); %last time in the sim with a witch on
%                 
%                 %Fast CPath formed - possibly wrong?
%                 rat = s.c(:,i) - C1;
%                 s.firstCPath(i) = tvec(find(rat == max(rat),1));     
%                 %For DC and     wait only         
%                 s.lastCPath(i) = tvec(find(rat == min(rat),1));   
                
                %{               
                if ~strcmp(Conn.filename, sims{i}.ConnectFile)
                    Conn.filename = sims{i}.ConnectFile;
                    Conn = getConnectivity(Conn);   
                    SimulationOptions.ContactMode = 'farthest';
                    SimulationOptions = selectContacts(Conn, SimulationOptions);
                    sdDist = distances(graph(Conn.weights),SimulationOptions.ContactNodes(1),SimulationOptions.ContactNodes(2));
                end
                

                if sdDist <= s.numSwOn(1,i)
                    s.numCPath(1,i) = isConductingPath(Conn, OnOrOff(1,:), sims{i}.ContactNodes);
                end                
                % Conducting path between source and drain node
                for j = 2:floor(numel(tvec))
                    %Only check if path is complete if enough switches are
                    %on and at least one switch turns off
                    if sdDist <= s.numSwOn(j,i) && sum(OnOrOff(j,:) < OnOrOff(j-1,:)) > 0 
                        s.numCPath(j,i) = isConductingPath(Conn, OnOrOff(j,:), sims{i}.ContactNodes);
                    end
                end
                nonzero         = find(s.numCPath(:,i)); %returns array of non-zero elements
                s.firstCPath(i) = tvec(nonzero(1)); %1st time in sim where a switch turns on
                s.lastCPath(i)  = tvec(nonzero(end)); %last time in the sim with a witch on
                %}
                
                %s.firstCPath    = zeros(numel(sims),1); %1st time in sim with a cond. path
                %s.lastCPath     = zeros(numel(sims),1); %last time in simulation with a cond. path         
                
                
                %Number of conducting paths at each time step
                %To add
                %s.numCPath      = zeros(numel(tvec),numel(sims));                
                %numConductingPaths(, DFA,maxConductingPaths)

            end
           
            
            if strcmp(sims{1}.Stim.BiasType, 'DCandWait') == 1
                %Area under conductance but above min possible conductance
                s.OnArea   = trapz(tvec,s.c) - min(s.c)*sims{i}.T;   
                %calculates time from first crossing onU to dropping below
                %after activation
                s.FallTime = zeros(numel(sims),1);
                s.MinLoc   = zeros(numel(sims),1);
                %Time to the minimum of the conductance after activation
                for i = 1:numel(sims)
                    x = tvec(((s.c(:,i) == min(s.c(tvec > sims{i}.Stim.OffTime,i))) & (tvec > sims{i}.Stim.OffTime)));
                    s.MinLoc(i) = x(1);
                    x = tvec(((s.c(:,i) < onU) & (tvec > sims{i}.Stim.OffTime)));                
                    %s.FallTime(i) = x(1) - s.onStart(i,2);
                end
                
            end
        case {'AC', 'ACsaw'}
            period = floor(1/sims{1}.Stim.Frequency/sims{1}.dt); %In units of timesteps
            numPer = floor(sims{1}.T*sims{1}.Stim.Frequency);
            
            tvec =  sims{1}.dt:sims{1}.dt:sims{1}.T;
            tvec = tvec';
            cList           = zeros(numel(sims),1);   
            
            %stores first crossing of threshold
            %3rd index corresponds to position
            %1 - V>0 inc, 2 - V>0 dec, 3 - V<0 inc, 4 - V<0 dec
            %Fourth  index correspond to either C (1) or I (2)
            
            s.Max           = zeros(numel(sims),numPer,4,2);
            s.MaxLoc        = zeros(numel(sims),numPer,4,2);  
            s.Min           = zeros(numel(sims),numPer,4,2);
            s.MinLoc        = zeros(numel(sims),numPer,4,2);  
            s.onStart       = zeros(numel(sims),numPer,4);
            s.onEnd         = zeros(numel(sims),numPer,4);
            s.onStartNum    = zeros(numel(sims),numPer,4);
            s.onEndNum      = zeros(numel(sims),numPer,4);
            
            s.c             = zeros(numel(tvec),numel(sims));
            s.I             = zeros(numel(tvec),numel(sims));
            s.V             = zeros(numel(tvec),numel(sims));
            s.avLam         = zeros(numel(tvec),numel(sims));
            s.beta          = zeros(numel(sims),1);
            s.beta_0_10     = zeros(numel(sims),1);
            s.beta_100_500  = zeros(numel(sims),1);
            s.posarea       = zeros(numel(sims),numPer);
            s.negarea       = zeros(numel(sims),numPer);  
            s.stability     = zeros(period, numel(sims), numPer - 1);
            V_T4 = zeros(period/4, 4); %temp storage
            I_T4 = zeros(period/4, 4); %temp storage           
            C_T4 = zeros(period/4, 4); %temp storage   
            t_T4 = sims{1}.dt*[1:period/4;(period/4+1:period/2);...
                (period/2+1):period/4*3;(period/4*3+1):period]';
            
            
        for i = 1:numel(sims)

            cList(i) = sims{i}.(field).(changeVar);
            c = sims{i}.netC;
            
            s.c(:,i) = c;
            s.I(:,i) = sims{i}.netI;
            s.V(:,i) = sims{i}.Stim.Signal;
            s.avLam(:,i) = mean(abs(sims{i}.swLam),2);
            s.beta(i) = getBeta (tvec, c, -1, -1);
            s.beta(i) = getBeta (tvec, c, 0, 10);        
            s.beta_100_500(i) = getBeta (tvec, c, 100, 500);  
            

            
            for j = 1:numPer
                x = (j-1)*period;

                %Vp = s.V{i}((x+1):(x+period/2));
                %Vn = s.V{i}((x+1+period/2):(x+period));
                for k = 1:4
                    x = (j-1)*period;
                    V_T4(:,k) = s.V((x+1+period/4*(k-1)):(x+period/4*k),i);
                    I_T4(:,k) = s.I((x+1+period/4*(k-1)):(x+period/4*k),i);
                    C_T4(:,k) = c((x+1+period/4*(k-1)):(x+period/4*k));
                    
                    s.Max(i,j,1)    = max(C_T4(:,k));
                    s.MaxLoc(i,j,1) = t_T4(find(C_T4(:,k)==s.Max(i,j,1),1),k);
                    s.Max(i,j,2)    = max(I_T4(:,k));
                    s.MaxLoc(i,j,2) = t_T4(find(I_T4(:,k)==s.Max(i,j,2),1),k);                    
 
                    s.Min(i,j,1)    = min(C_T4(:,k));
                    s.MinLoc(i,j,1) = t_T4(find(C_T4(:,k)==s.Min(i,j,1),1),k);
                    s.Min(i,j,2)    = min(I_T4(:,k));
                    s.MinLoc(i,j,2) = t_T4(find(I_T4(:,k)==s.Min(i,j,2),1),k);  

                    C1 = [0; C_T4(1:end -1,k)];
                    x = C_T4(((C1 < onL) & (C_T4(:,k) >= onL)) ...
                        | ((C1 >= onL) & (C_T4(:,k) < onL)),k);
                    
                    if numel(x) == 0
                        s.onStart(i,j,k) = NaN;
                        s.onStartNum(i,j,k) = 0;                        
                    else
                        s.onStart(i,j,k) = t_T4(find(C_T4(:,k)==x(1),1),k);
                        s.onStartNum(i,j,k) = size(x,1);                          
                    end

                    x = C_T4(((C1 < onU) & (C_T4(:,k) >= onU)) ...
                        | ((C1 >= onU) & (C_T4(:,k) < onU)),k);
                    
                    if numel(x) == 0
                        s.onEnd(i,j,k) = NaN;
                        s.onEndNum(i,j,k) = 0;                        
                    else
                        s.onEnd(i,j,k) = t_T4(find(C_T4(:,k)==x(1),1),k);
                        s.onEndNum(i,j,k) = size(x,1);                          
                    end                   
                end               
                
                s.posarea(i,j) = abs(trapz(V_T4(:,2),I_T4(:,2))) - abs((trapz(V_T4(:,1),I_T4(:,1))));
                s.negarea(i,j) = abs(trapz(V_T4(:,3),I_T4(:,3))) - abs((trapz(V_T4(:,4),I_T4(:,4))));
                
            end
            for j = 1:numPer-1
                x = (j-1)*period;
                y = j*period;
                s.stability(:,i,j) = c((y+1):(y+period))./c((x+1):(x+period));
            end
        end
    end

end