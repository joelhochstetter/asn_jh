% function netC = getNetworkConductance(componentConductance, edgeList, src, drn, V)
function netC = getNetworkConductance(Gmat, src, drn)

%{
    Calculates network conductance
%}
% 
%     Gmat = zeros(V,V);
%     for i = 1:E
%         Gmat(edgeList(i,1),edgeList(i,2)) = componentConductance(i);
%         Gmat(edgeList(i,2),edgeList(i,1)) = componentConductance(i);
%     end
%     
%     for i = 1:E
%         Gmat(edgeList(i,1),edgeList(i,2)) = componentConductance(i);
%         Gmat(edgeList(i,2),edgeList(i,1)) = componentConductance(i);
%     end
% 
%     Gmat = diag(sum(Gmat, 1)) - Gmat;

    V = size(Gmat,1);
    ns = numel(src);
    nd = numel(drn);
    LHS          = zeros(V+ns+nd, V+ns+nd);
    RHS             = zeros(V+ns+nd,1);
    LHS(1:V,1:V) = Gmat;
    
    for i = 1:ns
        this_elec           = src(i);
        LHS(V+i,this_elec)  = 1;
        LHS(this_elec,V+i)  = 1;
        RHS(V+i)            = 1;
    end

    for i = 1:nd
        this_elec           = drn(i);
        LHS(V+i+ns,this_elec)  = 1;
        LHS(this_elec,V+i+ns)  = 1;
        RHS(V+i+ns)            = 0;
    end

    % Solve equation:
    sol = LHS\RHS;
    
    electrodeCurrent = sol(V+1:end);     
    electrodeCurrent(isnan(electrodeCurrent)) = 0;
    netC = abs(sum(electrodeCurrent(1:ns)));
    
end
