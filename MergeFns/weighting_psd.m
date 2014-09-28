function [psd] = weighting_psd(fft_data, dt, clen_fgm, clen_scm)
    %
    % Calculate the power spectral density of a given set of FFT
    % data. The longer of the two data sets being analyzed by the
    % merging process will be truncated to have the same number of
    % frequency bins as the data set with the fewest frequncy bins.
    %

    % get the length of the fft
    n = length(fft_data);

    % make sure that it matches one of the data sets being
    % analayzed
    assert(n == clen_fgm | n == clen_scm, ...
           'the length of fft_data does not match either data set')

    % get the smallest FFT interval
    nmin = min([clen_fgm, clen_scm]);

    % caclulate the psd normally for the smaller frequency range
    if n == nmin
        psd = powersd(fft_data, dt);

    % truncate the frequency range for the larger frequency range
    else
        psd = (2*dt/n) * ( abs( fft_data(2:(nmin/2)+1, :) ).^2 );
    end
end