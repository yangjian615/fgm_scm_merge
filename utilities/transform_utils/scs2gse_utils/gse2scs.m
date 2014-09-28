%--------------------------------------------------------------------------
% NAME
%   gse2scs
%
% PURPOSE
%   Return the transformation matrix to the despun spacecraft system (SCS)
%   to Geocentric Solar Ecliptic (GSE).
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
%                   Right-ascention of the spacecraft.
%   DEC:            in, required, type=double
%                   Declination of the spacecraft.
%
% RETURNS
%   GSE2SCS:        out, optional, type=float
%                   Transformation matrix to rotate GSE to SCS.
%
% USES
%   Uses the following external programs:
%       gei2scs.m
%       gei2gse.m
%       get_mjd.m
%--------------------------------------------------------------------------
function rot_gse2scs = gse2scs(year, month, day, secs, ra, dec)

    % My interpretation of how the program should work, based on file names.
%     rot_gei2scs = gei2scs(year,month,day,secs,ra,dec);
%     rot_gei2gse = gei2gse(date2mjd(year,month,day), secs/3600));
%     rot_gse2scs = rot_gei2scs * rot_gse2gei;

    rot_gse2scs =  gei2scs(year,month,day,secs,ra,dec) * ...
                  (gei2gse(date2mjd(year,month,day), secs/3600))';
end