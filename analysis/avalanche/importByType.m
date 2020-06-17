function [G, V, t, fname] = importByType(importMode, idx)

    switch importMode
        case 0 %simulated data
            sims = multiImport(struct('importAll', true));
            numFiles = numel(sims);
            for i = 1:numel(sims)
                Gvals{i} = sims{i}.netC;
                Vvals{i} = sims{i}.Stim.Signal;
                tvals{i} = sims{i}.Stim.dt:sims{i}.Stim.dt:sims{i}.Stim.T;   
                fn = split(sims{i}.filename, '/');
                fname{i} = char(fn(end));
            end
        case 1 %TDMS file, datatype of Adrian's file from labview
            files = dir(strcat(importFolder, '/*.tdms'));
            for file = files'
                ff = strcat(file.folder,'/',file.name);
                my_tdms_struct = TDMS_getStruct(ff);
                if isfield(my_tdms_struct,'Untitled')
                    if isfield(my_tdms_struct.Untitled,'Volt')
                        t = my_tdms_struct.Untitled.Time.data;
                        t = t - t(1);
                        I = my_tdms_struct.Untitled.Input.data;
                        [~, I] = fixDupTimes(t, I);

                        V = my_tdms_struct.Untitled.Volt.data;
                        [t1, V] = fixDupTimes(t, V); 
                        t = t1;
                        G = abs(I./V);
                        G(abs(V)< 1e-6) = NaN;
                    else
                        t = my_tdms_struct.Untitled.Time.data;
                        t = t - t(1);
                        I = my_tdms_struct.Untitled.Input.data;
                        [t, I] = fixDupTimes(t, I);
                        V = str2double(my_tdms_struct.Props.Source__V_or_A_)*ones(size(I));
                        G = abs(I./V);
                        G(abs(V)< 1e-6) = NaN;
                    end
                    
                    numFiles = numFiles + 1;
                    Gvals{numFiles} = G;
                    Vvals{numFiles} = V;
                    tvals{numFiles} = t;
                    fname{numFiles} = file.name;   
                end

            end
        case 2 %text file - rintaro data format
            files = dir('*.txt');
            [t, I, V] = importCVRint(files(idx).name);
            G = I./V;
            G(abs(V)< 1e-6) = NaN;
                numFiles = numFiles + 1;
                Gvals{numFiles} = G';
                Vvals{numFiles} = V';
                tvals{numFiles} = t';
                fname{numFiles} = file.name;   
    end 
            
    
end
    

