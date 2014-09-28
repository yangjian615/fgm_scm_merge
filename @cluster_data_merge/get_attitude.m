function [OMEGA, ra, dec] = get_attitude(sc, date, time, attitude_dir)
    %
    %   get the attitude data
    %
    fid = fopen([attitude_dir, 'satt.cl', sc]);

    % read the spacecraft number, the first date, the first time,
    % skip over the second time and date, read the right ascention,
    % declination, and revolutions per minute, then skip the rest
    %                    SC   R YYYY-MM - DD T HH : MM : SS Z 
    Attd = fscanf( fid, '%g %*s %g - %g - %g T %g : %g : %g Z %*s %g  %g %g %*s %*s %*s %*s %*s %*s %*s',[10 inf]);
    [nrows,ncolms] = size(Attd);
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
    decl = Attd(9,:)';
    rpm = Attd(10,:)';

    %spin1_ra = interp1(time_1,right_asc,
    clear Attd
    fclose(fid);
    %
    %    one might better determine OMEGA from the srtime's 
    %    themselves
    %

    % The second two cases of the if statement were brought over
    % from an older (non-method) version of the function in which
    % the variables t_FS and tp12 were suppose to be found in the
    % workspace. deciding to make this function static (i.e. not 
    % use obj.t_fgm), they became obsolete. I keep them here solely
    % for history's sake.
    if ~isempty(time)
        indexa = find(time_att > ctime0(date) + time,1) -1;
        ra = right_asc(indexa);
        dec = decl(indexa);
        OMEGA = 2*pi*rpm(indexa)/60;

    % if t_FS is filled, then find an attitude time that
    % is greater than the start time of the FSR data interval
    elseif ( exist('t_FS', 'var' ) )
        indexa = find(time_att > ctime0(date) + t_FS(1),1) -1;
        ra = right_asc(indexa);
        dec = decl(indexa);
        OMEGA = 2*pi*rpm(indexa)/60;

    % try the same thing for the tp12 variable
    elseif ( exist('tp12','var') )
        indexa = find(time_att > ctime0(date)+tp12(1),1) -1;
        ra = right_asc(indexa);
        dec = decl(indexa);
        OMEGA = 2*pi*rpm(indexa)/60;
    else
        fprintf('No available time to find OMEGA\n')
    end
end