function [time_gaps, n_gaps] = find_gaps(time, n_min, n_max)
    %
    % Find data gaps between n_min and n_max number of samples.
    %


    % only fill the data gaps if they are small; 
    %   i.e., 2*dt < gap < 6*dt
    if nargin == 2
        n_min = 1.5;
        n_max = 6;
    end
    % calculate the time interval between each point
    % take the mode as being the desired time interval
    dt = diff(time);
    dt_mode = mode(dt);

    % find data gaps the lie within the specified range
    time_gaps = find(dt >= dt_mode*n_min & dt < n_max*dt_mode);
    n_gaps = length(time_gaps);
end