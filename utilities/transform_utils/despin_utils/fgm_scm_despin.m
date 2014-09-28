function [b_despun] = fgm_scm_despin(t, b, mission, sc, date, varargin)
    %
    % Transform data from the spinning spacecraft system to the despun spacecraft frame.
    % This process depends on the mission. Optional arguments for each mission are
    % defined below.
    %
    % CLUSTER
    %
    %   b_gse = fgm_scm_scs2gse(mission, t, b, sc, attitude_dir, srt_dir);
    %
    %       attitude_dir    - Directory in which to find spacecraft attitude data
    %       srt_dir         - Directory in which to find sun-reference-time data
    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\ CHECK INPUTS \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch mission
        % Cluster Optional Inputs
        case 'C'
            % The attitude and sun-reference time data directories must be provided
            if nargin < 6
                error('Incorrect number of inputs (%i) for mission %s', nargin, mission)
            end
            
            attitude_dir = varargin{1};
            srt_dir = varargin{2};
                    
        % Unrecognized Mission
        otherwise
            error('Unknown mission: %s', mission)
    end

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
    
    % Allocate memory for the transformed data.
    b_despun = zeros(size(b));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESPIN EACH DATA INTERVAL \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % for each continuous interval
    for k = 1:n_intervals

        % transform the data
        switch mission
            case 'C'
                b_despun(intervals(k,1):intervals(k,2), :) ...
                    = cluster_despin(t(intervals(k,1):intervals(k,2)), b(intervals(k,1):intervals(k,2), :), sc, date, attitude_dir, srt_dir);
        end
    end
end