function [] = interp_transfr_fn(obj)
    %
    % Interpolate the transfer function to the points where we
    % actually have data. 
    %
    
    obj.comp = zeros(obj.clen, 3);
    
    % On the Cluster spacecraft, the FGM and SCM instruments are not
    % aligned, so the compents are mixed: FGM (x,y,z) correspond to 
    % SCM (2,3,1).
    obj.comp(:,1) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,2), obj.transfr_fn(:,2));
    obj.comp(:,2) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,3), obj.transfr_fn(:,3));
    obj.comp(:,3) = obj.fcompst(obj.clen, obj.df, obj.transfr_freqs(:,1), obj.transfr_fn(:,1));
end