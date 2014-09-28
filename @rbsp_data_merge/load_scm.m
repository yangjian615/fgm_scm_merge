function [success] = load_scm(obj, filename)
    %
    % Read SCM time and magnetic field data and store them in the object
    % properties 't' and 'b'.
    %
    % Email from Dan Crawford (daniel-crawford@uiowa.edu):
    %
    %   The continuous burst mode is a series of waveforms, so really
    %   its a time-series stacked in a way that the ISTP is considering 
    %   standardizing. The Epoch variable has 96 time-tags for that
    %   day, and each channel starts at the corresponding time tag
    %   (the first dimension you list below). There are 208896 samples
    %   per channel per start-time, and each sample is separated from 
    %   the next by a time factor equal one over the sample frequency
    %   of 35khz. The variable "timeOffsets" in the CDF is a table 
    %   pre-built of the time differences using this code:
    %
    %       for (int i = 0; i < numSamples; i++) {
    %           timeOffsets[i] = (float) (i / sampleFrequency);
    %
    % Modifications:
    %   08/11/2013 - Reshape and transpose instead of looping. - MRA
    %

    if nargin < 2
        filename = [obj.data_dir, 'rbsp-a_WFR-waveform-continuous-burst_emfisis-L1_20130323T23_v1.3.3.cdf'];
    end
    
    % Get the hour of the start interval.
    hour = obj.tstart(1:2);
    
    % Build the filename and look for it in the filesystem
    filename = ['rbsp-', lower(obj.sc), '_WFR-waveform-continuous-burst_emfisis-L1_', ...
                obj.date, 'T', hour, '*.cdf'];
    fullname = dir([obj.data_dir, filename]);
    
    % Make sure it exists
    assert(~isempty(fullname), ['File Name Not Found: ', obj.data_dir, filename]);
    success = 1;

    t_name = 'Epoch';
    dt_name = 'timeOffsets';
    Bu_name = 'BuSamples';
    Bv_name = 'BvSamples';
    Bw_name = 'BwSamples';

    % Read the data
    disp('Reading search coil data.');
    cdfdata = cdfread([obj.data_dir, fullname.name], ...
                      'Variable', {t_name, dt_name, Bu_name, Bv_name, Bw_name}, ...
                      'CombineRecords', true, ...
                      'ConvertEpochToDatenum', true);
                  
    % Convert serial time values to seconds since midnight starting 
    % on OBJ.DATE.
    cdfdata{1} = time_in_day_date([cdfdata{1}], obj.date);

    % Search for the bursts that fall within the desired time range
    tstart_ssm = hms_to_ssm(str2double(obj.tstart));
    tend_ssm = hms_to_ssm(str2double(obj.tend));
    iburst = find(cdfdata{1} >= tstart_ssm & cdfdata{1} <= tend_ssm);
    n_bursts = length(iburst);

    % The number of samples in each burst of data. Convert times offsets
    % from nanoseconds to seconds.
    n_per_burst = numel(cdfdata{2});

    % Initialize the data properties
    obj.t = zeros(n_per_burst, n_bursts);
    obj.b = zeros(n_bursts * n_per_burst, 3);

    % Add the time and offset.
    obj.t = repmat(double(cdfdata{2}')*1e-9, [1, n_bursts]) + ...
            repmat(cdfdata{1}(iburst)', [n_per_burst, 1]);
    
    % Store the time and field data
    obj.t      = reshape(obj.t                , n_per_burst*n_bursts, 1);
    obj.b(:,1) = reshape(cdfdata{3}(iburst,:)', n_per_burst*n_bursts, 1);
    obj.b(:,2) = reshape(cdfdata{4}(iburst,:)', n_per_burst*n_bursts, 1);
    obj.b(:,3) = reshape(cdfdata{5}(iburst,:)', n_per_burst*n_bursts, 1);
    
    % Indicate that we are done
    disp('Finished reading search coil data');
end