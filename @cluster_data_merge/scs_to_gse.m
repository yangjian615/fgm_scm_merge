function [gse_data] = scs_to_gse(obj, t, scs_despun_data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from the spacecraft system (SCS) to geocentric
    % solar ecliptic (GSE).
    %
    
    dt = mode(diff(t));

    [omega, ra, dec] = obj.get_attitude(sc, date, t(1), attitude_dir);

    [srtime, year, month, day] = obj.get_srtime(sc, date, srt_dir);
    gse_data = GSE(scs_despun_data, ...
                   omega, dt, t, ...
                   srtime, year, month, day, ra, dec);
end