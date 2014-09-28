%--------------------------------------------------------------------------
% NAME
%   obliquity_earth
%
% PURPOSE
%   Determine the axial tilt, a.k.a obliquity. It is the angle between an
%   object's rotational axis and a line perpendicular to its orbital plane.
%
%   References:
%       - https://www.spenvis.oma.be/help/background/coortran/coortran.html
%       - U.S. Naval Observatory, Almanac for Computers 1990. Nautical 
%           Almanac Office, U.S. Naval Observatory, Washington, D.C., 1989.
%
%
% INPUTS
%   T0:             in, required, type=double
%                   Time in Julian centuries calculated from 12:00:00 UT
%                       on 1 Jan 2000 (known as Epoch 2000) to the previous
%                       midnight. It is computed as:
%                           T0 = (MJD - 51544.5) / 36525.0
%
% RETURNS
%   obliquity:      out, required, type=double
%                   Obliquity of Earth's ecliptic orbit.
%--------------------------------------------------------------------------
function obliquity = obliquity_earth(T0)
    obliquity = 23.439 - 0.013*T0;
end