function [] = get_sample_rate(obj, istart, istop)
    %
    % Calculate the sampling rate
    %
    % This method is inaccurate if there are data gaps. Using 
    %
    %                  obj.dt = mode(diff(obj.t))
    %
    % might prove to be more accurate
    %
    if nargin == 1
        istart = 1;
        istop = length(obj.t);
    end
    
    % obj.dt = (obj.t(istop) - obj.t(istart)) / length(obj.t(istart:istop));
    obj.dt = mode(diff(obj.t(istart:istop)));
end