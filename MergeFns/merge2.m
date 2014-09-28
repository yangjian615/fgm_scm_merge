function [merged_data] = merge2(fgm, scm, ...
                               max_number, f_min, f_max)
    %
    % Main function for combining FGM and STAFF data. 
    % This function loops through all of the FFT intervals and
    % combines the data.
    %

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial Loop Conditions //////////////////// %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Allocate memory to the output array.
    n_to_merge = scm.intervals(scm.iCurrent,2)-scm.intervals(scm.iCurrent,1)+1;
    merged_data = zeros(n_to_merge, 3, 'single');

    %
    % Only the middle quarter will be kept in most cases.
    %   - Extends from 3/8 to 5/8
    %
    % For clen = 16
    %   1/4*clen =  4
    %   3/8*clen =  6
    %   5/8*clen = 10
    %
    % - Middle quarter extends from 7 to 10.
    % - Shifting by 4, the next middle quarter is 11 to 14.
    %
    istart_middle = floor( 0.375 * scm.clen ) + 1;
    istop_middle  = floor( 0.625 * scm.clen );
    n_shift_scm   = istop_middle - istart_middle;
    n_shift_fgm   = floor(0.625*fgm.clen) - (floor(0.375*fgm.clen) + 1);
                                
    % Start of the first merging interval
    istart_fgm   = fgm.intervals(fgm.iCurrent,1);
    istart_scm   = scm.intervals(scm.iCurrent,1);
    istart_fill  = 1;
    istart_merge = 1;
    
    % End of the first merging interval
    %   - If only 1 interval, merge the exact interval.
    %   - Otherwise, merge to the end of the middle quarter.
    if max_number == 1
        istop_fgm   = fgm.intervals(fgm.iCurrent,2);
        istop_scm   = scm.intervals(scm.iCurrent,2);
        istop_fill  = istop_scm - istart_scm + 1;
        istop_merge = istop_scm - istart_scm + 1;
    else
        istop_fgm   = istart_fgm   + fgm.clen - 1;
        istop_scm   = istart_scm   + scm.clen - 1;
        istop_fill  = istart_fill  + istop_middle - 1;
        istop_merge = istart_merge + istop_middle - 1;
    end
    
    % Window to be used
    win_fgm = window(@hamming, fgm.clen, 'periodic');
    win_scm = window(@hamming, scm.clen, 'periodic');
    
    % Total number of points merged
    n_merged = 0;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step through each Merging Interval ///////// %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for m = 1:max_number
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Merge the Data ///////////////////////////// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Calculate the power spectral density of the reference interval. This only needs
        % to be done for the first, second, and last interval (when the FFT window
        % changes).
        if m == 1 || m == 2 || m == max_number
            ref_pwr_fgm = merge_ref_power(fgm, scm.clen, win_fgm);
            ref_pwr_scm = merge_ref_power(scm, fgm.clen, win_scm);
        end

        % Find the difference between the start times of FGM and SCM
        deltat_sf = (scm.t(istart_scm) - fgm.t(istart_fgm));
        
        % Take the FFT of the CCDI
        %   - Rotate to SCM frame     (for FGM)
        %   - Correct amplitude       (for SCM)
        %   - Window & FFT
        %   - Apply transfer function (for SCM)
        fgm.take_fft(istart_fgm, istop_fgm, win_fgm);
        scm.take_fft(istart_scm, istop_scm, win_scm);

        % Calculate the power spectral density of SCM and FGM for the CCDI
        pwr_merge_fgm = weighting_psd(fgm.b_fft, fgm.dt, fgm.clen, scm.clen);
        pwr_merge_scm = weighting_psd(scm.b_fft, scm.dt, fgm.clen, scm.clen);
    
        % calculate weight function, combine data, inverse
        % fft, unwindow, put into merged array
        w          = weight_function(pwr_merge_fgm, pwr_merge_scm, ref_pwr_fgm, ref_pwr_scm);
        merged_fft = combine_fgm_scm(fgm.b_fft, scm.b_fft, ...
                                     fgm.clen, scm.clen, fgm.freqs, ...
                                     w, f_min, f_max, deltat_sf);
                                     
        temp_data = ifft(merged_fft);
        temp_data = apply_window(temp_data, win_scm, 1);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Put the Merged Data into the Merged Array /// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Put it into the overall calibrated data array. Rotate it into the
        % frame of the FGM instrument.
        merged_data(istart_merge:istop_merge, :) ...
            = temp_data(istart_fill:istop_fill, :) * inv(fgm.rotmat_to_scm);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Move to the Next Merging Interval /////////// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Keep track of the number of merged points
        n_merged = n_merged + (istop_fill - istart_fill + 1);
        
        if m < max_number - 1
            % Shift forward to the next interval
            istart_fgm   = istart_fgm + n_shift_fgm;
            istart_scm   = istart_scm + n_shift_scm;
            istop_fgm    = istart_fgm + fgm.clen - 1;
            istop_scm    = istart_scm + scm.clen - 1;

            % Fill the middle quarter.
            istart_fill  = istart_middle;
            istop_fill   = istop_middle;

            % Continue from previous point.
            istart_merge = istop_merge + 1;
            istop_merge  = istart_merge + (istop_fill-istart_fill+1) - 1;
            
        else
            % Extend backward from the end of the array.
            istop_fgm  = fgm.intervals(fgm.iCurrent,2);
            istop_scm  = scm.intervals(scm.iCurrent,2);
            istart_fgm = istop_fgm - fgm.clen + 1;
            istart_scm = istop_scm - scm.clen + 1;
            
            % Fill from the last merged point.
            last_merged_point = scm.intervals(scm.iCurrent,1)+istop_merge-1;
            istart_fill = (last_merged_point+1) - istart_scm + 1;
            istop_fill  = scm.clen;
            
            % Merge to the end of the array.
            istart_merge = istop_merge + 1;
            istop_merge  = n_to_merge;
        end
        
        % Window
        if m == max_number - 1
            win_fgm = window(@hamming, fgm.clen, 'periodic');
            win_scm = window(@hamming, scm.clen, 'periodic');
        elseif m == 2
            win_fgm = window(@tukeywin, fgm.clen, 0.75);
            win_scm = window(@tukeywin, scm.clen, 0.75);
        end
    end
end