function DC_multi_random_connect(idx, saveFolder, netType)
%{
    Connectivity = struct('WhichMatrix', 'WattsStrogatz', 'beta', 0.0,...
    'EdgesPerNode', 2, 'NumberOfNodes', 500)
    Connectivity = struct('WhichMatrix', 'BarabasiAlbert', 'm0', 2.0,...
    'm', 2, 'NumberOfNodes', 500)
    Connectivity = struct('WhichMatrix', 'Lattice', 'sizex', 23,...
    'BondProb', 1.0)

    DC_by_random_connectivity(1, '.',  1.05, true, true, struct('WhichMatrix', 'WattsStrogatz', 'beta', 0.0,...
    'EdgesPerNode', 2, 'NumberOfNodes', 500), 30)
%}
    
    T = 50;
    numSeeds = 100;
    sidx = mod((idx-1), numSeeds); 
    netidx = floor((idx-1)/numSeeds) + 1;
    amp = 1.05;
    
    switch netType
        case 0
            beta = [0.01, 0.05, 0.1, 0.5, 1.0];%0.2:0.2:1.0;
            DC_by_random_connectivity(sidx, saveFolder, amp, false, true, struct('WhichMatrix', 'WattsStrogatz', 'beta', beta(netidx), 'EdgesPerNode', 2, 'NumberOfNodes', 1000), T);
        case 1
            DC_by_random_connectivity(sidx, saveFolder, amp, false, true, struct('WhichMatrix', 'BarabasiAlbert', 'm0', 2.0, 'm', 2, 'NumberOfNodes', 1000), T);
        case 2
            p = 0.55:0.10:0.95;
            DC_by_random_connectivity(sidx, saveFolder, amp, true, true, struct('WhichMatrix', 'Lattice', 'sizex', 32, 'BondProb', p(netidx)), T);
    end

end