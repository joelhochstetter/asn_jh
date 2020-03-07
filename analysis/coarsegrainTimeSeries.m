n = 10; % average every n values
a = reshape(cumsum(ones(n,10),2),[],1); % arbitrary data
b = arrayfun(@(i) mean(a(i:i+n-1)),1:n:length(a)-n+1)' % the averaged vector