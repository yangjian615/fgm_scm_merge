function [filename] = make_cluster_filename(experiment, sc, date, tstart, tend)

    % Remove any delimeters.
    [year, month, day] = dissect_date(date);
    [sHr, sMin, sSec]  = dissect_time(tstart);
    [eHr, eMin, eSec]  = dissect_time(tend);
    
    % Recreate the dates and times without delimeters.
    the_date  = [year, month, day];
    the_sTime = [sHr, sMin, sSec];
    the_eTime = [eHr, eMin, eSec];

    % Form the file name.
    filename = ['C', sc, '_', experiment, '__', ...
                the_date, '_', the_sTime, '_', ...
                the_date, '_', the_eTime, '_', '*.cdf'];

end