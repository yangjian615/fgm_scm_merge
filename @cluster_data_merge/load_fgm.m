function [] = load_fgm(obj)
    %
    % Read time and magnetic field data from a Cluster FSR data file.
    %
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the File                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Remove delimeters from date, if there are any
    [year, month, day] = dissect_date(obj.date);
    date = [year, month, day];
    
    % Create a filename for the FGM data
    %   /C#_YYYYMMDD_FSR.mag
    filename = fullfile(obj.data_dir, ['C', obj.sc, '_', date, '_FSR.mag']);
    
    % load the file
    FSR_data = load(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Eliminate Data                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Occasionally, data from the previous day will be included in the
    % file. Remove it.
    if FSR_data(1,1) > 23
        % Find the first time in the new day
        counter = 1;
        while FSR_data(counter,1) > 23
            counter = counter + 1;
        end
        
        % Remove data from the previous day
        FSR_data = FSR_data(counter:end,:);
    end
    
    % convert from hours to seconds
    % separate the time and magnetic field data
    t_ssm = 3600.* FSR_data(:,1);
    b_vec = single(FSR_data(:,2:4));
    clear FSR_data
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select Data Interval          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select the time interval
    sTime_ssm = hms_to_ssm(obj.tstart);
    eTime_ssm = hms_to_ssm(obj.tend);
    
    % Index range in data
    sIndex = find(t_ssm >= sTime_ssm, 1);
    eIndex = find(t_ssm <= eTime_ssm, 1, 'last');
    
    % Set the data
    obj.t = t_ssm(sIndex:eIndex);
    obj.b = b_vec(sIndex:eIndex, :);
end