function [cross, above, below] = thresholdCrossing(x, thresh)
%{
    For a time-series vector x records the points where x crosses above the
    threshold  as above. Crosses below threshold as below. cross records
    all crossings with threshold

%}
    y = diff(x > thresh);
    above = find(y > 0);
    below = find(y < 0);
    cross = above;
    cross(below) = 1;
end