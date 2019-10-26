function negSemiLogy(x,y)
    % Transform
    ylog = sign(y).*log10(abs(y));
    plot(x,ylog)
    % Do nothing else to get just exponents.  Otherwise:
    yt = get(gca,'YTick')';
    set(gca,'YTickLabel',num2str(sign(yt).*10.^abs(yt)))
    % Or, for scientific notation



end