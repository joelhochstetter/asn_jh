function savemat(saveFolder, critResults, events)
    save(strcat(saveFolder,'/critResults.mat'), 'critResults');
    save(strcat(saveFolder,'/events.mat'),       'events');
end