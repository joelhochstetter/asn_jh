function y = invertArray(x)
%{
    Takes an array of integer mappings and takes inverse:
    e.g. invertArray([5,2,1,3,4]) = [3,2,4,5,1]

    If no inverse then assigns index of -1
    invertArray([7,2,1,3,4]) = [3,2,4,5,-1,-1,1]

    Assumes x is all positive integers
%}

    y = -1*ones(max(x),1);
    y(x) = 1:numel(x);

end