%--------------------------------------------------------------------------
% NAME
%   SCSfSCSi
%
% PURPOSE
%   Transform from the STAFF's Sensor Coordinate System (SCS) to the despun
%   Spin Reference2 (SR2) system. Rotate by an additional 32.7 degrees
%   about the spin axis to bring STAFF's  axes into alignment with those of
%   FSR. Finally, interchange STAFF's axes so that [x,y,z]_STAFF
%   corresponds to [x,y,z]_FSR.
%
%   NOTE
%       32.7 degrees = 0.5707226654 radians
%
%   REFERENCES:
%       Robert, P., Cornilleau-Wehrlin, N., Piberne, R., de Conchy, Y., 
%           Lacombe, C., Bouzid, V., ? Canu, P. (2014). CLUSTER-STAFF 
%           search coil magnetometer calibration - comparisons with FGM. 
%           Geoscientific Instrumentation, Methods and Data Systems, 3(2),
%           153?177. doi:10.5194/gi-3-153-2014
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
function [rotmat] = STAFF2FSR_despun(time, srtime, OMEGA)
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
    if isempty(index)
        index = length(srtime);
    end
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