classdef data_merge < handle
    %
    % DATA_MERGE is a generic data object used for reading and processing search coil and
    % flux gate magnetometer data with the goal of merging the two in a specefied
    % frequency range.
    %
    
    properties
        mission         % Satellite Mission
        inst            % Instrument {FGM | SCM}
        sc              % Spacecraft
        date            % Date of the data interval
        tstart          % Start time of the data interval
        tend            % End time of the data interval
        
        %Data
        data_dir        % Data directory
        TransfrFn_dir   % Transfer function directory
        t               % Time
        b               % Magnetic field
        mode            % Instrument mode
        
        %Indices
        intervals       % Intervals of continuous data.
                        % (with no major data gaps between)
                        %   (:,1) - iStart
                        %   (:,2) - iEnd
        iCurrent        % Current interval
        iStart_ref      % Start of the reference interval
        
        %FFT
        dt              % Sampling period
        n               % Number of points per fft
        N_max           % Number of ffts 
        clen            % Length of fft
        df              % Frequency bin size
        freqs           % FFT frequencies
        win_ham         % Hamming window
        win_tuk         % Tukey window
        b_fft           % The FFT corresponding to: b(iMerge(1):iMerge(2))
        b_psd           % The power spectral density of b_fft
        
        %Transfer Function & Calibration
        amp_factor      % Amplitude correction factor between FGM and SCM
        rotmat_to_scm   % Rotation matrix from the FGM to SCM frame
        transfr_fn      % Transfer function to 
        transfr_freqs   % Frequencies of the transfer function
        comp            % Interpolated transfer function frequencies
    end
    
    methods (Static)
        % EXTERNAL STATIC METHODS
        % CALIBRATION Methods
        [N_fgm, N_scm] = get_dt_ratio(dt_fgm, dt_scm)
        [field] = apply_transf(field, comp, undo)
        [comp] = fcompst(N, del_f, tr_freq, transf)
        
        % FFT Methods
        [time_gaps, n_gaps] = find_gaps(time, n_min, n_max)
        [field] = apply_window(field, win, undo)
        
        % DESPINNING Methods
        [OMEGA, ra, dec] = get_attitude(sc, date, time, directory)
        [srtime, year, month, day] = get_srtime(sc, date, directory)
        
        % ROTATE TO GSE Methods
    end
    
    methods
        % CLASS CONSTRUCTOR
        function obj = cluster_data_merge(inst, sc, date, tstart, tend, varargin)
            %
            % Define the mission upon instantiation. If inputs were given, check them
            %
            obj.mission = '';
            
            % Check the inputs if some were given.
            if nargin > 0
                obj.check_inputs(inst, sc, date, tstart, tend, varargin{:})
            end
        end
        
        % PLACEHOLDER Methods (must be over-ridden)
        %   - load_fgm
        %   - load_scm
        %   - load_transfr_fn
        
        % GET DATA Methods
        [] = get_data(obj, inst, sc, date, tstart, tend, varargin)
        [] = check_inputs(obj, inst, sc, date, tstart, tend, varargin)
        [] = load_fgm(obj)
        [] = load_scm(obj, filename)
        
        % TRANSFER FUNCTION Methods
        [] = load_transfr_fn(obj)
        [] = interp_transfr_fn(obj)
        
        % CALIBRATION Methods
        []          = calibrate(obj)
        [rot_angle] = get_rot_angle(obj)
        []          = get_amp_factor(obj)  
        []          = get_rotmat_to_scm_frame(obj)      
        
        % PREP FOR FFT Methods
        [] = get_sample_rate(obj, istart, istop)
        [] = get_fft_clen(obj, multiplier)
        [] = get_N_max(obj, n_shift, sIndex, eIndex)
        [] = get_df(obj)
        [] = get_freqs(obj)
        [] = get_windows(obj)
        [] = prep_fft(obj, multiplier)
        
        
        % FFT Methods
        [] = take_fft(obj, istart, istop, win)

        
        
        % SET Methods
        function obj = set.data_dir(obj, data_dir)
            obj.data_dir = data_dir;
        end
        function obj = set.TransfrFn_dir(obj, TransfrFn_dir)
            obj.TransfrFn_dir = TransfrFn_dir;
        end
        function obj = set.inst(obj, inst)
            obj.inst = inst;
        end
        function obj = set.mission(obj, mission)
            obj.mission = mission;
        end
        function obj = set.sc(obj, sc)
            obj.sc = sc;
        end
        function obj = set.date(obj, date)
            obj.date = date;
        end
        function obj = set.tstart(obj, tstart)
            obj.tstart = tstart;
        end
        function obj = set.tend(obj, tend)
            obj.tend = tend;
        end
        function obj = set.intervals(obj, intervals)
            obj.intervals = intervals;
        end
        function obj = set.iCurrent(obj, iCurrent)
            obj.iCurrent = iCurrent;
        end
        function obj = set.iStart_ref(obj, iStart_ref)
            obj.iStart_ref = iStart_ref;
        end
        function obj = set.t(obj, t)
            obj.t = t;
        end
        function obj = set.dt(obj, dt)
            obj.dt = dt;
        end
        function obj = set.b(obj, b)
            obj.b = b;
        end
        function obj = set.mode(obj, mode)
            obj.mode = mode;
        end
        function obj = set.n(obj, n)
            obj.n = n;
        end
        function obj = set.N_max(obj, N_max)
            obj.N_max = N_max;
        end
        function obj = set.clen(obj, clen)
            obj.clen = clen;
        end
        function obj = set.df(obj, df)
            obj.df = df;
        end
        function obj = set.freqs(obj, freqs)
            obj.freqs = freqs;
        end
        function obj = set.win_ham(obj, win_ham)
            obj.win_ham = win_ham;
        end
        function obj = set.win_tuk(obj, win_tuk)
            obj.win_tuk = win_tuk;
        end
        function obj = set.b_fft(obj, b_fft)
            obj.b_fft = b_fft;
        end
        function obj = set.b_psd(obj, b_psd)
            obj.b_psd = b_psd;
        end
        function obj = set.transfr_fn(obj, transfr_fn)
            obj.transfr_fn = transfr_fn;
        end
        function obj = set.transfr_freqs(obj, transfr_freqs)
            obj.transfr_freqs = transfr_freqs;
        end
        function obj = set.rotmat_to_scm(obj, rotmat_to_scm)
            obj.rotmat_to_scm = rotmat_to_scm;
        end
        function obj = set.amp_factor(obj, amp_factor)
            obj.amp_factor = amp_factor;
        end
        function obj = set.comp(obj, comp)
            obj.comp = comp;
        end
        
        % GET Methods
        function data_dir = get.data_dir(obj)
            data_dir = obj.data_dir;
        end
        function TransfrFn_dir = get.TransfrFn_dir(obj)
            TransfrFn_dir = obj.TransfrFn_dir;
        end
        function mission = get.mission(obj)
            mission = obj.mission;
        end
        function inst = get.inst(obj)
            inst = obj.inst;
        end
        function sc = get.sc(obj)
            sc = obj.sc;
        end
        function date = get.date(obj)
            date = obj.date;
        end
        function tstart = get.tstart(obj)
            tstart = obj.tstart;
        end
        function tend = get.tend(obj)
            tend = obj.tend;
        end
        function intervals = get.intervals(obj)
            intervals = obj.intervals;
        end
        function iCurrent = get.iCurrent(obj)
            iCurrent = obj.iCurrent;
        end
        function iStart_ref = get.iStart_ref(obj)
            iStart_ref = obj.iStart_ref;
        end
        function t = get.t(obj)
            t = obj.t;
        end
        function dt = get.dt(obj)
            dt = obj.dt;
        end
        function b = get.b(obj)
            b = obj.b;
        end
        function mode = get.mode(obj)
            mode = obj.mode;
        end
        function n = get.n(obj)
            n = obj.n;
        end
        function N_max = get.N_max(obj)
            N_max = obj.N_max;
        end
        function clen = get.clen(obj)
            clen = obj.clen;
        end
        function df = get.df(obj)
            df = obj.df;
        end
        function freqs = get.freqs(obj)
            freqs = obj.freqs;
        end
        function win_ham = get.win_ham(obj)
            win_ham = obj.win_ham;
        end
        function win_tuk = get.win_tuk(obj)
            win_tuk = obj.win_tuk;
        end
        function b_fft = get.b_fft(obj)
            b_fft = obj.b_fft;
        end
        function b_psd = get.b_psd(obj)
            b_psd = obj.b_psd;
        end
        function transfr_fn = get.transfr_fn(obj)
            transfr_fn = obj.transfr_fn;
        end
        function transfr_freqs = get.transfr_freqs(obj)
            transfr_freqs = obj.transfr_freqs;
        end
        function rotmat_to_scm = get.rotmat_to_scm(obj)
            rotmat_to_scm = obj.rotmat_to_scm;
        end
        function amp_factor = get.amp_factor(obj)
            amp_factor = obj.amp_factor;
        end
        function comp = get.comp(obj)
            comp = obj.comp;
        end
    end
    
end

