function [beta, dbeta] = fitPowerLawLinearLogLog(x, y)
    if numel(x) <= 1
        beta   = nan;
        dbeta = nan;
        return
    end
    [xData, yData] = prepareCurveData( x, y );
    
    %Linear fit on a log-log plot
    fitRes = polyfitn(log10(xData), log10(yData), 1);
    fitCoef = fitRes.Coefficients;
    errors  = fitRes.ParameterStd;
    beta = -fitCoef(1);
    dbeta = errors(1);


end