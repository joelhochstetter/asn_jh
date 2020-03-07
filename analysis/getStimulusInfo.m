function Stimulus = getStimulusInfo(V, t, type)
%{
    Gets the stimulus information into the form used by simulations
    Uses a non-linear, least-square fit to evaluate the best on average
%}
    
    Stimulus = struct();
    Stimulus.BiasType = type;
    
    
    switch type
        case 'DC'
            Stimulus.Amplitude = mean(V);
            
        case 'ACsaw'                           
            fun = @(x, t) x(1)*sawtooth(x(3) + 2*pi*x(2)*(t-0.75/x(2)) , 0.5);
            x0 = [1, 1, 0];
            x = lsqcurvefit(fun, x0, t, V);            
            Stimulus.Amplitude = x(1); 
            Stimulus.Frequency = x(2);             
            Stimulus.Phase     = x(3);  
            
        case 'DCsaw'
            fun = @(x, t) x(1)*abs(sawtooth(x(3) + 2*pi*x(2)*(t-0.75/x(2)) , 0.5));
            x0 = [1, 1, 0];
            x = lsqcurvefit(fun, x0, t, V);            
            Stimulus.Amplitude = x(1); 
            Stimulus.Frequency = x(2);             
            Stimulus.Phase     = x(3);              

        case 'Square'
            fun = @(x, t) max(x(3), x(1)*square(1*pi*t/x(2) + x(4), x(5)));
            x0 = [1, 0.1, 1, 0.0, 50.0];
            x = lsqcurvefit(fun, x0, t, V);
            Stimulus.AmplitudeOn  = x(1);            
            Stimulus.AmplitudeOff = x(2);
            Stimulus.OffTime      = x(3);             
            Stimulus.Phase        = x(4);      
            Stimulus.Duty         = x(5);
            
    end
end