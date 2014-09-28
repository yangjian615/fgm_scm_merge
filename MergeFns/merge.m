function [merged_data] = merge(fgm, scm, ...
                               max_number, f_min, f_max)
    %
    % Main function for combining FGM and STAFF data. 
    % This function loops through all of the FFT intervals and
    % combines the data.
    %
    
    % Allocate memory for the merged data array. It will be the
    % same size as the SCM magnetic field data (SCM is the 
    % instrument that is used for high frequency signal and
    % contributes most to the merged data product).
    n_to_merge = scm.intervals(scm.iCurrent,2)-scm.intervals(scm.iCurrent,1)+1;
    merged_data = zeros(n_to_merge, 3, 'single');
                                
    % Get the start and stop indices of the first merging interval
    istart_merge_fgm = fgm.intervals(fgm.iCurrent,1);
    istart_merge_scm = scm.intervals(scm.iCurrent,1);

    istop_merge_fgm = istart_merge_fgm + fgm.clen - 1;
    istop_merge_scm = istart_merge_scm + scm.clen - 1;

    % Only the middle quarter of the FFT interval will be kept, the
    % rest will be overwritten by the next.
    begin_fill = floor( 0.375 * scm.clen );     % 3/8 of the interval
    end_fill   = begin_fill + scm.clen/4 - 1;   % 5/8 of the interval
    
    % Step through all of the calibration intervals for the k-th continuous data interval
    for m = 1:max_number
        %
        % A hamming window is used on the first and last interval. A tukey
        % window is used on intermediate windows.
        %
        % The current continuous data interval (CCDI), fgm.[t,b] and scm.[t,b], has been
        % split into "max_number" of merging intervals. "istart_merge_*" and "istop_merge_*"
        % are the indices of the CCDI that indicate the m-th merging interval. Of this
        % m-th merging interval, only the middle quarter will be kept. The inidices of
        % this middle quarter are "filler_istart" and "filler_istop". This middle quarter,
        % then, is placed into the complete merged array, "merged_data" at indices
        % "istart" and "istop".
        %
        % Keep in mind that the indices described above are determined differently for the
        % first and last merging interval.
        %
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Which Part of the m-th Interval to Keep //// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        switch m
            % The first interval
            case 1
                % To start, we need an entire FFT interval.
                filler_istart = 1;
                filler_istop = filler_istart + scm.clen - 1;
                
                % Use a hamming window.
                win_fgm = window(@hamming, fgm.clen, 'periodic');
                win_scm = window(@hamming, scm.clen, 'periodic');
                
            % The last interval
            case max_number
                % The last iteration calibrates from the last point in the
                % array backward by one whole interval. As such, there
                % could be some overlap between this final interval and the
                % previous one. Calculate this overlap and only fill new
                % points.
                %
                %   (last_merged_point+1)
                %       = first not-merged point
                %   (istop_merge_scm - scm.clen + 1)
                %       = beginning of current merged interval
                %
                % The difference between the two is the overlap.
                filler_istart = (last_merged_point+1) - (istop_merge_scm-scm.clen+1) + 1;
                filler_istop  = scm.clen;
                
                % Use a Hamming window
                win_fgm = window(@hamming, fgm.clen, 'periodic');
                win_scm = window(@hamming, scm.clen, 'periodic');
                
            % Intermediate intervals
            otherwise
                % Intermediate iterations only required the middle quarter
                % of the calibrated waveform, far away from any fringe
                % effects and Gibbs phenomena and tapering effects, to be
                % recorded.
                filler_istart = begin_fill;
                filler_istop  = end_fill;
                
                % Use a Tukey window
                if m == 2
                    win_fgm = window(@tukeywin, fgm.clen, 0.75);
                    win_scm = window(@tukeywin, scm.clen, 0.75);
                end
        end
        
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
        try
            deltat_sf = (scm.t(istart_merge_scm) - fgm.t(istart_merge_fgm));
        catch err
            disp(err);
        end
        
        % Take the FFT of the CCDI
        %   - Rotate to SCM frame     (for FGM)
        %   - Correct amplitude       (for SCM)
        %   - Window & FFT
        %   - Apply transfer function (for SCM)
        fgm.take_fft(istart_merge_fgm, istop_merge_fgm, win_fgm);
        scm.take_fft(istart_merge_scm, istop_merge_scm, win_scm);

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
    % Indices into the Final Merged Array ///////// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % First Interval
        if m == 1
            % istart = first point
            % istop  = last point of interval
            istart = 1;
            istop  = istart + scm.clen - 1;
        
        % Second Interval
        elseif m == 2 && m ~= max_number
            % istart = One point after the middle quarter of the first interval
            % istop  = istart + 1/4 merging interval
            %
            % The first interval will be overwritten starting at 5/8 and
            % extending to 7/8 of the interval
            istart = istart + end_fill;         %(istart + end_fill - 1) + 1
            istop  = istart + scm.clen/4 - 1;
            
        % Intermediate Intervals
        elseif (2 < m) && (m < max_number)
            % Shift by one point. Extend 1/4 interval.
            istart = istop + 1;
            istop  = istart + scm.clen/4 - 1;
            
        % Last interval
        elseif m == max_number
            % Shift by one point. Extend to end of interval (take more than
            % just the middle quarter -- however much remains).
            istart = istop + 1;
            istop  = n_to_merge;
        end
        
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
%         plot(fgm.t(istart_merge_fgm:istop_merge_fgm), fgm.b(istart_merge_fgm:istop_merge_fgm,2), ...
%              scm.t(istart_merge_scm:istop_merge_scm), check_merged(:,2));
%         hold on
%         ylim([-30 30])
%         legend('FGM', 'Merged')
%         
%         % Indices of the section begin kept
%         merge_section = [istart_merge_scm + filler_istart - 1, ...
%                          istart_merge_scm + filler_istop  - 1];
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
%         scm_inds = [istart_merge_scm - scm.intervals(scm.iCurrent,1) + 1 + filler_istart - 1, ...
%                     istart_merge_scm - scm.intervals(scm.iCurrent,1) + 1 + filler_istop  - 1];
%         mer_inds = [istart, istop];
%         text     = sprintf('SCM-Merged = [%d, %d]', scm_inds(1)-mer_inds(1), scm_inds(2)-mer_inds(2));
%         disp(text);
%         
%         % Is the merged interval shifting properly? Is its length
%         % consistent?
%         if m == 1
%             istart_old = istart;
%             istop_old  = istop;
%         elseif m > 1
%             text = sprintf('[shift, length] = [%d, %d]', ...
%                            istart-istop_old, ...
%                            (istop-istart)-(filler_istop-filler_istart));
%             disp(text);
%             istart_old = istart;
%             istop_old  = istop;
%         end
% 
%         % Is the last interval being chosen properly?
%         if m == max_number-1
%             istop_merge_scm_old = istop_merge_scm - begin_fill;
%         elseif m == max_number
%             text = sprintf('iLast = %d', last_merged_point-istop_merge_scm_old);
%             disp(text);
%         end
%--------------------------------------------------------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Put the Merged Data into the Merged Array /// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Put it into the overall calibrated data array. Rotate it into the
        % frame of the FGM instrument.
        try
            merged_data(istart:istop, :) ...
                = temp_data(filler_istart:filler_istop, :) * inv(fgm.rotmat_to_scm);
        catch err
            % Display the error
            disp(err);
            str1 = sprintf('merged_data(%i:%i) = %i', istart, istop, istop-istart+1);
            str2 = sprintf('temp_data(%i:%i) = %i', filler_istart, filler_istop, filler_istop-filler_istart+1);
            disp(str1);
            disp(str2);
            
            % Display indices
            str = sprintf('Dimensions of merged_data: %ix%i. [%i,%i] %i. %i-%i', ...
                          size(merged_data), istart, istop, m, ...
                          istart_merge_scm-scm.intervals(scm.iCurrent,1)+1, ...
                          istop_merge_scm-scm.intervals(scm.iCurrent,1)+1);
            disp(str);
        end
        
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
%         iifgm   = [fgm.intervals(fgm.iCurrent,1), istop_merge_fgm];
%         iimerge = [1 istop];
%         
%         if m == 1
%             iiscm = [scm.intervals(scm.iCurrent,1), istop_merge_scm];
%         elseif 2 <= m < max_number
%             iiscm = [scm.intervals(scm.iCurrent,1), istop_merge_scm - 3*scm.clen/8 - 1];
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
%         inew_scm   = [istart_merge_scm, istop_merge_scm];
%         inew_fgm   = [istart_merge_fgm, istop_merge_fgm];
%         inew_merge = [istart_merge_scm + filler_istart - 1, ...
%                       istart_merge_scm + filler_istop - 1];
%         inew_data  = [scm.intervals(scm.iCurrent,1) + istart - 1, ...
%                       scm.intervals(scm.iCurrent,1) + istop - 1];
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
%         iold_fgm = [istart_merge_fgm, istop_merge_fgm];
%         iold_scm = [istart_merge_scm, istop_merge_scm];
%         iold_merge = [istart_merge_scm + filler_istart - 1, ...
%                       istart_merge_scm + filler_istop  - 1];
%         iold_data = [scm.intervals(scm.iCurrent,1) + istart - 1, ...
%                      scm.intervals(scm.iCurrent,1) + istop - 1];
%--------------------------------------------------------------------------
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Move to the Next Merging Interval /////////// %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Prepare for the last interval...
        if m == max_number - 1
            % Record the last calibrated point
            %   For the last iteration, this means taking an interval that
            %   extends from the end of the array back one whole FFT
            %   interval. Any overlap with the preceding iteration will be
            %   dealt with later.
            last_merged_point = istop + scm.intervals(scm.iCurrent,1) - 1;
            istop_merge_fgm   = fgm.intervals(fgm.iCurrent,2);
            istop_merge_scm   = scm.intervals(scm.iCurrent,2);
            istart_merge_fgm  = istop_merge_fgm - fgm.clen + 1;
            istart_merge_scm  = istop_merge_scm - scm.clen + 1;
            
        % All other intervals
        else
            % Advance by 1/4 of the calibration interval
            istart_merge_fgm = istart_merge_fgm + fgm.clen/4;
            istart_merge_scm = istart_merge_scm + scm.clen/4;
            istop_merge_fgm  = istart_merge_fgm + fgm.clen - 1;
            istop_merge_scm  = istart_merge_scm + scm.clen - 1;
        end
    end
end