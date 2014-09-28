function [] = get_freqs(obj)
    %
    % The positive FFT frequencies ranging from DC to the Nyquist frequency
    %
    % NOTE: This assumes that the number of points in the FFT is even
    %
    obj.freqs = obj.df * (0:obj.clen/2);
end