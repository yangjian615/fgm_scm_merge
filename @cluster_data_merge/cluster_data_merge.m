classdef cluster_data_merge < data_merge
    % CLUSTER_DATA_MERGE retrieves Cluster fluxgate and search coil
    % magnetometer data and prepares them to be merged.
    %
    %   The original merging class was data_merge, but RBSP has
    %   different calibration details, so the relevant methods were
    %   overridden here. Basic differences are:
    %
    %       1. SCM and FGM are not aligned on the spacecraft
    %       2. SCM's transfer function needs to be divided into the FFT spectra
    %           a. NaN's set to Inf, not 0
    %       3. Amplitude correction factor applied
    %
    
    properties
    end
    
    methods (Static)
        % EXTERNAL STATIC METHODS
        % CALIBRATION Methods
        [field] = apply_transf(field, comp, undo)
        [comp]  = fcompst(N, del_f, tr_freq, transf)
        
        % FFT Methods
        
        % DESPINNING Methods
        [OMEGA, ra, dec]           = get_attitude(sc, date, time, directory)
        [srtime, year, month, day] = get_srtime(sc, date, directory)
        
        % ROTATE TO GSE Methods
    end
    
    methods
        % CLASS CONSTRUCTOR
        function obj = cluster_data_merge(inst, sc, date, tstart, tend, varargin)
            @obj.data_merge;
            %
            % Nothing to do here yet...
            %
            obj.mission = 'C';
        end
        
        % GET DATA Methods
        [] = load_fgm(obj)
        [] = load_scm(obj)
        
        % TRANSFER FUNCTION Methods
        [] = load_transfr_fn(obj)
        [] = interp_transfr_fn(obj)
        
        % CALIBRATION Methods
        [rot_angle] = get_rot_angle(obj)
        []          = get_amp_factor(obj)
        []          = get_rotmat_to_scm_frame(obj)
    end
end





% function [] = load_fgm(obj)
%     %
%     % Read data from a Cluster FSR data
%     %
%     % Create a filename for the FGM data
%     %   /C#_YYYYMMDD_FSR.mag
%     filename = [obj.fgm_data_dir, 'C', obj.sc, '_', obj.date, '_FSR.mag'];
%     
%     % load the file
%     FSR_data = load(filename);
%     
%     % convert from hours to seconds
%     % separate the time and magnetic field data
%     obj.t = 3600.* FSR_data(:,1);
%     obj.b = single(FSR_data(:,2:4) );
%     
%     % calculate the sampling rate
%     obj.get_sample_rate;
% end

% function [success] = load_scm(obj)
%     %
%     % Read FGM time and magnetic field data and store them in the object
%     % properties 't' and 'b'.
%     %
%     
%     % Create the Cluster Active Archive experiment name for the
%     % data
%     exp_root = 'CP_STA_DWF_';
%     exp_mode = 'HBR';
%     experiment = [exp_root, exp_mode];
%     
%     %
%     % Create a filename for the data based on Cluster Active
%     % Archive convention: 
%     %   e.g. C1_CP_STA_DWF_NBR_20050325_093000_20050325_113000_v######.cdf
%     % The version number is assigned at moment of download.            
%     % Replaced with "*". "dir" will look for the partial file name 
%     % and return any matches.
%     %
%     % Look for a file with a high bit-rate (HBR) first. If none is found, search
%     % again for nominal bit-rate (NBR).
%     %
%     filename = make_cluster_filename(experiment, obj.sc, obj.date, ...
%                                      obj.tstart, obj.tend);
%     fullname = dir([obj.scm_data_dir, filename]);
%     
%     if isempty(fullname)
%         exp_mode = 'NBR';
%         experiment = [exp_root, exp_mode];
%         filename = make_cluster_filename(experiment, obj.sc, obj.date, ...
%                                          obj.tstart, obj.tend);
%         fullname = dir([obj.scm_data_dir, filename]);
%         
%         if isempty(fullname)
%             success = 0;
%             disp(filename)
%             return
%         end
%     end
%     
%     obj.mode = exp_mode;
%     fullname = [obj.scm_data_dir, fullname.name];
%     success = 1;
%     
%     %
%     % The variable names of the time and magnetic field data within 
%     % the EXPERIMENT data file.
%     %
%     time_name = ['Time__C', obj.sc, '_', experiment];
%     b_name = ['B_vec_xyz_Instrument__C', obj.sc, '_', experiment];
%     
%     %
%     % Read the time and magnetic field data from the cdf file.
%     % Organize data into variables and components instead of just
%     % variables. Convert cdf epoch time values to MatLab serial 
%     % date values.
%     %
%     cdfdata = cdfread(fullname,...
%        'Variable', {time_name, b_name},...
%        'CombineRecords', true, ...
%        'ConvertEpochToDatenum', true);
%    
%     % Convert serial time values to seconds since midnight starting 
%     % on OBJ.DATE.
%     obj.t = time_in_day_date([cdfdata{1}], obj.date);
% 
%     % extract the magnetic field data
%     % Data is stored as bits with 2^16 bits of precision and the 
%     % first 2^15 bits being negative values. Convert to base 10.
%     data_staff_f1 = [cdfdata{2}];
%     obj.b = single(10.*(double(data_staff_f1) - 32767)./65535);
% 
%     % Calculate the sampling rate as the average time interval. This could be
%     % inaccurate if there are data gaps.
%     obj.get_sample_rate
% end
        
        % TRANSFER FUNCTION Methods
