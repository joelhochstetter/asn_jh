function cb = phasePlot(x, y, t, type, color, symbol, varargin)
%varargin are variable arguments for plotting functionality
%Type = 0- color for time plot, 1- arrow time plot


    if nargin < 6
        symbol = '.';
    end
    
    if nargin < 4
        type = 0;
    end

    if type
        %Put a cross at initial location
        
       
        hold on;
        

        numArrow = 1000;
        qTimes = 2:round(numel(x)/numArrow):numel(x);

        x1 = (x(qTimes - 1) + x(qTimes))/2;
        y1 = (y(qTimes - 1) + y(qTimes))/2;
        
        u = x(qTimes) - x(qTimes - 1);
        v = y(qTimes) - y(qTimes - 1);
     
        scale = 5;
        %centres arrow at centre of datapoint
        x1 = x1 - u*scale/2;
        y1 = y1 - v*scale/2;
        
%         qNorm = u.^2 + v.^2;
%         u = u./qNorm;
%         v = v./qNorm;
        
        
        quiver(x1, y1, u, v, scale)
        %plot(x, y)
        %scatter(x(1), y(1), 20,  'x');
        %Label timepoints according

        cb = [];
        %Space arrows for timesteps
        
    else
        cm = colormap(jet);                                             % Approximates Spectrum
        y(end) = NaN;                                                 % Set Last Value To ‘NaN’ To Create Line
        
        patch(x,y,t,'EdgeColor','interp','Marker','.','MarkerFaceColor','flat', 'MarkerSize', 1e-2, 'Linewidth', 2);
        %Plot as points instead
         pointsize = 30; 
%          scatter(x, y, pointsize, t, 'filled');
        cb = colorbar;
%         set(gca, 'yscale', 'log')
    end

end