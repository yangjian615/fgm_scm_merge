%--------------------------------------------------------------------------
% NAME
%   gei2gse
%
% PURPOSE
%   Produce a transformation from GEI to GSE.
%
%   References:
%       - https://www.spenvis.oma.be/help/background/coortran/coortran.html
%       - Hapgood, M. A. (1992). Space physics coordinate transformations:
%           A user guide. Planetary and Space Science, 40(5), 711?717. 
%           doi:http://dx.doi.org/10.1016/0032-0633(92)90012-D
%       - Hapgood, M. A. (1997). Corrigendum. Planetary and Space Science,
%           45(8), 1047 ?. doi:http://dx.doi.org/10.1016/S0032-0633(97)80261-9
%
% INPUTS
%   MJD:            in, required, type=double
%                   Modified julian date.
%   UT:             in, required, type=double
%                   Universal Time in hours since midnight.
%
% RETURNS
%   T2:             out, required, type=double
%                   Number of days since 17 Nov 1858 at 00:00 UT, which is
%                       the definition of Modified Julian Date.
%--------------------------------------------------------------------------
function T2 = gei2gse(mjd, ut)
    % Convert degrees to radians.
    deg_to_rad = pi/180;
    
    % Time in Julian centruies from Epoch 2000 (12:00 UT, 1 Jan. 2000)
    %   - datestr(51544.5+datenum(1858, 11, 17)) = 01-Jan-2000 12:00:00
    T0=(fix(mjd)-51544.5)/36525.0;
    
    % Axial tilt
    obliq = obliquity_earth(T0)            * deg_to_rad;
    eLon  = ecliptic_longitude_sun(T0, ut) * deg_to_rad;
    
    %
    % The transformation from GEI to GSE, then is
    %   - T2 = <eLon, Z> <obliq, X>
    %   - A pure rotation about Z by angle obliq
    %   - A pure rotation about X by angle elon
    %
    
    % <obliq, X>
    sob = sin( obliq );
    cob = cos( obliq);
    T21 = [ 1    0    0;  ...
            0   cob  sob; ...
            0  -sob  cob];
    
    % <eLon, X>
    sol = sin(eLon);
    col = cos(eLon);
    T22 = [ col  sol  0; ...
           -sol  col  0; ...
             0    0   1];
         
    % Rotation from GEI to GSE
    T2 = T22*T21;
end
