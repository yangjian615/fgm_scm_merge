function [] = get_df(obj)
    %
    % Get the frequencies of the FFT bins. We want the width of the
    % frequency bins (df) as well as the duration of the FFT interval
    % in the time domain to be equal for both FGM and SCM.
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
    % n and d can be multiplied by an integer (m) to include
    % multiple periods in the same interval.
    %
    %       m * (d * dt_fgm) = m * (n * dt_scm)
    %
    % The length of the fft interval is then
    %
    %       len_fgm = m * d
    %       len_scm = m * n
    %
    % The width of the frequecy bins, then, is just the inverse of
    % each relationship
    %
    %       df_fgm = 1 / (len_fgm * dt_fgm)
    %       df_scm = 1 / (len_scm * dt_scm)
    %
    %       df_fgm = df_scm
    %
    obj.df = 1 ./ (obj.dt * obj.clen);
end