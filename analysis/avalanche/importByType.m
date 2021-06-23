function [G, V, t, fname] = importByType(importMode, importFolder, idx)

    switch importMode
        case 0 %simulated data
            files = dir(strcat(importFolder, '/*.mat'));
            sims = multiImport(struct('importByName', files(idx).name, 'SimOpt', struct('saveFolder', importFolder)));
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
                    G = [G(2), G, G(end-1)]; 
                    %fix weird anomalies
                    G(G == inf) = max(G(G < inf));  
                    G(G == 0) = min(G(G > 0)); 
                    G(isnan(G)) = min(G(~isnan(G)));   
                    V(1) = V(1) + 1e-6;
                    V(end) = V(end) + 1e-6;                    
                    G(abs(V)< 1e-6) = (G(find(abs(V)< 1e-6)-1) + G(find(abs(V)< 1e-6)+1))/2;                  
                    G = G(2:end-1);
                else
                    t = my_tdms_struct.Untitled.Time.data;
                    t = t - t(1);
                    I = my_tdms_struct.Untitled.Input.data;
                    [t, I] = fixDupTimes(t, I);
                    V = str2double(my_tdms_struct.Props.Source__V_or_A_)*ones(size(I));
                    G = abs(I./V);
                    G = [G(2), G, G(end-1)]; 
                    %fix weird anomalies
                    G(G == inf) = max(G(G < inf));  
                    G(G == 0) = min(G(G > 0)); 
                    G(isnan(G)) = min(G(~isnan(G)));  
                    V(1) = V(1) + 1e-6;
                    V(end) = V(end) + 1e-6;                       
                    G(abs(V)< 1e-6) = (G(find(abs(V)< 1e-6)-1) + G(find(abs(V)< 1e-6)+1))/2;                  
                    G = G(2:end-1);                
                end
                fname = file.name;   
            end

            
        case 2 %text file - rintaro data format
            files = dir(strcat(importFolder, '/*.txt'));
            [t, I, V] = importCVRint(strcat(importFolder, '/', files(idx).name));
            t = t';
            I = I';
            V = V';
            G = abs(I./V);
            G(abs(V)< 1e-6) = NaN;
%             G = [G(2), G, G(end-1)];                                                          
%             G(abs(V)< 1e-6) = (G(find(abs(V)< 1e-6)-1) + G(find(abs(V)< 1e-6)+1))/2;
%             G(G == inf) = max(G(G < inf)); 
%             G(G == 0) = min(G(G > 0));                      
%             G = G(2:end-1);
%             G(isnan(G)) = min(G(~isnan(G)));   
            fname = files(idx).name;
            
        case 3 %data saved to .mat file
            files = dir(strcat(importFolder, '/*.mat'));
            load(strcat(importFolder, '/', files(idx).name), 't', 'G', 'V');
            fname = files(idx).name;   
            
        case 4 %data saved as .tdms: UCLA format
            files = dir(strcat(importFolder, '/*.tdms'));
            file = files(idx);
            ff = strcat(file.folder,'/',file.name);
            my_tdms_struct = TDMS_getStruct(ff);
            I  = my_tdms_struct.I_V_0.SMU_Current.data;
            t = my_tdms_struct.I_V_0.SMU_Current.Props.wf_increment*(1:numel(I));
            % V  = my_tdms_struct.I_V_0.SMU_Voltage.data;
%             V = my_tdms_struct.I_V_0.Voltage_Out_0.data;
            V = 1;
            G  = I./V;
            fname = files(idx).name;
           
    end 
            
    
end