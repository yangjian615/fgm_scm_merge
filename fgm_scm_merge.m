function [t, b, fgm, scm] = fgm_scm_merge(mission, sc, date, tstart, tend, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\ CHECK INPUTS \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Check the inputs. In none were given, fg_sc_check_inputs will
    % generate a GUI and ask for them.
    if nargin == 0
        inputs = fgm_scm_check_inputs();
    else
        inputs = fgm_scm_check_inputs(mission, sc, date, tstart, tend, varargin{:});
    end
    
    % Transfer all inputs to the workspace.
    mission       = inputs.mission;
    sc            = inputs.sc;
    date          = inputs.date;
    tstart        = inputs.tstart;
    tend          = inputs.tend;
    f_min         = inputs.f_min;
    f_max         = inputs.f_max;
    n_min         = inputs.n_min;
    n_max         = inputs.n_max;
    multiplier    = inputs.multiplier;
    coord_sys     = inputs.coord_sys;
    ref_time      = inputs.ref_time;
    fgm_data_dir  = inputs.fgm_data_dir;
    scm_data_dir  = inputs.scm_data_dir;
    TransfrFn_dir = inputs.TransfrFn_dir;

    %
    % The remainder of the optional arguments are used to despin and rotate spacecraft
    % data to another coordinate system, a process that is mission- and spacecraft-
    % specific. As such, the arguments to the necessary programs will be specified
    % differently for each mission. See 'fgm_scm_scs2gse.m' and 'fgm_scm_despin.m' for
    % more details.
    %

    % Optional Inputs to fgm_scm_despin and fgm_scm_scs2gse.
    switch mission
        case 'C'
            optArg1 = inputs.date;
            optArg1 = inputs.attitude_dir;
            optArg2 = inputs.srt_dir;
        case 'RBSP'
            optArg1 = inputs.date;
            optArg1 = inputs.n_sec;
            optArg2 = inputs.spice_kernel;
        otherwise
            if ~strcmp(coord_sys, 'SPIN')
                error('Mission %s does not have Despinning/Coord Transform implemented', mission)
            end
    end
    clear inputs
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\\\\\ GET DATA \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create a [mission]_data_merge object for FGM
    disp('Getting FGM data...')
    fgm = get_inst_obj(mission);
    fgm.get_data('FGM', sc, date, tstart, tend, ...
                 'data_dir', fgm_data_dir, ...
                 'TransfrFn_dir', TransfrFn_dir);
    
    % Create a [mission]_data_merge object for SCM
    disp('Getting SCM data...')
    scm = get_inst_obj(mission);
    scm.get_data('SCM', sc, date, tstart, tend, ...
                 'data_dir', scm_data_dir, ...
                 'TransfrFn_dir', TransfrFn_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK REFERENCE TIME \\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % "ref_time" is < 0
    %   - It is an into then FGM time array.
    %   - Get the time indicated by the index.
    %   - Must be FGM because of how get_start_ind.m works.
    %       o see "assert" therein.
    if strcmp(ref_time(1), '-')
        ref_index = abs(str2double(ref_time));
        ref_time  = fgm.t(ref_index);
        ref_time  = ssm_to_hms(ref_time, 'to_string', true);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND MERGING INTERVALS \\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % find data gaps of 6 data points or more
    disp('Searching for data gaps...')
    fgm_major_gaps = find_gaps(fgm.t, n_max, inf);
    scm_major_gaps = find_gaps(scm.t, n_max, inf);

    % Display information about the gaps found
    str = sprintf('  %i gaps of >= %i points found.', ...
                  length(fgm_major_gaps) + length(scm_major_gaps), ...
                  n_max);
    disp(str);
    
    
    % Transfer the whole data interval into the global variables t_fgm and
    % t_scm for safe keeping.
    % Find the intervals where merging can take place
    disp('Finding intervals to merge...')
    [fgm.intervals, scm.intervals] = find_merge_intervals(fgm.t, scm.t, ...
                                                          fgm_major_gaps, ...
                                                          scm_major_gaps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILL MINOR DATA GAPS \\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %
    % The minor data gaps between each major data gap must then be
    % filled in before beginning the merging process. This is for
    % two reasons: 1) to create a continuous data product, 2) so that the
    % reference interval may be determined before any of the
    % merging takes place.
    %
    % The motivation for this was that Cluster has many data gaps that are
    % 5 samples long.
    %
    str = sprintf('Filling data gaps between %f and %i points...', n_min, n_max);
    disp(str);

    % Fill in the minor data gap
    [fgm.t, fgm.b, fgm.intervals] = fill_gaps(fgm.t, fgm.b, n_min, n_max, fgm.intervals);
    [scm.t, scm.b, scm.intervals] = fill_gaps(scm.t, scm.b, n_min, n_max, scm.intervals);
    n_intervals = length(fgm.intervals(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE A SYNCHRONOUS START INDEX FOR THE QUIET INTERVAL %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [fgm.iStart_ref, scm.iStart_ref] = get_start_ind(fgm.t, scm.t, ref_time);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP THROUGH EACH CONTINUOUS DATA INTERVAL \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    b_scs_spin = zeros(size(scm.b));
    for ii = 1:n_intervals
        %Show progress
        str = sprintf('Merging interval %i of %i.', ii, n_intervals);
        disp(str);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SELECT THE CURRENT CONTINUOUS DATA INTERVAL \\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Reset FGM and SCM data to be of the smaller time interval
        fgm.iCurrent = ii;
        scm.iCurrent = ii;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE SAMPLE RATE AND LENGTH OF FFT INTERVAL \\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Calculate the sampling rate and find an FFT window that produces the same
        % frequency bins for FGM and SCM. Keep in this order.
        fgm.get_sample_rate(fgm.intervals(ii,1), fgm.intervals(ii,2));
        scm.get_sample_rate(scm.intervals(ii,1), scm.intervals(ii,2));
        [fgm.n, scm.n] = fgm.get_dt_ratio(fgm.dt, scm.dt);
        
        % Lengthen the the FFT window by an integer multiple, "multiplier"
        fgm.get_fft_clen(multiplier);
        scm.get_fft_clen(multiplier);
        
        % Calculate the maximum number of merging intervals to perform.
        fgm.get_N_max(fgm.clen/4, fgm.intervals(ii,1), fgm.intervals(ii,2));
        scm.get_N_max(scm.clen/4, scm.intervals(ii,1), scm.intervals(ii,2));
        max_number = min([fgm.N_max, scm.N_max]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAKE "MULTIPLIER" ADAPTIVE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Make the multiplier adaptive.
        %   - max_number =< 0 if the window is bigger than the number of
        %       points available to merge. Shrink the multiplier until
        %       max_number > 0.
        %   - new_multiplier is a power of 2 and must be at least 2^1 so
        %       that the length of the FFT interval is guaranteed to be even.
        %
        new_multiplier = multiplier;
        while max_number < 1 && new_multiplier >= 2
            new_multiplier = new_multiplier / 2;
            fgm.get_fft_clen(new_multiplier)
            scm.get_fft_clen(new_multiplier)
            
            % Compute the number of FFT windows in the interval
            fgm.get_N_max(fgm.clen/4, fgm.intervals(ii,1), fgm.intervals(ii,2));
            scm.get_N_max(scm.clen/4, scm.intervals(ii,1), scm.intervals(ii,2));
            
            % Take the minimum number
            max_number = min([fgm.N_max, scm.N_max]);
        end

        % If the continuous data interval is still shorter than
        % that needed to perform an FFT. Skip to the next merging
        % interval
        if max_number <= 1 || new_multiplier < 2
            str = sprintf('  Skipping Interval %i., Data interval < Merging interval: %i < %i.', ...
                          ii, (fgm.intervals(ii,2) - fgm.intervals(ii,1) + 1), 2*fgm.clen);
            disp(str);
            continue
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE CALIBRATION AND FFT PARAMETERS FOR MERGING \\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Ready FFT parameters for FGM
        fgm.get_df;
        fgm.get_freqs;

        % Ready FFT parameters for SCM
        scm.get_df;
        scm.get_freqs;

        % Ready calibration parameters. For FGM, this entails loading a rotation matrix to
        % rotate the FGM coordinate system into the SCM frame. For SCM, this entails
        % loading an amplitude correction factor to scale into the range of FGM.
        %
        % NOTE: the rotation matrix is suppose to be used as x* = xA', 
        %       not the usual x* = Ax
        fgm.calibrate
        scm.calibrate
        
        % Load SCM's transfer function and interpolate it to the frequencies of our
        % continuous data interval (i.e., scm.freqs)
        %   - Components of SCM's transfer function are rearranged:
        %       FGM (x,y,z) correspond to SCM (2,3,1).
        scm.load_transfr_fn
        scm.interp_transfr_fn
                
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MERGE THE CURRENT CONTINUOUS INTERVAL \\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % The maximum number of merging loops within this continuous interval
        max_number = min([fgm.N_max, scm.N_max]);
        
        % Merge the data
        merged_data = merge2(fgm, scm, ...
                             max_number, f_min, f_max);

        % Combine all of the major intervals into a single array
        b_scs_spin(scm.intervals(ii,1):scm.intervals(ii,2),:) = merged_data;
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE COORDINATE SYSTEMS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Change coordinate systems
    switch coord_sys
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TRANSFORM TO GSE? \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'GSE'
            % Despin the spacecraft before transforming.
            if ~strcmp(mission, 'RBSP')
                b_scs = fgm_scm_despin(scm.t, b_scs_spin, mission, sc, date, ...
                                       optArg1, optArg2);
            else
                % RBSP is despun and transformed into GSE in a single step.
                b_scs = b_scs_spin;
            end
            
            % Transform into GSE
            b = fgm_scm_scs2gse(mission, scm.t, b_scs, sc, date, ...
                                optArg1, optArg2);
            clear b_scs b_scs_spin
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DESPIN THE DATA? \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'SCS'
            if ~strcmp(mission, 'RBSP')
                b = fgm_scm_despin(scm.t, b_scs_spin, mission, sc, date, ...
                                   optArg1, optArg2, optArg3);
            else
                b = b_scs_spin;
                disp('Cannot despin %s data. Returning in the spinning spacecraft frame.', mission);
            end
            clear b_scs_spin
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LEAVE THE DATA ALONE? \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'SPIN'
            b = b_scs_spin;
            clear b_scs_spin
    end
    
    % The merged time is the same as t_scm
    t = scm.t;
    
    disp('Merging Complete!');
end