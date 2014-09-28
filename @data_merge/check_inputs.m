function [] = check_inputs(obj, inst, sc, date, tstart, tend, varargin)
    %
    % Check the inputs given.
    %
    % (A method for the 'data_merge' class.)
    %
    
    % Create default values
    root                  = '/User/argall/Documents/Work/';
    default_data_dir      = fullfile(root, 'Programs/Magnetic Merging/Data/magnetometer/');
    default_TransfrFn_dir = fullfile(root, 'Programs/Magnetic Merging/Data/Transfer_Functions/');
    default_attitude_dir  = fullfile(root, 'Programs/Magnetic Merging/Data/orbit/');
    default_srt_dir       = fullfile(root, 'Programs/Magnetic Merging/Data/orbit/');
    
    % Define Inputs
    inputs = inputParser;
    inputs.addRequired('inst')
    inputs.addRequired('sc')
    inputs.addRequired('date')
    inputs.addRequired('tstart')
    inputs.addRequired('tend')
    inputs.addParamValue('data_dir', default_data_dir)
    inputs.addParamValue('TransfrFn_dir', default_TransfrFn_dir)
    
    % Check the inputs
    inputs.parse(inst, sc, date, tstart, tend, varargin{:});
        
    % Store the inputs as object properties
    obj.inst          = inputs.Results.inst;
    obj.sc            = inputs.Results.sc;
    obj.date          = inputs.Results.date;
    obj.tstart        = inputs.Results.tstart;
    obj.tend          = inputs.Results.tend;
    obj.data_dir      = inputs.Results.data_dir;
    obj.TransfrFn_dir = inputs.Results.TransfrFn_dir;
end
