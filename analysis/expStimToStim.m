function Stimulus = expStimToStim(V, my_tdms_struct, t, type)
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
            Stimulus.Amplitude  = str2double(my_tdms_struct.Props.Amplitude);            
            Stimulus.Frequency    = t(end)/str2double(my_tdms_struct.Props.Frequency); %half the frequency             
            Stimulus.Phase        = str2double(my_tdms_struct.Props.Phase);     
            
        case 'DCsaw'
            fun = @(x, t) x(1)*abs(sawtooth(x(3) + 2*pi*x(2)*(t-0.75/x(2)) , 0.5));
            x0 = [1, 1, 0];
            x = lsqcurvefit(fun, x0, t, V);            
            Stimulus.Amplitude = x(1); 
            Stimulus.Frequency = x(2);             
            Stimulus.Phase     = x(3);              

        case 'Square'
            Stimulus.AmplitudeOn  = str2double(my_tdms_struct.Props.Amplitude + my_tdms_struct.Props.Offset);            
            Stimulus.AmplitudeOff = my_tdms_struct.Props.Offset - my_tdms_struct.Props.Amplitude;
            Stimulus.OffTime      = t(end)/str2double(my_tdms_struct.Props.Frequency)/2; %half the frequency             
            Stimulus.Phase        = str2double(my_tdms_struct.Props.Phase);     
            Stimulus.Duty         = str2double(my_tdms_struct.Props.Duty_);
            %NumbSamples tells you number of time-points
            
    end
end