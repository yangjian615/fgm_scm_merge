function [] = take_fft(obj, istart, istop, win)
    %
    % Evaluate the FFT of the magnetic field data. Apply windows
    % and any calibration corrections.
    %
    % NOTE: obj.b_fft is the fft of a subset of data ranging from 'istart' to
    %       'istop'. It is not necessarily the FFT of the entire magnetic field array.
    %
    
    % If only one parameter was given, it was the window.
    if nargin() == 1
        istart = 1;
        istop = length(obj.b(:,1));
    end
    
    switch obj.inst
        case 'FGM'
            % FGM: rotate to SCM frame, window, FFT
            dat_tmp = double(obj.b((istart:istop),:)) * obj.rotmat_to_scm;
            
            % Apply the window if it was given
            if nargin == 4
                dat_tmp = obj.apply_window(dat_tmp, win);
            end
            
            % take the FFT
            obj.b_fft = fft(dat_tmp);
            
        case 'SCM'
            % SCM: correct amplitude, window, and FFT, transfer funct
            dat_tmp = obj.amp_factor * double(obj.b(istart:istop,:));
            
            % Apply the window if it was given
            if nargin == 4
                dat_tmp = obj.apply_window(dat_tmp, win);
            end
            
            % Take the FFT and apply the transfer function.
            b_fft_temp = fft(dat_tmp);
            obj.b_fft = obj.apply_transf(b_fft_temp, obj.comp);
    end
end