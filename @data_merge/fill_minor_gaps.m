function [filled_t, filled_b] = fill_minor_gaps(obj, t, b, n_min, n_max)

    %
    % Fill all data gaps that are between n_min and n_max number of
    % samples.
    %

    % find where the time gaps are located
    [time_gaps, n_gaps] = obj.find_gaps(t, n_min, n_max);

    % make an editable copy of the time and field arrays
    filled_t = t;
    dt = (filled_t(end) - filled_t(1)) / length(filled_t);
    n_total = 0;

    % for each gap...
    for j=1:n_gaps
        % fill in the gap
        fill = filled_t(time_gaps(j)):dt:filled_t(time_gaps(j)+1);
        n_fill = length(fill) - 2;

        % first:step_size:last does not include the last data point
        % if the step_size steps beyond it. We want to include the
        % last data point no matter what.
        % e.g. 1:1.5:5 = 1, 2.5, 4 ... where as we want ...
        %      1:1.5:5 = 1, 2.5, 4, 5
        % but only if the last point is more than 65% of step_size
        % away from the penultimate point.
        if (filled_t(time_gaps(j)+1) - fill(end)) / dt > 0.65
            fill = [fill filled_t(time_gaps(j)+1)];
            n_fill = n_fill + 1;
        end

        % put the filler times into to time array
        filled_t = [filled_t(1:time_gaps(j)-1); fill'; filled_t(time_gaps(j)+2:end)];

        % move the other gaps ahead by the number of points
        % inserted
        if j < n_gaps
            time_gaps(j+1:end) = time_gaps(j+1:end) + n_fill;
        end

        % count the total number of points filled in
        n_total = n_total + n_fill;
    end

    % interpolate the magnetic field at the new time points
    filled_b = zeros(length(filled_t), 3);
    filled_b(:, 1) = interp1(t, b(:, 1), filled_t);
    filled_b(:, 2) = interp1(t, b(:, 2), filled_t);
    filled_b(:, 3) = interp1(t, b(:, 3), filled_t);
end