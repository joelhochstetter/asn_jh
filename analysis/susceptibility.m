function susceptibility(V, C, saveFolder)
%Input
%   V, voltage
%   C, condutance
%   saveFolder, string of where to save file

    %Define the critical point as points from asL to desU
    %Define the sub-critical phase as below this and the super-critical phase
    %as above this 



    %Classify points close to susceptibility maxima
    % We choose second derivation > 1e-2 as some arbitrary cutoff to the
    % locality around the critical point

    %We then split critical point into ascending and descending susceptibiliy
    %sections. L means lower index bound, U means upper index bound

    succ = (C(2:end)-C(1:end-1))./(V(2:end)-V(1:end-1));
    V2   = (V(1:end - 1) + V(2:end))/2;

    %Calculate quantities used for analying the suceptibility
    maxLoc = find(max(succ)==succ);
    d2CdV2 = (succ(2:end)-succ(1:end-1))./(V2(2:end)-V2(1:end-1));
    V3     = (V2(1:end - 1) + V2(2:end))/2;
    critLocality = (find(abs(d2CdV2) > 1e4)) + 1; %+1 to indicate fewer points in 2nd derivative
    ascL = min(critLocality);
    ascU = maxLoc - 1;
    desL = maxLoc + 1;
    desU = max(critLocality) - 1;


    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,1,1);
    semilogy(V2,succ,'x-');
    xlabel 'V (V)'
    ylabel '\chi'
    title 'Plot of susceptibility'


    subplot(3,1,2);
    semilogy(V2(ascL:ascU),succ(ascL:ascU),'--*'); 
    xlabel 'V (V)'
    ylabel '\chi'
    title 'Plot of susceptibility - left of crit'

    subplot(3,1,3);
    semilogy(V2(desL:desU),succ(desL:desU),'--*'); 
    xlabel 'V (V)'
    ylabel '\chi'
    title 'Plot of susceptibility - right of crit'

    saveas(gcf,strcat(saveFolder,'/analysis/SuccPlot.png'))


    % Fit susceptibility power law
    V21 = V2(ascL:ascU); %-(V21-Vcrit)/Vcrit
    s21 = succ(ascL:ascU);
    Vcrit = V2(find(succ == max(succ)));
    V22 = -(V21-Vcrit)/Vcrit;
    [ft, xData, yData] = fitPowerLaw(-(V21-Vcrit)/Vcrit,s21);
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,1,1);
    plot( ft, xData, yData );
    xlabel '|V (V)|'; ylabel '\chi';
    title(strcat('Power law V->V_{c-} critical point \alpha = ', num2str(ft.b)));
    grid on

    V21 = V2(desL:desU); %-(V21-Vcrit)/Vcrit
    s21 = succ(desL:desU);
    Vcrit = V2(find(succ == max(succ)));
    V22 = (V21-Vcrit)/Vcrit;
    [ft, xData, yData] = fitPowerLaw((V21-Vcrit)/Vcrit,s21);
    subplot(2,1,2);
    plot( ft, xData, yData );
    xlabel '|V (V)|'; ylabel '\chi';
    title(strcat('Power law V->V_{c+} critical point \alpha = ', num2str(ft.b)));
    grid on
    saveas(gcf,strcat(saveFolder,'/analysis/SuccFit.png'))


end