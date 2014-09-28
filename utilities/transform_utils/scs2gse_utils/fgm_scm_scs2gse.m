%--------------------------------------------------------------------------
% NAME
%   fgm_scm_scs2gse
%
% PURPOSE
%   Transform spacecraft data from the inertial spacecraft frame to
%   geocentric solar ecliptic (GSE).
%
% INPUTS
%   MISSION:        in, required, type=string
%                   Spacecraft mission from which data is taken. Choices:
%                       "C"     -   Cluster
%                       "RBSP"  -   Radiation Belt Storm Probes (Van Allen
%                                   Probes)
%   T:              in, required, type=double array
%                   Time at which B were recorded.
%   B:              in, required, type=3xN double array
%                   3-component vector data to be transformed from the
%                       spacecraft's interial frame to GSE.
%   SC:             in, required, type=string
%                   Number of the spacecraft for which the spin rate is to be
%                       determined. Options are {1 | 2 | 3 | 4}.
%   DATE:           in, required, type=string
%                   Date on which the ephemeris data is to be read. 'YYYYMMDD'
%                       format is required.
%   VARARGIN:       in, required
%                   Mission-specific parameters.
%                       CLUSTER
%                           attitude_dir - Directory in which to find
%                                          spacecraft attitude data.
%                           srt_dir      - Directory in which to find sun
%                                          reference time (SRT) data.
%
%                       RBSP
%                           n_sec  - Number of seconds of data to manually
%                                    transform.
%                           kernel - The spice kernel to be used to
%                                    transform the data.
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
%       cluster_scs2gse.m
%--------------------------------------------------------------------------
function [b_gse] = fgm_scm_scs2gse(mission, t, b, sc, date, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\ CHECK INPUTS \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch mission
        % Cluster Optional Inputs
        case 'C'
            % The attitude and sun-reference time data directories must be provided
            if nargin ~= 7
                error('Incorrect number of inputs (%i) for mission %s', nargin, mission)
            end
            
            attitude_dir = varargin{1};
            srt_dir = varargin{2};
        
        % Cluster Optional Inputs
        case 'RBSP'
            % 'date' is mandatory for RBSP, so 5 arguments must be given
            if nargin < 5 || nargin > 7
                error('Incorrect number of inputs (%i) for mission %s', nargin, mission)
            end
            
            % Make a cell array of default values
            optArgsToUse = {0, ...                  % # of sec. of data to despin manually
                            char(zeros(0,1))};      % default kernel
            
            % Over-ride the default values with user-supplied values
            nOptParams = length(varargin);
            optArgsToUse(1:nOptParams) = varargin;
            
            % Give the inputs memorable names.
            [n_sec, kernel] = optArgsToUse{:};
            
        % Unrecognized Mission
        otherwise
            error('Unknown mission: %s', mission)
    end
    clear varargin
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND INTERVALS OF CONTINUOUS DATA \\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Find major data gaps. Make a list of start and stop indices for each interval.
    [intervals, n_intervals] = find_gaps(t, 6, inf);
    if n_intervals == 0
        intervals = [1 length(t)];
        n_intervals = 1;
    else
        % The concatenation that follows requires a row vector.
        if iscolumn(intervals)
            intervals = intervals';
        end
        
        % "find_gaps" returns the number of data gaps. There are "n_intervals + 1" number
        % of data intervals
        intervals = [1, intervals+1; intervals, length(t)]';
        n_intervals = n_intervals + 1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSFORM TO GSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Allocate memory for the transformed data.
    b_gse = zeros(size(b));
    
    % for each continuous interval
    for k = 1:n_intervals
        msg = sprintf('Transforming interval %d of %d', k, n_intervals);
        disp(msg);

        % transform the data
        switch mission
            case 'C'
                % Transform to GSE
                b_gse(intervals(k,1):intervals(k,2), :) ...
                    = cluster_scs2gse(t(intervals(k,1):intervals(k,2)), ...
                                      b(intervals(k,1):intervals(k,2), :), sc, date, ...
                                      attitude_dir, srt_dir);
            case 'RBSP'
                % Convert seconds since midnight to ephemeris time.
                %   Start by finding the TT2000 time for the current date.
                %   Convert SSM to nanoSSM and add it to the beginning of the day TT2000.
                %   Convert TT2000 to ET.
                [year, month, day] = dissect_date(date, 'double');
                tt2000 = computett2000([year month day 0 0 0 0 0 0]);
                t_tt2000 = tt2000 + int64(t*1e9);
                et = epoch_to_et(t_tt2000, 'kernel', kernel);
                
                clear t_tt2000
                
                % Transform to GSE
                b_gse(intervals(k,1):intervals(k,2), :) ...
                    = rbsp_scs2gse(b(intervals(k,1):intervals(k,2), :), ...
                                   et(intervals(k,1):intervals(k,2)), sc, ...
                                   'n_sec', n_sec, 'kernel', kernel);
        end
    end
end