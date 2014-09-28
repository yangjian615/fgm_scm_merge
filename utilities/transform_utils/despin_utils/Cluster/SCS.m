%--------------------------------------------------------------------------
% NAME
%   SCS
%
% PURPOSE
%   Transform data from the STAFF (search coil) instrument in the spinning
%   spacecraft reference frame to the inertial frame of the spacecraft,
%   co-aligned with the FSR (flux gate magnetometer) instrument frame. The
%   difference between the two STAFF and FSR inertial frames is 32.7
%   degrees.
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
function [b_scs] = SCS(data, OMEGA, dt, time, srtime)

    % Get the number of data points per period
    nPeriod = round((2*pi)/(OMEGA * dt ));
    
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
        
        %
        % Build a coordinate transformation that spins us clockwise back
        % to where an axis is pointing at the sun.
        SCS_mat = SCSfSCSi(time(sIndex), srtime, OMEGA);
        
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