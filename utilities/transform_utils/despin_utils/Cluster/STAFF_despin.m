%--------------------------------------------------------------------------
% NAME
%   srs2scs_STAFF
%
% PURPOSE
%   Transform from the Spin Reference Frame (SRS) to the Spin Reference2
%   (SR2) system. At the same time, transform from STAFF's
%   coordinate system to that of FSR. This involves a fixed rotation of
%   32.7 degrees and the interchange of axes.
%
%   REFERENCES:
%       Robert, P., Cornilleau-Wehrlin, N., Piberne, R., de Conchy, Y., 
%           Lacombe, C., Bouzid, V., ? Canu, P. (2014). CLUSTER-STAFF 
%           search coil magnetometer calibration - comparisons with FGM. 
%           Geoscientific Instrumentation, Methods and Data Systems, 3(2),
%           153?177. doi:10.5194/gi-3-153-2014
%
% INPUTS
%   DATA:           in, required, type=3xN double array
%                   3-component vector data to be despun. DATA is assumed
%                       to be measured by the STAFF instrument (or by an
%                       instrument aligned with the three axes of STAFF).
%   OMEGA:          in, required, type=double
%                   Spin rate of the spacecraft, in revolutions per second.
%   DT:             in, required, type=double
%                   Sampling period at which DATA was recorded.
%   TIME:           in, required, type=double array
%                   Time at which DATA was recorded.
%   SRTIME:         in, required, type=double array
%                   Sun reference time during the day on which data was
%                       recorded.
%
% RETURNS
%   B_SCS:          out, optional, type=3xN double
%                   The result of transforming DATA into the inertial
%                       frame of the spacecraft.
%
% USES
%   Uses the following external programs:
%       SCSfSCSi.m
%       fast_rot.m
%--------------------------------------------------------------------------
function [b_scs] = STAFF_despin(data, OMEGA, dt, time, srtime)

    % Get the number of data points per period
    nPeriod = round((2*pi)/(OMEGA * dt));
    
    nPts   = length(data);         % length of data interval
    nSpins = ceil(nPts/nPeriod);   % number of spin periods per data interval
    b_scs  = data;                 % allocate memory for new data
    
    % for each period
    for jloop = 0:nSpins-1
    %
    %  first rotate into initial system
    %
        % Get the start index of the current period
        sIndex = jloop*nPeriod + 1;
        
        % Get the stop index of the current spin period. Stop early if
        % there are not enough data points to fill a whole period.
        eIndex = min([sIndex+nPeriod-1, nPts]);
        
        % The number of points in this spin period
        j_len = eIndex - sIndex + 1;
        
        % Build a coordinate transformation that spins us clockwise back
        % to where an axis is pointing at the sun.
        SCS_mat = STAFF2FSR_despun(time(sIndex), srtime, OMEGA);
        
        % fast_rotat
        %   - Despin all points to time(sIndex)
        %   - Interchange axes so that
        %       x -> z' (spin-axis)
        %       y -> x'
        %       z -> y'
        %
        % SCS_mat
        %   - Rotate all points so that X' points along X-FGM.
        b_scs(sIndex:eIndex,:) = single(fast_rotat(data(sIndex:eIndex,:),dt,j_len, OMEGA)*SCS_mat');
    end
end