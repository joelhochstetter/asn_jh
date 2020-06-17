function [G, V, t, fname] = importByType(importMode, importFolder, idx)

    switch importMode
        case 0 %simulated data
            files = dir(strcat(importFolder, '/*.mat'));
            sims = multiImport(struct('importByName', files(idx).name, struct('SimOpt', struct('saveFolder', importFolder))));
            G = sims{1}.netC;
            V = sims{1}.Stim.Signal;
            t = sims{1}.Stim.dt:sims{1}.Stim.dt:sims{1}.Stim.T;   
            fn = split(sims{1}.filename, '/');
            fname = char(fn(end));
            
        case 1 %TDMS file, datatype of Adrian's file from labview
            files = dir(strcat(importFolder, '/*.tdms'));
            file = files(idx);
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
                fname = file.name;   
            end

            
        case 2 %text file - rintaro data format
            files = dir('*.txt');
            [t, I, V] = importCVRint(files(idx).name);
            G = I./V;
            G(abs(V)< 1e-6) = NaN;
            fname = files(idx).name;   
    end 
            
    
end
    

