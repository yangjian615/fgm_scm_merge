function [] = load_scm(obj)
    %
    % Read FGM time and magnetic field data and store them in the object
    % properties 't' and 'b'.
    %
    % TODO: Calculate t_ssm from Epoch values, not Datenum.
    %
    
    % Create the Cluster Active Archive experiment name for the
    % data
    exp_root = 'CP_STA_DWF_';
    exp_mode = 'HBR';
    experiment = [exp_root, exp_mode];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the File                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Create a filename for the data based on Cluster Active
    % Archive convention: 
    %   e.g. C1_CP_STA_DWF_NBR_20050325_093000_20050325_113000_v######.cdf
    % The version number is assigned at moment of download.            
    % Replaced with "*". "dir" will look for the partial file name 
    % and return any matches.
    %
    % Look for a file with a high bit-rate (HBR) first. If none is found, search
    % again for nominal bit-rate (NBR).
    %
    filename = make_cluster_filename(experiment, obj.sc, obj.date, ...
                                     obj.tstart, obj.tend);
    fullname = dir(fullfile(obj.data_dir, filename));
    
    % Look for NBR file if HBR was not found.
    if isempty(fullname)
        exp_mode = 'NBR';
        experiment = [exp_root, exp_mode];
        filename = make_cluster_filename(experiment, obj.sc, obj.date, ...
                                         obj.tstart, obj.tend);
        fullname = dir(fullfile(obj.data_dir, filename));
    end
    
    obj.mode = exp_mode;
    fullname = fullfile(obj.data_dir, fullname.name);
    assert(exist(fullname, 'file') == 2, ['STAFF file not found: ', filename])
    
    %
    % The variable names of the time and magnetic field data within 
    % the EXPERIMENT data file.
    %
    t_name = ['Time__C', obj.sc, '_', experiment];
    b_name    = ['B_vec_xyz_Instrument__C', obj.sc, '_', experiment];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read Data                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Turn file validation off
    cdflib.setValidate('VALIDATEFILEoff')
    
    %
    % Read the time and magnetic field data from the cdf file.
    % Organize data into variables and components instead of just
    % variables. Convert cdf epoch time values to MatLab serial 
    % date values.
    %
    cdfdata = cdfread(fullname,             ...
       'Variable', {t_name, b_name},        ...
       'CombineRecords', true,              ...
       'ConvertEpochToDatenum', true);
   
   % Turn file validation back on
    cdflib.setValidate('VALIDATEFILEon')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Interval                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Convert data interval to datenumbers
    sDateNum = datenum([obj.date, ' ', obj.tstart], 'yyyy-mm-dd HH:MM:SS');
    eDateNum = datenum([obj.date, ' ', obj.tend], 'yyyy-mm-dd HH:MM:SS');
    
    % Find the appropriate index range.
    irange = zeros(2,1);
    irange(1) = find(cdfdata{1} >= sDateNum, 1);
    irange(2) = find(cdfdata{1} <= eDateNum, 1, 'last');
    
    % Convert serial time values to seconds since midnight starting 
    % on "obj.date".
    obj.t = MrDatenumToSSM(cdfdata{1}(irange(1):irange(2)));

    % extract the magnetic field data
    % Data is stored as bits with 2^16 bits of precision and the 
    % first 2^15 bits being negative values. Convert to base 10.
    data_staff_f1 = cdfdata{2}(irange(1):irange(2), :);
    obj.b = single(10.*(double(data_staff_f1) - 32767)./65535);
end