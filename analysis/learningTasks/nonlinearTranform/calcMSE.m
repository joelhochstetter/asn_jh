function [mse, rnmse] = calcMSE(y, T)
    mse   = mean((y-T).^2);
    rnmse = sqrt(mse/mean(T.^2));
end