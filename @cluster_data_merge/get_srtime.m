
function [srtime, year, month, day] = get_srtime(sc, date, srt_dir)
    %
    %   input sun-reference times
    %
    %   be sure to use these data to determine OMEGA
    %
    %   We will eventually need a routine to clean up these times.
    %   also year month day from CDATE
    %
    
    % Remove delimeters from the date.
    if length(date) > 8
        [year, month, day] = dissect_date(date);
        date_out = [year, month, day];
    else
        date_out = date;
    end
    
    srt_file = fullfile(srt_dir, date_out, '_', sc, '_srt');
    srtime = load(srt_file);
    
    % CTIME0() takes DATE='YYYYMMDD' and returns the number of seconds
    % since Jan 1 1970. SRTIME is the sun reference time given in the
    % number of seconds since Jan 1 1970.
    
    % Return the sun reference time in seconds since midnight on DATE
    srtime = srtime - ctime0(date_out);
    year  = str2double(date_out(1:4));
    month = str2double(date_out(5:6));
    day   = str2double(date_out(7:8));
end