function [n_fgm, n_scm] = merge_dt_ratio(dt_fgm, dt_scm)
    %
    % Get the number of points from FGM and SCM that creates an
    % creates an equal interval of time.
    %
    % If we take the ratio of dt_fgm with dt_staff to get a
    % rational number:
    %
    %       dt_fgm / dt_scm = n[umerator] / d[enominator]
    %
    % where n and d are integers, then the number of points
    % points required to make the time intervals equal is
    %
    %       d * dt_fgm = n * dt_scm
    %
    [n_fgm, n_scm] = rat(dt_scm / dt_fgm);
end