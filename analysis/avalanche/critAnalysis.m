function results = critAnalysis(G1, dt, G, time, V, saveFolder)
%{
    Given a conductance cut-off (G1) performs the criticality analysis
    on a given conductance dataset

    Input:
        G1 (positive float): Delta G cut-off
        dt (positive float): Time bin
        G  (Nx1 vector)    : Conductance time-series
        time (Nx1 vector)  : Time vector
        V (Nx1 vector)     : Voltage time-series
        savefolder (string): Folder to save the results struct and images

    Outputs:
        results (struct): Saves the results 
%}

    results = struct();

    %% conductance
    results.netG.G = G;    %network conductance
    results.netG.t = time; %time vector
    results.netG.V = V;    %voltage
    
    
    
    %% dG
    dG        = [diff(G), 0];
    ddG       = abs(dG) >= G1;
    [N,edges] = histcounts(abs(dG));
    
    
    
    %% Fourier transform
    [t_freq, conductance_freq] = fourier_analysis(time, G);
    
    
    
    %% Auto correlation function
    
    
    
    %% Inter-event interval
    ieiDat = IEI(ddG,1);
    [Niei,edgesiei] = histcounts(ieiDat);
    results.IEI.pts  = Niei;
    results.IEI.bins = edgesiei;
    
    
    % Plot if a save-folder is provided and save
    if nargin == 5
        
        
    end
    
    
    figure;
    loglog((edgesiei(1:end-1) + edgesiei(2:end))/2,Niei, 'bx')
    [N1,edges1] = histcounts(abs(ieiDat(abs(ieiDat) >= 2)), edgesiei(4:end-2));
    [fitresult, xData, yData, gof] = fitPowerLaw((edges1(1:end-1) + edges1(2:end))/2, N1);
    hold on;
    plot(fitresult, xData, yData, 'gx')
    xlim([edgesiei(1), edgesiei(end)]);
    legend('not fitted', 'data', 'fit');
    xlabel('Time (dt)')
    ylabel('P(t)')
    text(10,500,strcat('t^{-', num2str(-fitresult.b,3),'}'))
    savefig(gcf, '/import/silo2/joelh/modelValidation/Adrian/Network#4/DC/highC/Mallinson2019SciAdv/F2C.fig')
    saveas(gcf, '/import/silo2/joelh/modelValidation/Adrian/Network#4/DC/highC/Mallinson2019SciAdv/F2C.png')

    
    %% Avalanche stats: 
    
    
    
    %% Avalanche size:
    
    
    %% Avalanche lifetime:
    
    
    %% <S>(T)
    
    
    %% Avalanche shape analysis
    
    
    %% Shape collapse and scaling function
    
    
    
    %% Comparison of independent measures of gamma+1
    
    
    
    % Plot if a save-folder is provided and save
    if nargin == 5
        
        
    end
    

end