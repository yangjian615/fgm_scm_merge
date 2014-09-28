function [merged_fft] = combine_fgm_scm(fft_merge_fgm, fft_merge_scm, ...
                                        clen_fgm, clen_scm, freqs_fgm, ...
                                        w, f_min, f_max, deltat_sf)
    %
    % Use the weighting function to combine the signal of FSR and
    % STAFF between the frequency bins numbered s_index and
    % e_index.
    %
    % The goal is to take two data products
    %       |<--------------- FGM ---------------->|
    %       |<--------------- SCM ---------------->|
    % And combine them into one. FSR will comprise the lower
    % frequencies, STAFF the higher, and a weighted average of the
    % two will fill the middle.
    %       |<- FGM ->|<-- Merged -->|<--- SCM --->|
    %
    % For the resulting signal to be real, the negative frequency
    % signal must be a mirrored complex conjugate of the positive
    % frequency signal.
    %
    
    % the ratio of the number of points per FFT for FSR and STAFF
    N_ratio = clen_scm / clen_fgm;

    % Get the index values of the FGM data that will be merged into
    % the SCM data. FGM and SCM FFT merging intervals have been chosen so that they have
    % the same frequency bins. Thus, "i_merge" applies to both FGM and SCM.
    i_merge = find(freqs_fgm >= f_min & ...
                   freqs_fgm <= f_max);

    % the exponent of the exponential term
    %       F(omega) = A exp(i omega t)  ... where omega = 2 pi f
    % once for frequencies below the merging interval and ...
    % once for frequencies within the merging interval.
    twopifreq_fgm    = repmat(2 * pi * 1i * freqs_fgm(1:i_merge(1)-1)', 1, 3);
    twopifreq_merged = repmat(2 * pi * 1i * freqs_fgm(i_merge)', 1, 3);

    % combine the signals from FGM and SCM within the specified
    % frequency range
    s =      w(i_merge,:)  .* (N_ratio * fft_merge_fgm(i_merge,:) .* exp(deltat_sf* twopifreq_merged)) + ...
        (1 - w(i_merge,:)) .*            fft_merge_scm(i_merge,:);

    % Use FGM data at frequencies below the frequency at which
    % merging begins. Mirror the signal into the end of the array.
    merged_fft                           = fft_merge_scm;
    merged_fft(1:i_merge(1)-1,:)         = N_ratio * fft_merge_fgm(1:i_merge(1)-1,:) .*  exp(deltat_sf * twopifreq_fgm);
    merged_fft(end-(i_merge(1)-3):end,:) = conj(flipud(merged_fft(2:i_merge(1)-1,:)));

    % Use the combined signal for frequencies in the cross-over
    % region where the noise floors of the two instruments begin to
    % diverge from one another.
    merged_fft(i_merge,:) = s;
    merged_fft(end-((i_merge(1)-3)+1):-1:end-((i_merge(1)-3)+(i_merge(end)-i_merge(1))+1),:) ...
              = conj(s);

    % The rest of the data can be left as is -- as SCM data.
end