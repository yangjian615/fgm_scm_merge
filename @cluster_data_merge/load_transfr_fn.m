function [] = load_transfr_fn(obj)
    %
    %  Read SCM transfer functions for burst and nominal modes.
    %
    
    % Check whether STAFF is in nominal mode
    switch obj.mode
        case 'NBR'
            file_root = 'STAFF_SC_Nbr';
        case 'HBR'
            file_root = 'STAFF_SC_Hbr';
    end
        
    % Look for the transfer function data, read it in to a
    % dummy variable, store the frequencies, and combine the
    % real and complex components of the transfer function.
    transfile              = fullfile(obj.TransfrFn_dir, [file_root, obj.sc, '_X.txt']);
    dummy_in               = load(transfile); 
    obj.transfr_freqs(:,1) = dummy_in(:,1);
    obj.transfr_fn(:,1)    = complex( dummy_in(:,2),dummy_in(:,3) );

    % Repeat for the Y component
    transfile              = fullfile(obj.TransfrFn_dir, [file_root, obj.sc, '_Y.txt']);
    dummy_in               = load(transfile); 
    obj.transfr_freqs(:,2) = dummy_in(:,1);
    obj.transfr_fn(:,2)    = complex( dummy_in(:,2),dummy_in(:,3) );

    % Repeat for the Z component
    transfile              = fullfile(obj.TransfrFn_dir, [file_root, obj.sc, '_Z.txt']);
    dummy_in               = load(transfile); 
    obj.transfr_freqs(:,3) = dummy_in(:,1);
    obj.transfr_fn(:,3)    = complex( dummy_in(:,2),dummy_in(:,3) );
end