%--------------------------------------------------------------------------
% NAME
%   cluster_get_attitude
%
% PURPOSE
%   Calculate the spin rate of a Cluster satellite using its ephemeris data.
%
% INPUTS
%   SC:             in, required, type=string
%                   Number of the spacecraft for which the spin rate is to be
%                       determined. Options are {1 | 2 | 3 | 4}.
%   DATE:           in, required, type=string
%                   Date on which the ephemeris data is to be read. 'YYYYMMDD'
%                       format is required.
%   TIME:           in, required, type=double
%                   Time at which data interval starts. It is the time at
%                       which despinning will begin.
%   ATTITUDE_DIR:   in, required, type=string
%                   Directory in which to file Cluster attitude data. Files
%                       are named as "satt.cl#", where "#" represents the
%                       spacecraft number, SC.
%
% RETURNS
%   OMEGA:          out, optional, type=float
%                   Spin rate of the spacecraft calculated as
%                       OMEGA = 2*pi * (rev/min) / (60sec/min)
%   RA:             out, optional, type=float
%                   Right ascention of the spacecraft at time TIME.
%   DEC:            out, optional, type=float
%                   Declination of the spacecraft at time TIME.
%
% USES
%   Uses the following external programs:
%       ctime0.m
%--------------------------------------------------------------------------
function [OMEGA, ra, dec] = cluster_get_attitude(sc, date, time, attitude_dir)
    %
    %   get the attitude data
    %
    attitude_file = fullfile(attitude_dir, ['satt.cl', sc]);
    fid           = fopen(attitude_file);
    assert(fid ~= -1, ['Cannot open attitude file "', attitude_file, '".'])
    
    % read the spacecraft number, the first date, the first time,
    % skip over the second time and date, read the right ascention,
    % declination, and revolutions per minute, then skip the rest
    %                    SC   R YYYY-MM - DD T HH : MM : SS Z 
    Attd = fscanf( fid, '%g %*s %g - %g - %g T %g : %g : %g Z %*s %g  %g %g %*s %*s %*s %*s %*s %*s %*s',[10 inf]);
    [~,ncolms] = size(Attd);
    %
    %   time will be given as ctime for each interval
    %   ctime is the Cluster Time measured from Jan 1 1970
    %

    % create a time array the same length as the attitude file
    time_att = zeros(ncolms,1);

    % for each line of data
    for j= 1:ncolms
        % if the month > Sept. and the day > 9th
        if( Attd(3,j) > 9 && Attd(4,j) > 9 )
            % calculate ctime(YYYYMMDD) + (HHMMSS --> seconds)
            time_att(j) = ctime0( [ num2str(Attd(2,j)) num2str(Attd(3,j)) num2str(Attd(4,j)) ] ) +3600*Attd(5,j) +60*Attd(6,j) +Attd(7,j);

        % if the month or day < 10, then add a '0' to it so that
        % the input argument to ctime0 is of the format 'YYYYMMDD'
        elseif ( Attd(3,j) > 9 )
            time_att(j) = ctime0( [ num2str(Attd(2,j)) num2str(Attd(3,j)) '0' num2str(Attd(4,j)) ] ) +3600*Attd(5,j) +60*Attd(6,j) +Attd(7,j);
        elseif ( Attd(4,j) > 9 )
            time_att(j) = ctime0( [ num2str(Attd(2,j)) '0' num2str(Attd(3,j)) num2str(Attd(4,j)) ] ) +3600*Attd(5,j) +60*Attd(6,j) +Attd(7,j);
        else
            time_att(j) = ctime0( [ num2str(Attd(2,j)) '0' num2str(Attd(3,j)) '0' num2str(Attd(4,j)) ] ) +3600*Attd(5,j) +60*Attd(6,j) +Attd(7,j);
        end
    end

    % pick out the right ascention, declination, and revolutions
    % per minute
    right_asc = Attd(8,:)';
    decl      = Attd(9,:)';
    rpm       = Attd(10,:)';

    %spin1_ra = interp1(time_1,right_asc,
    clear Attd
    fclose(fid);
    
    %
    %    one might better determine OMEGA from the srtime's 
    %    themselves
    %

    % Find the spin frequency associated with the time given.
    indexa = find(time_att > ctime0(date) + time, 1) -1;
    ra     = right_asc(indexa);
    dec    = decl(indexa);
    OMEGA  = 2*pi*rpm(indexa)/60;
end