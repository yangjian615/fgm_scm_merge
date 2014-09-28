function [] = prep_fft(obj, multiplier)
    %
    % Combine all of the FFT prepping methods into a single call.
    %
    
    % Set a default multiplier
    if nargin == 1
        multiplier = 64;
    end
    
    % obj.n must be defined before calculating anything else
    assert(isempty(obj.n) == 0, ...
           'Must define "obj.n" -- The # points/FFT.')
    
    obj.get_fft_clen(multiplier)
    obj.get_N_max
    obj.get_df
    obj.get_freqs
    obj.get_windows
end