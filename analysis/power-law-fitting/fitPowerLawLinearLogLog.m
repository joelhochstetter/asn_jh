function [beta, dbeta] = fitPowerLawLinearLogLog(x, y)
    if numel(x) <= 1
        beta   = nan;
        dbeta = nan;
        return
    end
%     [xData, yData] = prepareCurveData( x, y );
    x = reshape(x, [numel(x),1]);
    y = reshape(y, [numel(y),1]);
    
    %remove zeros
    nonzero = find(y); 
    x = x(nonzero);
    y = y(nonzero);
    
    %Linear fit on a log-log plot
    fitRes = polyfitn(log10(x), log10(y), 1);
    fitCoef = fitRes.Coefficients;
    errors  = fitRes.ParameterStd;
    beta = -fitCoef(1);
    dbeta = errors(1);


end