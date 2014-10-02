%--------------------------------------------------------------------------
% NAME
%   cluster_despin
%
% PURPOSE
%   Despin Cluster data from the spinning spacecraft frame to the inertial
%   spacecraft frame.
%
% INPUTS
%   T:              in, required, type=double array
%                   Time at which DATA were recorded.
%   DATA:           in, required, type=3xN double array
%                   3-component vector data to be despun.
%   SC:             in, required, type=string
%                   Number of the spacecraft for which the spin rate is to be
%                       determined. Options are {1 | 2 | 3 | 4}.
%   DATE:           in, required, type=string
%                   Date on which the ephemeris data is to be read. 'YYYYMMDD'
%                       format is required.
%   TIME:           in, required, type=double
%                   Time at which data interval starts. It is the time at which
%                       despinning will begin.
%   ATTITUDE_DIR:   in, required, type=string
%                   Directory in which to file Cluster attitude data. Files
%                       are named as "satt.cl#", where "#" represents the
%                       spacecraft number, SC.
%   SRT_DIR:        in, required, type=string
%                   Directory in which to file Cluster sun reference time
%                       (SRT) data. The naming convention of the SRT files
%                       is "YYYYMMDD_#_srt", where "YYYYMMDD" is the year
%                       (YYYY), month (MM), and day (DD) and "#" is the
%                       spacecraft number, SC.
%
% RETURNS
%   OMEGA:          out, optional, type=float
%                   Spin rate of the spacecraft calculated as
%                       OMEGA = 2*pi * (rev/min) / (60sec/min)
%   RA:             out, optional, type=float
%                   Right ascention of the spacecraft at time TIME.
%   DEC:            out, optional, type=float
%                   Declination of the spacecraft at time TIME.
%
% USES
%   Uses the following external programs:
%       cluster_get_attitude.m
%       cluster_get_strime.m
%       SCS.m
%--------------------------------------------------------------------------
function [despun] = cluster_despin(t, data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from which the fields are spinning and the
    % spacecraft is static to one in which the fields are static
    % and the spacecraft is spinning.
    %
    dt = mode(diff(t));

    % Get the number of radians the spacecraft spins every second
    omega = cluster_get_attitude(sc, date, t(1), attitude_dir);

    % Get the Sun-Reference Times
    srtime = cluster_get_srtime(sc, date, srt_dir);
    
    % Despin the data
    %   - Note that omega is given as a constant scalar value.
    despun = STAFF_despin(data, omega, dt, t, srtime);
end