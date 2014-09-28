%--------------------------------------------------------------------------
% NAME
%   SCSfGEI
%
% PURPOSE
%   Return the transformation to the despun spacecraft frame (SCS) from
%   Geocentric Equatorial Inertial system (GEI) at the given time, with ra
%   and dec ( in degrees ) of the spin vector.
%
%   GEI:
%       X = Direction from the earth to the first point of Aries (location
%           of the sun on the vernal equinox). This direction is the
%           intersection of Earth's equitorial plane and the ecliptic plane
%           and thus X lies in both planes.
%       Z = Parallel to the rotation axis of Earth.
%       Y = Completes the right-hand system (Z x X).
%
% INPUTS
%   YEAR:           in, required, type=double
%                   Year in which the data was collected.
%   MONTH:          in, required, type=double
%                   Month in which the data was collected.
%   DAY:            in, required, type=string
%                   Day in which the data was collected.
%   SECS:           in, required, type=double
%                   Seconds into `DAY`.
%   RA:             in, required, type=double
%                   Right-ascention of the spacecraft (degrees).
%   DEC:            in, required, type=double
%                   Declination of the spacecraft (degrees).
%
% RETURNS
%   SCS2GSE:        out, optional, type=float
%                   Transformation matrix to rotate SCS to GSE.
%
% USES
%   Uses the following external programs:
%       sunrad.m
%--------------------------------------------------------------------------
function gei2scs = gei2scs(year, month, day, secs, ra, dec)

    % Fractional number of days since the beginning of the year in
    % question.
    iday = datenum(year,month,day) - datenum(year,1,1) + 1;
    
    % Location of the sun
    SUN = solar_position(year,iday,secs);
    RAD = 180/pi;
    
    % RA and DEC form a spherical coordinate system.
    %   - RA  = number of hours past the vernal equinox (location on the
    %           celestial equator of sunrise on the first day of spring).
    %   - DEC = degrees above/below the equator
    cosd = cos( dec/RAD);

    % [x y z] components of the unit vector pointing in the direction of
    % the spin axis.
    %   - The spin axis points to a location on the suface of the celestial
    %       sphere.
    %   - ra and dec are the spherical coordinates of that location,
    %       with the center of the earth as the origin.
    %   - Transforming GEI to SCS transforms [0 0 1] to [x y z] = OMEGA
    OMEGA = [cos(ra/RAD)*cosd  sin(ra/RAD)*cosd  sin(dec/RAD)];
    
    % Form the X- and Y- vectors
    %   - X must point in the direction of the sun.
    %   - To ensure this, Y' = Z' x Sun
    %   - X' = Y' x Z'
    yhat  = normalize( cross(OMEGA, SUN) );
    xhat  = cross( yhat, OMEGA ) ;

    % Transformation from GEI to SCS.
    gei2scs = [ xhat; yhat; OMEGA];
end
