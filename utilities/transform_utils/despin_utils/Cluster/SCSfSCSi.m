%--------------------------------------------------------------------------
% NAME
%   SCSfSCSi
%
% PURPOSE
%   Use the spin frequency of the Cluster spacecraft as well as the output
%   from the sun sensor to determine how far into a spin each data
%   point was recorded. Then, using this information, create a transformation
%   matrix to transform the spinning frame about the spin axis backwards
%   through the spin cycle so that data points are co-aligned with the 
%   instrument's inertial frame. Rotate by an additional fixed 32.7 degrees
%   to change from the STAFF instrument frame to the FGM instrument frame.
%
%   NOTE
%       32.7 degrees = 0.5707226654 radians
%
% INPUTS
%   TIME:           in, required, type=double
%                   Time at which data was recorded.
%   SRTIME:         in, required, type=double array
%                   Sun reference time during the day on which data was
%                       recorded.
%   OMEGA:          in, required, type=double
%                   Spin rate of the spacecraft, in revolutions per second.
%
% RETURNS
%   ROTMAT:         out, optional, type=3xN double
%                   Matrix that will transform STAFF (search coil) data
%                       from the spinning frame to the flux-gate%
%                       magnetometer's instrument frame.
%--------------------------------------------------------------------------
function [rotmat] = SCSfSCSi(time, srtime, OMEGA)
    %
    %   routine to get a matrix to get to SCS system at any time,
    %   from an initial SCS-like system, but where the x-axis points
    %   along an x (body-like ) axis in the direction of yFSR at time = 0;     
    %   given an array of srtimes ( sun reference times)
    %
    %   see also SCSfFSR   and fast_rotat
    %
    %   correction angle is 32.7 degrees  =  0.5707226654   radians
    %
    
    % Get the Sun-Reference Time just prior to the given time stamp
    index = find(srtime > time, 1) - 1;
    if index < 1
        index = 1;
    end
    
    % How many radians into the spin are we? Subtract 32.7 degrees to be in
    % the FSR frame
    phi_F  = OMEGA*(time-srtime(index)) - 0.5707226654;
    cosphi = cos(phi_F);
    sinphi = sin(phi_F);
    
    % The spacecraft spins counter-clockwise, so we need to rotate the
    % coordinate system clockwise in order to despin properly.
    rotmat = [ cosphi -sinphi  0; ...
               sinphi  cosphi  0; ...
                 0       0     1];
end