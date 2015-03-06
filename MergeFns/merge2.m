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
    n_shift_scm   = istop_middle - istart_middle + 1;
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
        
%--------------------------------------------------------------------------
%         %%%%%%%%%%%%%%%%
%         % SANITY CHECK %
%         %%%%%%%%%%%%%%%%
%         %
%         % Check progress 
%         %   - Overplot the merged data onto the FGM data
%         %   - Do so for this interval only
%         %
%         % Process
%         %   1. Rotate the newly merged data back into the FGM frame
%         %   2. Plot the newly merged data on top of the FGM data
%         %   3. Draw vertical lines outlining the data interval that will be
%         %       saved.
%         %
%         check_merged = temp_data * inv(fgm.rotmat_to_scm);
%         plot(fgm.t(istart_fgm:istop_fgm), fgm.b(istart_fgm:istop_fgm,2), ...
%              scm.t(istart_scm:istop_scm), check_merged(:,2));
%         hold on
%         ylim([-30 30])
%         legend('FGM', 'Merged')
%         
%         % Indices of the section begin kept
%         merge_section = [istart_scm + istart_fill - 1, ...
%                          istart_scm + istop_fill  - 1];
%         
%         % Outline the section begin kept in red.
%         %   - For the first interval, we are keeping the entire interval.
%         %   - For intermediate intervals, we are keeping the middle 1/4
%         %   - For the last interval, keep to end of array.
%         line([scm.t(merge_section(1)) scm.t(merge_section(1))], ylim ,'Color',[1 0 0])
%         line([scm.t(merge_section(2)) scm.t(merge_section(2))], ylim ,'Color',[1 0 0])
%         hold off
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%         %%%%%%%%%%%%%%%%
%         % SANITY CHECK %
%         %%%%%%%%%%%%%%%%
%         
%         % Do the indices into SCM and MERGED refer to the same interval?
%         scm_inds = [istart_scm - scm.intervals(scm.iCurrent,1) + 1 + istart_fill - 1, ...
%                     istart_scm - scm.intervals(scm.iCurrent,1) + 1 + istop_fill  - 1];
%         mer_inds = [istart_merge, istop_merge];
%         fprintf('SCM-Merged = [%d, %d]\n', scm_inds(1)-mer_inds(1), scm_inds(2)-mer_inds(2));
%         
%         % Is the merged interval shifting properly? Is its length
%         % consistent?
%         if m == 1
%             istart_old = istart_merge;
%             istop_old  = istop_merge;
%         elseif m > 1
%             fprintf('[shift, length] = [%d, %d]\n', ...
%                     istart_merge-istop_old, ...
%                     (istop_merge-istart_merge)-(istop_fill-istart_fill));
%             istart_old = istart_merge;
%             istop_old  = istop_merge;
%         end
% 
%         % Is the last interval being chosen properly?
%         if m == max_number-1
%             istop_scm_old = istop_scm - istart_fill;
%         elseif m == max_number
%             fprintf('iLast = %d\n', last_merged_point-istop_scm_old);
%         end
%--------------------------------------------------------------------------


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Put the Merged Data into the Merged Array /// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Put it into the overall calibrated data array. Rotate it into the
        % frame of the FGM instrument.
        merged_data(istart_merge:istop_merge, :) ...
            = temp_data(istart_fill:istop_fill, :) * inv(fgm.rotmat_to_scm);

