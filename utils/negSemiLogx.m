function negSemiLogx(x,y)
    % Transform
    xlog = sign(x).*log10(abs(x));
    plot(xlog, y)
    % Do nothing else to get just exponents.  Otherwise:
    xt = get(gca,'XTick')';
    set(gca,'XTickLabel',num2str(sign(xt).*10.^abs(xt)))



end