function snapshotFigure = snapshotToFigure(snapshot, contacts, connectivity, whatToPlot, axesLimits, highlightNodes, highlightEdges)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This funciton generates a visualization of a snapshot of the network.
% This includes: the spatial distribution of wires, the location of
% contacts, the state of each switch (ON\OFF), the voltage on each wire the
% currents distribution and the dissipation (heat-map).
%
% ARGUMENTS: 
% snapshot - A struct containing the voltage, conductance, etc. of the 
%            electrical components in the network, at a particular 
%            timestamp.
% contact - the indices of the two wires that serve as contacts.
% connectivity - A structure with the adjacency matrix as well as the
%                spatial information of the wires (location, orientation
%                etc.).
% whatToPlot - A structure of boolean flags, controlling the contents of
%              the output figure. Fields:
%                .GraphRep (true plot graph, false plots nwires)
%                if false we need
%                   .Nanowires
%                   .Contacts
%                   .Dissipation
%                   .Currents
%                   .Voltages
%                   .Lambda
%                   .Labels
%                   .VDrop
%                if true we need
%                   .Dissipation
%                   .Currents
%                   .VDrop
%                   .Voltages
%                   .Lambda
%                   .Labels
%
% weights - plots the number of the coloured variable along each edge
%                   
% whatToPlot can also be an empty structure or miss fields and can use
% defaults
%
% axesLimits - A structure of limits for the different axes used. This is
%              usefull in order to compile a movie, in which the colorbar,
%              length of arrows etc. should be consistent between the
%              different frames. Fields:
%                .DissipationCbar - since the colorbar is shown in
%                                   logarithmic scale, its limits will be:
%                                   [10^axesLimits.DissipationCbar(1),
%                                   10^axesLimits.DissipationCbar(2)]     
%                                   (in pW).
%                .CurrentArrowScaling - a common factor that scales all the
%                                       current arrows.
%                .VoltageCbar - limits of the voltage colorbar. for
%                               (positive DC bias that should be [0,Vext].
%                .LambdaCbar - limits of the lambda colorbar
%
%
% Axes limits can also be an empty structure and we use defaults
%
%
% OUTPUT:
% snapshotFigure - a figure object containing the wanted map of the
%                  network.
%
% REQUIRES:
% getAbsoluteVoltage
%
% Authors:
% Ido Marcus
% Joel Hochstetter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%{
    Example usage:
        cd /import/silo2/joelh/Criticality/largeNetworks
        load('a_T10_DC2V_s0.01_r0.001_c0.1_m0.15_b10_p1.mat')
        Connectivity = struct('filename', sim.ConnectFile);
        Connectivity = getConnectivity(Connectivity);
        Components   = sim.Comp;
        timeVec      = sim.dt:sim.dt:sim.T;
        whatToPlot   = struct('Dissipation',  false, 'Lambda',  true, 'GraphRep', true);
        axesLimits   = struct('LambdaCbar',[0; max(max(sim.swLam))]);
        makeSnapshotMovie(sim.Stim.Signal, sim.netC, sim.swV, sim.swLam, ...
            timeVec, sim.ContactNodes, sim.Comp, Connectivity, whatToPlot, axesLimits)
%}

    %% Sets default values
    
    %By default additonal contacts are drains
    if nargin < 6
        highlightNodes = [];
        highlightEdges = [];
    end
    
    isSource = zeros(numel(contacts),1);
    isSource(1) = 1;
    
    if ~isfield(whatToPlot, 'GraphRep')
       whatToPlot.GraphRep = false; 
    end
 
    
    if ~isfield(whatToPlot, 'Weights')
       whatToPlot.Weights = false; 
    end
     
    
    if ~isfield(whatToPlot, 'Nanowires')
       whatToPlot.Nanowires = true; 
    end

    if ~isfield(whatToPlot, 'OnOrOff')
       whatToPlot.OnOrOff = true; 
    end    
    
    if ~isfield(whatToPlot, 'Contacts')
       whatToPlot.Contacts = true; 
    end    
    
    if ~isfield(whatToPlot, 'Dissipation')
       whatToPlot.Dissipation = true; 
    end
    
    if ~isfield(whatToPlot, 'Lambda')
       whatToPlot.Lambda = false; 
    end
    
    if ~isfield(axesLimits, 'dVCbar')
       axesLimits.dVCbar = [min(abs(snapshot.Voltage)), max(abs(snapshot.Voltage))]; 
    end
    
    if ~isfield(whatToPlot, 'Currents')
       whatToPlot.Currents = true; 
    end    

    if ~isfield(whatToPlot, 'Voltages')
       whatToPlot.Voltages = true; 
    end    
    
    if ~isfield(whatToPlot, 'Labels')
       whatToPlot.Labels = false; 
    end
    
    if ~isfield(whatToPlot, 'VDrop')
       whatToPlot.VDrop = false; 
    end
    
    if ~isfield(axesLimits, 'DissipationCbar')
        axesLimits.DissipationCbar = [0,5];
    end

    if ~isfield(axesLimits, 'CurrentArrowScaling')
        axesLimits.CurrentArrowScaling = 0.25;
    end
    
    if ~isfield(axesLimits, 'DissipationCbar')
        axesLimits.DissipationCbar = [0,5];
    end

    if ~isfield(axesLimits, 'CurrentArrowScaling')
        axesLimits.CurrentArrowScaling = 0.25;
    end

    % compute absolute voltages:
    absoluteVoltage = getAbsoluteVoltage(snapshot.Voltage, connectivity, contacts);
    
    if ~isfield(axesLimits, 'VoltageCbar')
      axesLimits.VoltageCbar = [min(absoluteVoltage), max(absoluteVoltage)];
    end

    if ~isfield(axesLimits, 'LambdaCbar')
      axesLimits.LambdaCbar = [0, max(snapshot.filamentState(1:connectivity.NumberOfEdges))];
    end
    
    
    %% Plotting

    if whatToPlot.GraphRep
        % https://au.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.graphplot-properties.html
        %Set-up figure and colour
        snapshotFigure = figure('visible','off', 'units','normalized','outerposition',[0 0 1 1]);
        set(gca,'Color',[0.25 0.25 0.25],'xtick',[],'ytick',[]);

        %Convert to graph rep
        g = connectivity.weights;
        G = graph(g);

        %Set weights to Voltage across junction
        
        %G.Edges.Weight = full(snapshot.Voltage(1:connectivity.NumberOfEdges));

        hold all;
        p = plot(G,'Layout','auto','LineStyle','--');

        % Highlight on switches
            % Find the edges which correspond to OFF switches:
        badPairs = connectivity.EdgeList(:,~snapshot.OnOrOff(1:connectivity.NumberOfEdges));
            % Get the original adjacency matrix:
        adjacencyMatrix = connectivity.weights;
            % Remove the edges which correspond to OFF switches:
        adjacencyMatrix(sub2ind(size(adjacencyMatrix),badPairs(1,:),badPairs(2,:))) = 0;
        adjacencyMatrix(sub2ind(size(adjacencyMatrix),badPairs(2,:),badPairs(1,:))) = 0;
        highlight(p, graph(adjacencyMatrix),'EdgeColor','w','LineWidth',2.5,'LineStyle','-')

        ax=plot(NaN,NaN,'b--',NaN,NaN,'w'); %plotting invisible points of desired colors
        legend(ax,'OFF switch','ON switch');        %adding the legend
        

        % Highlight a nanowire
        if numel(highlightNodes) > 0
            highlight(p, highlightNodes, 'NodeColor','r','LineWidth',10)%,'Marker', 'square','MarkerSize',10)  
        end
        
        highlightEdges =  [];%snapshot.Voltage(1:connectivity.NumberOfEdges) > 0;
        
        % Highlight an edge
        if numel(highlightEdges) > 0
            highlight(p, connectivity.EdgeList(1,highlightEdges),connectivity.EdgeList(2,highlightEdges), 'EdgeColor','r','LineWidth',10)%,'Marker', 'square','MarkerSize',10)
        end
        
        if whatToPlot.Voltages    

            % trim results so that they don't saturate the color-scale:
            absoluteVoltage(absoluteVoltage < axesLimits.VoltageCbar(1)) = axesLimits.VoltageCbar(1);
            absoluteVoltage(absoluteVoltage > axesLimits.VoltageCbar(2)) = axesLimits.VoltageCbar(2);

            % linearly transform results to the range [0,1]:
            voltageColorCode = (absoluteVoltage - axesLimits.VoltageCbar(1)) / (axesLimits.VoltageCbar(2) - axesLimits.VoltageCbar(1));

            % construct RGB triplets (from green near contact(1) to red near contact(2)):
            voltageColorCode = [1-voltageColorCode,voltageColorCode,zeros(connectivity.NumberOfNodes,1)];

            %Sets node colours
            p.NodeColor = voltageColorCode;   
        end
        
        if ~whatToPlot.Nanowires
            p.NodeColor = 'none';
        end
            
        if whatToPlot.Contacts
            %Highlight Contacts
            colours = ['r';'g'];
            if whatToPlot.Nanowires
                for i = 1:numel(contacts)
                    highlight(p,contacts(i),'Marker', '*','MarkerSize',10,'NodeColor',colours(1+isSource(i)))
                end
            else
                source = contacts(logical(isSource));
                drain  = contacts(~logical(isSource));
                
                scatter(p.XData(source),p.YData(source),15,[[0 1 0];[1 0 0]],'Marker', '*','g');
                scatter(p.XData(drain),p.YData(drain),15,[[0 1 0];[1 0 0]],'Marker', '*','r');
            end
        end
            
        if whatToPlot.Labels
            %Show edge labels
            labeledge(p,1:numedges(G),1:numedges(G))   
        else
            %Hide Node Labels
            p.NodeLabel = {};
        end
        
        if whatToPlot.Currents
            % Calculate currents:
            currents = 5e3*full(snapshot.Voltage(1:connectivity.NumberOfEdges)).*(snapshot.Conductance(1:connectivity.NumberOfEdges)); % (nA)

            %Lengths of quiver vectors
            sectionCurrentX = (p.XData(connectivity.EdgeList(2,:)) -  p.XData(connectivity.EdgeList(1,:))).*currents'/axesLimits.CurrentArrowScaling;
            sectionCurrentY = (p.YData(connectivity.EdgeList(2,:)) -  p.YData(connectivity.EdgeList(1,:))).*currents'/axesLimits.CurrentArrowScaling;          

            %Positions of Current vectors. Centre of quivers are at the centre of edges
            sectionCentreX  = (p.XData(connectivity.EdgeList(1,:)) +  p.XData(connectivity.EdgeList(2,:)))/2 - sectionCurrentX/2;
            sectionCentreY  = (p.YData(connectivity.EdgeList(1,:)) +  p.YData(connectivity.EdgeList(2,:)))/2 - sectionCurrentY/2; 
            %sectionCentreX(1)
            quiver(sectionCentreX,sectionCentreY,sectionCurrentX,sectionCurrentY,0,'Color','w','LineWidth',1.5);
            %sectionCentreX(1)
        end


        % Can currently plot one out of dissipations, lambda and VDrop
        % Defaults order (if multiple are suggested): diss > lam > VDrop

        if whatToPlot.Dissipation
            p.EdgeCData = 1e9*(snapshot.Voltage(1:connectivity.NumberOfEdges)).^2./(snapshot.Conductance(1:connectivity.NumberOfEdges)); % Joule heating is V^2/R.
            cbar  = colorbar;    
            cbar.Label.String = 'P (nW)';
            %upperLimit = 0.15;
            %cbar.axis([0,upperLimit]);
            
            if whatToPlot.Weights
                edgeLabels = cell(numedges(G),1);
                for i = 1:numedges(G)
                   edgeLabels{i} = num2str(1e9*(snapshot.Voltage(i)).^2./(snapshot.Conductance(i)), '%.2e');
                end
               
                labeledge(p,1:numedges(G),edgeLabels)                      
            end
            

        elseif whatToPlot.Lambda
            p.EdgeCData = abs(snapshot.filamentState(1:connectivity.NumberOfEdges));
            cbar  = colorbar;
            cbar.Label.String = '\lambda (Vs)';
            caxis(axesLimits.LambdaCbar);
            
            if whatToPlot.Weights 
                edgeLabels = cell(numedges(G),1);
                for i = 1:numedges(G)
                   edgeLabels{i} = num2str(abs(snapshot.filamentState(i)), '%.2e');
                end            
                labeledge(p,1:numedges(G),edgeLabels)                                       
            end
            
        elseif whatToPlot.VDrop
            %p.EdgeCData = abs(snapshot.Voltage(1:connectivity.NumberOfEdges));
            p.EdgeCData = (snapshot.Voltage(1:connectivity.NumberOfEdges));
            cbar  = colorbar;    
            cbar.Label.String = '\Delta V (V)';    
            %upperLimit = 0.15;
            %caxis(axesLimits.dVCbar);
            if whatToPlot.Weights 
                edgeLabels = cell(numedges(G),1);
                for i = 1:numedges(G)
                   edgeLabels{i} = num2str(abs(snapshot.Voltage(i)), '%.2e');
                end            
                labeledge(p,1:numedges(G),edgeLabels)                                       
            end
            
        end
        
        
        if whatToPlot.Weights 
            edgeLabels = cell(numedges(G),1);
            for i = 1:numedges(G)
               edgeLabels{i} = num2str(abs(snapshot.Voltage(i)), '%.2e');
            end            
            labeledge(p,1:numedges(G),edgeLabels)                                       
        end

        %Set title
        title(strcat(sprintf('t=%.2f (s), ', snapshot.Timestamp),' \sigma=', sprintf('%.2e (S)',snapshot.netC),' V=', sprintf('%.2e (V)',snapshot.netV),' I=', sprintf('%.2e (A)',snapshot.netI)));
        
       
        
        hold off;
        
        
        
    else %Plots nanowire rep
        %% input control
        if ~strcmp(connectivity.WhichMatrix, 'nanoWires')
            error('Cannot visualize a snapshot for connectivity graphs that have no spatial meaning');
        end

        %% preliminaries
        snapshotFigure = figure('visible','off','Position', [0, 0, 1000, 550]);
        set(gca,'Color',[0.2 0.2 0.2]);
        hold all;

        %% nanowires and voltage distribution:  
        if whatToPlot.Voltages    

            % trim results so that they don't saturate the color-scale:
            absoluteVoltage(absoluteVoltage < axesLimits.VoltageCbar(1)) = axesLimits.VoltageCbar(1);
            absoluteVoltage(absoluteVoltage > axesLimits.VoltageCbar(2)) = axesLimits.VoltageCbar(2);

            % linearly transform results to the range [0,1]:
            voltageColorCode = (absoluteVoltage - axesLimits.VoltageCbar(1)) / (axesLimits.VoltageCbar(2) - axesLimits.VoltageCbar(1));

            % construct RGB triplets (from green near contact(1) to red near contact(2)):
            voltageColorCode = [1-voltageColorCode,voltageColorCode,zeros(connectivity.NumberOfNodes,1)];

            % add color bar:
                % Matlab allows only one colorbar per axes, see
                % voltageColorbar.
        end

        if whatToPlot.Nanowires
            if whatToPlot.Voltages    
                % nanowires with a voltage color-code
                lineColor = voltageColorCode;
            else
                % only (white) nanowires
                lineColor = ones(connectivity.NumberOfNodes,3);
            end
            for currWire=1:connectivity.NumberOfNodes
                    line([connectivity.WireEnds(currWire,1),connectivity.WireEnds(currWire,3)],[connectivity.WireEnds(currWire,2),connectivity.WireEnds(currWire,4)],'Color',lineColor(currWire,:),'LineWidth',0.5)
            end
        else
            if whatToPlot.Voltages
                % no nanowires, only points at the centers of the nanowires with a voltage color-code
                markerSize = 100;
                scatter(connectivity.VertexPosition(:,1), ...
                        connectivity.VertexPosition(:,2), ...
                        markerSize,                       ...
                        voltageColorCode,                 ...
                        'filled',                         ...
                        's'                               ...
                        );

            else
                % nothing.
            end
        end

            %% Lambda states of each junction:
        if ~whatToPlot.Dissipation & whatToPlot.Lambda
            junctionSize = 50;

            % calculate power consumption:
            %power = 1e9*(snapshot.Voltage(1:connectivity.NumberOfEdges)).^2./(snapshot.Conductance(1:connectivity.NumberOfEdges)); % Joule heating is V^2/R.
            power = abs(snapshot.filamentState);
            % if possible, give different marker to open switches, otherwise
            % just plot all the switches in the same manner:
            if isfield(snapshot, 'OnOrOff')
                on = snapshot.OnOrOff(1:connectivity.NumberOfEdges);

                onDots = scatter(connectivity.EdgePosition(on,1),    ...
                                 connectivity.EdgePosition(on,2),    ...
                                 2.0*junctionSize,                       ...
                                 (power(on)),                     ... %log10(power(on))
                                 'filled',                           ...
                                 'o');

                offDots = scatter(connectivity.EdgePosition(~on,1),   ...
                                  connectivity.EdgePosition(~on,2),   ...
                                  junctionSize,                       ...
                                  (power(~on)),                    ...%log10(power(~on))
                                  'filled',                           ...
                                  's');

                % legend:
                if any(on) && any(~on)
                    leg = legend([onDots,offDots],{'ON switch','OFF switch'});
                elseif any(on)
                    leg = legend(onDots,{'ON switch'});
                else
                    leg = legend(offDots,{'OFF switch'});
                end
                leg.Color = 'white';

            else
                scatter(connectivity.EdgePosition(:,1),     ...
                        connectivity.EdgePosition(:,2),     ...
                        junctionSize,                       ...
                        log10(power),                         ...
                        'filled');
            end

            % colorbar:               
            dissipationColorbar  = colorbar;
            dissipationColorbar.Label.String = '\lambda';
            upperLimit = 0.15;
            caxis([0,upperLimit]);
            %upperLimit = ceil(max(log10(power)));
            %{
            upperLimit = axesLimits.DissipationCbar(2);
            caxis([0,upperLimit]);
            dissipationColorbar.Ticks = 0:1:upperLimit;
            dissipationColorbar.TickLabels(:) = '';
                % tick labels:
                labelBank = {'pW', '', '', 'nW', '', '', '\muW', '', '', 'mW', '', '', 'W', '', '', 'kW', '', '', 'MW'};
                dissipationColorbar.TickLabels = labelBank(1:upperLimit+1); 
            %}
            colormap('parula');
        end


        %% dissipation:
        if whatToPlot.Dissipation
            junctionSize = 50;

            % calculate power consumption:
            power = 1e9*(snapshot.Voltage(1:connectivity.NumberOfEdges)).^2.*(snapshot.Conductance(1:connectivity.NumberOfEdges)); % Joule heating is V^2/R.

            % if possible, give different marker to open switches, otherwise
            % just plot all the switches in the same manner:
            if isfield(snapshot, 'OnOrOff')
                on = snapshot.OnOrOff(1:connectivity.NumberOfEdges);

                onDots = scatter(connectivity.EdgePosition(on,1),    ...
                                 connectivity.EdgePosition(on,2),    ...
                                 1.5*junctionSize,                       ...
                                 log10(power(on)),                     ...
                                 'filled',                           ...
                                 'o');

                offDots = scatter(connectivity.EdgePosition(~on,1),   ...
                                  connectivity.EdgePosition(~on,2),   ...
                                  junctionSize,                       ...
                                  log10(power(~on)),                    ...
                                  'filled',                           ...
                                  's');

                % legend:
                if any(on) && any(~on)
                    leg = legend([onDots,offDots],{'ON switch','OFF switch'});
                elseif any(on)
                    leg = legend(onDots,{'ON switch'});
                else
                    leg = legend(offDots,{'OFF switch'});
                end
                leg.Color = 'white';

            else
                scatter(connectivity.EdgePosition(:,1),     ...
                        connectivity.EdgePosition(:,2),     ...
                        junctionSize,                       ...
                        log10(power),                         ...
                        'filled');
            end

            % colorbar:               
            dissipationColorbar  = colorbar;
            dissipationColorbar.Label.String = 'Power (logarithmic scale)';
            %upperLimit = ceil(max(log10(power)));
            upperLimit = axesLimits.DissipationCbar(2);
            caxis([0,upperLimit]);
            dissipationColorbar.Ticks = 0:1:upperLimit;
            dissipationColorbar.TickLabels(:) = '';
                % tick labels:
                labelBank = {'pW', '', '', 'nW', '', '', '\muW', '', '', 'mW', '', '', 'W', '', '', 'kW', '', '', 'MW'};
                dissipationColorbar.TickLabels = labelBank(1:upperLimit+1);            
            colormap('parula');
        end
             %% Voltage Drops across each junction:
        if ~whatToPlot.Dissipation & ~whatToPlot.Lambda & whatToPlot.VDrop
            junctionSize = 50;

            % calculate power consumption:
            %power = 1e9*(snapshot.Voltage(1:connectivity.NumberOfEdges)).^2./(snapshot.Conductance(1:connectivity.NumberOfEdges)); % Joule heating is V^2/R.
            power = abs(snapshot.Voltage(1:connectivity.NumberOfEdges));
            % if possible, give different marker to open switches, otherwise
            % just plot all the switches in the same manner:
            if isfield(snapshot, 'OnOrOff')
                on = snapshot.OnOrOff(1:connectivity.NumberOfEdges);

                onDots = scatter(connectivity.EdgePosition(on,1),    ...
                                 connectivity.EdgePosition(on,2),    ...
                                 2.0*junctionSize,                       ...
                                 (power(on)),                     ... %log10(power(on))
                                 'filled',                           ...
                                 'o');

                offDots = scatter(connectivity.EdgePosition(~on,1),   ...
                                  connectivity.EdgePosition(~on,2),   ...
                                  junctionSize,                       ...
                                  (power(~on)),                    ...%log10(power(~on))
                                  'filled',                           ...
                                  's');

                % legend:
                if any(on) && any(~on)
                    leg = legend([onDots,offDots],{'ON switch','OFF switch'});
                elseif any(on)
                    leg = legend(onDots,{'ON switch'});
                else
                    leg = legend(offDots,{'OFF switch'});
                end
                leg.Color = 'white';

            else
                scatter(connectivity.EdgePosition(:,1),     ...
                        connectivity.EdgePosition(:,2),     ...
                        junctionSize,                       ...
                        (power),                         ...
                        'filled');
            end

            % colorbar:               
            dissipationColorbar  = colorbar;
            dissipationColorbar.Label.String = 'Junction Voltage (V)';
            caxis(axesLimits.dVCbar);
            %upperLimit = ceil(max(log10(power)));
            %{
            upperLimit = axesLimits.DissipationCbar(2);
            caxis([0,upperLimit]);
            dissipationColorbar.Ticks = 0:1:upperLimit;
            dissipationColorbar.TickLabels(:) = '';
                % tick labels:
                labelBank = {'pW', '', '', 'nW', '', '', '\muW', '', '', 'mW', '', '', 'W', '', '', 'kW', '', '', 'MW'};
                dissipationColorbar.TickLabels = labelBank(1:upperLimit+1); 
            %}
            colormap('parula');
        end   
        
    %% currents:
    if whatToPlot.Currents
        % Allocate space (assuming no intersections at ends of wires):
        numberOfSections = 2*length(connectivity.EdgeList) - connectivity.NumberOfNodes + 2;
        sectionCenterX  = zeros(numberOfSections,1);
        sectionCenterY  = zeros(numberOfSections,1);
        sectionCurrentX = zeros(numberOfSections,1);
        sectionCurrentY = zeros(numberOfSections,1);
        numSectionsDone = 0;
        
        % Calculate currents:
        currents = 1e6*(snapshot.Voltage(1:connectivity.NumberOfEdges)).*(snapshot.Conductance(1:connectivity.NumberOfEdges)); % (nA)
        
        % Calculate wire angles ([-pi/2,pi/2]):
                % first [0,pi]
        wireAngles = mod(atan2(connectivity.WireEnds(:,4)-connectivity.WireEnds(:,2), connectivity.WireEnds(:,3)-connectivity.WireEnds(:,1)),pi);
            % The modulu operation makes sure that the result is between
            % 0 and pi. It is just for safety, since the ends are sorted
            % such that WireEnds(:,4)>WireEnds(:,2).        
                % then [-pi/2,pi/2]
        wireAngles(wireAngles>pi/2) = wireAngles(wireAngles>pi/2) - pi;
            % Since the sections will soon be sorted from left to right, a
            % positive current value along a section must always have a
            % positive cosine value, and vise versa.
   
        % Wire by wire:
        for currWire= 1 : connectivity.NumberOfNodes            
            % Find the indices of edges (=intersections) relevant for this
            % vertex (=wire):
            relevantEdges = find(connectivity.EdgeList(1,:) == currWire | connectivity.EdgeList(2,:) == currWire);
            
            % Sort them according to physical location (left-to-right, or
            % if the wire is vertical then bottom-up):
            if connectivity.WireEnds(currWire,1) ~= connectivity.WireEnds(currWire,3)
                [~,I] = sort(connectivity.EdgePosition(relevantEdges,1));
            else
                [~,I] = sort(connectivity.EdgePosition(relevantEdges,2));
            end
            relevantEdges = relevantEdges(I);
            
            % Calculate the current along each section of the wire:
            direction = ((currWire ~= connectivity.EdgeList(1,relevantEdges))-0.5)*2;       
                % Using the convention that currents are defined to flow
                % from wires with lower index to wires with higher index, 
                % and that in the field EdgeList the upper row always 
                % contains lower indices. 
            wireCurrents = cumsum(currents(relevantEdges(1:end - 1)).*direction(1:end - 1)'); 
                % The first element in wireCurrents is the current in the
                % section between relevantEdge(1) and relevantEdge(2). We
                % assume that between relevantEdge(1) and the closest wire
                % end there's no current. Then, acording to a KCL
                % equation, there's also no current from relevantEdge(end)
                % to the other wire end (that's why the end-1 in the 
                % expression). 
                % The only two exceptions are the two contacts, where the 
                % contact point is defined as the wire end closest to 
                % relevantEdge(end).
            
            % Accumulate for a quiver (vector field) plot:
            first = numSectionsDone + 1;
            last = first + length(wireCurrents) - 1;
            sectionCenterX(first:last)  = mean([connectivity.EdgePosition(relevantEdges(1:end-1),1), connectivity.EdgePosition(relevantEdges(2:end),1)],2);
            sectionCenterY(first:last)  = mean([connectivity.EdgePosition(relevantEdges(1:end-1),2), connectivity.EdgePosition(relevantEdges(2:end),2)],2);
            sectionCurrentX(first:last) = cos(wireAngles(currWire))*wireCurrents;
            sectionCurrentY(first:last) = sin(wireAngles(currWire))*wireCurrents;
            numSectionsDone = last;
            
            % Contacts stuff:
            if any(contacts == currWire)
                % Find the relevant end of the wire:
                if connectivity.WireEnds(currWire,1) ~= connectivity.WireEnds(currWire,3)
                    if connectivity.WireEnds(currWire,1) < connectivity.WireEnds(currWire,3)
                        contactEnd = connectivity.WireEnds(currWire,3:4);
                    else
                        contactEnd = connectivity.WireEnds(currWire,1:2);
                    end
                else
                    if connectivity.WireEnds(currWire,2) < connectivity.WireEnds(currWire,4)
                        contactEnd = connectivity.WireEnds(currWire,3:4);
                    else
                        contactEnd = connectivity.WireEnds(currWire,1:2);
                    end
                end

                % Add total current arrow:
                totalCurrent = sum(currents(relevantEdges).*direction');
                sectionCenterX(numSectionsDone+1)  = mean([connectivity.EdgePosition(relevantEdges(end),1), contactEnd(1)],2);
                sectionCenterY(numSectionsDone+1)  = mean([connectivity.EdgePosition(relevantEdges(end),2), contactEnd(2)],2);
                sectionCurrentX(numSectionsDone+1) = cos(wireAngles(currWire))*totalCurrent; 
                sectionCurrentY(numSectionsDone+1) = sin(wireAngles(currWire))*totalCurrent;
                numSectionsDone = numSectionsDone + 1;
                
                % Gather contact point location, if needed:
                if whatToPlot.Contacts
                % The location of the current wire's end which is 
                % rightmost (or if vertical, upper) is defined as the 
                % contact POINT:
                    if currWire == contacts(1)
                        sourcePoint = contactEnd;
                    else
                        drainPoint  = contactEnd;
                    end
                end
            end
        end
        
        % Plot current arrows:
        quiver(sectionCenterX,sectionCenterY,sectionCurrentX/axesLimits.CurrentArrowScaling,sectionCurrentY/axesLimits.CurrentArrowScaling,0,'Color','w','LineWidth',3);
        %quiver(sectionCenterX,sectionCenterY,sectionCurrentX,sectionCurrentY,'Color','w','LineWidth',1);
    end
    

        %% contacts:   
        if whatToPlot.Contacts
            for currWire = contacts
                    % Find the relevant end of the wire:
                    if connectivity.WireEnds(currWire,1) ~= connectivity.WireEnds(currWire,3)
                        if connectivity.WireEnds(currWire,1) < connectivity.WireEnds(currWire,3)
                            contactEnd = connectivity.WireEnds(currWire,3:4);
                        else
                            contactEnd = connectivity.WireEnds(currWire,1:2);
                        end
                    else
                        if connectivity.WireEnds(currWire,2) < connectivity.WireEnds(currWire,4)
                            contactEnd = connectivity.WireEnds(currWire,3:4);
                        else
                            contactEnd = connectivity.WireEnds(currWire,1:2);
                        end
                    end
                
                    if currWire == contacts(1)
                        sourcePoint = contactEnd;
                    else
                        drainPoint  = contactEnd;
                    end
            end

                
            scatter([sourcePoint(1),drainPoint(1)],[sourcePoint(2),drainPoint(2)],200,[[0 1 0];[1 0 0]],'filled','h');
            sourceTextPosition = sourcePoint;
            drainTextPosition  = drainPoint;
                
%             text(sourceTextPosition(1), sourceTextPosition(2), strcat('  (1)'),  'Color', 'g', 'FontSize', 16);
%             text(drainTextPosition(1),  drainTextPosition(2),  strcat('  (2)'),  'Color', 'r', 'FontSize', 16);
        end

        %% Labels for junctions and nanowires
        if whatToPlot.Labels
                % plots switch number next to switch and nanowire
                % cellstr(num2str([1:a]')) produces list of number of each
                % switch

                text(connectivity.EdgePosition(:,1), ...
                    connectivity.EdgePosition(:,2), ...
                    cellstr(num2str([1:connectivity.NumberOfEdges]')), ...
                    'Color','red','FontSize',7);

                text(connectivity.VertexPosition(:,1), ...
                    connectivity.VertexPosition(:,2), ...
                    cellstr(num2str([1:connectivity.NumberOfNodes]')), ...
                    'Color','yellow','FontSize',7);

        end
        %% title, axes labels and limits:
        %title(strcat(sprintf('t=%.2f (s), ', snapshot.Timestamp),' \sigma=', sprintf('%.2e (S)',snapshot.netC),' V=', sprintf('%.2e (V)',snapshot.netV),' I=', sprintf('%.2e (A)',snapshot.netI)));

        xlabel('x (\mum)');
        ylabel('y (\mum)');
        shoulder = 800;
        axis([-shoulder,connectivity.GridSize(1)+shoulder,-shoulder,connectivity.GridSize(2)+shoulder]);
        axis square;
        hFig=findall(0,'type','figure');
        hLeg=findobj(hFig(1,1),'type','legend');
        set(hLeg,'visible','off');
        
        text(2500, 3500, sprintf('t = %.2f s', snapshot.Timestamp), 'Color', 'white', 'FontSize', 16);
        
        set(gcf,'color','w');
        
    end
end