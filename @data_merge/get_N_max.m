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
    % include the first interval. If there are left-over points, an
    % additional 1 must be added. This can be achieved by taking the
    % ceiling.
    %
      obj.N_max = ceil( (eIndex-sIndex+1 - obj.clen) / n_shift) + 1;
end