% function [] = load_transfr_fn(obj)
%     %
%     %  program to load SCM transfer functions for BM and NM
%     %
%     
%     % Check whether STAFF is in nominal mode
%     switch obj.mode
%         case 'NBR'
%             file_root = 'STAFF_SC_Nbr';
%         case 'HBR'
%             file_root = 'STAFF_SC_Hbr';
%     end
%         
%     % Look for the transfer function data, read it in to a
%     % dummy variable, store the frequencies, and combine the
%     % real and complex components of the transfer function.
%     transfile = [obj.TransfrFn_dir, file_root, obj.sc, '_X.txt'];
%     dummy_in = load(transfile); 
%     obj.transfr_freqs(:,1) = dummy_in(:,1);
%     obj.transfr_fn(:,1) = complex( dummy_in(:,2),dummy_in(:,3) );
% 
%     % Repeat for the Y component
%     transfile = [obj.TransfrFn_dir, file_root, obj.sc, '_Y.txt'];
%     dummy_in = load(transfile); 
%     obj.transfr_freqs(:,2) = dummy_in(:,1);
%     obj.transfr_fn(:,2) = complex( dummy_in(:,2),dummy_in(:,3) );
% 
%     % Repeat for the Z component
%     transfile = [obj.TransfrFn_dir, file_root, obj.sc, '_Z.txt'];
%     dummy_in = load(transfile); 
%     obj.transfr_freqs(:,3) = dummy_in(:,1);
%     obj.transfr_fn(:,3) = complex( dummy_in(:,2),dummy_in(:,3) );
% end
% function [] = interp_transfr_fn(obj)
%     %
%     % Interpolate the transfer function to the points where we
%     % actually have data. 
%     %
%     
%     obj.comp = zeros(obj.clen, 3);
%     
%     % On the Cluster spacecraft, the FGM and SCM instruments are
%     % aligned, so the compents are mixed: (x,y,z) correspond to 
%     % (3,1,2). See rotate_to_staff_frame method for why.
%     obj.comp(:,1) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,2), obj.transfr_fn(:,2));
%     obj.comp(:,2) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,3), obj.transfr_fn(:,3));
%     obj.comp(:,3) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,1), obj.transfr_fn(:,1));
% end
        
        % CALIBRATION Methods
% function [rot_angle] = get_rot_angle(obj)
%     %
%     %   set up to rotate the FG to near the staff coordinates
%     %   we also negate the z component of FGM for correlation purposes
%     %   THis is now for both NM and BM1 data
%     %   NOte:  We use the transpose of the matrix to save time.
%     %   We also swap around the FSR data in order to make comparisons easier
%     %
%     %     Y(FSR)  ---> 1
%     %     Z(FSR)  ---> 2
%     %     X(FSR)  ---> 3
%     %
%     switch obj.sc
%         case '1'
%             rot_angle = (53.0) * pi/180;
%         case '2'
%             rot_angle = (52.5) * pi/180;
%         case '3'
%             rot_angle = (51.8) * pi/180;
%         case '4'
%             %  angle has not been determined for C4
%             rot_angle = (52.5) * pi/180;
%     end
% end

% function [] = get_amp_factor(obj)
%     %
%     %   The amplitude correction factor is determined by on-the-
%     %   ground callibration done before flight. It is the 
%     %   multiplicative difference between STAFF and FGM amplitudes.
%     %
%     switch obj.sc
%         case '1'
%             obj.amp_factor = 1.24;
%         case '2'
%             obj.amp_factor = 1.073;
%         case '3'
%             obj.amp_factor = 1.073;
%         case '4'
%             %  amp_factor has (somewhat) not been determined for C4
%             obj.amp_factor = 1.08;
%     end
% end
        
% function [] = get_rotmat_to_scm_frame(obj)
%     %
%     %   set up to rotate the FG to near the staff coordinates
%     %   we also negate the z component of FGM for correlation purposes
%     %   This is now for both NM and BM1 data
%     %   NOte:  We use the transpose of the matrix to save time
%     %   (i.e. so we do not have to transpose the entire data array:
%     %       |x'|       |x|             
%     %       |y'| = A * |y| = |x y z| * transpose(A)
%     %       |z'|       |z|
%     %   We also swap around the FSR data in order to make comparisons easier
%     %
%     %     Y(FSR)  ---> 1
%     %     Z(FSR)  ---> 2
%     %     X(FSR)  ---> 3
%     %
%     %	Note we put spin axis in third component
%     %
%     %   The spin axis is X(FSR).
%     %
%     rot_angle = obj.get_rot_angle;
%     
%     obj.rotmat_to_scm = [ 0    cos(rot_angle)  sin(rot_angle) ; ...
%                           0   -sin(rot_angle)  cos(rot_angle) ; ...
%                           1           0               0            ]';
% end