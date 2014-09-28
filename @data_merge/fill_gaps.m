function [t, b, ints] = fill_gaps(obj, ints, n_min, n_max)
    %
    % Fill data gaps that are between n_min and n_max number of samples.
    % "ints" is an array of start and end indices that outline the
    % intervals in which to look for these data gaps.
    %

    % count the number of minor gaps so that we can allocate memory to the
    % filled time and field arrays
    n_minor_gaps = obj.count_minor_gaps(ints, n_min, n_max);
    n_pts = length(obj.t);

    % allocate memory to the time and field arrays
    t = zeros(n_pts + n_minor_gaps*(n_max + 1), 1);
    b = zeros(n_pts + n_minor_gaps*(n_max + 1), 1, 3);
    t(1:n_pts) = obj.t;
    b(1:n_pts, :) = obj.b;

    %
    % Fill in the minor gaps for each major interval
    %
    n_gaps = length(ints(:,1));
    n_diff_total = 0;

    for i = 1:n_gaps
        % get ith data interval
        t_temp = t(ints(i,1):ints(i,2));
        b_temp = b(ints(i,1):ints(i,2), :);

        % fill in the minor gaps
        [t_temp, b_temp] = obj.fill_minor_gaps(t_temp, b_temp, n_min, n_max);

        % find how many points were added
        n_new = length(t_temp);
        n_old = ints(i,2) - ints(i,1) + 1;
        n_diff = n_new - n_old;
        n_diff_total = n_diff_total + n_diff;

        % shift the end of the array down to make room for the new
        % points. "circshift" will shift all of the points to the
        % right by "n_diff", wrapping the final zeros back around
        % to the beginning. The wrap-around is ok because those
        % points are going to be over-written in a second.
        t(ints(i,2)+1:end)   = circshift(t(ints(i,2)+1:end),   [n_diff, 0]);
        b(ints(i,2)+1:end,:) = circshift(b(ints(i,2)+1:end,:), [n_diff, 0]);

        % add that number of points to the remaining intervals
        ints(i,2) = ints(i,2) + n_diff;
        if i < n_gaps
            ints(i+1:end,:) = ints(i+1:end,:) + n_diff;
        end

        % store the current segment of data into the total field array
        t(ints(i,1):ints(i,2)) = t_temp;
        b(ints(i,1):ints(i,2), :) = b_temp;
    end

    %remove the extra points at the end
    t = t(1:n_pts+n_diff_total);
    b = b(1:n_pts+n_diff_total, :);
end