function DC_vary_nets_by_ensemble(idx, netFolder, saveFolder, ensembleID, Vidx) 
 %{
               idx: index from cluster
    netFolder: folder containing network ensemble
ensembleID: 0 (fixed density, change size), 
                       1 (fixed wires, change density), 
                       2 (fixed size, change density)

%}


     numSeeds = 500;
     seedIdx  = mod((idx-1), numSeeds) + 1;

  
    % Gets connect file
    switch ensembleID
        case 0 %fixed density, change size 
            disp('Simulating networks of fixed density, changing size')
            netSizes = 40:10:80;
            Szeidx    = floor((idx-1)/numSeeds) + 1;
            disp(strcat2({'Seed: ', seedIdx - 1, ', D = ', netSizes(Szeidx)}));

            nets = dir(strcat(netFolder, '/*_seed_', num2str(seedIdx - 1,'%03.f'), '*lx_', num2str(netSizes(Szeidx)),'*.mat'))';
            connFile = nets(1).name;
            nameComment = strcat2({'_Lx', netSizes(Szeidx), '_seed', seedIdx - 1}, '%03.f');

        case 1 %fixed wires, change density
            disp('Simulating networks of fixed wires, changing density')            
            netSizes = 40:10:80;
            Szeidx    = floor((idx-1)/numSeeds) + 1;
            disp(strcat2({'Seed: ', seedIdx - 1, ', D = ', netSizes(Szeidx)}));
            nets = dir(strcat(netFolder, '/*_seed_', num2str(seedIdx - 1,'%03.f'), '*lx_', num2str(netSizes(Szeidx)),'*.mat'))';
            connFile = nets(1).name;
            nameComment = strcat2({'_Lx', netSizes(Szeidx), '_seed', seedIdx - 1}, '%03.f');     
            
        case 2 %fixed size, change density
            disp('Simulating networks of fixed size, changing density')   
%             numSeedsInFile = 500;
%             numWires = 600:100:1000;
            numWires = [2500, 3000];%1300:100:1600;
            Nidx    = floor((idx-1)/numSeeds) + 1;
            
            files = dir(strcat(netFolder, '/*.mat'))';
            N = numel(files);%numel(numWires) *numSeedsInFile;

%             assert(N == numel(files));
            nodes = zeros(N,1);
            genWires = zeros(N,1);
            seeds      = zeros(N,1);
            fnames    = cell(N,1);

            for i = 1:N
                conn = load(strcat(files(i).name));
                nodes(i) = double(conn.number_of_wires);    
                if ~isfield(conn, 'generating_number_of_wires')
                    conn.generating_number_of_wires = nodes(i);
                end
                genWires(i) = round(double(conn.generating_number_of_wires));
                seeds(i) = conn.this_seed;
                fnames{i} = files(i).name;
                clear('conn');
            end

            connFile = fnames{find((seeds == (seedIdx-1)) & (genWires == numWires(Nidx)), 1)};
            nameComment = strcat2({'_N', numWires(Nidx), '_seed', seedIdx - 1}, '%03.f');     
            disp(strcat2({'Seed: ', seedIdx - 1, ', N = ', numWires(Nidx)}));          
    end

    %%
    
    saveF1 = strcat(saveFolder, '/Vidx', num2str(Vidx), '/seed', num2str(seedIdx - 1,'%03.f'), '/');
    mkdir(fullfile(saveF1))
    
    DC_Vsweep_for_cluster(Vidx, saveF1, 1.05*0.01, 2.08*0.01, 0.95*0.01, connFile, 0 , '.', -1, 30, true, true, -1, 1, true, 0.02, nameComment, 1.0, true)
    
    
end