function [inputs] = fgm_scm_check_inputs(mission, sc, date, tstart, tend, varargin)
    %
    % Check the inputs given.
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Defaults \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    default_coord_sys           = 'SPIN';
    root                        = '/Users/argall/Documents/Work';
    default_fgm_data_directory  = fullfile(root, '/Data/magnetometer/');
    default_scm_data_directory  = fullfile(root, '/Data/magnetometer/');
    default_attitude_directory  = fullfile(root, '/Programs/Magnetic Merging/Data/orbit/');
    default_srt_directory       = fullfile(root, '/Programs/Magnetic Merging/Data/orbit/');
    default_TransfrFn_directory = fullfile(root, '/Programs/Magnetic Merging/Data/Transfer_Functions/');
    default_spice_kernel        = '/Users/argall/Documents/External_Libraries/Spice/rbsp_current_argall.txt';
    default_coord_sys           = 'GSE';
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spawn GUI \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 0
        in = merging_input_gui();
        mission = in.mission;
        sc = in.sc;
        date = in.date;
        tstart = in.tstart;
        tend = in.tend;
        varargin = {'f_min', in.f_min, ...
                    'f_max', in.f_max, ...
                    'ref_time', in.ref_time, ...
                    'multiplier', in.multiplier, ...
                    'n_min', in.n_min, ...
                    'n_max', in.n_max', ...
                    'coord_sys', default_coord_sys, ...
                    'fgm_data_dir', default_fgm_data_directory, ...
                    'scm_data_dir', default_scm_data_directory, ...
                    'TransfrFn_dir', default_TransfrFn_directory};
        
        % Mission-specific input arguments
        switch mission
            case 'C'
                varargin = {varargin{:}, 'srt_dir', default_srt_directory, ...
                                         'attitude_dir', default_attitude_directory};
            case 'RBSP'
                varargin = {varargin{:}, 'spice_kernel', default_spice_kernel, ...
                                         'n_sec', 0};
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse Inputs \\\\\\\\\\\\\    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs = inputParser;
    inputs.addRequired('mission')
    inputs.addRequired('sc')
    inputs.addRequired('date')
    inputs.addRequired('tstart')
    inputs.addRequired('tend')
    inputs.addParamValue('f_min',         0.3)
    inputs.addParamValue('f_max',         1.5)
    inputs.addParamValue('ref_time',      '-1')
    inputs.addParamValue('multiplier',    64)
    inputs.addParamValue('n_min',         1.5)
    inputs.addParamValue('n_max',         6)
    inputs.addParamValue('coord_sys',     default_coord_sys)
    inputs.addParamValue('fgm_data_dir',  default_fgm_data_directory)
    inputs.addParamValue('scm_data_dir',  default_scm_data_directory)
    inputs.addParamValue('TransfrFn_dir', default_TransfrFn_directory)
    
    % Parse optional mission-specific inputs.
    % CLUSTER
    inputs.addParamValue('srt_dir', default_srt_directory)
    inputs.addParamValue('attitude_dir', default_attitude_directory)
    
    % RBSP
    inputs.addParamValue('spice_kernel', default_spice_kernel)
    inputs.addParamValue('n_sec', 0)

    % Check the inputs
    inputs.parse(mission, sc, date, tstart, tend, varargin{:});
    
    % Return only the results
    inputs = inputs.Results;
end