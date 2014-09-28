function [] = get_fft_clen(obj, multiplier)
    %
    % Calculate the number of points in an FFT interval, where the
    % interval is chosen such that the period spanned by FGM and
    % SCM are equal.
    %
    % The number of points chosen for the interval can be an
    % integer multiple of the least number of points required to
    % create such an interval.
    %
    
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
    %       m * (d * dt_fgm) = m * (n * dt_scm)
    %
    % The length of the fft interval is then
    %       len_fgm = m * d
    %       len_scm = m * n
    %
    
    % if no multiplier is given, choose 2^6
    if nargin == 1
        multiplier = 64;
    end
    
    % calculate the number of points per FFT window
    obj.clen = multiplier * obj.n;
end