%--------------------------------------------------------------------------
% NAME
%   c_scs2gse
%
% PURPOSE
%   Rotate Cluster data from SR2 (despun coordinate system) to GSE.
%
% INPUTS
%   T:              in, required, type=Nx1 double
%                   Time tags of `DATA`.
%   DATA:           in, required, type=Nx3 double
%                   Data to be rotated into GSE.
%   SC:             in, required, type=string
%                   Number of the spacecraft for which the spin rate is to be
%                       determined. Options are {1 | 2 | 3 | 4}.
%   DATE:           in, required, type=string
%                   Date on which the ephemeris data is to be read. 'YYYYMMDD'
%                       format is required.
%   TIME:           in, required, type=double
%                   Time at which data interval starts. It is the time at
%                       which despinning will begin.
%   ATTITUDE_DIR:   in, required, type=string
%                   Directory in which to find Cluster attitude data. Files
%                       are named as "satt.cl#", where "#" represents the
%                       spacecraft number, SC.
%   SRT_DIR:        in, required, type=string
%                   Directory in which to find Cluster sun-reference time
%                       data. Files are named as "YYYYMMDD_#_srt", where
%                       "#" represents the spacecraft number, SC.
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
%       c_get_attitude.m
%       scs2gse.m
%--------------------------------------------------------------------------
function [gse_data] = c_scs2gse(t, scs_despun_data, sc, date, attitude_dir, srt_dir)
    %
    % Rotate data from the spacecraft system (SCS) to geocentric
    % solar ecliptic (GSE).
    %
    
    % Sample interval
    dt = mode(diff(t));

    % Spin rate, right ascention, and declination
    [omega, ra, dec] = cluster_get_attitude(sc, date, t(1), attitude_dir);

    % Sun reference time.
    [srtime, year, month, day] = cluster_get_srtime(sc, date, srt_dir);
    
    % Rotate
    gse_data = scs2gse(scs_despun_data, ...
                       omega, dt, t, ...
                       srtime, year, month, day, ra, dec);
end