%--------------------------------------------------------------------------
%         %%%%%%%%%%%%%%%%
%         % SANITY CHECK %
%         %%%%%%%%%%%%%%%%
%         %
%         % Check progress by comparing the merged product with the FGM
%         % instrument data. This is for all merged intervals to this point.
%         %
%         %   1. Plot the entire merged interval on top of FGM
%         %   2. Plot vertical lines on the FGM data showing that the merged
%         %       data was spliced properly
%         %
%         
%         
%         %
%         % Indices:
%         %   iifgm:    All data in FGM that has been merged with SCM
%         %   iiscm:    All data in SCM that has been merged with FGM
%         %   iimerge:  All data that has been merged (the results).
%         %
%         %   inew_scm:   Current interval of SCM being merged.
%         %   inew_fgm:   Current interval of FGM being merged.
%         %   inew_merge: Subset of "inew_scm" that will be kept.
%         %   inew_data:  The interval that has been merged and kept.
%         %                 (it should be the same as "inew_merge").
%         %
%         %   iold_*:     Same as "inew_*", but for the previous interval.
%         %
%         
%         %
%         % Compare the merged result with FGM data
%         %   - Plot FGM through current merging interval
%         %   - Plot Merged data up to last point merged (fewer points than FGM)
%         %   - Indices of SCM through last merged point (3/8 less than end)
%         %
%         iifgm   = [fgm.intervals(fgm.iCurrent,1), istop_fgm];
%         iimerge = [1 istop_merge];
%         
%         if m == 1
%             iiscm = [scm.intervals(scm.iCurrent,1), scm.intervals(scm.iCurrent,1)+istop_fill-1];
%         elseif 2 <= m < max_number
%             iiscm = [scm.intervals(scm.iCurrent,1), istop_scm - istart_fill + 1];
%         end
%         
%         % Plot merged
%         plot(fgm.t(iifgm(1):iifgm(2)), fgm.b(iifgm(1):iifgm(2), 2), ...
%              scm.t(iiscm(1):iiscm(2)), merged_data(iimerge(1):iimerge(2), 2));
%         hold on
%         legend('FGM', 'Merged')
%         
%         %
%         % Draw lines outlining the previous and current merging interval to
%         % make sure that they are adjacent and shifting properly.
%         %
%         
%         %%%%%%%%%%%%%%%%%%%%%
%         % PREVIOUS INTERVAL %
%         %%%%%%%%%%%%%%%%%%%%%
%         
%         if m > 1
%             % Index ranges.
%             t_old_scm   = [scm.t(iold_scm(1)),   scm.t(iold_scm(2))];
%             t_old_fgm   = [fgm.t(iold_fgm(1)),   fgm.t(iold_fgm(2))];
%             t_old_merge = [scm.t(iold_merge(1)), scm.t(iold_merge(2))];
%             
%             % Entire merging interval.
%             line([t_old_scm(1) t_old_scm(1)], ylim, 'Color', 'yellow', 'LineStyle', '-')
%             line([t_old_scm(2) t_old_scm(2)], ylim, 'Color', 'yellow', 'LineStyle', '-')
%             
%             % Interval being spliced.
%             line([t_old_merge(1) t_old_merge(1)], ylim, 'Color', 'cyan', 'LineStyle', '-')
%             line([t_old_merge(2) t_old_merge(2)], ylim, 'Color', 'cyan', 'LineStyle', '-')
% 
%             % Compare the old intervals with the new ones
%             sold_merge = sprintf('Old Merge Indices: [%d, %d]', iold_merge);
%             snew_merge = sprintf('New Merge Indices: [%d, %d]', inew_merge);
%             disp('Comparison of Merging Indices');
%             disp(['   ', sold_merge]);
%             disp(['   ', snew_merge]);
%         end
%         
%         %%%%%%%%%%%%%%%%%%%%
%         % CURRENT INTERVAL %
%         %%%%%%%%%%%%%%%%%%%%
%         inew_scm   = [istart_scm, istop_scm];
%         inew_fgm   = [istart_fgm, istop_fgm];
%         inew_merge = [istart_scm + istart_fill - 1, ...
%                       istart_scm + istop_fill - 1];
%         inew_data  = [scm.intervals(scm.iCurrent,1) + istart_merge - 1, ...
%                       scm.intervals(scm.iCurrent,1) + istop_merge - 1];
%         
%         % Time intervals
%         t_new_scm   = [scm.t(inew_scm(1)),   scm.t(inew_scm(2))];
%         t_new_fgm   = [fgm.t(inew_fgm(1)),   fgm.t(inew_fgm(2))];
%         t_new_merge = [scm.t(inew_merge(1)), scm.t(inew_merge(2))];
%         t_new_data  = [scm.t(inew_data(1)),  scm.t(inew_data(2))];
%         
%         % LINE 1: Outline the entire merged section
%         line([t_new_scm(1) t_new_scm(1)], ylim ,'Color', 'black')
%         line([t_new_scm(2) t_new_scm(2)], ylim ,'Color', 'black')
%         
%         % LINE 2: Outline the subset of the merged section being kept
%         line([t_new_merge(1) t_new_merge(1)], ylim ,'Color', 'red')
%         line([t_new_merge(2) t_new_merge(2)], ylim ,'Color', 'red')
%         
%         % LINE 3: Outline the subset of the merged section in
%         %         "merged_data". This should be the same as LINE 2.
%         line([t_new_data(1) t_new_data(1)], ylim ,'Color', 'magenta')
%         line([t_new_data(2) t_new_data(2)], ylim ,'Color', 'magenta')
%         
%         hold off
%         
%         %%%%%%%%%%%%%%%%%%%%
%         % SAVE INDICES     %
%         %%%%%%%%%%%%%%%%%%%%
%         iold_fgm = [istart_fgm, istop_fgm];
%         iold_scm = [istart_scm, istop_scm];
%         iold_merge = [istart_scm + istart_fill - 1, ...
%                       istart_scm + istop_fill  - 1];
%         iold_data = [scm.intervals(scm.iCurrent,1) + istart_merge - 1, ...
%                      scm.intervals(scm.iCurrent,1) + istop_merge - 1];
%--------------------------------------------------------------------------
            
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