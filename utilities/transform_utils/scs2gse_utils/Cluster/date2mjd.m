%--------------------------------------------------------------------------
% NAME
%   date2mjd
%
% PURPOSE
%
%   Original comments by Roy Torbret:
%       This calculates the Modified Julian Date.
%       This is the days since 17 Nov 1858 ( at 00:00 UT )
%       replaces the machine-dependent piece of shit
%       provided by Hapgood.
%
%
% INPUTS
%   YEAR:           in, required, type=double
%                   Year in which the data was collected.
%   MONTH:          in, required, type=double
%                   Month in which the data was collected.
%   DAY:            in, required, type=string
%                   Day in which the data was collected.
%
% RETURNS
%   OUTDAT:         out, required, type=double
%                   Number of days since 17 Nov 1858 at 00:00 UT, which is
%                       the definition of Modified Julian Date.
%--------------------------------------------------------------------------
function outdat = date2mjd(year, month, day)

    % Modified Julian Date
    %   - Fractional number of days since 17 Nov. 1858
    %   - datenum(1858, 11, 17) = 678942
    outdat = datenum(year, month, day) - 678942 ;
end
