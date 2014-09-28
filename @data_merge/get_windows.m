function [] = get_windows(obj)
    %
    % Load FFT windowing schemes into object properties. This is more for
    % convenience than anything else.
    %
    obj.win_ham = window(@hamming, obj.clen, 'periodic');
    obj.win_tuk = window(@tukeywin, obj.clen, 0.75);
end