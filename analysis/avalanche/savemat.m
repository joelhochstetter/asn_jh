function savemat(saveFolder, critResults, events, netC)
    save(strcat(saveFolder,'/critResults.mat'), 'critResults');
    save(strcat(saveFolder,'/events.mat'),       'events');
    save(strcat(saveFolder,'/netC.mat'),       'netC');
    
end