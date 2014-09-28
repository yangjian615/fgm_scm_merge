%--------------------------------------------------------------------------
% NAME
%   ecliptic_longitude_sun
%
% PURPOSE
%   Reduce any angle (in degrees) to the range [0, 360).
%
%
% INPUTS
%   ANGLE:          in, required, type=double
%                   An angle in degrees.
%                   
%
% RETURNS
%   A:              out, required, type=double
%                   The same `ANGLE` reduced to be in the range [0, 360).
%--------------------------------------------------------------------------
function A = A360(ANGLE)
    A = mod(ANGLE,360);
end

%
%Alternative method:
%	I = fix(ANGLE/360.0);
%	A = ANGLE - I*360.0;
%	A(A<0) = A(A<0) +360;
%	if (A < 0) 
%       A=A+360.0;
%	end
%
