function makeSnapshotMovie(Signal, netC, swV, swLam, swC, timeVec, contacts, Components, Connectivity, whatToPlot, axesLimits, samplingTime, tend)
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
    if nargin < 11
        samplingTime = 1;
        tend = timeVec(end);
    end

    fprintf('\nCompiling movie...\n');

    % Only Windows and MacOS >  10.7
    %v = VideoWriter('networkMovie.mp4','MPEG-4');
    
    v = VideoWriter('networkMovie','Motion JPEG AVI');

    v.FrameRate = 50;%floor(1/(timeVec(2)-timeVec(1))/10);
    v.Quality = 100;
    open(v);
    
    if isfield(Components, 'critFlux')
        critLam = Components.critFlux(1);
    elseif isfield(Components, 'criticalFlux')
        critLam = Components.criticalFlux(1);
    end
        
    for i = 1: samplingTime: length(timeVec)
        if timeVec(i) > tend
            break
        end
        progressBar(i,length(timeVec));
        swVolt                = swV(i,:)';
        swLambda              = swLam(i,:)';
        swCon = swC(i,:)';
        snapshot = generateSnapshotFromData(swVolt, swLambda, swCon, critLam,  Signal(i), netC(i), timeVec(i));
%         frameFig = snapshotToFigureThesis(snapshot, contacts, Connectivity, whatToPlot, axesLimits, [], []);
        frameFig = snapshotToFigurePaper(snapshot, contacts, Connectivity, whatToPlot, axesLimits, [], []);          
        xx = double(Connectivity.GridSize(1));
        yy = double(Connectivity.GridSize(2));
        RF = 0.06;
        ex = [0, xx, xx, 0];
        sy = yy*[1-RF, 1-RF, 1, 1];
        dy = [0, 0, yy*RF, yy*RF];
        patch(ex,sy,'g');
        patch(ex,dy,'r');
        xlim([0,xx])
        ylim([0,yy])
        axis square;
        myfig = gcf;
        myfig.InvertHardcopy = 'off'; 
        title(strcat('t = ', num2str(timeVec(i), '%.2f')))
        
        axis square;
        writeVideo(v,getframe(frameFig));
        close(frameFig);
    end
    close(v);
    fprintf('\nDone.\n');


end