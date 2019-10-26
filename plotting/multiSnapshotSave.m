function multiSnapshotSave(sims, idx, Connectivity, Components, Contacts, saveFolder)
%inputs:
%   sims: cell array of simulation files as imported from importSim
%   idx: is the array of the timeStep at which to evaluate the snapshot at
%   Connectivity: Connectivity as output by getConnectivity
%   Contacts
%   saveFolder: folder to save snapshots in. If doesn't exist this function
%       will create this folder
%
%
% This function saves snapshots to a folder

    for j = 1:numel(sims) 

        sim = sims{j};
        i = idx(j); %10000
        
        swVolt                = sim.swV(i,:)';
        swLambda              = sim.swLam(i,:)';   
        swCon                 = sim.swC(i,:)';
        netV                  = sim.Stim.Signal(i);
        netC                  = sim.netC(i);

        timestamp             = i*sim.dt;

        whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', true, 'Nanowires', true, 'Lambda', true, 'Labels',false);
        axesLimits            = struct('LambdaCbar',[0; 0.15], 'CurrentArrowScaling',0.1);

        snapshot = generateSnapshotFromData(swVolt, swLambda, swCon, Components.critFlux, netV, netC, timestamp);
        snapshotToFigure(snapshot, Contacts, Connectivity, whatToPlot, axesLimits);

        set(gcf, 'InvertHardcopy', 'off')

        mkdir(strcat(saveFolder,'/analysis/snapshots'));
        fname = strcat(saveFolder,'/analysis/snapshots/eq_V',sprintf('%0.6e',sim.Stim.Amplitude) ,'.png');
        saveas(gcf, fname)
        
        if exist(fname, 'file') ==1
            'did not save'
            break;
        end 
        close all
    end    



end