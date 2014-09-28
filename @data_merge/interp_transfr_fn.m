function [] = interp_transfr_fn(obj)
    %
    % Interpolate the transfer function to the points where we
    % actually have data.
    %
    
    % Allocate space to the object property
    obj.comp = zeros(obj.clen, 3);
    
    % Interpolate the calibrated transfer function data to the frequencies of the
    % real magnetic field.
    obj.comp(:,1) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,1), obj.transfr_fn(:,1));
    obj.comp(:,2) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,2), obj.transfr_fn(:,2));
    obj.comp(:,3) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,3), obj.transfr_fn(:,3));
end