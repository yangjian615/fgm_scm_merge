function [] = load_fgm(obj)
    %
    % Read FGM time and magnetic field data and store them in the object
    % properties 't' and 'b'.
    %
    
    % Build the filename and look for it in the filesystem
    filename = ['rbsp-', lower(obj.sc), '_magnetometer_emfisis-L1_', obj.date, '_*.cdf'];
    fullname = dir([obj.data_dir, filename]);
    
    % Make sure the file exists.
    assert(~isempty(fullname), ['File Name Not Found: ', obj.data_dir, filename]);

    t_name = 'Epoch';
    b_name = 'Mag';

    cdfdata = cdfread([obj.data_dir, fullname.name], ...
                      'Variable', {t_name, b_name}, ...
                      'CombineRecords', true, ...
                      'ConvertEpochToDatenum', true);

    % Convert to seconds since midnight
    cdfdata{1} = time_in_day_date([cdfdata{1}], obj.date);

    % Search data within the desired time range
    tstart_ssm = hms_to_ssm(str2double(obj.tstart));
    tend_ssm = hms_to_ssm(str2double(obj.tend));
    istart = find(cdfdata{1} >= tstart_ssm, 1);
    iend = find(cdfdata{1} <= tend_ssm, 1, 'last');

    % Store the data in the object property
    obj.t = [cdfdata{1}(istart:iend)];
    obj.b = [cdfdata{2}(istart:iend, :)];
end 