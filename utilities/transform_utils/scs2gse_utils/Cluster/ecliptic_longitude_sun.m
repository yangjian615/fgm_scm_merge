%--------------------------------------------------------------------------
% NAME
%   ecliptic_longitude_sun
%
% PURPOSE
%   Determine the ecliptic longitude of the sun
%
%   Note:
%       Strictly speaking, TDT (Terrestrial Dynamical Time) should be used
%       here in place of UT, but the difference of about a minute gives a
%       difference of about 0.0007° in lambdaSun.
%
%   References:
%       - https://www.spenvis.oma.be/help/background/coortran/coortran.html
%
%
% INPUTS
%   T0:             in, required, type=double
%                   Time in Julian centuries calculated from 12:00:00 UT
%                       on 1 Jan 2000 (known as Epoch 2000) to the previous
%                       midnight. It is computed as:
%                           T0 = (MJD - 51544.5) / 36525.0
%   UT:             in, required, type=double
%                   
%
% RETURNS
%   ELON:           out, required, type=double
%                   Ecliptic longitude of the sun.
%--------------------------------------------------------------------------
function eLon = ecliptic_longitude_sun(T0, UT)
	% Convert degrees to radians.
    C = pi/180;

    % Sun's Mean anomoly
    M = A360(357.528 + 35999.050*T0 + 0.04107*UT);

    % Mean longitude
    LAMBDA = A360(280.460 + 36000.772*T0 + 0.04107*UT);

    % Ecliptic Longitude
    eLon = A360(LAMBDA + (1.915-0.0048*T0)*sin(M*C) + 0.020*sin(2*M*C));
end
