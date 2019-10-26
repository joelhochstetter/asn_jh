function perturbationAnalysis(folder)
%{
    Networks are classified into sub-crit, crit and super

    We want to classify perturbations in terms of positive and negative
    depending on what it does to the sign of |lambda|

    Consider perturbation of each switch along current path. 

    And switches of increasing periphery. Periphery defined by V_i/V_sig

    Analyse how perturbation propagates in the network

%}

%{

    EDIT: Whether is a positive or negative perturbation



%}
%end

%folder = '/import/silo2/joelh/Criticality/perturbation/100nwn/sub/run2';
%folder = '/import/silo2/joelh/Criticality/perturbation/100nwn/crit/run2';
%folder = '/import/silo2/joelh/Criticality/perturbation/100nwn/sub/run2';
cd(folder);

%% Get snapshot of unperturbed
params = struct();
params.SimOpt.saveFolder = 'switch0';
params.importAll = true;
s0 = multiImport(params);

for i = 1:numel(s0)
    
    s0{i} = spliceData(s0{i}, 1e-4, 1e-3);
    
    sim = s0{i};
    
    
    Connectivity          = struct('filename', s0{1}.ConnectFile);
    Connectivity          = getConnectivity(Connectivity);
    adjMat                = Connectivity.weights;
    contacts              = s0{1}.ContactNodes;
    sp  = kShortestPath(adjMat, contacts(1), contacts(2), 1);%contacts(2), 1);
    spE = getPathEdges(sp{1}, Connectivity.EdgeList);


    whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
    axesLimits            = struct('LambdaCbar',[min(min(abs(sim.swLam))); max(max(abs(sim.swLam)))], 'CurrentArrowScaling',10);
    snapshot = generateSnapshotFromData(sim.swV(i,:)', sim.swLam(i,:)', sim.swC(i,:)',  sim.Comp.critFlux, sim.Stim.Signal(i), sim.netC(i), i*sim.dt);
    snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], []);
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf,strcat(params.SimOpt.saveFolder, '/Lambda_unpert_', num2str(s0{i}.netC(1)), '.png'));


    whatToPlot            = struct('Dissipation',  false, 'VDrop',  true, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', false, 'Labels',false, 'Currents', false);
    snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], []);
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf,strcat(params.SimOpt.saveFolder, '/VDrop_unpert_', num2str(s0{i}.netC(1)), '.png'));

end


%% Get all the plots

files = dir('switch*');

