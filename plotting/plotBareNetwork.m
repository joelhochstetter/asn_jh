function plotBareNetwork(ConnFile, src, drn, graphRep)
%{
    Plots network onto the current figure pannel
    
    ConnFile: character vector of the filename
    GraphRep: 1 (plots in graph representation), 0 (plots in nanowire
    representation).
%}

    con.filename = ConnFile;
    con.WhichMatrix  = 'nanoWires';  
    connectivity       = getConnectivity(con);

    
    if graphRep
        G = graph(connectivity.weights);
        lineColor = 0.6*ones(connectivity.NumberOfNodes,3);
        edgColor = 0.7*ones(connectivity.NumberOfEdges,3);
        p = plot(G, 'XData', connectivity.VertexPosition(:,1), 'YData', connectivity.VertexPosition(:,2), 'LineStyle','-','LineWidth',2, 'MarkerSize',4);
        p.NodeLabel = {};               
        p.NodeColor = lineColor;
        p.EdgeColor = edgColor;
        highlight(p,src, 'Marker', '*','MarkerSize',15,'NodeColor',[0 1 0])
        highlight(p,drn,'Marker', '*','MarkerSize',15,'NodeColor',[1 0 0]) 
        
    else
        sourcePoint = connectivity.WireEnds(src,3:4);
        drainPoint     = connectivity.WireEnds(drn,1:2);
        lineColor = 0.6*ones(connectivity.NumberOfNodes,3);
        hold on;
        for currWire=1:connectivity.NumberOfNodes
                line([connectivity.WireEnds(currWire,1),connectivity.WireEnds(currWire,3)],[connectivity.WireEnds(currWire,2),connectivity.WireEnds(currWire,4)],'Color',lineColor(currWire,:),'LineWidth',1.5)
        end
        %plot sources
        scatter(sourcePoint(:,1),sourcePoint(:,2),200,[0 1 0],'*');
        %plot drains
        scatter(drainPoint(:,1),drainPoint(:,2),200,[1 0 0],'*');        
    end
    

    xlim([-connectivity.GridSize(1)*0.2,connectivity.GridSize(1)*1.2])
    ylim([-connectivity.GridSize(2)*0.2,connectivity.GridSize(2)*1.2])
    
    ax = gca;
    ax.DataAspectRatio = [1 1 1];
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);set(gca,'xtick',[]);set(gca,'ytick',[]);
    box on;

    
end