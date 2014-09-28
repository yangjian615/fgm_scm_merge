%--------------------------------------------------------------------------
% NAME
%   cluster_get_srtime
%
% PURPOSE
%   Read sun reference time (SRT) data for the Cluster mission. The sun
%   reference time is the time at which the sun sensor on-board the
%   spacecraft detected the sun during its rotation.
%
%   NOTE:
%       The naming convention of the SRT files is "YYYYMMDD_#_srt", where
%           "YYYYMMDD"  -   year (YY), month (MM), day (DD)
%           "#"         -   Spacecraft number
%
%       This data can be used to determine the spin rate of the spacecraft.
%
% INPUTS
%   SC:             in, required, type=string
%                   Number of the spacecraft for which the spin rate is to
%                       be determined. Options are {1 | 2 | 3 | 4}.
%   DATE:           in, required, type=string
%                   Date on which the SRT data is to be read. 'YYYYMMDD'
%                       format is required.
%   SRT_DIR:        in, required, type=string
%                   Directory in which to file Cluster sun reference time
%                       (SRT) data.
%
% RETURNS
%   SRTIME:         out, required, type=double array
%                   Sun reference time, returned in units of seconds since
%                       midnight on DATE.
%   YEAR:           out, optional, type=double
%                   The year portion of DATE.
%   MONTH:          out, optional, type=double
%                   The month portion of DATE.
%   DAY:            out, optional, type=double
%                   The day portion of DATE.
%
% USES
%   Uses the following external programs:
%       ctime0.m
%--------------------------------------------------------------------------
function [srtime, year, month, day] = cluster_get_srtime(sc, date, srt_dir)
    
    % Remove delimeters
    if length(date) > 8
        [year, month, day] = dissect_date(date);
        date_out = [year, month, day];
    else
        date_out = date;
    end

    % Load the SRT data.
    srtime = load(fullfile(srt_dir, [date_out, '_', sc, '_srt']));
    
    % CTIME0() takes DATE='YYYYMMDD' and returns the number of seconds
    % since Jan 1 1970. SRTIME is the sun reference time given in the
    % number of seconds since Jan 1 1970.
    
    % Return the sun reference time in seconds since midnight on DATE
    srtime = srtime - ctime0(date_out);
    year   = str2double(date_out(1:4));
    month  = str2double(date_out(5:6));
    day    = str2double(date_out(7:8));
end