ddlThresh = 1e-16;

    for i = 1:numel(files)
        %Only for other switches

        if strcmp(files(i).name, 'switch0')
            continue
        end

              
        
        %Determine which switch is perturbed
        pts = str2num(erase(files(i).name, 'switch'));

        params = struct();
        params.SimOpt.saveFolder = files(i).name;
        params.importAll = true;
        t = multiImport(params);

        for j = 1:numel(t) 
            t{j} = spliceData(t{j}, 1e-4, 1e-3); 
            sim = t{j};
         
            unPtIdx = 1;
            %Determine which simulation 
            while sum(abs(sim.swLam(1,:) - s0{unPtIdx}.swLam(1,:)) > 1e-7) > 1
                unPtIdx = unPtIdx + 1;
                if unPtIdx > numel(s0)
                    unPtIdx = ceil(j/2);
                    break;
                end
            end
            
            
            %Determine whether perturbation is positive of negative
            if (sign(s0{unPtIdx}.swLam(1,pts)) == (sign(sim.swLam(1,pts) - s0{unPtIdx}.swLam(1,pts)))) || (sim.swLam(1,pts) == s0{unPtIdx}.swLam(1,pts))
                posOrNeg = 'pos';
            else
                posOrNeg = 'neg';
            end
            
            mkdir(strcat(params.SimOpt.saveFolder , '/', posOrNeg));
            
                
            %Determine equilibriation time (eqt)
            %Defined by sum of lambda differences is less than threshold
            %between timesteps

            dl = sum(abs(sim.swLam(2:end,:) - sim.swLam(1:end - 1,:)), 2);
            ddl = dl(2:end) - dl(1:end -1);        
            eqt = numel(sim.netC);%find(ddl < ddlThresh, 1);


            %% Get snapshot of perturbed with perturbed switch highlighted
            ii = 1;
            whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
            axesLimits            = struct('LambdaCbar',[min(min(abs(sim.swLam))); max(max(abs(sim.swLam)))], 'CurrentArrowScaling',10);
            snapshot = generateSnapshotFromData(sim.swV(ii,:)', sim.swLam(ii,:)', sim.swC(ii,:)',  sim.Comp.critFlux, sim.Stim.Signal(ii), sim.netC(ii), ii*sim.dt);
            snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/', posOrNeg,'_t0_Lambda_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            whatToPlot            = struct('Dissipation',  false, 'VDrop',  true, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', false, 'Labels',false, 'Currents', false);
            snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/', posOrNeg,'_t0_VDrop_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            ii = numel(sim.netC);
            whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
            snapshot = generateSnapshotFromData(sim.swV(ii,:)', sim.swLam(ii,:)', sim.swC(ii,:)',  sim.Comp.critFlux, sim.Stim.Signal(ii), sim.netC(ii), ii*sim.dt);
            snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/', posOrNeg,'_te_Lambda_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            whatToPlot            = struct('Dissipation',  false, 'VDrop',  true, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', false, 'Labels',false, 'Currents', false);
            snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/', posOrNeg,'_te_VDrop_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));        


            %% Differential with the equilibrium value
            sd = sim;
            sd.netC = s0{unPtIdx}.netC ./ sim.netC;
            sd.init = s0{unPtIdx}.netC(1);
            sd.swC  = s0{unPtIdx}.swC ./ sim.swC;
            sd.swLam= s0{unPtIdx}.swLam - sim.swLam;
            sd.swV  = s0{unPtIdx}.swV - sim.swV;  

            % Get snapshot of perturbed with perturbed switch highlighted
            ii = 1;
            whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
            axesLimits            = struct('LambdaCbar',[min(min(abs(sd.swLam))); max(max(abs(sd.swLam)))], 'CurrentArrowScaling',10);
            snapshot = generateSnapshotFromData(sd.swV(ii,:)', sd.swLam(ii,:)', sd.swC(ii,:)',  sd.Comp.critFlux, sd.Stim.Signal(ii), sd.netC(ii), ii*sd.dt);
            snapshotToFigure(snapshot, sd.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/d', posOrNeg,'_t0_Lambda_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            whatToPlot            = struct('Dissipation',  false, 'VDrop',  true, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', false, 'Labels',false, 'Currents', false);
            snapshotToFigure(snapshot, sd.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/d', posOrNeg,'_t0_VDrop_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            ii = numel(sd.netC);
            whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
            snapshot = generateSnapshotFromData(sd.swV(ii,:)', sd.swLam(ii,:)', sd.swC(ii,:)',  sd.Comp.critFlux, sd.Stim.Signal(ii), sd.netC(ii), ii*sd.dt);
            snapshotToFigure(snapshot, sd.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/d', posOrNeg,'_te_Lambda_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));


            whatToPlot            = struct('Dissipation',  false, 'VDrop',  true, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', false, 'Labels',false, 'Currents', false);
            snapshotToFigure(snapshot, sd.ContactNodes, Connectivity, whatToPlot, axesLimits, [], pts);
            set(gcf, 'InvertHardcopy', 'off')
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/d', posOrNeg,'_te_VDrop_',files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));         

            %% Compare network conductance with unperturbed
            multiPlotConductance(s0{unPtIdx}.Stim.TimeAxis, {s0{unPtIdx}, sim})
            legend('Unpert', 'pert');
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/conCompare', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));  




            %% Main current path
            timeSeriesLVC(sim, spE, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/CPath', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));          

            %plot the difference
            timeSeriesLVC(sd, spE, sim.dt*eqt)

            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/dCPath', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));          

            %3D Plot
            figure;
            mesh(sim.Stim.TimeAxis, 1:numel(spE), abs(sim.swV(:,spE))');ylabel('Distance from source');xlabel('Time (s)');zlabel('Junction voltage (V)');colorbar;
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/dCPath', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png')); 
            close all;


            %% Switches adjacent
            %Get adjacent nodes

            nds = horzcat(find(Connectivity.EdgeList(1, pts) == Connectivity.EdgeList(1,:)),find(Connectivity.EdgeList(1, pts) == Connectivity.EdgeList(2,:)));
            timeSeriesLVC(sim, nds, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/nds', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));          

            %plot the difference
            timeSeriesLVC(sd, nds, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/dnds', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));            



            %% Path to peripheral nodes in the network
            sp  = kShortestPath(adjMat, Connectivity.EdgeList(1, pts), 47, 1);%contacts(2), 1);
            spE47 = getPathEdges(sp{1}, Connectivity.EdgeList);

            %nodes 83 and 47 are considered peripheral nodes
            timeSeriesLVC(sim, spE47, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/Path47', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));          

            %plot the difference
            timeSeriesLVC(sd, spE47, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/dCPath47', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));     

            sp  = kShortestPath(adjMat, Connectivity.EdgeList(1, pts), 83, 1);%contacts(2), 1);
            spE83 = getPathEdges(sp{1}, Connectivity.EdgeList);

            %nodes 83 and 47 are considered peripheral nodes
            timeSeriesLVC(sim, spE83, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/Path83', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));          

            %plot the difference
            timeSeriesLVC(sd, spE83, sim.dt*eqt)
            xlim([0,sim.dt*eqt])
            saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/dCPath83', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png'));   



            %% Smallest loop plot


            %Plot the difference

            
           %% Phase space plots for each switch along current path      
           jnPhasePlot(sim, spE, [0, sim.dt*eqt], 0)
           saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/jnphasePthCol', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png')); 

          jnPhasePlot(sim, spE, [0, sim.dt*eqt], 1)
           saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/jnphasePthQuiv', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png')); 


           %% Phase space plots for adjacent nodes

           jnPhasePlot(sim, nds, [0, sim.dt*eqt], 0)
           saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/jnphaseAdjCol', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png')); 

          jnPhasePlot(sim, nds, [0, sim.dt*eqt], 1)
           saveas(gcf,strcat(params.SimOpt.saveFolder , '/', posOrNeg , '/jnphaseAdjQuiv', posOrNeg,files(i).name, '_', num2str(s0{unPtIdx}.netC(1)), '.png')); 

           close all;
        end

    end    
    
    
end



