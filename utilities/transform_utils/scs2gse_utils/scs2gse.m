%--------------------------------------------------------------------------
% NAME
%   scs2gse
%
% PURPOSE
%   SCS represents any coordinate system for which the direction of the
%   z-axis is given in terms of right ascension and declination, the x-axis
%   points toward the sun, and the y-axis completes the right-handed
%   system.
%
%   GSE is Geocentric Solar Ecliptic:
%       Z points perpendicular to earth's ecliptic plane
%       Y points toward dusk, opposite to Earth's motion
%       X completes the right-handed system and points toward the sun.
%
% INPUTS
%   B_SCS:          in, required, type=Nx3 double
%                   3-component vector data in the despun spacecraft system.
%   DT:             in, required, type=double
%                   Sampling interval at which `DATA` was recorded.
%   TIME:           in, required, type=Nx1 double
%                   Time tags of `DATA` in seconds since midnight.
%   YEAR:           in, required, type=string
%                   Year in which the data was collected.
%   MONTH:          in, required, type=string
%                   Month in which the data was collected.
%   DAY:            in, required, type=string
%                   Day in which the data was collected.
%   RA:             in, required, type=Lx1 double
%                   Right-ascention of the spacecraft.
%   DEC:            in, required, type=Lx1 double
%                   Declination of the spacecraft.
%
% RETURNS
%   B_GSE:          out, optional, type=float
%                   Data represented in the GSE coordinate system.
%
% USES
%   Uses the following external programs:
%       ctime0.m
%--------------------------------------------------------------------------
function [b_gse] = scs2gse(b_scs, dt, time, year, month, day, ra, dec)

    % Initial loop conditions
    N_len   = length(b_scs);        % Total number of points.
    N_loop  = round(1000/ dt );     % Number of data points in 1000 seconds.
    n_lendo = ceil(N_len/N_loop);   % Number of 1000s intervals.
    
    % Allocate memory to output.
    b_gse   = b_scs;

    for jloop = 0:n_lendo-1
        % Interval being transformed.
        sIndex  = jloop*N_loop +1;
        eIndex  = min([sIndex + N_loop, N_len]);
        iMidPt  = round( (sIndex + eIndex) / 2 );
        
        % Rotation matrix to GSE
        %   - Pick a reference time in the middle.
        %   - Use single coordinate transformation for all points in group.
        GSE_mat = gse2scs(year, month, day, time(iMidPt), ra, dec);
        
        % Transform
        b_gse(sIndex:eIndex,:) = b_scs(sIndex:eIndex,:)*GSE_mat;
    end
end