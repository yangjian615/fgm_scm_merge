function [] = get_N_max(obj, n_shift, sIndex, eIndex)
    %
    % Calculate the numer of FFT windows that fit within the sampling period. Default to
    % overlapping by a quarter of the FFT window.
    %
    if nargin < 2
        n_shift = obj.clen/4;
    end
    if nargin <= 2
        sIndex = 1;
        eIndex = length(obj.t);
    end
    
    %
    % |-----------------------------------------------|
    % |------|---)
    %    (---|--|---)
    %       (---|--|---)
    %                         ...        (---|--|---) | 
    %                                                ^   < n_shift points
    %                                        (--|-----|  > 1/4 interval
    %
    % After the first interval, the window creeps forward by n_shift
    % points. The equation
    %
    %       (nTotal - clen) / n_shift
    %
    % tells us how many shifts can occur. To this, we need to add 1 to
    % include the first interval. To this, we must add an extra 1 to
    % account for the last merging interval. It extends backward from the
    % end of the array to the last merged point. Until this last merged
    % interval, only the middle quarter is kept, leaving a trailing gap.
    % The last interval closes this gap.
    %
      obj.N_max = floor( (eIndex-sIndex+1 - obj.clen) / n_shift) + 2;
end