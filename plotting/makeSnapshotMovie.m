function makeSnapshotMovie(Signal, netC, swV, swLam, timeVec, contacts, Components, Connectivity, whatToPlot, axesLimits)
%{
    Example usage:
        cd /import/silo2/joelh/Criticality/largeNetworks
        load('a_T10_DC2V_s0.01_r0.001_c0.1_m0.15_b10_p1.mat')
        i = 1;
        Connectivity          = struct('filename', sim.ConnectFile);
        Connectivity          = getConnectivity(Connectivity);
        Components            = sim.Comp;
        swVolt                = sim.swV(i,:)';
        swLambda              = sim.swLam(i,:)';
        netV                  = sim.Stim.Signal(i);
        netC                  = sim.netC(i);
        timestamp             = i*sim.dt;
        timeVector            = sim.dt:sim.dt:sim.T;
        contacts              = sim.ContactNodes;
        whatToPlot            = struct('Dissipation',  false, 'Lambda',  true, 'GraphRep', true);
        axesLimits            = struct('LambdaCbar',[0; max(max(sim.swLam))]);

        snapshot = generateSnapshotFromData(swVolt, swLambda, Components, netV, netC, timestamp);
        snapshotToFigure(snapshot, contacts, Connectivity, whatToPlot, axesLimits);
        set(gcf, 'visible','on')
%}


    fprintf('\nCompiling movie...\n');

    % Only Windows and MacOS >  10.7
    %v = VideoWriter('networkMovie.mp4','MPEG-4');
    
    v = VideoWriter('networkMovie','Motion JPEG AVI');

    v.FrameRate = floor(1/(timeVec(2)-timeVec(1))/10);
    v.Quality = 100;
    open(v);
    
    for i = 1 : length(timeVec)
        progressBar(i,length(timeVec));
        swVolt                = swV(i,:)';
        swLambda              = swLam(i,:)';
        snapshot = generateSnapshotFromData(swVolt, swLambda, Components, Signal(i), netC(i), timeVec(i));
        frameFig = snapshotToFigure(snapshot, contacts, Connectivity, whatToPlot, axesLimits);
        writeVideo(v,getframe(frameFig));
        close(frameFig);
    end
    close(v);
    fprintf('\nDone.\n');


end