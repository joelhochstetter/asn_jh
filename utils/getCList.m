function cList = getCList(sims, field, changeVar)
    cList = zeros(numel(sims), 1);
    
    for i = 1:numel(sims)
        cList(i) = sims{i}.(field).(changeVar);
    end

end