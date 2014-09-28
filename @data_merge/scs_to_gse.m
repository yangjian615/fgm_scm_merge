function [gse_data] = scs_to_gse(obj, t, scs_despun_data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from the spacecraft system (SCS) to geocentric
    % solar ecliptic (GSE).
    %
    % This method depends on the attitude of the spacecraft and, hence, is mission-
    % specific. Therefore, this method should be over-ridden by a superclass
    % @[mission]_data_merge.
    %
    error(['This is just a place-holder function. ' ...
           'Overwrite this method to make it data-type/mission specific.'])
end