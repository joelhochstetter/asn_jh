function plotAvalanceAveSize(sizeAv, lifeAv, fitP)
%{
    Plots the avalanche average size as a function of lifetime

    Inputs:
    sizeAv: Avalanche sizes
    
     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI


    Option to fit if we provide cut-offs

%}


    [mSize, mLife] = avalancheAvSize(sizeAv, lifeAv);
    figure;
    [fitresult, xData, yData, gof] = fitPowerLaw(mLife(2:end), mSize(2:end));
    plot(fitresult, xData, yData, 'gx')
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    xlabel('T (bins)')
    ylabel('<S>(T)')
    text(30,100,strcat('T^{', num2str(fitresult.b,3),'}'))
    savefig(gcf, '/import/silo2/joelh/modelValidation/Adrian/Network#4/DC/highC/Mallinson2019SciAdv/F3C.fig')
    saveas(gcf, '/import/silo2/joelh/modelValidation/Adrian/Network#4/DC/highC/Mallinson2019SciAdv/F3C.png')
    x2  = fitresult.b;
    CI  = confint(fitresult, cLevel);
    aCI = CI(:,2);
    dx2 = (tCI(2) - tCI(1))/2;



end