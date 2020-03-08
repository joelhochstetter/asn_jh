function [tcrit, tsub, tsup] = criticalTimes(G, a)
%{
	Calculates critical times as defined in MyNotes 08-03
	
	Inputs:
		G - conductance time-series
		a - (float > 1) cutoff ratio
		
    Outputs:
    	tcrit - time-step of max conductance gradient
    	tsub  - time-step marks end of sub-critical and beginning of critical
    	tsup  - time-step marks end of critical and beginning of supercritical
    	
    Works for deactivations to. Just note that names of tsub and tsup will be swapped 		in such a case.
    
    This assumes evenly spaced time-steps
%}	
	
    dG = [diff(G), 0];
    dG(isnan(dG)) = 0;
	dG = runningMean(dG, 10); %average out noise
	
	dGmax = max(dG);
	
	tcrit = find(dGmax == dG, 1);
	cutoff = dGmax/a;
	x = find(dG >= cutoff);
	
	%most primitive definition
	tsub = x(1);
	tsup = x(end);
	
	%check that we found an interval such that dG> dGmax/cutoff for all on interval
	while max(dG(tsub:tcrit) < cutoff) == true
		x = find(dG >= cutoff);
		tsub = x(find(x > tsub, 1));
	end
	
	while max(dG(tcrit:tsup) < cutoff) == true
		x = find(dG >= cutoff);
		tsup = x(find(x < tsup));
        tsup = tsup(end);
	end	

	
end