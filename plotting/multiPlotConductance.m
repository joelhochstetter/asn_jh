function fig = multiPlotConductance(timeVec, sims, field, fieldName, tlim)
%inputs:
%   timeVec (Nx1 vector): vector of time
%   sims (cell array). sims{i} must contain netC a (Nx1 vector) of network
%       conductance time series
%   field / subfield: a string of field which is the variable changing between sims.
%       field must exist in sims
%   E.g. field = 'Stim', subfield = 'Amplitude', fieldName = 'Voltage Bias'
%   fieldName (string): name of the field used in the title
%   tlim (1x2 vector): contains lower and upper limits to plot
%   Minimum usage: enter timeVec, sims and field

    fig = figure();
    set(gca,'yscale','log');
    hold on
    for i = 1:numel(sims)
        semilogy(timeVec, sims{i}.netC)
    end
    ylabel 'Conductance (S)'
    xlabel 't (s)'
    if nargin == 5
        xlim(tlim)
    end
        
    %If enter field plot a legend and title
    if nargin >= 3
        leg = cell(numel(sims),1);
        for i = 1:numel(sims)
            leg{i} = num2str(eval(strcat('sims{i}.', field)));
        end
        legend(leg)
        title(strcat('Conductance Time Series Comparison, Changing ', fieldName))       
    else
        title('Conductance Time Series Comparison')
        leg = cell(numel(sims),1);
        for i = 1:numel(sims)
            leg{i} = num2str(i);
        end
        legend(leg)
    end
        
end